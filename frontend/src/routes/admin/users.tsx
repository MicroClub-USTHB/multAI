import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { useMemo, useState } from 'react'
import { z } from 'zod'

import type {
	ListStaffUsersParams,
	StaffRole,
	StaffUser,
	StaffUserCreateInput,
	StaffUserUpdateInput,
} from '@/features/admin/staff-users/types'
import type {
	AdminUser,
	AdminUserCreateInput,
	AdminUserUpdateInput,
} from '@/features/admin/users/types'

import { StaffUserConfirmDialog } from '@/features/admin/staff-users/components/staff-user-confirm-dialog'
import { StaffUserFormDialog } from '@/features/admin/staff-users/components/staff-user-form-dialog'
import { StaffUsersTable } from '@/features/admin/staff-users/components/staff-users-table'
import {
	STAFF_ROLE_LABELS,
	STAFF_ROLE_OPTIONS,
} from '@/features/admin/staff-users/constants'
import { useStaffUsers } from '@/features/admin/staff-users/hooks'
import { UserConfirmDialog } from '@/features/admin/users/components/user-confirm-dialog'
import { UserFormDialog } from '@/features/admin/users/components/user-form-dialog'
import { UsersTable } from '@/features/admin/users/components/users-table'
import { useAdminUsers } from '@/features/admin/users/hooks'
import {
	Alert,
	AlertDescription,
	AlertTitle,
	Button,
	Input,
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
	Tabs,
	TabsContent,
	TabsList,
	TabsTrigger,
} from '@/shared/ui'

type AdminUsersView = 'users' | 'staff'

type UserDialogState =
	| {
			mode: 'create'
	  }
	| {
			mode: 'edit'
			user: AdminUser
	  }
	| null

type StaffUserDialogState =
	| {
			mode: 'create'
	  }
	| {
			mode: 'edit'
			user: StaffUser
	  }
	| null

const USERS_PAGE_LIMIT = 20

const adminUsersSearchSchema = z.object({
	view: z.enum(['users', 'staff']).catch('users'),
})

const getErrorMessage = (error: unknown) =>
	error instanceof Error ? error.message : 'Unable to complete the action.'

export const Route = createFileRoute('/admin/users')({
	component: RouteComponent,
	validateSearch: adminUsersSearchSchema,
})

function RouteComponent() {
	const navigate = useNavigate()
	const { view } = Route.useSearch()

	const handleViewChange = (nextView: AdminUsersView) => {
		navigate({
			to: '/admin/users',
			search: { view: nextView },
			replace: true,
		})
	}

	return (
		<div className='flex-1 space-y-6 p-4 md:p-6'>
			<Tabs
				value={view}
				onValueChange={(nextView) =>
					handleViewChange(nextView as AdminUsersView)
				}
				className='w-full'
			>
				<div className='flex flex-col gap-4 md:flex-row md:items-end md:justify-between'>
					<div className='space-y-2'>
						<p className='text-muted-foreground text-sm font-medium uppercase tracking-[0.2em]'>
							Admin users
						</p>
						<h1 className='text-4xl font-bold tracking-tight'>Users</h1>
						<p className='text-muted-foreground max-w-2xl text-sm'>
							Manage end users and internal staff in one place. Switch between
							views without leaving the page.
						</p>
					</div>

					<TabsList
						variant='line'
						className='w-full justify-start p-0 md:w-auto'
					>
						<TabsTrigger value='users'>Users</TabsTrigger>
						<TabsTrigger value='staff'>Staff users</TabsTrigger>
					</TabsList>
				</div>

				<TabsContent value='users' keepMounted className='mt-0'>
					<UsersPanel />
				</TabsContent>

				<TabsContent value='staff' keepMounted className='mt-0'>
					<StaffUsersPanel />
				</TabsContent>
			</Tabs>
		</div>
	)
}

