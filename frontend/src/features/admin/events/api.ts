import { ApiError, apiGet, apiPost } from '@/shared/utils/api-client'

import {
	type AdminEvent,
	type CreateAdminEventInput,
	type EventCreateDto,
	type EventStatus,
	type ListAdminEventsParams,
	toAdminEvent,
} from './types'

export class AdminEventsApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'AdminEventsApiError'
		this.status = status
		this.details = details
	}
}

const buildListQuery = (params: ListAdminEventsParams) => {
	const query = new URLSearchParams()

	if (typeof params.limit === 'number') {
		query.set('limit', String(params.limit))
	}

	if (typeof params.offset === 'number') {
		query.set('offset', String(params.offset))
	}

	if (params.name) {
		query.set('name', params.name)
	}

	if (params.status && params.status !== 'all') {
		query.set('status', params.status)
	}

	const serialized = query.toString()
	return serialized ? `?${serialized}` : ''
}

const createEventPayload = (input: CreateAdminEventInput): EventCreateDto => ({
	name: input.name.trim(),
	event_date: input.eventDate,
	status: input.status,
})

const request = async <TResponse>(
	requestFn: () => Promise<TResponse>,
): Promise<TResponse> => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new AdminEventsApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

export async function listAdminEvents(
	params: ListAdminEventsParams = {},
): Promise<AdminEvent[]> {
	const events = await request(() =>
		apiGet<unknown[]>(`/admin/events/${buildListQuery(params)}`, {
			fallbackErrorMessage: 'Unable to load events.',
			tokenKey: 'admin_access_token',
		}),
	)

	return events.map(event => toAdminEvent(event as Parameters<typeof toAdminEvent>[0]))
}

export async function createAdminEvent(input: CreateAdminEventInput): Promise<AdminEvent> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminEvent>[0]>(
			'/admin/events/',
			createEventPayload(input),
			{
				fallbackErrorMessage: 'Unable to create event.',
				tokenKey: 'admin_access_token',
			},
		),
	)

	return toAdminEvent(payload)
}

const mutateEventStatus = async (
	eventId: string,
	status: EventStatus,
): Promise<AdminEvent> => {
	const actionByStatus: Record<EventStatus, string> = {
		draft: 'draft',
		scheduled: 'schedule',
		archived: 'archive',
	}

	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminEvent>[0]>(
			`/admin/events/${eventId}/${actionByStatus[status]}`,
			undefined,
			{
				fallbackErrorMessage: 'Unable to update event status.',
				tokenKey: 'admin_access_token',
			},
		),
	)

	return toAdminEvent(payload)
}

export const scheduleAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'scheduled')

export const archiveAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'archived')

export const draftAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'draft')
