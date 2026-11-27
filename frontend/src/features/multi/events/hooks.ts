import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import type {
	CreateMultiEventInput,
	ListMultiEventsParams,
	MultiEvent,
} from './types'

import {
	archiveMultiEvent,
	createMultiEvent,
	draftMultiEvent,
	listMultiEvents,
	scheduleMultiEvent,
} from './api'

export const MULTI_EVENTS_QUERY_KEY = ['multi', 'events'] as const

const defaultListParams: ListMultiEventsParams = {
	limit: 50,
	offset: 0,
	status: 'all',
	name: '',
}

const mergeEventInCache = (events: MultiEvent[], updated: MultiEvent) =>
	events.map(event => (event.id === updated.id ? updated : event))

export function useMultiEventsQuery(params: ListMultiEventsParams = defaultListParams) {
	return useQuery({
		queryKey: [...MULTI_EVENTS_QUERY_KEY, params],
		queryFn: () => listMultiEvents(params),
	})
}

export function useCreateMultiEventMutation(params: ListMultiEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: CreateMultiEventInput) => createMultiEvent(input),
		onSuccess: createdEvent => {
			queryClient.setQueryData<MultiEvent[]>(
				[...MULTI_EVENTS_QUERY_KEY, params],
				previous => [createdEvent, ...(previous ?? [])],
			)
		},
	})
}

export function useScheduleMultiEventMutation(params: ListMultiEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => scheduleMultiEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<MultiEvent[]>(
				[...MULTI_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useArchiveMultiEventMutation(params: ListMultiEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => archiveMultiEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<MultiEvent[]>(
				[...MULTI_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useDraftMultiEventMutation(params: ListMultiEventsParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (eventId: string) => draftMultiEvent(eventId),
		onSuccess: updatedEvent => {
			queryClient.setQueryData<MultiEvent[]>(
				[...MULTI_EVENTS_QUERY_KEY, params],
				previous => (previous ? mergeEventInCache(previous, updatedEvent) : previous),
			)
		},
	})
}

export function useMultiEvents(params: ListMultiEventsParams = defaultListParams) {
	const eventsQuery = useMultiEventsQuery(params)
	const createMutation = useCreateMultiEventMutation(params)
	const scheduleMutation = useScheduleMultiEventMutation(params)
	const archiveMutation = useArchiveMultiEventMutation(params)
	const draftMutation = useDraftMultiEventMutation(params)

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
