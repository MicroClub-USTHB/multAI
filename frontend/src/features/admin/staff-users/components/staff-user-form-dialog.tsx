import type React from 'react'

import { useEffect, useState } from 'react'

import { Button, Input, Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui'
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from '@/shared/ui'
import { Label } from '@/shared/ui/label'

import type {
	StaffRole,
	StaffUser,
	StaffUserCreateInput,
	StaffUserUpdateInput,
} from '../types'

import {
	STAFF_ROLE_LABELS,
	STAFF_ROLE_OPTIONS,
} from '../constants'

type StaffUserDialogMode = 'create' | 'edit'

interface StaffUserFormDialogProps {
	open: boolean
	mode: StaffUserDialogMode
	user?: StaffUser | null
	isSubmitting?: boolean
	onOpenChange: (open: boolean) => void
	onSubmit: (
		input: StaffUserCreateInput | StaffUserUpdateInput,
	) => Promise<void>
}

const getInitialState = (mode: StaffUserDialogMode, user?: StaffUser | null) => ({
	email: user?.email ?? '',
	password: '',
	role: user?.role ?? 'multi',
	mode,
})

export function StaffUserFormDialog({
	open,
	mode,
	user,
	isSubmitting = false,
	onOpenChange,
	onSubmit,
}: StaffUserFormDialogProps) {
	const [email, setEmail] = useState('')
	const [password, setPassword] = useState('')
	const [role, setRole] = useState<StaffRole>('multi')

	useEffect(() => {
		if (!open) {
			return
		}

		const initialState = getInitialState(mode, user)
		setEmail(initialState.email)
		setPassword(initialState.password)
		setRole(initialState.role)
	}, [mode, open, user?.email, user?.id, user?.role])

	const isCreate = mode === 'create'
	const title = isCreate ? 'Create staff user' : 'Edit staff user'
	const description = isCreate
		? 'Create an internal staff account with the proper access role.'
		: 'Update the staff account email or role.'

	const handleClose = (nextOpen: boolean) => {
		onOpenChange(nextOpen)

		if (!nextOpen) {
			const initialState = getInitialState(mode, user)
			setEmail(initialState.email)
			setPassword(initialState.password)
			setRole(initialState.role)
		}
	}

	const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
		event.preventDefault()

		if (isCreate) {
			await onSubmit({
				email: email.trim() || null,
				password,
				role,
			} satisfies StaffUserCreateInput)
		} else {
			await onSubmit({
				email: email.trim() || null,
				role,
			} satisfies StaffUserUpdateInput)
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
							<Label htmlFor='staff-email'>Email</Label>
							<Input
								id='staff-email'
								type='email'
								autoComplete='email'
								value={email}
								onChange={(event) => setEmail(event.target.value)}
								disabled={isSubmitting}
								placeholder='staff@company.com'
							/>
						</div>

						{isCreate ? (
							<div className='grid gap-2'>
								<Label htmlFor='staff-password'>Password</Label>
								<Input
									id='staff-password'
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

						<div className='grid gap-2'>
							<Label htmlFor='staff-role-trigger'>Role</Label>
							<Select value={role} onValueChange={(value) => setRole(value as StaffRole)}>
								<SelectTrigger id='staff-role-trigger' className='w-full'>
									<SelectValue />
								</SelectTrigger>
								<SelectContent>
									{STAFF_ROLE_OPTIONS.map((option) => (
										<SelectItem key={option} value={option}>
											{STAFF_ROLE_LABELS[option]}
										</SelectItem>
									))}
								</SelectContent>
							</Select>
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
							{isCreate ? 'Create staff user' : 'Save changes'}
						</Button>
					</DialogFooter>
				</form>
			</DialogContent>
		</Dialog>
	)
}
