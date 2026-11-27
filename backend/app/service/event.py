from datetime import datetime
import secrets
import uuid
from typing import List, Optional
from app.core.exceptions import AppException
from app.schema.request.internal.event import HrEventSync

from app.schema.response.web.event import (
    EventResponse,
    JoinEventResponse,
    UserEventResponse,
    ParticipantResponse,
)
from db.generated import events as event_queries
from db.generated import event_participant as participant_queries
from db.generated import models


class EventService:
    def __init__(
        self,
        e_querier: event_queries.AsyncQuerier,
        p_querier: participant_queries.AsyncQuerier,
    ):
        self.e_querier = e_querier
        self.p_querier = p_querier

    # --- Core Event Management ---

    async def create_event(
        self,
        *,
        name: str,
        event_date: datetime,
        end_date: datetime | None = None,
        created_by: uuid.UUID | None = None,
        status: str = "draft",
    ) -> EventResponse:
        event = await self.e_querier.create_event(
            event_queries.CreateEventParams(
                name=name,
                event_code=secrets.token_urlsafe(8),
                event_date=event_date,
                end_date=end_date,
                status=status,
                created_by=created_by,
            )
        )
        if event is None:
            raise AppException.internal_error("Failed to create event")
        return EventResponse.model_validate(event)

    async def sync_from_hr(self, req: HrEventSync) -> EventResponse:
        """Idempotently create/link the MultiAi event for an HR-Events event."""
        existing = await self.e_querier.get_event_by_external_id(
            external_id=req.external_id
        )
        if existing:
            if (
                existing.name != req.name
                or existing.event_date != req.starts_at
                or existing.end_date != req.ends_at
            ):
                updated = await self.e_querier.update_synced_event(
                    event_queries.UpdateSyncedEventParams(
                        external_id=req.external_id,
                        name=req.name,
                        event_date=req.starts_at,
                        end_date=req.ends_at,
                    )
                )
                if updated:
                    return EventResponse.model_validate(updated)
            return EventResponse.model_validate(existing)

        linked = await self.e_querier.link_legacy_event(
            external_id=req.external_id, name=req.name, event_date=req.starts_at
        )
        if linked:
            return EventResponse.model_validate(linked)

        params = event_queries.CreateSyncedEventParams(
            name=req.name,
            event_code=secrets.token_urlsafe(8),
            event_date=req.starts_at,
            end_date=req.ends_at,
            status="draft",
            external_id=req.external_id,
        )
        event = await self.e_querier.create_synced_event(params)
        if not event:
            # ON CONFLICT DO NOTHING: a concurrent sync of this external_id won.
            event = await self.e_querier.get_event_by_external_id(
                external_id=req.external_id
            )
        if not event:
            raise AppException.internal_error("Failed to sync event")
        return EventResponse.model_validate(event)

    async def update_status(
        self, event_id: uuid.UUID, new_status: str
    ) -> EventResponse:
        event = await self.e_querier.update_event_status(id=event_id, status=new_status)
        if not event:
            raise AppException.not_found("Event not found")
        return EventResponse.model_validate(event)

    async def delete_event(self, event_id: uuid.UUID) -> bool:
        await self.e_querier.delete_event(id=event_id)
        return True

    # --- Retrieval & Filtering ---

    async def list_events(
        self,
        limit: int = 10,
        offset: int = 0,
        status: Optional[models.EventStatus] = None,
    ) -> List[EventResponse]:

        params = event_queries.ListEventsParams(
            limit=limit,
            offset=offset,
            status=status,
            start_date=None,
            end_date=None,
            search_name=None,
            sort_order="date_desc",
        )

        events: List[EventResponse] = []
        async for e in self.e_querier.list_events(params):
            events.append(EventResponse.model_validate(e))
        return events

    async def find_events_by_name(self, name_query: str) -> List[EventResponse]:
        events: List[EventResponse] = []
        async for e in self.e_querier.get_events_by_name(dollar_1=name_query):
            events.append(EventResponse.model_validate(e))
        return events

    # --- Participation (Scan to Join) ---

    async def join_event_by_code(
        self, user_id: uuid.UUID, code: str
    ) -> JoinEventResponse:
        # 1. Find event by the scanned hash
        event = await self.e_querier.get_event_by_code(event_code=code)
        if not event:
            raise AppException.not_found("Invalid QR Code")

        if event.status == "archived":
            raise AppException.forbidden("This event is already closed.")

        # 2. Check if already joined
        is_member = await self.p_querier.is_user_in_event(
            event_id=event.id, user_id=user_id
        )
        if is_member:
            raise AppException.forbidden("You have already joined this event")

        # 3. Join
        join_record = await self.p_querier.join_event(
            event_id=event.id, user_id=user_id
        )
        if not join_record:
            raise AppException.internal_error("Failed to join event")

        return JoinEventResponse.model_validate(join_record)

    async def get_event_attendees(
        self, event_id: uuid.UUID
    ) -> List[ParticipantResponse]:
        # Explicitly hint the list type to resolve Pylance 'Unknown' errors
        users: List[ParticipantResponse] = []
        async for u in self.p_querier.get_event_participants(event_id=event_id):
            users.append(ParticipantResponse.model_validate(u))
        return users

    async def get_my_events(self, user_id: uuid.UUID) -> List[UserEventResponse]:
        # Explicitly hint the list type
        events: List[UserEventResponse] = []
        async for e in self.p_querier.get_user_events(user_id=user_id):
            events.append(UserEventResponse.model_validate(e))
        return events
