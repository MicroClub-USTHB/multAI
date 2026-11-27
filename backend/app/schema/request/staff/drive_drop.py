import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, model_validator


class DriveDropNewEvent(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    event_date: datetime | None = None
    end_date: datetime | None = None


class DriveDropRequest(BaseModel):
    folder_url: str = Field(min_length=1, max_length=1000)
    event_id: uuid.UUID | None = None
    new_event: DriveDropNewEvent | None = None
    visibility: Literal["private", "public"] = "private"
    day_number: int | None = Field(default=None, ge=1)

    @model_validator(mode="after")
    def _one_event_source(self) -> "DriveDropRequest":
        if (self.event_id is None) == (self.new_event is None):
            raise ValueError("Provide either event_id or new_event")
        return self
