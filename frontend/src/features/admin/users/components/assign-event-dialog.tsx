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

import type { AdminUser } from '../types'

type AssignEventDialogProps = {
	user: AdminUser | null
	open: boolean
	onOpenChange: (open: boolean) => void
	onSubmit: (input: { userId: string; eventName: string }) => Promise<unknown>
	isSubmitting?: boolean
}

export function AssignEventDialog({
	user,
	open,
	onOpenChange,
	onSubmit,
	isSubmitting = false,
}: AssignEventDialogProps) {
	const [eventName, setEventName] = useState('')
	const [error, setError] = useState<string | null>(null)

	const canSubmit = useMemo(() => eventName.trim().length >= 3, [eventName])

	useEffect(() => {
		if (!open) {
			setEventName('')
			setError(null)
		}
	}, [open])

	const handleSubmit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError(null)

		if (!user) {
			setError('No user selected')
			return
		}

		try {
			await onSubmit({
				userId: user.id,
				eventName: eventName.trim(),
			})
			onOpenChange(false)
		} catch (submissionError) {
			if (submissionError instanceof Error) {
				setError(submissionError.message)
				return
			}
			setError('Unexpected error while assigning event')
		}
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent>
				<DialogHeader>
					<DialogTitle>Assign new event</DialogTitle>
					<DialogDescription>
						Assign an additional event to {user?.fullName ?? 'the selected user'}.
					</DialogDescription>
				</DialogHeader>

				<form className="space-y-4" onSubmit={handleSubmit}>
					{error && (
						<Alert variant="destructive">
							<AlertTitle>Assignment failed</AlertTitle>
							<AlertDescription>{error}</AlertDescription>
						</Alert>
					)}

					<div className="space-y-1.5">
						<label className="text-sm text-muted-foreground">Event name</label>
						<Input
							placeholder="Ex: Spring Gala 2026"
							value={eventName}
							onChange={e => setEventName(e.target.value)}
						/>
					</div>

					<DialogFooter>
						<Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
							Cancel
						</Button>
						<Button type="submit" disabled={!canSubmit || isSubmitting}>
							{isSubmitting ? 'Assigning...' : 'Assign event'}
						</Button>
					</DialogFooter>
				</form>
			</DialogContent>
		</Dialog>
	)
}
