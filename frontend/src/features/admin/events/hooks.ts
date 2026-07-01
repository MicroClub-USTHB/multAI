import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import type {
	AdminEvent,
	CreateAdminEventInput,
	ListAdminEventsParams,
} from './types'

import {
	archiveAdminEvent,
	createAdminEvent,
	draftAdminEvent,
	listAdminEvents,
	scheduleAdminEvent,
} from './api'


export const ADMIN_EVENTS_QUERY_KEY = ['admin', 'events'] as const

const defaultListParams: ListAdminEventsParams = {
	limit: 50,
	offset: 0,
	status: 'all',
	name: '',
}

const mergeEventInCache = (events: AdminEvent[], updated: AdminEvent) =>
	events.map(event => (event.id === updated.id ? updated : event))

export function useAdminEventsQuery(params: ListAdminEventsParams = defaultListParams) {
	return useQuery({
		queryKey: [...ADMIN_EVENTS_QUERY_KEY, params],
		queryFn: () => listAdminEvents(params),
	})
}

export function useCreateAdminEventMutation(params: ListAdminEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: CreateAdminEventInput) => createAdminEvent(input),
		onSuccess: createdEvent => {
			queryClient.setQueryData<AdminEvent[]>(
				[...ADMIN_EVENTS_QUERY_KEY, params],
				previous => [createdEvent, ...(previous ?? [])],
			)
		},
	})
}

export function useScheduleAdminEventMutation(params: ListAdminEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => scheduleAdminEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<AdminEvent[]>(
				[...ADMIN_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useArchiveAdminEventMutation(params: ListAdminEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => archiveAdminEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<AdminEvent[]>(
				[...ADMIN_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useDraftAdminEventMutation(params: ListAdminEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => draftAdminEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<AdminEvent[]>(
				[...ADMIN_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useAdminEvents(params: ListAdminEventsParams = defaultListParams) {
	const eventsQuery = useAdminEventsQuery(params)
	const createMutation = useCreateAdminEventMutation(params)
	const scheduleMutation = useScheduleAdminEventMutation(params)
	const archiveMutation = useArchiveAdminEventMutation(params)
	const draftMutation = useDraftAdminEventMutation(params)

	return {
		events: eventsQuery.data ?? [],
		isLoading: eventsQuery.isLoading,
		isError: eventsQuery.isError,
		error: eventsQuery.error,
		refetch: eventsQuery.refetch,
		createEvent: createMutation.mutateAsync,
		scheduleEvent: scheduleMutation.mutateAsync,
		archiveEvent: archiveMutation.mutateAsync,
		draftEvent: draftMutation.mutateAsync,
		isMutating:
			createMutation.isPending ||
			scheduleMutation.isPending ||
			archiveMutation.isPending ||
			draftMutation.isPending,
	}
}
