import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import type {
	ListStaffUsersParams,
	StaffUser,
	StaffUserCreateInput,
	StaffUserUpdateInput,
} from './types'

import {
	createStaffUser,
	deleteStaffUser,
	listStaffUsers,
	updateStaffUser,
} from './api'

export const STAFF_USERS_QUERY_KEY = ['admin', 'staff-users'] as const

const defaultListParams: ListStaffUsersParams = {
	limit: 20,
	offset: 0,
	sortBy: 'created_at',
	sortDirection: 'desc',
}

export function useStaffUsersQuery(
	params: ListStaffUsersParams = defaultListParams,
) {
	return useQuery({
		queryKey: [...STAFF_USERS_QUERY_KEY, params],
		queryFn: () => listStaffUsers(params),
	})
}

export function useCreateStaffUserMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: StaffUserCreateInput) => createStaffUser(input),
		onSuccess: async () => {
			await queryClient.invalidateQueries({ queryKey: STAFF_USERS_QUERY_KEY })
		},
	})
}

export function useUpdateStaffUserMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: ({
			staffUserId,
			input,
		}: {
			staffUserId: string
			input: StaffUserUpdateInput
		}) => updateStaffUser(staffUserId, input),
		onSuccess: async () => {
			await queryClient.invalidateQueries({ queryKey: STAFF_USERS_QUERY_KEY })
		},
	})
}

export function useDeleteStaffUserMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (staffUserId: string) => deleteStaffUser(staffUserId),
		onSuccess: async () => {
			await queryClient.invalidateQueries({ queryKey: STAFF_USERS_QUERY_KEY })
		},
	})
}

export function useStaffUsers(params: ListStaffUsersParams = defaultListParams) {
	const query = useStaffUsersQuery(params)
	const createMutation = useCreateStaffUserMutation()
	const updateMutation = useUpdateStaffUserMutation()
	const deleteMutation = useDeleteStaffUserMutation()

	return {
		users: query.data ?? [],
		isLoading: query.isLoading,
		isError: query.isError,
		error: query.error,
		refetch: query.refetch,
		createUser: createMutation.mutateAsync,
		updateUser: updateMutation.mutateAsync,
		deleteUser: deleteMutation.mutateAsync,
		isMutating:
			createMutation.isPending ||
			updateMutation.isPending ||
			deleteMutation.isPending,
	} satisfies {
		users: StaffUser[]
		isLoading: boolean
		isError: boolean
		error: unknown
		refetch: typeof query.refetch
		createUser: typeof createMutation.mutateAsync
		updateUser: typeof updateMutation.mutateAsync
		deleteUser: typeof deleteMutation.mutateAsync
		isMutating: boolean
	}
}