function UsersPanel() {
	const {
		users,
		isLoading,
		isError,
		error,
		refetch,
		isMutating,
		createUser,
		updateUser,
		deleteUser,
		blockUser,
		unblockUser,
	} = useAdminUsers()

	const [searchInput, setSearchInput] = useState('')
	const [appliedSearch, setAppliedSearch] = useState('')
	const [userDialog, setUserDialog] = useState<UserDialogState>(null)
	const [userToDelete, setUserToDelete] = useState<AdminUser | null>(null)
	const [actionError, setActionError] = useState<string | null>(null)

	const isBusy = isLoading || isMutating
	const filteredUsers = useMemo(() => {
		const normalizedSearch = appliedSearch.trim().toLowerCase()

		if (!normalizedSearch) {
			return users
		}

		return users.filter((user) => {
			const email = user.email.toLowerCase()
			const displayName = user.displayName?.toLowerCase() ?? ''
			const status = user.blocked ? 'blocked' : 'active'

			return (
				email.includes(normalizedSearch) ||
				displayName.includes(normalizedSearch) ||
				status.includes(normalizedSearch)
			)
		})
	}, [appliedSearch, users])

	const userDialogOpen = Boolean(userDialog)
	const userDialogMode = userDialog?.mode ?? 'create'
	const userDialogUser = userDialog?.mode === 'edit' ? userDialog.user : null
	const isSearchActive = Boolean(appliedSearch.trim())

	const openCreateDialog = () => {
		setActionError(null)
		setUserDialog({ mode: 'create' })
	}

	const openEditDialog = (user: AdminUser) => {
		setActionError(null)
		setUserDialog({ mode: 'edit', user })
	}

	const handleSubmitUser = async (
		input: AdminUserCreateInput | AdminUserUpdateInput,
	) => {
		setActionError(null)

		try {
			if (userDialog?.mode === 'edit' && userDialog.user) {
				await updateUser({
					userId: userDialog.user.id,
					input: input as AdminUserUpdateInput,
				})
				return
			}

			await createUser(input as AdminUserCreateInput)
		} catch (error) {
			setActionError(getErrorMessage(error))
			throw error
		}
	}

	const handleToggleBlocked = async (user: AdminUser) => {
		setActionError(null)

		try {
			if (user.blocked) {
				await unblockUser(user.id)
				return
			}

			await blockUser(user.id)
		} catch (error) {
			setActionError(getErrorMessage(error))
		}
	}

	const handleSearch = () => {
		setActionError(null)
		setAppliedSearch(searchInput)
	}

	const handleResetSearch = () => {
		setActionError(null)
		setSearchInput('')
		setAppliedSearch('')
	}

	const handleDeleteUser = async () => {
		if (!userToDelete) {
			return
		}

		setActionError(null)

		try {
			await deleteUser(userToDelete.id)
		} catch (error) {
			setActionError(getErrorMessage(error))
			throw error
		}
	}

	return (
		<div className='space-y-6'>
			<div className='grid gap-3 rounded-lg border border-border/60 bg-card/50 p-4 lg:grid-cols-[1.5fr_auto_auto] lg:items-end'>
				<div className='grid gap-2'>
					<label className='text-sm font-medium' htmlFor='users-search'>
						Search
					</label>
					<Input
						id='users-search'
						value={searchInput}
						onChange={(event) => setSearchInput(event.target.value)}
						placeholder='Search by email, display name, or status'
						onKeyDown={(event) => {
							if (event.key === 'Enter') {
								event.preventDefault()
								handleSearch()
							}
						}}
						disabled={isBusy}
					/>
				</div>

				<div className='flex gap-2'>
					<Button variant='outline' onClick={handleSearch} disabled={isBusy}>
						Search
					</Button>
					<Button variant='ghost' onClick={handleResetSearch} disabled={isBusy}>
						Reset
					</Button>
				</div>

				<div className='flex flex-wrap gap-2 lg:justify-end'>
					<Button
						variant='outline'
						onClick={() => {
							void refetch()
						}}
						disabled={isBusy}
					>
						Refresh
					</Button>
					<Button onClick={openCreateDialog} disabled={isBusy}>
						Create user
					</Button>
				</div>
			</div>

			{actionError ? (
				<Alert variant='destructive'>
					<AlertTitle>Action failed</AlertTitle>
					<AlertDescription>{actionError}</AlertDescription>
				</Alert>
			) : null}

			{isError ? (
				<div className='border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm'>
					{error instanceof Error ? error.message : 'Unable to load users.'}
				</div>
			) : isLoading ? (
				<div className='text-muted-foreground text-sm'>Loading users...</div>
			) : (
				<div className='space-y-3'>
					<div className='text-muted-foreground flex flex-wrap items-center justify-between gap-2 text-sm'>
						<p>
							Showing {filteredUsers.length} of {users.length} loaded users
							{isSearchActive ? ` for "${appliedSearch}"` : ''}
						</p>
						{isSearchActive ? (
							<p className='text-xs uppercase tracking-[0.2em]'>
								Filtered view
							</p>
						) : null}
					</div>
					<div className='border-border/40 overflow-hidden rounded-md border'>
						{filteredUsers.length ? (
							<UsersTable
								users={filteredUsers}
								isBusy={isBusy}
								onEdit={openEditDialog}
								onDelete={(user) => setUserToDelete(user)}
								onToggleBlocked={(user) => {
									void handleToggleBlocked(user)
								}}
							/>
						) : (
							<div className='text-muted-foreground flex h-24 items-center justify-center text-sm'>
								{isSearchActive
									? `No users match "${appliedSearch}".`
									: 'No users found.'}
							</div>
						)}
					</div>
				</div>
			)}

			<UserFormDialog
				open={userDialogOpen}
				mode={userDialogMode}
				user={userDialogUser}
				isSubmitting={isMutating}
				onOpenChange={(open) => {
					if (!open) {
						setUserDialog(null)
					}
				}}
				onSubmit={handleSubmitUser}
			/>

			<UserConfirmDialog
				open={Boolean(userToDelete)}
				title='Delete user'
				description={
					<span>
						This will permanently delete{' '}
						<strong>{userToDelete?.email ?? 'this user'}</strong> from the
						admin users list.
					</span>
				}
				confirmLabel='Delete user'
				isSubmitting={isMutating}
				onOpenChange={(open) => {
					if (!open) {
						setUserToDelete(null)
					}
				}}
				onConfirm={handleDeleteUser}
			/>
		</div>
	)
}

