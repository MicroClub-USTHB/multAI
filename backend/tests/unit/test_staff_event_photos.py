import datetime
import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException

from app.router.staff.event_photos import get_event_photo_image, list_event_photos


def _photo(event_id: uuid.UUID) -> MagicMock:
    p = MagicMock()
    p.id = uuid.uuid4()
    p.event_id = event_id
    p.visibility = "private"
    p.status = "approved"
    p.face_count = 2
    p.day_number = None
    p.taken_at = None
    p.created_at = datetime.datetime(2026, 11, 1, tzinfo=datetime.timezone.utc)
    return p


@pytest.mark.asyncio
async def test_list_event_photos() -> None:
    event_id = uuid.uuid4()
    photos = [_photo(event_id), _photo(event_id)]

    async def gen(**_: object):
        for p in photos:
            yield p

    container = MagicMock()
    container.photo_querier.count_event_photos_for_staff = AsyncMock(return_value=7)
    container.photo_querier.list_event_photos_for_staff = gen

    res = await list_event_photos(
        event_id=event_id, limit=24, offset=0, _staff=MagicMock(), container=container
    )
    assert res.total == 7
    assert [i.face_count for i in res.items] == [2, 2]
    assert res.items[0].status == "approved"


@pytest.mark.asyncio
async def test_image_rejects_photo_from_another_event() -> None:
    container = MagicMock()
    container.photo_querier.get_photo_by_id = AsyncMock(
        return_value=_photo(uuid.uuid4())
    )
    with pytest.raises(HTTPException):
        await get_event_photo_image(
            event_id=uuid.uuid4(),
            photo_id=uuid.uuid4(),
            _staff=MagicMock(),
            container=container,
        )
