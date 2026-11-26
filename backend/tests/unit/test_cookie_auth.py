import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException

from app.container import Container
from app.deps.cookie_auth import (
    ensure_admin_staff,
    ensure_multi_team_lead_staff,
    get_current_staff_user,
)
from db.generated.models import StaffRole, StaffUser


def _create_staff_user(role: StaffRole | str, user_id: uuid.UUID | None = None) -> StaffUser:
    return StaffUser(
        id=user_id or uuid.uuid4(),
        email="test@microclub.info",
        password="hash",
        role=role,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )


def test_ensure_multi_team_lead_staff_allows_lead_and_admin() -> None:
    lead_enum = _create_staff_user(StaffRole.MULTI_TEAM_LEAD)
    lead_str = _create_staff_user("multi_team_lead")
    admin_enum = _create_staff_user(StaffRole.ADMIN)
    admin_str = _create_staff_user("admin")

    assert ensure_multi_team_lead_staff(lead_enum) == lead_enum
    assert ensure_multi_team_lead_staff(lead_str) == lead_str
    assert ensure_multi_team_lead_staff(admin_enum) == admin_enum
    assert ensure_multi_team_lead_staff(admin_str) == admin_str


def test_ensure_multi_team_lead_staff_forbids_other_roles() -> None:
    multi_user = _create_staff_user(StaffRole.MULTI)
    other_user = _create_staff_user("unknown_role")

    with pytest.raises(HTTPException) as exc_info:
        ensure_multi_team_lead_staff(multi_user)
    assert exc_info.value.status_code == 403

    with pytest.raises(HTTPException) as exc_info:
        ensure_multi_team_lead_staff(other_user)
    assert exc_info.value.status_code == 403


def test_ensure_admin_staff() -> None:
    admin_user = _create_staff_user(StaffRole.ADMIN)
    lead_user = _create_staff_user(StaffRole.MULTI_TEAM_LEAD)

    assert ensure_admin_staff(admin_user) == admin_user

    with pytest.raises(HTTPException) as exc_info:
        ensure_admin_staff(lead_user)
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_get_current_staff_user_no_token() -> None:
    container = MagicMock(spec=Container)
    with pytest.raises(HTTPException) as exc_info:
        await get_current_staff_user(container=container, token=None)
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_staff_user_invalid_token() -> None:
    container = MagicMock(spec=Container)
    container.redis = MagicMock()
    container.mcdi_service = MagicMock()
    container.mcdi_service.validate_token_cached = AsyncMock(side_effect=Exception("Invalid token"))

    with pytest.raises(HTTPException) as exc_info:
        await get_current_staff_user(container=container, token="bad_token")
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_staff_user_missing_email() -> None:
    container = MagicMock(spec=Container)
    container.redis = MagicMock()
    container.mcdi_service = MagicMock()
    container.mcdi_service.validate_token_cached = AsyncMock(return_value={"member": {}})

    with pytest.raises(HTTPException) as exc_info:
        await get_current_staff_user(container=container, token="valid_token")
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_staff_user_not_found() -> None:
    container = MagicMock(spec=Container)
    container.redis = MagicMock()
    container.mcdi_service = MagicMock()
    container.mcdi_service.validate_token_cached = AsyncMock(
        return_value={"member": {"email": "unknown@microclub.info"}}
    )
    container.staff_user_querier = MagicMock()
    container.staff_user_querier.get_staff_user_by_email = AsyncMock(return_value=None)

    with pytest.raises(HTTPException) as exc_info:
        await get_current_staff_user(container=container, token="valid_token")
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_get_current_staff_user_success() -> None:
    container = MagicMock(spec=Container)
    container.redis = MagicMock()
    user = _create_staff_user(StaffRole.ADMIN)
    container.mcdi_service = MagicMock()
    container.mcdi_service.validate_token_cached = AsyncMock(
        return_value={"member": {"email": "test@microclub.info"}}
    )
    container.staff_user_querier = MagicMock()
    container.staff_user_querier.get_staff_user_by_email = AsyncMock(return_value=user)

    result = await get_current_staff_user(container=container, token="valid_token")
    assert result == user
