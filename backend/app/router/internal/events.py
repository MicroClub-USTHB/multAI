from fastapi import APIRouter, Depends

from app.container import Container, get_container
from app.deps.service_auth import require_service_key
from app.schema.request.internal.event import HrEventSync
from app.schema.response.web.event import EventResponse

router = APIRouter(dependencies=[Depends(require_service_key)])


@router.post("/events", response_model=EventResponse)
async def sync_event(
    req: HrEventSync,
    container: Container = Depends(get_container),
) -> EventResponse:
    """Service-to-service: HR-Events pushes a newly created event (idempotent)."""
    return await container.event_service.sync_from_hr(req)
