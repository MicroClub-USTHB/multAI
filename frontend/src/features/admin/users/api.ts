import type {
	AdminUser,
	AssignAdminUserToEventInput,
	UpdateAdminUserRoleInput,
	UpdateAdminUserStatusInput,
} from './types'

const MOCK_LATENCY_MS = 350

let mockUsers: AdminUser[] = [
	{
		id: 'usr-001',
		fullName: 'Aya Bensalem',
		email: 'aya@multai.app',
		role: 'admin',
		status: 'member',
		assignedEventsCount: 0,
		avatarUrl: null,
		lastActiveAt: '2026-03-19T08:45:00.000Z',
		createdAt: '2025-11-04T10:25:00.000Z',
	},
	{
		id: 'usr-002',
		fullName: 'Yacine Kaci',
		email: 'yacine@multai.app',
		role: 'multi',
		status: 'member',
		assignedEventsCount: 5,
		avatarUrl: null,
		lastActiveAt: '2026-03-18T19:18:00.000Z',
		createdAt: '2025-10-10T09:00:00.000Z',
	},
	{
		id: 'usr-003',
		fullName: 'Lina Boudiaf',
		email: 'lina@multai.app',
		role: 'user',
		status: 'invited',
		assignedEventsCount: 0,
		avatarUrl: null,
		lastActiveAt: null,
		createdAt: '2026-03-12T13:20:00.000Z',
	},
	{
		id: 'usr-004',
		fullName: 'Anis Merabet',
		email: 'anis@multai.app',
		role: 'user',
		status: 'suspended',
		assignedEventsCount: 0,
		avatarUrl: null,
		lastActiveAt: '2026-02-28T11:00:00.000Z',
		createdAt: '2025-12-01T08:45:00.000Z',
	},
	{
		id: 'usr-005',
		fullName: 'Sofia Messaoudi',
		email: 'sofia@multai.app',
		role: 'multi',
		status: 'member',
		assignedEventsCount: 3,
		avatarUrl: null,
		lastActiveAt: '2026-03-19T06:10:00.000Z',
		createdAt: '2025-11-20T15:30:00.000Z',
	},
]

const sleep = (ms: number) =>
	new Promise(resolve => {
		setTimeout(resolve, ms)
	})

const cloneUser = (user: AdminUser): AdminUser => ({ ...user })

const cloneUsers = (): AdminUser[] => mockUsers.map(cloneUser)

const findUserIndex = (userId: string) =>
	mockUsers.findIndex(user => user.id === userId)

const getUserOrThrow = (userId: string) => {
	const index = findUserIndex(userId)

	if (index === -1) {
		throw new Error('User not found')
	}

	return { index, user: mockUsers[index] }
}

export async function getAdminUsers(): Promise<AdminUser[]> {
	await sleep(MOCK_LATENCY_MS)

	return cloneUsers().sort((a, b) => a.fullName.localeCompare(b.fullName))
}

export async function updateAdminUserRole(
	input: UpdateAdminUserRoleInput,
): Promise<AdminUser> {
	await sleep(MOCK_LATENCY_MS)

	const { index, user } = getUserOrThrow(input.userId)
	const updatedUser: AdminUser = {
		...user,
		role: input.role,
	}

	mockUsers[index] = updatedUser
	return cloneUser(updatedUser)
}

export async function updateAdminUserStatus(
	input: UpdateAdminUserStatusInput,
): Promise<AdminUser> {
	await sleep(MOCK_LATENCY_MS)

	const { index, user } = getUserOrThrow(input.userId)
	const updatedUser: AdminUser = {
		...user,
		status: input.status,
		lastActiveAt:
			input.status === 'member'
				? user.lastActiveAt ?? new Date().toISOString()
				: user.lastActiveAt,
	}

	mockUsers[index] = updatedUser
	return cloneUser(updatedUser)
}

export async function resendAdminUserInvite(userId: string): Promise<AdminUser> {
	await sleep(MOCK_LATENCY_MS)

	const { index, user } = getUserOrThrow(userId)
	const updatedUser: AdminUser = {
		...user,
		status: 'invited',
	}

	mockUsers[index] = updatedUser
	return cloneUser(updatedUser)
}

export async function assignAdminUserToNewEvent(
	input: AssignAdminUserToEventInput,
): Promise<AdminUser> {
	await sleep(MOCK_LATENCY_MS)
	const eventName = input.eventName.trim()

	if (eventName.length < 3) {
		throw new Error('Event name must contain at least 3 characters')
	}

	const { index, user } = getUserOrThrow(input.userId)

	if (user.role !== 'multi') {
		throw new Error('Only multi users can be assigned to new events')
	}

	const updatedUser: AdminUser = {
		...user,
		status: 'member',
		assignedEventsCount: user.assignedEventsCount + 1,
		lastActiveAt: new Date().toISOString(),
	}

	mockUsers[index] = updatedUser
	return cloneUser(updatedUser)
}

