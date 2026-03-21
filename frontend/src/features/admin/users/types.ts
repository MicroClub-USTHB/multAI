export const ADMIN_USER_ROLES = ['admin', 'multi_team_lead', 'multi'] as const
export type AdminUserRole = (typeof ADMIN_USER_ROLES)[number]

export const ADMIN_USER_EDITABLE_ROLES = ['multi_team_lead', 'multi'] as const
export type EditableAdminUserRole = (typeof ADMIN_USER_EDITABLE_ROLES)[number]

export interface AdminUser {
	id: string
	fullName: string
	email: string
	role: AdminUserRole
	avatarUrl?: string | null
	createdAt: string
	updatedAt: string
}

export interface CreateAdminUserInput {
	email: string
	password: string
	role: EditableAdminUserRole
}

export interface UpdateAdminUserRoleInput {
	userId: string
	role: EditableAdminUserRole
	email: string | null
}

