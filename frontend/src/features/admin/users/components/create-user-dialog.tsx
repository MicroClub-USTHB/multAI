import { useEffect, useMemo, useState } from 'react'
import { Alert, AlertDescription, AlertTitle } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from '@/shared/ui/dialog'
import { Input } from '@/shared/ui/input'
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/shared/ui/select'
import {
	ADMIN_USER_EDITABLE_ROLES,
	type CreateAdminUserInput,
	type EditableAdminUserRole,
} from '../types'

type CreateUserDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	onSubmit: (input: CreateAdminUserInput) => Promise<unknown>
	isSubmitting?: boolean
}

export function CreateUserDialog({
	open,
	onOpenChange,
	onSubmit,
	isSubmitting = false,
}: CreateUserDialogProps) {
	const [email, setEmail] = useState('')
	const [password, setPassword] = useState('')
	const [role, setRole] = useState<EditableAdminUserRole>('multi')
	const [error, setError] = useState<string | null>(null)

	useEffect(() => {
		if (!open) {
			setEmail('')
			setPassword('')
			setRole('multi')
			setError(null)
		}
	}, [open])

	const canSubmit = useMemo(() => {
		const normalizedEmail = email.trim()
		return normalizedEmail.length > 4 && normalizedEmail.includes('@') && password.length >= 8
	}, [email, password])

	const handleSubmit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError(null)

		try {
			await onSubmit({
				email: email.trim(),
				password,
				role,
			})
			onOpenChange(false)
		} catch (submissionError) {
			if (submissionError instanceof Error) {
				setError(submissionError.message)
				return
			}
			setError('Unexpected error while creating user')
		}
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent>
				<DialogHeader>
					<DialogTitle>Create staff user</DialogTitle>
					<DialogDescription>
						Create a new account with role multi or multi team lead.
					</DialogDescription>
				</DialogHeader>

				<form className="space-y-4" onSubmit={handleSubmit}>
					{error && (
						<Alert variant="destructive">
							<AlertTitle>Creation failed</AlertTitle>
							<AlertDescription>{error}</AlertDescription>
						</Alert>
					)}

					<div className="space-y-1.5">
						<label className="text-sm text-muted-foreground">Email</label>
						<Input
							type="email"
							placeholder="multi@example.com"
							value={email}
							onChange={event => setEmail(event.target.value)}
						/>
					</div>

					<div className="space-y-1.5">
						<label className="text-sm text-muted-foreground">Password</label>
						<Input
							type="password"
							placeholder="At least 8 characters"
							value={password}
							onChange={event => setPassword(event.target.value)}
						/>
					</div>

					<div className="space-y-1.5">
						<label className="text-sm text-muted-foreground">Role</label>
						<Select
							value={role}
							onValueChange={value => setRole(value as EditableAdminUserRole)}
						>
							<SelectTrigger>
								<SelectValue />
							</SelectTrigger>
							<SelectContent>
								{ADMIN_USER_EDITABLE_ROLES.map(item => (
									<SelectItem key={item} value={item}>
										{item.replace('_', ' ')}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</div>

					<DialogFooter>
						<Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
							Cancel
						</Button>
						<Button type="submit" disabled={!canSubmit || isSubmitting}>
							{isSubmitting ? 'Creating...' : 'Create user'}
						</Button>
					</DialogFooter>
				</form>
			</DialogContent>
		</Dialog>
	)
}
