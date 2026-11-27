export type MultiNotificationPayload = Record<string, unknown>

export type MultiNotification = {
	id: string
	type: string
	payload: MultiNotificationPayload
	readAt: string | null
	createdAt: string
}

export type ListMultiNotificationsResponse = {
	items: MultiNotification[]
}

export type MarkMultiNotificationsAsReadInput = {
	notification_ids: string[]
}

type MultiNotificationApi = {
	id: string
	type: string
	payload?: MultiNotificationPayload | null
	read_at: string | null
	created_at: string
}

type MultiNotificationsResponseApi = {
	items: MultiNotificationApi[]
}

export const toMultiNotification = (
	notification: MultiNotificationApi,
): MultiNotification => ({
	id: notification.id,
	type: notification.type,
	payload: notification.payload ?? {},
	readAt: notification.read_at,
	createdAt: notification.created_at,
})

export const toMultiNotificationsResponse = (
	response: MultiNotificationsResponseApi,
): ListMultiNotificationsResponse => ({
	items: response.items.map(toMultiNotification),
})
