export const ADMIN_USER_ROLES = ['admin', 'multi', 'user'] as const
export type AdminUserRole = (typeof ADMIN_USER_ROLES)[number]

export const ADMIN_USER_STATUSES = ['member', 'invited', 'suspended'] as const
export type AdminUserStatus = (typeof ADMIN_USER_STATUSES)[number]

export interface AdminUser {
	id: string
	fullName: string
	email: string
	role: AdminUserRole
	status: AdminUserStatus
	assignedEventsCount: number
	avatarUrl?: string | null
	lastActiveAt: string | null
	createdAt: string
}

export interface UpdateAdminUserRoleInput {
	userId: string
	role: AdminUserRole
}

export interface UpdateAdminUserStatusInput {
	userId: string
	status: AdminUserStatus
}

export interface AssignAdminUserToEventInput {
	userId: string
	eventName: string
}

