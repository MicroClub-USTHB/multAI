export type AdminAuthRequest = {
	email: string
	password: string
}

export type AdminAuthResponse = {
	accessToken: string
	userId: string
	role: string
}

export type AdminProfile = {
	id: string
	email: string | null
	role: string
	createdAt: string
	updatedAt: string
}

type AdminAuthResponseApi = {
	access_token: string
	user_id: string
	role: string
}

type AdminProfileApi = {
	id: string
	email: string | null
	role: string
	created_at: string
	updated_at: string
}

export const toAdminAuthResponse = (input: AdminAuthResponseApi): AdminAuthResponse => ({
	accessToken: input.access_token,
	userId: input.user_id,
	role: input.role,
})

export const toAdminProfile = (input: AdminProfileApi): AdminProfile => ({
	id: input.id,
	email: input.email,
	role: input.role,
	createdAt: input.created_at,
	updatedAt: input.updated_at,
})
