import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import type { ListMultiNotificationsResponse } from './types'

import {
	listMultiNotifications,
	markMultiNotificationsAsRead,
} from './api'

export const MULTI_NOTIFICATIONS_QUERY_KEY = ['multi', 'notifications'] as const

export function useMultiNotificationsQuery() {
	return useQuery({
		queryKey: MULTI_NOTIFICATIONS_QUERY_KEY,
		queryFn: listMultiNotifications,
	})
}

export function useMarkMultiNotificationsAsReadMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (notificationIds: string[]) =>
			markMultiNotificationsAsRead({
				notification_ids: notificationIds,
			}),
		onSuccess: (response) => {
			queryClient.setQueryData<ListMultiNotificationsResponse>(
				MULTI_NOTIFICATIONS_QUERY_KEY,
				response,
			)
		},
	})
}

export function useMultiNotifications() {
	const notificationsQuery = useMultiNotificationsQuery()
	const markAsReadMutation = useMarkMultiNotificationsAsReadMutation()

	return {
		notifications: notificationsQuery.data?.items ?? [],
		isLoading: notificationsQuery.isLoading,
		isError: notificationsQuery.isError,
		error: notificationsQuery.error,
		refetch: notificationsQuery.refetch,
		markAsRead: markAsReadMutation.mutateAsync,
		isMutating: markAsReadMutation.isPending,
	}
}
