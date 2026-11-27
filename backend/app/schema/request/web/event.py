from pydantic import BaseModel


class JoinEventRequest(BaseModel):
    event_code: str
