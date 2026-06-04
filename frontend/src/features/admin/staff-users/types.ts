export type StaffRole = 'admin' | 'multi_team_lead' | 'multi'

export type StaffUser = {
	id: string
	email: string | null
	role: StaffRole
	createdAt: string
	updatedAt: string
}

export type StaffUserCreateInput = {
	email: string | null
	password: string
	role: StaffRole
}

export type StaffUserUpdateInput = {
	email: string | null
	role: StaffRole
}

export type ListStaffUsersParams = {
	limit?: number
	offset?: number
	search?: string | null
	role?: StaffRole | null
	sortBy?: 'created_at' | 'email'
	sortDirection?: 'asc' | 'desc'
}

type StaffUserApi = {
	id: string
	email: string | null
	role: StaffRole
	created_at: string
	updated_at: string
}

type StaffUserCreatePayload = {
	email: string | null
	password: string
	role: StaffRole
}

type StaffUserUpdatePayload = {
	email: string | null
	role: StaffRole
}

export const toStaffUser = (input: StaffUserApi): StaffUser => ({
	id: input.id,
	email: input.email,
	role: input.role,
	createdAt: input.created_at,
	updatedAt: input.updated_at,
})

export const toStaffUserCreatePayload = (
	input: StaffUserCreateInput,
): StaffUserCreatePayload => ({
	email: input.email,
	password: input.password,
	role: input.role,
})

export const toStaffUserUpdatePayload = (
	input: StaffUserUpdateInput,
): StaffUserUpdatePayload => ({
	email: input.email,
	role: input.role,
})