function StaffUsersPanel() {
	const [searchInput, setSearchInput] = useState('')
	const [appliedSearch, setAppliedSearch] = useState('')
	const [roleFilter, setRoleFilter] = useState<'all' | StaffRole>('all')
	const [sortBy, setSortBy] = useState<'created_at' | 'email'>('created_at')
	const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc')
	const [pageOffset, setPageOffset] = useState(0)
	const [dialogState, setDialogState] = useState<StaffUserDialogState>(null)
	const [staffUserToDelete, setStaffUserToDelete] = useState<StaffUser | null>(
		null,
	)
	const [actionError, setActionError] = useState<string | null>(null)

	const queryParams = useMemo<ListStaffUsersParams>(
		() => ({
			limit: USERS_PAGE_LIMIT,
			offset: pageOffset,
			search: appliedSearch.trim() || undefined,
			role: roleFilter === 'all' ? undefined : roleFilter,
			sortBy,
			sortDirection,
		}),
		[appliedSearch, pageOffset, roleFilter, sortBy, sortDirection],
	)

	const {
		users,
		isLoading,
		isError,
		error,
		refetch,
		createUser,
		updateUser,
		deleteUser,
		isMutating,
	} = useStaffUsers(queryParams)

	const isBusy = isLoading || isMutating
	const hasNextPage = users.length === USERS_PAGE_LIMIT
	const currentPage = Math.floor(pageOffset / USERS_PAGE_LIMIT) + 1
	const totalShownLabel =
		users.length > 0
			? `${pageOffset + 1}-${pageOffset + users.length}`
			: '0'

	const openCreateDialog = () => {
		setActionError(null)
		setDialogState({ mode: 'create' })
	}

	const openEditDialog = (user: StaffUser) => {
		setActionError(null)
		setDialogState({ mode: 'edit', user })
	}

	const handleSearch = () => {
		setPageOffset(0)
		setAppliedSearch(searchInput)
	}

	const handleReset = () => {
		setActionError(null)
		setSearchInput('')
		setAppliedSearch('')
		setRoleFilter('all')
		setSortBy('created_at')
		setSortDirection('desc')
		setPageOffset(0)
	}

	const handleSubmitStaffUser = async (
		input: StaffUserCreateInput | StaffUserUpdateInput,
	) => {
		setActionError(null)

		try {
			if (dialogState?.mode === 'edit' && dialogState.user) {
				await updateUser({
					staffUserId: dialogState.user.id,
					input: input as StaffUserUpdateInput,
				})
				return
			}

			await createUser(input as StaffUserCreateInput)
		} catch (error) {
			setActionError(getErrorMessage(error))
			throw error
		}
	}

	const handleDeleteStaffUser = async () => {
		if (!staffUserToDelete) {
			return
		}

		setActionError(null)

		try {
			await deleteUser(staffUserToDelete.id)
		} catch (error) {
			setActionError(getErrorMessage(error))
			throw error
		}
	}

	return (
		<div className='space-y-6'>
			<div className='flex flex-wrap items-center justify-between gap-3'>
				<p className='text-muted-foreground text-sm'>
					Internal staff from{' '}
					<span className='font-mono'>/admin/staff-users</span>
				</p>
				<div className='flex flex-wrap gap-2'>
					<Button
						variant='outline'
						onClick={() => {
							void refetch()
						}}
						disabled={isBusy}
					>
						Refresh
					</Button>
					<Button onClick={openCreateDialog} disabled={isBusy}>
						Create staff user
					</Button>
				</div>
			</div>

			<div className='grid gap-3 rounded-lg border border-border/60 bg-card/50 p-4 lg:grid-cols-[1.5fr_0.8fr_0.8fr_auto] lg:items-end'>
				<div className='grid gap-2'>
					<label className='text-sm font-medium' htmlFor='staff-search'>
						Search
					</label>
					<Input
						id='staff-search'
						value={searchInput}
						onChange={(event) => setSearchInput(event.target.value)}
						placeholder='Search by email'
						onKeyDown={(event) => {
							if (event.key === 'Enter') {
								event.preventDefault()
								handleSearch()
							}
						}}
						disabled={isBusy}
					/>
				</div>

				<div className='grid gap-2'>
					<label className='text-sm font-medium' htmlFor='staff-role-filter'>
						Role
					</label>
					<Select
						value={roleFilter}
						onValueChange={(value) => {
							setRoleFilter(value as 'all' | StaffRole)
							setPageOffset(0)
						}}
					>
						<SelectTrigger id='staff-role-filter' className='w-full'>
							<SelectValue />
						</SelectTrigger>
						<SelectContent>
							<SelectItem value='all'>All roles</SelectItem>
							{STAFF_ROLE_OPTIONS.map((option) => (
								<SelectItem key={option} value={option}>
									{STAFF_ROLE_LABELS[option]}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</div>

				<div className='grid gap-2'>
					<label className='text-sm font-medium' htmlFor='staff-sort'>
						Sort
					</label>
					<div className='grid grid-cols-2 gap-2'>
						<Select
							value={sortBy}
							onValueChange={(value) => {
								setSortBy(value as 'created_at' | 'email')
								setPageOffset(0)
							}}
						>
							<SelectTrigger id='staff-sort' className='w-full'>
								<SelectValue />
							</SelectTrigger>
							<SelectContent>
								<SelectItem value='created_at'>Created</SelectItem>
								<SelectItem value='email'>Email</SelectItem>
							</SelectContent>
						</Select>
						<Select
							value={sortDirection}
							onValueChange={(value) => {
								setSortDirection(value as 'asc' | 'desc')
								setPageOffset(0)
							}}
						>
							<SelectTrigger className='w-full'>
								<SelectValue />
							</SelectTrigger>
							<SelectContent>
								<SelectItem value='desc'>Newest first</SelectItem>
								<SelectItem value='asc'>Oldest first</SelectItem>
							</SelectContent>
						</Select>
					</div>
				</div>

				<div className='flex gap-2'>
					<Button variant='outline' onClick={handleSearch} disabled={isBusy}>
						Search
					</Button>
					<Button variant='ghost' onClick={handleReset} disabled={isBusy}>
						Reset
					</Button>
				</div>
			</div>

			{actionError ? (
				<Alert variant='destructive'>
					<AlertTitle>Action failed</AlertTitle>
					<AlertDescription>{actionError}</AlertDescription>
				</Alert>
			) : null}

			{isError ? (
				<div className='border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm'>
					{error instanceof Error
						? error.message
						: 'Unable to load staff users.'}
				</div>
			) : isLoading ? (
				<div className='text-muted-foreground text-sm'>
					Loading staff users...
				</div>
			) : (
				<div className='border-border/40 overflow-hidden rounded-md border'>
					<StaffUsersTable
						users={users}
						isBusy={isBusy}
						onEdit={openEditDialog}
						onDelete={(user) => setStaffUserToDelete(user)}
					/>
				</div>
			)}

			<div className='text-muted-foreground flex items-center justify-between text-sm'>
				<p>
					Showing {totalShownLabel} staff users
					{appliedSearch ? ` for "${appliedSearch}"` : ''}
				</p>
				<div className='flex items-center gap-2'>
					<Button
						variant='outline'
						size='sm'
						disabled={isBusy || pageOffset === 0}
						onClick={() =>
							setPageOffset((offset) => Math.max(0, offset - USERS_PAGE_LIMIT))
						}
					>
						Previous
					</Button>
					<span>Page {currentPage}</span>
					<Button
						variant='outline'
						size='sm'
						disabled={isBusy || !hasNextPage}
						onClick={() => setPageOffset((offset) => offset + USERS_PAGE_LIMIT)}
					>
						Next
					</Button>
				</div>
			</div>

			<StaffUserFormDialog
				open={Boolean(dialogState)}
				mode={dialogState?.mode ?? 'create'}
				user={dialogState?.mode === 'edit' ? dialogState.user : null}
				isSubmitting={isMutating}
				onOpenChange={(open) => {
					if (!open) {
						setDialogState(null)
					}
				}}
				onSubmit={handleSubmitStaffUser}
			/>

			<StaffUserConfirmDialog
				open={Boolean(staffUserToDelete)}
				title='Delete staff user'
				description={
					<span>
						This will permanently delete{' '}
						<strong>{staffUserToDelete?.email ?? 'this staff user'}</strong>.
					</span>
				}
				confirmLabel='Delete staff user'
				isSubmitting={isMutating}
				onOpenChange={(open) => {
					if (!open) {
						setStaffUserToDelete(null)
					}
				}}
				onConfirm={handleDeleteStaffUser}
			/>
		</div>
	)
}
