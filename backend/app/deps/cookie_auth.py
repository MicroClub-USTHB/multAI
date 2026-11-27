from typing import Annotated
from fastapi import Cookie, Depends
from app.container import Container, get_container
from app.core.exceptions import AppException
from app.service.mcdi_roles import resolve_staff_role
from db.generated.models import StaffRole, StaffUser


def _role_value(role: object) -> str:
    return getattr(role, "value", str(role))


async def get_current_staff_user(
    container: Annotated[Container, Depends(get_container)],
    token: Annotated[str | None, Cookie(alias="access_token")] = None,
) -> StaffUser:
    if token is None:
        raise AppException.unauthorized("Authentication token required")

    # 1. Validate token with MCDI (cached in Redis for sub-ms latency and rate-limit protection)
    try:
        mcdi_data = await container.mcdi_service.validate_token_cached(
            redis=container.redis,
            token=token,
            ttl_seconds=60,
        )
    except Exception:
        raise AppException.unauthorized("MCDI session invalid or expired")

    email = mcdi_data.get("member", {}).get("email")
    if not email:
        raise AppException.unauthorized("Invalid MCDI payload: missing email")

    role = resolve_staff_role(mcdi_data)
    if role is None:
        raise AppException.forbidden("Multimedia or Development role required")

    normalized_email = email.strip().lower()
    # Access comes from MCDI roles; the table is only a profile row for FKs.
    staff_user = await container.staff_user_querier.get_staff_user_by_email(
        email=normalized_email
    )
    if staff_user is None or _role_value(staff_user.role) != role.value:
        staff_user = await container.staff_user_querier.upsert_staff_user_from_sso(
            email=normalized_email, role=role.value
        )
    if staff_user is None:
        raise AppException.unauthorized("Could not load staff profile")
    return staff_user


def ensure_multi_team_lead_staff(current_staff_user: StaffUser) -> StaffUser:
    allowed_roles = {StaffRole.MULTI_TEAM_LEAD.value, StaffRole.ADMIN.value}
    if _role_value(current_staff_user.role) not in allowed_roles:
        raise AppException.forbidden("Multi team lead or admin access required")
    return current_staff_user


async def require_multi_team_lead_staff(
    current_staff_user: Annotated[StaffUser, Depends(get_current_staff_user)],
) -> StaffUser:
    return ensure_multi_team_lead_staff(current_staff_user)


def ensure_admin_staff(current_staff_user: StaffUser) -> StaffUser:
    if _role_value(current_staff_user.role) != StaffRole.ADMIN.value:
        raise AppException.forbidden("Admin access required")
    return current_staff_user


async def require_admin_staff(
    current_staff_user: Annotated[StaffUser, Depends(get_current_staff_user)],
) -> StaffUser:
    return ensure_admin_staff(current_staff_user)
