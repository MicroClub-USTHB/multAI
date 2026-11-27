import { ApiError, apiGet, apiPost } from '@/shared/utils/api-client'

import {
	type CreateMultiEventInput,
	type EventCreateDto,
	type EventStatus,
	type ListMultiEventsParams,
	type MultiEvent,
	toMultiEvent,
} from './types'

export class MultiEventsApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'MultiEventsApiError'
		this.status = status
		this.details = details
	}
}

const buildListQuery = (params: ListMultiEventsParams) => {
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

const createEventPayload = (input: CreateMultiEventInput): EventCreateDto => ({
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
			throw new MultiEventsApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

export async function listMultiEvents(
	params: ListMultiEventsParams = {},
): Promise<MultiEvent[]> {
	const events = await request(() =>
		apiGet<unknown[]>(`/admin/events/${buildListQuery(params)}`, {
			fallbackErrorMessage: 'Unable to load events.',
			credentials: 'include',
		}),
	)

	return events.map(event => toMultiEvent(event as Parameters<typeof toMultiEvent>[0]))
}

export async function createMultiEvent(input: CreateMultiEventInput): Promise<MultiEvent> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toMultiEvent>[0]>(
			'/admin/events/',
			createEventPayload(input),
			{
				fallbackErrorMessage: 'Unable to create event.',
				credentials: 'include',
			},
		),
	)

	return toMultiEvent(payload)
}

const mutateEventStatus = async (
	eventId: string,
	status: EventStatus,
): Promise<MultiEvent> => {
	const actionByStatus: Record<EventStatus, string> = {
		draft: 'draft',
		scheduled: 'schedule',
		archived: 'archive',
	}

	const payload = await request(() =>
		apiPost<Parameters<typeof toMultiEvent>[0]>(
			`/admin/events/${eventId}/${actionByStatus[status]}`,
			undefined,
			{
				fallbackErrorMessage: 'Unable to update event status.',
				credentials: 'include',
			},
		),
	)

	return toMultiEvent(payload)
}

export const scheduleMultiEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'scheduled')

export const archiveMultiEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'archived')

export const draftMultiEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'draft')
