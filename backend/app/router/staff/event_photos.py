from uuid import UUID

from fastapi import APIRouter, Depends, Query
from fastapi.responses import Response
from pydantic import BaseModel

from app.container import Container, get_container
from app.core.exceptions import AppException
from app.deps.cookie_auth import get_current_staff_user
from app.infra.minio import IMAGES_BUCKET_NAME, Bucket
from db.generated.models import StaffUser

router = APIRouter(prefix="/events")


class EventPhotoItem(BaseModel):
    id: UUID
    visibility: str
    status: str
    face_count: int
    day_number: int | None
    taken_at: str | None
    created_at: str


class EventPhotosResponse(BaseModel):
    total: int
    items: list[EventPhotoItem]


@router.get("/{event_id}/photos", response_model=EventPhotosResponse)
async def list_event_photos(
    event_id: UUID,
    limit: int = Query(default=24, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _staff: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> EventPhotosResponse:
    """Every photo of an event, newest first, for the staff event page."""
    total = await container.photo_querier.count_event_photos_for_staff(
        event_id=event_id
    )
    items = [
        EventPhotoItem(
            id=p.id,
            visibility=p.visibility,
            status=str(getattr(p.status, "value", p.status)),
            face_count=p.face_count,
            day_number=p.day_number,
            taken_at=p.taken_at.isoformat() if p.taken_at else None,
            created_at=p.created_at.isoformat(),
        )
        async for p in container.photo_querier.list_event_photos_for_staff(
            event_id=event_id, limit=limit, offset=offset
        )
    ]
    return EventPhotosResponse(total=total or 0, items=items)


@router.get("/{event_id}/photos/{photo_id}/image")
async def get_event_photo_image(
    event_id: UUID,
    photo_id: UUID,
    _staff: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> Response:
    photo = await container.photo_querier.get_photo_by_id(id=photo_id)
    if photo is None or photo.event_id != event_id:
        raise AppException.not_found("Photo not found")
    data, filename, content_type = await Bucket(IMAGES_BUCKET_NAME, "").get(
        photo.storage_key
    )
    return Response(
        content=data,
        media_type=content_type,
        headers={
            "Content-Disposition": f'inline; filename="{filename}"',
            "Cache-Control": "private, max-age=3600",
        },
    )
