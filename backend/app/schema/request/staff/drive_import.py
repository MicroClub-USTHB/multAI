from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator, model_validator


class DriveImportEventRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    event_date: datetime | None = None
    end_date: datetime | None = None

    @field_validator("name", mode="before")
    @classmethod
    def _strip_name(cls, value: object) -> object:
        if isinstance(value, str):
            return value.strip()
        return value

    @model_validator(mode="after")
    def _check_dates(self) -> "DriveImportEventRequest":
        if (
            self.event_date is not None
            and self.end_date is not None
            and self.end_date < self.event_date
        ):
            raise ValueError("end_date must not be before event_date")
        return self


class DriveImportUrlsRequest(BaseModel):
    event: DriveImportEventRequest
    file_urls: list[str] = Field(min_length=1, max_length=100)
    visibility: Literal["private", "public"] = "private"
    day_number: int | None = Field(default=None, ge=1)
    taken_at: datetime | None = None
