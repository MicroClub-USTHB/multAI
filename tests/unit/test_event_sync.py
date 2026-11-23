import datetime as dt
import uuid
from typing import Any, Optional

import pytest
from pydantic import ValidationError

from app.schema.request.internal.event import HrEventSync
from app.service.event import EventService
from db.generated import models

T0 = dt.datetime(2026, 12, 1, 18, 0, tzinfo=dt.timezone.utc)
T1 = dt.datetime(2026, 12, 1, 22, 0, tzinfo=dt.timezone.utc)


class FakeEventQuerier:
    """In-memory stand-in for db.generated.events.AsyncQuerier (sync subset)."""

    def __init__(self) -> None:
        self.rows: list[models.Event] = []

    def add(self, **overrides: Any) -> models.Event:
        base: dict[str, Any] = dict(
            id=uuid.uuid4(),
            name="Hackathon",
            event_code="legacy-code",
            event_date=T0,
            status="draft",
            created_by=uuid.uuid4(),
            created_at=dt.datetime.now(dt.timezone.utc),
            archived_at=None,
            end_date=None,
            external_id=None,
        )
        base.update(overrides)
        row = models.Event(**base)
        self.rows.append(row)
        return row

    async def get_event_by_external_id(
        self, *, external_id: Optional[str]
    ) -> Optional[models.Event]:
        return next((r for r in self.rows if r.external_id == external_id), None)

    async def link_legacy_event(
        self, *, external_id: Optional[str], name: str, event_date: dt.datetime
    ) -> Optional[models.Event]:
        matches = sorted(
            (
                r
                for r in self.rows
                if r.external_id is None
                and r.name == name
                and r.event_date == event_date
            ),
            key=lambda r: r.created_at,
        )
        if not matches:
            return None
        matches[0].external_id = external_id
        return matches[0]

    async def create_synced_event(self, arg: Any) -> Optional[models.Event]:
        return self.add(
            name=arg.name,
            event_code=arg.event_code,
            event_date=arg.event_date,
            end_date=arg.end_date,
            status=arg.status,
            external_id=arg.external_id,
            created_by=None,
        )


def make_service(q: FakeEventQuerier) -> EventService:
    return EventService(e_querier=q, p_querier=None)  # type: ignore[arg-type]


def payload(**overrides: Any) -> HrEventSync:
    data: dict[str, Any] = dict(
        external_id="hr-1", name="Hackathon", starts_at=T0, ends_at=T1
    )
    data.update(overrides)
    return HrEventSync(**data)


async def test_creates_event_with_generated_code() -> None:
    q = FakeEventQuerier()
    res = await make_service(q).sync_from_hr(payload())
    assert res.event_code
    assert res.status == "draft"
    assert res.created_by is None
    assert res.event_date == T0 and res.end_date == T1
    assert len(q.rows) == 1 and q.rows[0].external_id == "hr-1"


async def test_same_external_id_returns_existing_without_new_code() -> None:
    q = FakeEventQuerier()
    svc = make_service(q)
    first = await svc.sync_from_hr(payload())
    second = await svc.sync_from_hr(payload())
    assert second.id == first.id
    assert second.event_code == first.event_code
    assert len(q.rows) == 1


async def test_links_legacy_event_by_name_and_date() -> None:
    q = FakeEventQuerier()
    legacy = q.add()
    res = await make_service(q).sync_from_hr(payload())
    assert res.id == legacy.id
    assert res.event_code == "legacy-code"
    assert len(q.rows) == 1 and q.rows[0].external_id == "hr-1"


async def test_duplicate_legacy_events_link_only_oldest() -> None:
    q = FakeEventQuerier()
    old = q.add(created_at=dt.datetime(2026, 1, 1, tzinfo=dt.timezone.utc))
    q.add(created_at=dt.datetime(2026, 2, 1, tzinfo=dt.timezone.utc))
    res = await make_service(q).sync_from_hr(payload())
    assert res.id == old.id
    assert len(q.rows) == 2
    assert sum(r.external_id is not None for r in q.rows) == 1


def test_ends_before_starts_rejected() -> None:
    with pytest.raises(ValidationError):
        payload(starts_at=T1, ends_at=T0)


def test_blank_external_id_or_name_rejected() -> None:
    with pytest.raises(ValidationError):
        payload(external_id="")
    with pytest.raises(ValidationError):
        payload(name="")
