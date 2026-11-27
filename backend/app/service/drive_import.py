from __future__ import annotations

import asyncio
from collections.abc import Sequence
from datetime import datetime, timezone
import re

from app.core.exceptions import AppException
from app.core.logger import logger
from app.infra.google_drive import GoogleDriveClient
from app.schema.internal.uploads import UploadPhotoInput
from app.schema.response.web.event import EventResponse
from app.service.event import EventService
from app.service.staff_drive import StaffDriveService
from app.service.upload_requests import UploadRequestDetails, UploadRequestsService
from db.generated.models import StaffUser

# Mirrors UploadRequestsService so URLs are rejected before an event is created.
_ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp"}
_MAX_FILE_SIZE_BYTES = 20 * 1024 * 1024

_DRIVE_FILE_URL_PATTERNS = (
    re.compile(r"/file/d/([A-Za-z0-9_-]+)"),
    re.compile(r"[?&]id=([A-Za-z0-9_-]+)"),
    re.compile(r"/d/([A-Za-z0-9_-]+)"),
)
_DRIVE_FILE_ID_PATTERN = re.compile(r"[A-Za-z0-9_-]{10,}")


def extract_drive_file_id(value: str) -> str:
    """Return the Drive file id from a file URL (or a bare id).

    Folder links are rejected: this endpoint only accepts individual files.
    """
    raw = value.strip()
    if not raw:
        raise AppException.bad_request("Drive file URL must not be empty")

    if "/folders/" in raw:
        raise AppException.bad_request(
            "Folder links are not supported. Provide individual Drive file URLs."
        )

    for pattern in _DRIVE_FILE_URL_PATTERNS:
        match = pattern.search(raw)
        if match is not None:
            return match.group(1)

    if _DRIVE_FILE_ID_PATTERN.fullmatch(raw):
        return raw

    raise AppException.bad_request(
        f"Could not extract a Drive file id from '{value}'"
    )


def extract_unique_drive_file_ids(values: Sequence[str]) -> list[str]:
    """Parse and de-duplicate Drive file ids, preserving input order."""
    seen: set[str] = set()
    file_ids: list[str] = []
    for value in values:
        file_id = extract_drive_file_id(value)
        if file_id in seen:
            continue
        seen.add(file_id)
        file_ids.append(file_id)
    return file_ids


class DriveImportService:
    def __init__(
        self,
        *,
        event_service: EventService,
        upload_requests_service: UploadRequestsService,
        staff_drive_service: StaffDriveService,
    ) -> None:
        self._event_service = event_service
        self._upload_requests_service = upload_requests_service
        self._staff_drive_service = staff_drive_service

    async def import_to_new_event(
        self,
        *,
        event_name: str,
        event_date: datetime | None,
        end_date: datetime | None,
        file_urls: Sequence[str],
        visibility: str,
        day_number: int | None,
        taken_at: datetime | None,
        requested_by: StaffUser,
    ) -> tuple[EventResponse, UploadRequestDetails]:
        access_token = (
            await self._staff_drive_service.get_access_token_for_staff_user(
                requested_by.id
            )
        )
        file_ids = extract_unique_drive_file_ids(file_urls)

        semaphore = asyncio.Semaphore(10)

        async def validate(file_id: str) -> None:
            async with semaphore:
                metadata = await GoogleDriveClient.get_file_metadata(
                    access_token=access_token,
                    file_id=file_id,
                )
            if metadata.mime_type not in _ALLOWED_MIME_TYPES:
                raise AppException.image_format_error(
                    f"Unsupported image format: {metadata.mime_type}"
                )
            if metadata.size_bytes <= 0 or metadata.size_bytes > _MAX_FILE_SIZE_BYTES:
                raise AppException.bad_request(
                    f"'{metadata.name}' exceeds the maximum allowed size"
                )

        await asyncio.gather(*(validate(file_id) for file_id in file_ids))

        resolved_event_date = event_date or datetime.now(timezone.utc)
        resolved_end_date = end_date or resolved_event_date
        event = await self._event_service.create_event(
            name=event_name,
            event_date=resolved_event_date,
            end_date=resolved_end_date,
            created_by=requested_by.id,
        )

        photos = [
            UploadPhotoInput(
                drive_file_id=file_id,
                taken_at=taken_at,
                day_number=day_number,
                visibility=visibility,
            )
            for file_id in file_ids
        ]

        try:
            result = await self._upload_requests_service.create_upload(
                event_id=event.id,
                folder_id=None,
                photos=photos,
                visibility=visibility,
                day_number=day_number,
                requested_by=requested_by,
            )
        except Exception:
            # Nothing usable was staged, so remove the empty event we just made.
            try:
                await self._event_service.delete_event(event.id)
            except Exception:
                logger.warning(
                    "Failed to delete event %s after Drive import failure", event.id
                )
            raise

        if not isinstance(result, UploadRequestDetails):
            raise AppException.internal_error("Unexpected upload result")

        # Auto-approve: promotes staging objects to final MinIO keys, creates
        # photo rows, and publishes the photo.process jobs.
        approved = await self._upload_requests_service.approve_request(
            request_id=result.request.id,
            approved_by=requested_by,
        )
        return event, approved
