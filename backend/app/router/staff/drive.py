from datetime import datetime, timezone
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse

from app.container import Container, get_container
from app.core.exceptions import AppException
from app.deps.cookie_auth import get_current_staff_user, require_admin_staff
from app.infra.google_drive import GoogleDriveClient
from app.schema.request.staff.drive import GoogleDriveImportRequest
from app.schema.request.staff.drive_import import DriveImportUrlsRequest
from app.schema.request.staff.drive_drop import DriveDropRequest

from app.schema.response.staff.drive import (
    DriveBrowseResponse,
    DriveItemSchema,
    GoogleDriveCallbackResponse,
    GoogleDriveConnectResponse,
    GoogleDriveConnectionStatusResponse,
    GoogleDriveDisconnectResponse,
    GoogleDriveImportFileResult,
    GoogleDriveImportResponse,
)
from app.schema.response.staff.drive_import import DriveImportUrlsResponse
from app.schema.response.staff.uploads import UploadRequestSchema
from app.schema.response.staff.drive_drop import DriveDropResponse
from app.service.drive_folder import extract_drive_folder_id

from app.service.staff_drive import SelectedDriveFile
from db.generated.models import StaffUser


router = APIRouter(prefix="/drive")


@router.get("/connect", response_model=GoogleDriveConnectResponse)
async def connect_google_drive(
    redirect_url: str | None = Query(default=None),
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> GoogleDriveConnectResponse:
    authorization_url, state = await container.staff_drive_service.create_connect_url(
        current_staff_user,
        redirect_url=redirect_url,
    )
    return GoogleDriveConnectResponse(authorization_url=authorization_url, state=state)


@router.get("/callback", response_model=GoogleDriveCallbackResponse)
async def google_drive_callback(
    code: str = Query(...),
    state: str = Query(...),
    error: str | None = Query(default=None),
    container: Container = Depends(get_container),
) -> GoogleDriveCallbackResponse | RedirectResponse:
    redirect_url = await container.staff_drive_service.get_callback_redirect_url(state)
    if error is not None:
        if redirect_url is not None:
            return RedirectResponse(
                container.staff_drive_service.build_frontend_callback_url(
                    redirect_url,
                    status="error",
                    error=error,
                )
            )
        raise AppException.bad_request(f"Google OAuth error: {error}")

    try:
        connection, redirect_url = await container.staff_drive_service.handle_callback(
            code, state
        )
    except HTTPException as exc:
        if redirect_url is not None:
            return RedirectResponse(
                container.staff_drive_service.build_frontend_callback_url(
                    redirect_url,
                    status="error",
                    error=str(exc.detail),
                )
            )
        raise

    if redirect_url is not None:
        return RedirectResponse(
            container.staff_drive_service.build_frontend_callback_url(
                redirect_url,
                status="success",
                google_email=connection.google_email,
            )
        )
    return GoogleDriveCallbackResponse(
        message="Google Drive connected successfully",
        google_email=connection.google_email,
    )


@router.get("/status", response_model=GoogleDriveConnectionStatusResponse)
async def google_drive_status(
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> GoogleDriveConnectionStatusResponse:
    connection = await container.staff_drive_service.get_status(current_staff_user.id)
    if connection is None:
        return GoogleDriveConnectionStatusResponse(connected=False)

    return GoogleDriveConnectionStatusResponse(
        connected=True,
        google_email=connection.google_email,
        scopes=[scope for scope in connection.scopes.split(" ") if scope],
        connected_at=connection.connected_at,
        token_expires_at=connection.token_expires_at,
    )


@router.post("/disconnect", response_model=GoogleDriveDisconnectResponse)
async def disconnect_google_drive(
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> GoogleDriveDisconnectResponse:
    await container.staff_drive_service.disconnect(current_staff_user.id)
    return GoogleDriveDisconnectResponse(
        message="Google Drive disconnected successfully"
    )


@router.get("/browse", response_model=DriveBrowseResponse)
async def browse_drive(
    folder_id: str | None = Query(default=None),
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> DriveBrowseResponse:
    access_token = await container.staff_drive_service.get_access_token_for_staff_user(
        current_staff_user.id
    )
    files = await GoogleDriveClient.list_folder_contents(
        access_token=access_token,
        folder_id=folder_id,
    )
    return DriveBrowseResponse(
        items=[
            DriveItemSchema(
                id=f.id,
                name=f.name,
                mime_type=f.mime_type,
                size_bytes=f.size_bytes,
                is_folder=f.mime_type == GoogleDriveClient._drive_folder_mime_type,
            )
            for f in files
        ]
    )


@router.get("/search", response_model=DriveBrowseResponse)
async def search_drive(
    q: str = Query(..., min_length=1),
    type: Literal["folder", "image"] | None = Query(default=None),
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> DriveBrowseResponse:
    access_token = await container.staff_drive_service.get_access_token_for_staff_user(
        current_staff_user.id
    )
    files = await GoogleDriveClient.search_files(
        access_token=access_token,
        query=q,
        file_type=type,
    )
    return DriveBrowseResponse(
        items=[
            DriveItemSchema(
                id=f.id,
                name=f.name,
                mime_type=f.mime_type,
                size_bytes=f.size_bytes,
                is_folder=f.mime_type == GoogleDriveClient._drive_folder_mime_type,
            )
            for f in files
        ]
    )


@router.post("/files/import", response_model=GoogleDriveImportResponse)
async def import_drive_files(
    request: GoogleDriveImportRequest,
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> GoogleDriveImportResponse:
    selections = [
        SelectedDriveFile(id=f.id, name=f.name, mime_type=f.mime_type)
        for f in request.files
    ]
    results = await container.staff_drive_service.import_images_from_drive(
        staff_user=current_staff_user,
        selected_files=selections,
    )
    return GoogleDriveImportResponse(
        files=[
            GoogleDriveImportFileResult(
                drive_file_id=r.drive_file_id,
                original_file_name=r.original_file_name,
                minio_bucket=r.minio_bucket,
                minio_object_name=r.minio_object_name,
                minio_object_path=r.minio_object_path,
            )
            for r in results
        ]
    )


@router.post("/import-urls", response_model=DriveImportUrlsResponse)
async def import_drive_urls(
    req: DriveImportUrlsRequest,
    current_staff_user: StaffUser = Depends(get_current_staff_user),
    container: Container = Depends(get_container),
) -> DriveImportUrlsResponse:
    """Create an event from individual Google Drive file links.

    Downloads each file into MinIO staging with the connected staff Drive
    account, then auto-approves it so photos are promoted to final storage and
    face processing is queued.
    """
    event, upload_request = (
        await container.drive_import_service.import_to_new_event(
            event_name=req.event.name,
            event_date=req.event.event_date,
            end_date=req.event.end_date,
            file_urls=req.file_urls,
            visibility=req.visibility,
            day_number=req.day_number,
            taken_at=req.taken_at,
            requested_by=current_staff_user,
        )
    )
    return DriveImportUrlsResponse(
        event=event,
        upload_request=UploadRequestSchema.from_details(upload_request),
        imported_photo_count=len(upload_request.photos),
    )

@router.post("/drop", response_model=DriveDropResponse)
async def drop_drive_folder(
    req: DriveDropRequest,
    current_staff_user: StaffUser = Depends(require_admin_staff),
    container: Container = Depends(get_container),
) -> DriveDropResponse:
    """Import every photo in a Drive folder (subfolders included) and process it.

    Skips the team-lead review: the photos are promoted to final storage and the
    face-matching jobs are queued as soon as the import finishes. Admin only.
    Progress is readable from GET /uploads/groups/{group_id}.
    """
    folder_id = extract_drive_folder_id(req.folder_url)

    if req.event_id is not None:
        event_id = req.event_id
    else:
        assert req.new_event is not None
        now = datetime.now(timezone.utc)
        event = await container.event_service.create_event(
            name=req.new_event.name.strip(),
            event_date=req.new_event.event_date or now,
            end_date=req.new_event.end_date or req.new_event.event_date or now,
            created_by=current_staff_user.id,
        )
        event_id = event.id

    group = await container.upload_requests_service.create_group_from_folder(
        event_id=event_id,
        folder_id=folder_id,
        visibility=req.visibility,
        day_number=req.day_number,
        requested_by=current_staff_user,
        recursive=True,
        auto_approve=True,
        use_api_key=not req.use_my_drive,
    )
    return DriveDropResponse(group_id=group.group.id, event_id=event_id)

