import { useQuery } from '@tanstack/react-query'

import type { AuditEventType } from './types'

import { type ListAuditsParams, listAudits } from './api'

export const ADMIN_AUDITS_QUERY_KEY = ['admin', 'audits'] as const

const defaultListParams: ListAuditsParams = {
	limit: 50,
	offset: 0,
}

export function useAdminAuditsQuery(
	params: ListAuditsParams = defaultListParams,
) {
	return useQuery({
		queryKey: [...ADMIN_AUDITS_QUERY_KEY, params],
		queryFn: () => listAudits(params),
	})
}

export function useAdminAudits(params: ListAuditsParams = defaultListParams) {
	const query = useAdminAuditsQuery(params)

	return {
		audits: query.data ?? [],
		isLoading: query.isLoading,
		isError: query.isError,
		error: query.error,
		refetch: query.refetch,
	}
}

export const AUDIT_EVENT_TYPES: AuditEventType[] = [
	'user.signup',
	'user.login',
	'user.logout',
	'upload_request.created',
	'upload_request.approved',
	'upload_request.rejected',
	'photo.processed',
	'photo_approval.decided',
]
