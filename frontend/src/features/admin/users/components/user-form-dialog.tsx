import type React from 'react'

import { useEffect, useState } from 'react'

import { Button } from '@/shared/ui'
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
	Input,
} from '@/shared/ui'
import { Checkbox } from '@/shared/ui/checkbox'
import { Label } from '@/shared/ui/label'

import type {
	AdminUser,
	AdminUserCreateInput,
	AdminUserUpdateInput,
} from '../types'

type UserDialogMode = 'create' | 'edit'

interface UserFormDialogProps {
	open: boolean
	mode: UserDialogMode
	user?: AdminUser | null
	isSubmitting?: boolean
	onOpenChange: (open: boolean) => void
	onSubmit: (
		input: AdminUserCreateInput | AdminUserUpdateInput,
	) => Promise<void>
}

const getInitialState = (mode: UserDialogMode, user?: AdminUser | null) => ({
	email: user?.email ?? '',
	password: '',
	displayName: user?.displayName ?? '',
	blocked: user?.blocked ?? false,
	mode,
})

export function UserFormDialog({
	open,
	mode,
	user,
	isSubmitting = false,
	onOpenChange,
	onSubmit,
}: UserFormDialogProps) {
	const [email, setEmail] = useState('')
	const [password, setPassword] = useState('')
	const [displayName, setDisplayName] = useState('')
	const [blocked, setBlocked] = useState(false)

	useEffect(() => {
		if (!open) {
			return
		}

		const initialState = getInitialState(mode, user)
		setEmail(initialState.email)
		setPassword(initialState.password)
		setDisplayName(initialState.displayName)
		setBlocked(initialState.blocked)
	}, [mode, open, user?.blocked, user?.displayName, user?.email, user?.id])

	const isCreate = mode === 'create'
	const title = isCreate ? 'Create user' : 'Edit user'
	const description = isCreate
		? 'Create a new admin user account with login credentials.'
		: 'Update the selected user profile and access state.'

	const handleClose = (nextOpen: boolean) => {
		onOpenChange(nextOpen)

		if (!nextOpen) {
			const initialState = getInitialState(mode, user)
			setEmail(initialState.email)
			setPassword(initialState.password)
			setDisplayName(initialState.displayName)
			setBlocked(initialState.blocked)
		}
	}

	const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
		event.preventDefault()

		if (isCreate) {
			await onSubmit({
				email: email.trim(),
				password,
				displayName: displayName.trim() || null,
				blocked,
			} satisfies AdminUserCreateInput)
		} else {
			await onSubmit({
				email: email.trim() || null,
				displayName: displayName.trim() || null,
				blocked,
			} satisfies AdminUserUpdateInput)
		}

		handleClose(false)
	}

	return (
		<Dialog open={open} onOpenChange={handleClose}>
			<DialogContent className='sm:max-w-lg'>
				<form className='space-y-5' onSubmit={handleSubmit}>
					<DialogHeader>
						<DialogTitle>{title}</DialogTitle>
						<DialogDescription>{description}</DialogDescription>
					</DialogHeader>

					<div className='grid gap-4'>
						<div className='grid gap-2'>
							<Label htmlFor='user-email'>Email</Label>
							<Input
								id='user-email'
								type='email'
								autoComplete='email'
								value={email}
								onChange={(event) => setEmail(event.target.value)}
								required
								disabled={isSubmitting}
								placeholder='admin@company.com'
							/>
						</div>

						<div className='grid gap-2'>
							<Label htmlFor='user-display-name'>Display name</Label>
							<Input
								id='user-display-name'
								type='text'
								autoComplete='nickname'
								value={displayName}
								onChange={(event) => setDisplayName(event.target.value)}
								disabled={isSubmitting}
								placeholder='Jane Doe'
							/>
						</div>

						{isCreate ? (
							<div className='grid gap-2'>
								<Label htmlFor='user-password'>Password</Label>
								<Input
									id='user-password'
									type='password'
									autoComplete='new-password'
									minLength={8}
									value={password}
									onChange={(event) => setPassword(event.target.value)}
									required
									disabled={isSubmitting}
								/>
								<p className='text-muted-foreground text-xs'>
									Use at least 8 characters.
								</p>
							</div>
						) : null}

						<div className='flex items-start gap-3 rounded-lg border border-border/70 bg-muted/20 px-3 py-2'>
							<Checkbox
								id='user-blocked'
								checked={blocked}
								onCheckedChange={(value) => setBlocked(Boolean(value))}
								disabled={isSubmitting}
							/>
							<div className='grid gap-1'>
								<Label htmlFor='user-blocked'>Blocked</Label>
								<p className='text-muted-foreground text-xs'>
									Blocked users cannot authenticate until they are unblocked.
								</p>
							</div>
						</div>
					</div>

					<DialogFooter>
						<Button
							type='button'
							variant='outline'
							onClick={() => handleClose(false)}
							disabled={isSubmitting}
						>
							Cancel
						</Button>
						<Button type='submit' isLoading={isSubmitting}>
							{isCreate ? 'Create user' : 'Save changes'}
						</Button>
					</DialogFooter>
				</form>
			</DialogContent>
		</Dialog>
	)
}
