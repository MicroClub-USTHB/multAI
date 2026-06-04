import {
	ApiError,
	apiDelete,
	apiGet,
	apiPost,
	apiPatch,
} from '@/shared/utils/api-client'

import {
	type ListStaffUsersParams,
	type StaffUser,
	type StaffUserCreateInput,
	type StaffUserUpdateInput,
	toStaffUser,
	toStaffUserCreatePayload,
	toStaffUserUpdatePayload,
} from './types'

export class StaffUsersApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'StaffUsersApiError'
		this.status = status
		this.details = details
	}
}

const request = async <TResponse>(requestFn: () => Promise<TResponse>) => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new StaffUsersApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

const buildListQuery = (params: ListStaffUsersParams) => {
	const query = new URLSearchParams()

	if (typeof params.limit === 'number') {
		query.set('limit', String(params.limit))
	}

	if (typeof params.offset === 'number') {
		query.set('offset', String(params.offset))
	}

	if (params.search?.trim()) {
		query.set('search', params.search.trim())
	}

	if (params.role) {
		query.set('role', params.role)
	}

	if (params.sortBy) {
		query.set('sort_by', params.sortBy)
	}

	if (params.sortDirection) {
		query.set('sort_direction', params.sortDirection)
	}

	const serialized = query.toString()
	return serialized ? `?${serialized}` : ''
}

export async function listStaffUsers(
	params: ListStaffUsersParams = {},
): Promise<StaffUser[]> {
	const staffUsers = await request(() =>
		apiGet<unknown[]>(`/admin/staff-users/${buildListQuery(params)}`, {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to load staff users.',
		}),
	)

	return staffUsers.map((item) =>
		toStaffUser(item as Parameters<typeof toStaffUser>[0]),
	)
}

export async function createStaffUser(
	input: StaffUserCreateInput,
): Promise<StaffUser> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toStaffUser>[0]>(
			'/admin/staff-users/',
			toStaffUserCreatePayload(input),
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to create staff user.',
			},
		),
	)

	return toStaffUser(payload)
}

export async function updateStaffUser(
	staffUserId: string,
	input: StaffUserUpdateInput,
): Promise<StaffUser> {
	const payload = await request(() =>
		apiPatch<Parameters<typeof toStaffUser>[0]>(
			`/admin/staff-users/${staffUserId}`,
			toStaffUserUpdatePayload(input),
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to update staff user.',
			},
		),
	)

	return toStaffUser(payload)
}

export async function deleteStaffUser(staffUserId: string): Promise<StaffUser> {
	const payload = await request(() =>
		apiDelete<Parameters<typeof toStaffUser>[0]>(
			`/admin/staff-users/${staffUserId}`,
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to delete staff user.',
			},
		),
	)

	return toStaffUser(payload)
}
