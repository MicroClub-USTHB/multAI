from pydantic import BaseModel

from app.schema.response.staff.uploads import UploadRequestSchema
from app.schema.response.web.event import EventResponse


class DriveImportUrlsResponse(BaseModel):
    event: EventResponse
    upload_request: UploadRequestSchema
    imported_photo_count: int
