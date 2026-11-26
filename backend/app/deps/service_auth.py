import hmac
from typing import Optional

from fastapi import Header, HTTPException

from app.core.config import settings


async def require_service_key(
    x_service_key: Optional[str] = Header(default=None),
) -> None:
    """Allow only callers presenting the shared HR-Events service key.

    Rejects everything when the server key is unset (never open by default).
    """
    expected = settings.HR_EVENTS_SERVICE_KEY
    if not expected or not x_service_key:
        raise HTTPException(status_code=401, detail="Invalid service key")
    if not hmac.compare_digest(x_service_key.encode(), expected.encode()):
        raise HTTPException(status_code=401, detail="Invalid service key")
