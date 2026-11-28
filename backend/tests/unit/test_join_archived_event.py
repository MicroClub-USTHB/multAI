import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.service.event import EventService


@pytest.mark.asyncio
async def test_join_archived_event_is_allowed() -> None:
    event = MagicMock()
    event.id = uuid.uuid4()
    event.status = "archived"
    e_querier = MagicMock()
    e_querier.get_event_by_code = AsyncMock(return_value=event)
    p_querier = MagicMock()
    p_querier.is_user_in_event = AsyncMock(return_value=False)
    p_querier.join_event = AsyncMock(return_value=MagicMock(joined_at=None))

    service = EventService(e_querier=e_querier, p_querier=p_querier)
    try:
        await service.join_event_by_code(uuid.uuid4(), "code")
    except Exception as exc:  # response mapping may fail on the mock; the guard must not
        assert "already closed" not in str(getattr(exc, "detail", exc))

    p_querier.join_event.assert_awaited_once()
