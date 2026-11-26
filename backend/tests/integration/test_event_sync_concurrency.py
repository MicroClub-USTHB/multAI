"""Real-database concurrency tests for HrEventSync (each call = its own transaction)."""

import asyncio
import datetime as dt
import uuid

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from app.core.config import settings
from app.schema.request.internal.event import HrEventSync
from app.service.event import EventService
from db.generated import event_participant as participant_queries
from db.generated import events as event_queries

T0 = dt.datetime(2031, 5, 1, 18, 0, tzinfo=dt.timezone.utc)
T1 = dt.datetime(2031, 5, 1, 22, 0, tzinfo=dt.timezone.utc)


@pytest.fixture
async def engine():
    url = (
        f"postgresql+asyncpg://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}"
        f"@{settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}/{settings.POSTGRES_DB}"
    )
    eng = create_async_engine(url, pool_pre_ping=True)
    async with eng.connect() as conn:
        has_col = (
            await conn.execute(
                text(
                    "SELECT 1 FROM information_schema.columns "
                    "WHERE table_name='events' AND column_name='external_id'"
                )
            )
        ).first()
    if not has_col:
        await eng.dispose()
        pytest.skip("database is not migrated to events.external_id")
    yield eng
    await eng.dispose()


async def sync(engine: AsyncEngine, external_id: str, name: str):
    req = HrEventSync(external_id=external_id, name=name, starts_at=T0, ends_at=T1)
    async with engine.begin() as conn:
        service = EventService(
            e_querier=event_queries.AsyncQuerier(conn),
            p_querier=participant_queries.AsyncQuerier(conn),
        )
        return await service.sync_from_hr(req)


async def cleanup(engine: AsyncEngine, name: str) -> None:
    async with engine.begin() as conn:
        await conn.execute(text("DELETE FROM events WHERE name = :n"), {"n": name})


async def test_concurrent_syncs_of_same_new_event_yield_one_row(engine) -> None:
    name = f"conc-new-{uuid.uuid4()}"
    ext = f"hr-{uuid.uuid4()}"
    try:
        results = await asyncio.gather(
            sync(engine, ext, name), sync(engine, ext, name), sync(engine, ext, name)
        )
        assert len({r.id for r in results}) == 1
        assert len({r.event_code for r in results}) == 1
    finally:
        await cleanup(engine, name)


async def test_concurrent_syncs_of_different_events_never_share_a_legacy_row(
    engine,
) -> None:
    name = f"conc-legacy-{uuid.uuid4()}"
    ext_a, ext_b = f"hr-a-{uuid.uuid4()}", f"hr-b-{uuid.uuid4()}"
    try:
        async with engine.begin() as conn:
            await conn.execute(
                text(
                    "INSERT INTO events (name, event_code, event_date, status) "
                    "VALUES (:n, :c, :d, 'draft')"
                ),
                {"n": name, "c": f"legacy-{uuid.uuid4().hex[:8]}", "d": T0},
            )
        first = await asyncio.gather(sync(engine, ext_a, name), sync(engine, ext_b, name))
        assert first[0].id != first[1].id

        again = await asyncio.gather(sync(engine, ext_a, name), sync(engine, ext_b, name))
        assert again[0].id == first[0].id and again[1].id == first[1].id
        async with engine.connect() as conn:
            count = (
                await conn.execute(
                    text("SELECT count(*) FROM events WHERE name = :n"), {"n": name}
                )
            ).scalar_one()
        assert count == 2
    finally:
        await cleanup(engine, name)
