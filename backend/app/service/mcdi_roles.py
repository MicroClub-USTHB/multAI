from typing import Any

from app.core.config import settings
from db.generated.models import StaffRole


def resolve_staff_role(mcdi_data: dict[str, Any]) -> StaffRole | None:
    """Map MCDI (Discord) roles to a staff role. None means no dashboard access."""
    names = {
        str(r.get("roleName", "")).strip().lower()
        for r in (mcdi_data.get("roles") or [])
        if isinstance(r, dict)
    }

    def has(candidates: list[str]) -> bool:
        return any(c.strip().lower() in names for c in candidates)

    if has(settings.MCDI_ADMIN_ROLES):
        return StaffRole.ADMIN
    if has(settings.MCDI_TEAM_LEAD_ROLES):
        return StaffRole.MULTI_TEAM_LEAD
    if has(settings.MCDI_MULTI_ROLES):
        return StaffRole.MULTI
    return None
