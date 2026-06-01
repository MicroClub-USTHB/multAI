import { ApiError, apiGet, apiPost } from '@/shared/utils/api-client'

import {
	type AdminAuthRequest,
	type AdminAuthResponse,
	type AdminProfile,
	toAdminAuthResponse,
	toAdminProfile,
} from './types'

export const ADMIN_AUTH_TOKEN_KEY = 'admin_access_token'

export class AdminAuthApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'AdminAuthApiError'
		this.status = status
		this.details = details
	}
}

const request = async <TResponse>(requestFn: () => Promise<TResponse>) => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new AdminAuthApiError(error.message, error.status, error.details)
		}

		throw error
	}
}

export async function loginAdmin(
	input: AdminAuthRequest,
): Promise<AdminAuthResponse> {
	const payload = await request(() =>
		apiPost<Parameters<typeof toAdminAuthResponse>[0]>(
			'/admin/auth/login',
			input,
			{
				fallbackErrorMessage: 'Unable to sign in.',
			},
		),
	)

	return toAdminAuthResponse(payload)
}

export async function getAdminMe(): Promise<AdminProfile> {
	const payload = await request(() =>
		apiGet<Parameters<typeof toAdminProfile>[0]>('/admin/auth/me', {
			tokenKey: ADMIN_AUTH_TOKEN_KEY,
			fallbackErrorMessage: 'Unable to load admin profile.',
		}),
	)

	return toAdminProfile(payload)
}

export async function logoutAdmin(): Promise<void> {
	await request(() =>
		apiPost<void>('/admin/auth/logout', undefined, {
			tokenKey: ADMIN_AUTH_TOKEN_KEY,
			fallbackErrorMessage: 'Unable to sign out.',
		}),
	)
}
