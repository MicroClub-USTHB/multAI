import { ApiError, apiGet } from '@/shared/utils/api-client'

import { type AuditEvent, type AuditEventType, toAuditEvent } from './types'

export type ListAuditsParams = {
	eventType?: AuditEventType | null
	userId?: string | null
	from?: string | null
	to?: string | null
	limit?: number
	offset?: number
}

type AuditEventListResponse = {
	items: Parameters<typeof toAuditEvent>[0][]
}

export class AdminAuditsApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'AdminAuditsApiError'
		this.status = status
		this.details = details
	}
}

const request = async <TResponse>(requestFn: () => Promise<TResponse>) => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new AdminAuditsApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

const buildListQuery = (params: ListAuditsParams) => {
	const query = new URLSearchParams()

	if (params.eventType) {
		query.set('event_type', params.eventType)
	}

	if (params.userId) {
		query.set('user_id', params.userId)
	}

	if (params.from) {
		query.set('from', params.from)
	}

	if (params.to) {
		query.set('to', params.to)
	}

	if (typeof params.limit === 'number') {
		query.set('limit', String(params.limit))
	}

	if (typeof params.offset === 'number') {
		query.set('offset', String(params.offset))
	}

	const serialized = query.toString()
	return serialized ? `?${serialized}` : ''
}

export async function listAudits(
	params: ListAuditsParams = {},
): Promise<AuditEvent[]> {
	const response = await request(() =>
		apiGet<AuditEventListResponse>(`/admin/audits${buildListQuery(params)}`, {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to load audits.',
		}),
	)

	return response.items.map(item => toAuditEvent(item))
}
