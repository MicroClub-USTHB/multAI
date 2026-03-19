import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
	assignAdminUserToNewEvent,
	getAdminUsers,
	resendAdminUserInvite,
	updateAdminUserRole,
	updateAdminUserStatus,
} from './api'
import type {
	AdminUser,
	AssignAdminUserToEventInput,
	UpdateAdminUserRoleInput,
	UpdateAdminUserStatusInput,
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

export function useUpdateAdminUserStatusMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: UpdateAdminUserStatusInput) => updateAdminUserStatus(input),
		onSuccess: updatedUser => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				upsertUserInCache(users, updatedUser),
			)
		},
	})
}

export function useResendAdminUserInviteMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (userId: string) => resendAdminUserInvite(userId),
		onSuccess: updatedUser => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				upsertUserInCache(users, updatedUser),
			)
		},
	})
}

export function useAssignAdminUserToNewEventMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: AssignAdminUserToEventInput) =>
			assignAdminUserToNewEvent(input),
		onSuccess: updatedUser => {
			queryClient.setQueryData<AdminUser[]>(ADMIN_USERS_QUERY_KEY, users =>
				upsertUserInCache(users, updatedUser),
			)
		},
	})
}

export function useAdminUsers() {
	const usersQuery = useAdminUsersQuery()
	const roleMutation = useUpdateAdminUserRoleMutation()
	const statusMutation = useUpdateAdminUserStatusMutation()
	const inviteMutation = useResendAdminUserInviteMutation()
	const assignEventMutation = useAssignAdminUserToNewEventMutation()

	return {
		users: usersQuery.data ?? [],
		isLoading: usersQuery.isLoading,
		isError: usersQuery.isError,
		error: usersQuery.error,
		refetch: usersQuery.refetch,
		updateRole: roleMutation.mutateAsync,
		updateStatus: statusMutation.mutateAsync,
		resendInvite: inviteMutation.mutateAsync,
		assignNewEvent: assignEventMutation.mutateAsync,
		isMutating:
			roleMutation.isPending ||
			statusMutation.isPending ||
			inviteMutation.isPending ||
			assignEventMutation.isPending,
	}
}

