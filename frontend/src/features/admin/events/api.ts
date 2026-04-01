import {
	type AdminEvent,
	type CreateAdminEventInput,
	type EventCreateDto,
	type EventStatus,
	type ListAdminEventsParams,
	toAdminEvent,
} from './types'

const API_BASE_URL =
	(import.meta.env.VITE_SERVER_URL as string | undefined) ??
	'http://localhost:8000'

const getAdminAccessToken = () => {
	if (typeof window === 'undefined') {
		return null
	}

	return window.localStorage.getItem('admin_access_token')
}

const resolveErrorMessage = (payload: unknown, fallback: string) => {
	if (!payload || typeof payload !== 'object') {
		return fallback
	}

	const details = (payload as { detail?: unknown }).detail

	if (typeof details === 'string') {
		return details
	}

	if (Array.isArray(details) && details.length > 0) {
		const first = details[0]
		if (typeof first === 'string') {
			return first
		}

		if (first && typeof first === 'object' && 'msg' in first) {
			const message = (first as { msg?: unknown }).msg
			if (typeof message === 'string') {
				return message
			}
		}
	}

	return fallback
}

const jsonHeaders = () => {
	const token = getAdminAccessToken()

	return {
		'Content-Type': 'application/json',
		...(token ? { Authorization: `Bearer ${token}` } : {}),
	}
}

export class AdminEventsApiError extends Error {
	status: number

	constructor(message: string, status: number) {
		super(message)
		this.name = 'AdminEventsApiError'
		this.status = status
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
	path: string,
	init: RequestInit,
	fallbackErrorMessage: string,
): Promise<TResponse> => {
	const response = await fetch(`${API_BASE_URL}${path}`, {
		...init,
		headers: {
			...jsonHeaders(),
			...(init.headers ?? {}),
		},
		credentials: 'include',
	})

	const rawText = await response.text()
	const payload = rawText ? (JSON.parse(rawText) as unknown) : null

	if (!response.ok) {
		throw new AdminEventsApiError(
			resolveErrorMessage(payload, fallbackErrorMessage),
			response.status,
		)
	}

	return payload as TResponse
}

export async function listAdminEvents(
	params: ListAdminEventsParams = {},
): Promise<AdminEvent[]> {
	const events = await request<unknown[]>(
		`/admin/events/${buildListQuery(params)}`,
		{ method: 'GET' },
		'Unable to load events.',
	)

	return events.map(event => toAdminEvent(event as Parameters<typeof toAdminEvent>[0]))
}

export async function createAdminEvent(input: CreateAdminEventInput): Promise<AdminEvent> {
	const payload = await request<Parameters<typeof toAdminEvent>[0]>(
		'/admin/events/',
		{
			method: 'POST',
			body: JSON.stringify(createEventPayload(input)),
		},
		'Unable to create event.',
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

	const payload = await request<Parameters<typeof toAdminEvent>[0]>(
		`/admin/events/${eventId}/${actionByStatus[status]}`,
		{ method: 'POST' },
		'Unable to update event status.',
	)

	return toAdminEvent(payload)
}

export const scheduleAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'scheduled')

export const archiveAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'archived')

export const draftAdminEvent = async (eventId: string) =>
	mutateEventStatus(eventId, 'draft')
