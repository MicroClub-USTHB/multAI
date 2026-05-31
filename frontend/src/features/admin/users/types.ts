export type AdminUser = {
	id: string
	email: string
	displayName: string | null
	blocked: boolean
	createdAt: string
	updatedAt: string
}

export type AdminUserCreateInput = {
	email: string
	password: string
	displayName?: string | null
	blocked?: boolean
}

export type AdminUserUpdateInput = {
	email?: string | null
	displayName?: string | null
	blocked?: boolean | null
}

export type ListAdminUsersParams = {
	limit?: number
	offset?: number
}

type AdminUserApi = {
	id: string
	email: string
	display_name: string | null
	blocked: boolean
	created_at: string
	updated_at: string
}

type AdminUserCreatePayload = {
	email: string
	password: string
	display_name?: string | null
	blocked?: boolean
}

type AdminUserUpdatePayload = {
	email?: string | null
	display_name?: string | null
	blocked?: boolean | null
}

export const toAdminUser = (input: AdminUserApi): AdminUser => ({
	id: input.id,
	email: input.email,
	displayName: input.display_name,
	blocked: input.blocked,
	createdAt: input.created_at,
	updatedAt: input.updated_at,
})

export const toAdminUserCreatePayload = (
	input: AdminUserCreateInput,
): AdminUserCreatePayload => ({
	email: input.email,
	password: input.password,
	display_name: input.displayName ?? undefined,
	blocked: input.blocked,
})

export const toAdminUserUpdatePayload = (
	input: AdminUserUpdateInput,
): AdminUserUpdatePayload => ({
	email: input.email,
	display_name: input.displayName,
	blocked: input.blocked,
})
