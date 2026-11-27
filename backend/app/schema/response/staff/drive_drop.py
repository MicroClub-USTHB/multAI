import uuid

from pydantic import BaseModel


class DriveDropResponse(BaseModel):
    group_id: uuid.UUID
    event_id: uuid.UUID
