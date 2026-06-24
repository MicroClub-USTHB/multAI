import { useEffect, useMemo, useState } from 'react'

import {
	Alert,
	AlertDescription,
	AlertTitle,
	Button,
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
	Input,
} from '@/shared/ui'

import type { AdminUserCreateInput } from '../types'

type CreateUserDialogProps = {
	open: boolean
	onOpenChange: (open: boolean) => void
	onSubmit: (input: AdminUserCreateInput) => Promise<unknown>
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
	const [error, setError] = useState<string | null>(null)

	useEffect(() => {
		if (!open) {
			setEmail('')
			setPassword('')
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
				displayName: null,
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
