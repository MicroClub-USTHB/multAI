import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
	createAdminUser,
	deleteAdminUser,
	getAdminUsers,
	updateAdminUserRole,
} from './api'
import type {
	AdminUser,
	CreateAdminUserInput,
	UpdateAdminUserRoleInput,
} from './types'

export const ADMIN_USERS_QUERY_KEY = ['admin', 'users'] as const

const upsertUserInCache = (users: AdminUser[] | undefined, updated: AdminUser) => {
	if (!users) {
		return [updated]
	}

	const exists = users.some(user => user.id === updated.id)
	if (!exists) {
		return [updated, ...users]
	}

	return users.map(user => (user.id === updated.id ? updated : user))
}

const removeUserFromCache = (users: AdminUser[] | undefined, removedId: string) => {
	if (!users) {
		return []
	}

	return users.filter(user => user.id !== removedId)
}

export function useAdminUsersQuery() {
	return useQuery({
		queryKey: ADMIN_USERS_QUERY_KEY,
		queryFn: getAdminUsers,
	})
}

export function useUpdateAdminUserRoleMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: UpdateAdminUserRoleInput) => updateAdminUserRole(input),
		onSuccess: updatedUser => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				upsertUserInCache(users, updatedUser),
			)
		},
	})
}

export function useCreateAdminUserMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: CreateAdminUserInput) => createAdminUser(input),
		onSuccess: updatedUser => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				upsertUserInCache(users, updatedUser),
			)
		},
	})
}

export function useDeleteAdminUserMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (userId: string) => deleteAdminUser(userId),
		onSuccess: ({ id }) => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				removeUserFromCache(users, id),
			)
		},
	})
}

export function useAdminUsers() {
	const usersQuery = useAdminUsersQuery()
	const roleMutation = useUpdateAdminUserRoleMutation()
	const createMutation = useCreateAdminUserMutation()
	const deleteUserMutation = useDeleteAdminUserMutation()

	return {
		users: usersQuery.data ?? [],
		isLoading: usersQuery.isLoading,
		isError: usersQuery.isError,
		error: usersQuery.error,
		refetch: usersQuery.refetch,
		updateRole: roleMutation.mutateAsync,
		createUser: createMutation.mutateAsync,
		deleteUser: deleteUserMutation.mutateAsync,
		isMutating:
			roleMutation.isPending ||
			createMutation.isPending ||
			deleteUserMutation.isPending,
	}
}
