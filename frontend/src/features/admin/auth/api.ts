import { ApiError, apiGet, apiPost } from '@/shared/utils/api-client'

import {
	type AdminProfile,
	toAdminProfile,
} from './types'

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


export async function getAdminMe(): Promise<AdminProfile> {
	const payload = await request(() =>
		apiGet<Parameters<typeof toAdminProfile>[0]>('/admin/auth/me', {
			fallbackErrorMessage: 'Unable to load admin profile.',
			credentials: 'include',
		}),
	)

	return toAdminProfile(payload)
}

export async function logoutAdmin(): Promise<void> {
	await request(() =>
		apiPost<void>('/admin/auth/logout', undefined, {
			fallbackErrorMessage: 'Unable to sign out.',
			credentials: 'include',
		}),
	)
}
