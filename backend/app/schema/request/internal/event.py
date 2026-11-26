from datetime import datetime

from pydantic import BaseModel, Field, model_validator


class HrEventSync(BaseModel):
    """Event pushed from HR-Events. `external_id` is the HR-Events event id."""

    external_id: str = Field(min_length=1)
    name: str = Field(min_length=1)
    starts_at: datetime
    ends_at: datetime

    @model_validator(mode="after")
    def _check_dates(self) -> "HrEventSync":
        if self.ends_at < self.starts_at:
            raise ValueError("ends_at must not be before starts_at")
        return self
