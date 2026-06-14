import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import type {
	AdminUser,
	AdminUserCreateInput,
	AdminUserUpdateInput,
	ListAdminUsersParams,
} from './types'

import {
	blockAdminUser,
	createAdminUser,
	deleteAdminUser,
	getAdminUser,
	listAdminUsers,
	unblockAdminUser,
	updateAdminUser,
} from './api'

export const ADMIN_USERS_QUERY_KEY = ['admin', 'users'] as const

const defaultListParams: ListAdminUsersParams = {
	limit: 20,
	offset: 0,
}

const mergeUserInCache = (users: AdminUser[], updated: AdminUser) =>
	users.map(user => (user.id === updated.id ? updated : user))

export function useAdminUsersQuery(
	params: ListAdminUsersParams = defaultListParams,
) {
	return useQuery({
		queryKey: [...ADMIN_USERS_QUERY_KEY, params],
		queryFn: () => listAdminUsers(params),
	})
}

export function useAdminUserQuery(userId: string | null, enabled = true) {
	return useQuery({
		queryKey: [...ADMIN_USERS_QUERY_KEY, 'detail', userId],
		queryFn: () => {
			if (!userId) {
				throw new Error('Missing user id.')
			}

			return getAdminUser(userId)
		},
		enabled: Boolean(userId) && enabled,
	})
}

export function useCreateAdminUserMutation(params: ListAdminUsersParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: AdminUserCreateInput) => createAdminUser(input),
		onSuccess: created => {
			queryClient.setQueryData<AdminUser[]>(
				[...ADMIN_USERS_QUERY_KEY, params],
				previous => [created, ...(previous ?? [])],
			)
		},
	})
}

export function useUpdateAdminUserMutation(params: ListAdminUsersParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: ({ userId, input }: { userId: string; input: AdminUserUpdateInput }) =>
			updateAdminUser(userId, input),
		onSuccess: updated => {
			queryClient.setQueryData<AdminUser[]>(
				[...ADMIN_USERS_QUERY_KEY, params],
				previous => (previous ? mergeUserInCache(previous, updated) : previous),
			)
		},
	})
}

export function useDeleteAdminUserMutation(params: ListAdminUsersParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (userId: string) => deleteAdminUser(userId),
		onSuccess: deleted => {
			queryClient.setQueryData<AdminUser[]>(
				[...ADMIN_USERS_QUERY_KEY, params],
				previous => previous?.filter(user => user.id !== deleted.id) ?? previous,
			)
		},
	})
}

export function useBlockAdminUserMutation(params: ListAdminUsersParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (userId: string) => blockAdminUser(userId),
		onSuccess: updated => {
			queryClient.setQueryData<AdminUser[]>(
				[...ADMIN_USERS_QUERY_KEY, params],
				previous => (previous ? mergeUserInCache(previous, updated) : previous),
			)
		},
	})
}

export function useUnblockAdminUserMutation(params: ListAdminUsersParams) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (userId: string) => unblockAdminUser(userId),
		onSuccess: updated => {
			queryClient.setQueryData<AdminUser[]>(
				[...ADMIN_USERS_QUERY_KEY, params],
				previous => (previous ? mergeUserInCache(previous, updated) : previous),
			)
		},
	})
}

export function useAdminUsers(params: ListAdminUsersParams = defaultListParams) {
	const query = useAdminUsersQuery(params)
	const createMutation = useCreateAdminUserMutation(params)
	const updateMutation = useUpdateAdminUserMutation(params)
	const deleteMutation = useDeleteAdminUserMutation(params)
	const blockMutation = useBlockAdminUserMutation(params)
	const unblockMutation = useUnblockAdminUserMutation(params)

	return {
		users: query.data ?? [],
		isLoading: query.isLoading,
		isError: query.isError,
		error: query.error,
		refetch: query.refetch,

		createUser: createMutation.mutateAsync,
		updateUser: updateMutation.mutateAsync,
		deleteUser: deleteMutation.mutateAsync,
		blockUser: blockMutation.mutateAsync,
		unblockUser: unblockMutation.mutateAsync,
		isMutating:
			createMutation.isPending ||
			updateMutation.isPending ||
			deleteMutation.isPending ||
			blockMutation.isPending ||
			unblockMutation.isPending,
	}
}
