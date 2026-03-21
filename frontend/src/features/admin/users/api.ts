import type {
	AdminUser,
	CreateAdminUserInput,
	EditableAdminUserRole,
	UpdateAdminUserRoleInput,
} from './types'

type StaffRole = 'admin' | 'multi_team_lead' | 'multi'

type StaffUserSchema = {
	id: string
	email: string | null
	role: StaffRole
	created_at: string
	updated_at: string
}

const API_BASE_URL =
	(import.meta.env.VITE_API_BASE_URL as string | undefined) ??
	'http://localhost:8000'

export class AdminUsersApiError extends Error {
	status: number

	constructor(message: string, status: number) {
		super(message)
		this.name = 'AdminUsersApiError'
		this.status = status
	}
}

function getAuthToken() {
	if (typeof window === 'undefined') {
		return null
	}

	return (
		window.localStorage.getItem('admin_access_token') ??
		window.localStorage.getItem('adminToken') ??
		window.localStorage.getItem('access_token') ??
		window.localStorage.getItem('token') ??
		window.sessionStorage.getItem('admin_access_token') ??
		window.sessionStorage.getItem('access_token')
	)
}

function ensureAccessTokenCookie(token: string | null) {
	if (typeof document === 'undefined' || !token) {
		return
	}

	const encoded = encodeURIComponent(token)
	if (document.cookie.includes(`access_token=${encoded}`)) {
		return
	}

	document.cookie = `access_token=${encoded}; path=/; SameSite=Lax`
}

function buildHeaders(extra?: Record<string, string>) {
	const token = getAuthToken()

	return {
		...(token ? { Authorization: `Bearer ${token}` } : {}),
		...(extra ?? {}),
	}
}

async function requestJson<T>(path: string, init?: RequestInit): Promise<T> {
	const token = getAuthToken()
	ensureAccessTokenCookie(token)

	const response = await fetch(`${API_BASE_URL}${path}`, {
		...init,
		credentials: 'include',
		headers: {
			...buildHeaders(),
			...(init?.headers ?? {}),
		},
	})

	if (!response.ok) {
		const fallback = `Request failed (${response.status})`
		let message = fallback
		try {
			const data = (await response.json()) as { detail?: unknown }
			if (typeof data.detail === 'string') {
				message = data.detail
			}
		} catch {
			// Ignore parse errors and keep a generic message.
		}
		if (response.status === 401) {
			throw new AdminUsersApiError(
				'Session admin invalide ou absente. Connecte-toi puis reessaie.',
				401,
			)
		}

		throw new AdminUsersApiError(message, response.status)
	}

	if (response.status === 204) {
		return undefined as T
	}

	return (await response.json()) as T
}

function roleFromApi(role: StaffRole): AdminUser['role'] {
	return role
}

function roleToApi(role: EditableAdminUserRole): Exclude<StaffRole, 'admin'> {
	return role
}

function emailToFullName(email: string | null): string {
	if (!email) {
		return 'Unknown user'
	}

	const username = email.split('@')[0] ?? 'user'
	return username
		.split(/[._-]/g)
		.filter(Boolean)
		.map(part => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
		.join(' ')
}

function mapStaffUserToAdminUser(user: StaffUserSchema): AdminUser {
	return {
		id: user.id,
		fullName: emailToFullName(user.email),
		email: user.email ?? '',
		role: roleFromApi(user.role),
		avatarUrl: null,
		createdAt: user.created_at,
		updatedAt: user.updated_at,
	}
}

export async function getAdminUsers(): Promise<AdminUser[]> {
	const users = await requestJson<StaffUserSchema[]>('/admin/staff-users/')

	return users
		.map(mapStaffUserToAdminUser)
		.sort((a, b) => a.fullName.localeCompare(b.fullName))
}

export async function updateAdminUserRole(
	input: UpdateAdminUserRoleInput,
): Promise<AdminUser> {
	const current = await requestJson<StaffUserSchema>(
		`/admin/staff-users/${input.userId}`,
		{
			method: 'PATCH',
			headers: buildHeaders({
				'Content-Type': 'application/json',
			}),
			body: JSON.stringify({
				email: input.email ?? null,
				role: roleToApi(input.role),
			}),
		},
	)

	return mapStaffUserToAdminUser(current)
}

export async function createAdminUser(
	input: CreateAdminUserInput,
): Promise<AdminUser> {
	const created = await requestJson<StaffUserSchema>('/admin/staff-users/', {
		method: 'POST',
		headers: buildHeaders({
			'Content-Type': 'application/json',
		}),
		body: JSON.stringify({
			email: input.email,
			password: input.password,
			role: roleToApi(input.role),
		}),
	})

	return mapStaffUserToAdminUser(created)
}

export async function deleteAdminUser(userId: string): Promise<{ id: string }> {
	await requestJson<StaffUserSchema>(`/admin/staff-users/${userId}`, {
		method: 'DELETE',
		headers: buildHeaders(),
	})

	return { id: userId }
}

