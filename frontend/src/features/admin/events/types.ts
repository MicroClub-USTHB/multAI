export const EVENT_STATUSES = ['draft', 'scheduled', 'archived'] as const
export type EventStatus = (typeof EVENT_STATUSES)[number]

export interface AdminEvent {
	id: string
	name: string
	eventCode: string
	eventDate: string
	status: EventStatus
	createdBy: string
	createdAt: string
	archivedAt: string | null
}

export interface ListAdminEventsParams {
	limit?: number
	offset?: number
	name?: string
	status?: EventStatus | 'all'
}

export interface CreateAdminEventInput {
	name: string
	eventDate: string
	status?: EventStatus
}

interface EventResponseDto {
	id: string
	name: string
	event_code: string
	event_date: string
	status: string
	created_by: string
	created_at: string
	archived_at: string | null
}

export interface EventCreateDto {
	name: string
	event_date: string
	status?: EventStatus
}

const isEventStatus = (value: string): value is EventStatus =>
	EVENT_STATUSES.includes(value as EventStatus)

const normalizeStatus = (value: string): EventStatus => {
	if (isEventStatus(value)) {
		return value
	}

	return 'draft'
}

export const toAdminEvent = (event: EventResponseDto): AdminEvent => ({
	id: event.id,
	name: event.name,
	eventCode: event.event_code,
	eventDate: event.event_date,
	status: normalizeStatus(event.status),
	createdBy: event.created_by,
	createdAt: event.created_at,
	archivedAt: event.archived_at,
})
