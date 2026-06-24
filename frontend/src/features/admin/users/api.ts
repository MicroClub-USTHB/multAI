import {
	ApiError,
	apiDelete,
	apiGet,
	apiPost,
	apiPut,
} from '@/shared/utils/api-client'

import {
	type AdminUser,
	type AdminUserCreateInput,
	type AdminUserUpdateInput,
	type ListAdminUsersParams,
	toAdminUser,
	toAdminUserCreatePayload,
	toAdminUserUpdatePayload,
} from './types'

export class AdminUsersApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'AdminUsersApiError'
		this.status = status
		this.details = details
	}
}

const request = async <TResponse>(requestFn: () => Promise<TResponse>) => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new AdminUsersApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

const buildListQuery = (params: ListAdminUsersParams) => {
	const query = new URLSearchParams()

	if (typeof params.limit === 'number') {
		query.set('limit', String(params.limit))
	}

	if (typeof params.offset === 'number') {
		query.set('offset', String(params.offset))
	}

	const serialized = query.toString()
	return serialized ? `?${serialized}` : ''
}

export async function listAdminUsers(
	params: ListAdminUsersParams = {},
): Promise<AdminUser[]> {
	const users = await request(() =>
		apiGet<unknown[]>(`/admin/users/${buildListQuery(params)}`, {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to load users.',
		}),
	)

	return users.map(user => toAdminUser(user as Parameters<typeof toAdminUser>[0]))
}

export const getAdminUsers = listAdminUsers

export async function getAdminUser(userId: string): Promise<AdminUser> {
	const user = await request(() =>
		apiGet<Parameters<typeof toAdminUser>[0]>(`/admin/users/${userId}`, {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to load user.',
		}),
	)

	return toAdminUser(user)
}

export async function createAdminUser(
	input: AdminUserCreateInput,
): Promise<AdminUser> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminUser>[0]>(
			'/admin/users/',
			toAdminUserCreatePayload(input),
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to create user.',
			},
		),
	)

	return toAdminUser(payload)
}

export async function updateAdminUser(
	userId: string,
	input: AdminUserUpdateInput,
): Promise<AdminUser> {
	const payload = await request(() =>
		apiPut<Parameters<typeof toAdminUser>[0]>(
			`/admin/users/${userId}`,
			toAdminUserUpdatePayload(input),
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to update user.',
			},
		),
	)

	return toAdminUser(payload)
}

export async function deleteAdminUser(userId: string): Promise<AdminUser> {
	const payload = await request(() =>
		apiDelete<Parameters<typeof toAdminUser>[0]>(`/admin/users/${userId}`, {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to delete user.',
		}),
	)

	return toAdminUser(payload)
}

export async function blockAdminUser(userId: string): Promise<AdminUser> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminUser>[0]>(
			`/admin/users/${userId}/block`,
			undefined,
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to block user.',
			},
		),
	)

	return toAdminUser(payload)
}

export async function unblockAdminUser(userId: string): Promise<AdminUser> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminUser>[0]>(
			`/admin/users/${userId}/unblock`,
			undefined,
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to unblock user.',
			},
		),
	)

	return toAdminUser(payload)
}
