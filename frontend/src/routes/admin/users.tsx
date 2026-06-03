import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'

import type {
	AdminUser,
	AdminUserCreateInput,
	AdminUserUpdateInput,
} from '@/features/admin/users/types'

import { UserConfirmDialog } from '@/features/admin/users/components/user-confirm-dialog'
import { UserFormDialog } from '@/features/admin/users/components/user-form-dialog'
import { UsersTable } from '@/features/admin/users/components/users-table'
import { useAdminUsers } from '@/features/admin/users/hooks'
import { Alert, AlertDescription, AlertTitle, Button } from '@/shared/ui'

type UserDialogState =
	| {
			mode: 'create'
	  }
	| {
			mode: 'edit'
			user: AdminUser
	  }
	| null

export const Route = createFileRoute('/admin/users')({
	component: RouteComponent,
})

const getErrorMessage = (error: unknown) =>
	error instanceof Error ? error.message : 'Unable to complete the action.'

function RouteComponent() {
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

	const [userDialog, setUserDialog] = useState<UserDialogState>(null)
	const [userToDelete, setUserToDelete] = useState<AdminUser | null>(null)
	const [actionError, setActionError] = useState<string | null>(null)

	const isBusy = isLoading || isMutating
	const userDialogOpen = Boolean(userDialog)
	const userDialogMode = userDialog?.mode ?? 'create'
	const userDialogUser = userDialog?.mode === 'edit' ? userDialog.user : null

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
		<div className='flex-1 space-y-6 p-4 md:p-6'>
			<div className='flex flex-col gap-3 md:flex-row md:items-end md:justify-between'>
				<div className='space-y-2'>
					<p className='text-muted-foreground text-sm font-medium uppercase tracking-[0.2em]'>
						Admin users
					</p>
					<h1 className='text-4xl font-bold tracking-tight'>Users</h1>
					<p className='text-muted-foreground max-w-2xl text-sm'>
						Manage end users from the `/admin/users` endpoints. Create accounts,
						edit access state, block abuse, or remove records.
					</p>
				</div>

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
				<div className='border-border/40 overflow-hidden rounded-md border'>
					<UsersTable
						users={users}
						isBusy={isBusy}
						onEdit={openEditDialog}
						onDelete={(user) => setUserToDelete(user)}
						onToggleBlocked={(user) => {
							void handleToggleBlocked(user)
						}}
					/>
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
