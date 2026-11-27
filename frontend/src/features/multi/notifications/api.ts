import { ApiError, apiGet, apiPost } from '@/shared/utils/api-client'

import {
	type ListMultiNotificationsResponse,
	type MarkMultiNotificationsAsReadInput,
	toMultiNotificationsResponse,
} from './types'

export class MultiNotificationsApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'MultiNotificationsApiError'
		this.status = status
		this.details = details
	}
}

const request = async <TResponse>(requestFn: () => Promise<TResponse>) => {
	try {
		return await requestFn()
	} catch (error) {
		if (error instanceof ApiError) {
			throw new MultiNotificationsApiError(
				error.message,
				error.status,
				error.details,
			)
		}

		throw error
	}
}

export async function listMultiNotifications(): Promise<ListMultiNotificationsResponse> {
	const response = await request(() =>
		apiGet<unknown>('/staff/notifications', {
			credentials: 'include',
			fallbackErrorMessage: 'Unable to load notifications.',
		}),
	)

	return toMultiNotificationsResponse(response as Parameters<
		typeof toMultiNotificationsResponse
	>[0])
}

export async function markMultiNotificationsAsRead(
	input: MarkMultiNotificationsAsReadInput,
): Promise<ListMultiNotificationsResponse> {
	const response = await request(() =>
		apiPost<unknown, MarkMultiNotificationsAsReadInput>(
			'/staff/notifications/read',
			input,
			{
				credentials: 'include',
				fallbackErrorMessage: 'Unable to mark notifications as read.',
			},
		),
	)

	return toMultiNotificationsResponse(response as Parameters<
		typeof toMultiNotificationsResponse
	>[0])
}
