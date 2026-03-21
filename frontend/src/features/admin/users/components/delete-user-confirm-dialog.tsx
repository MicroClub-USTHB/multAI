import { useState } from 'react'
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
import type { AdminUser } from '../types'

type DeleteUserConfirmDialogProps = {
	open: boolean
	user: AdminUser | null
	onOpenChange: (open: boolean) => void
	onConfirm: (userId: string) => Promise<unknown>
	isSubmitting?: boolean
}

export function DeleteUserConfirmDialog({
	open,
	user,
	onOpenChange,
	onConfirm,
	isSubmitting = false,
}: DeleteUserConfirmDialogProps) {
	const [error, setError] = useState<string | null>(null)

	const handleConfirm = async () => {
		if (!user) {
			return
		}

		setError(null)
		try {
			await onConfirm(user.id)
			onOpenChange(false)
		} catch (confirmError) {
			if (confirmError instanceof Error) {
				setError(confirmError.message)
				return
			}
			setError('Unexpected error while deleting user')
		}
	}

	return (
		<Dialog
			open={open}
			onOpenChange={nextOpen => {
				if (!nextOpen) {
					setError(null)
				}
				onOpenChange(nextOpen)
			}}
		>
			<DialogContent>
				<DialogHeader>
					<DialogTitle>Delete user</DialogTitle>
					<DialogDescription>
						This action is permanent. Do you really want to delete{' '}
						<span className="font-medium text-foreground">
							{user?.email || user?.fullName || 'this user'}
						</span>
						?
					</DialogDescription>
				</DialogHeader>

				{error && (
					<Alert variant="destructive">
						<AlertTitle>Deletion failed</AlertTitle>
						<AlertDescription>{error}</AlertDescription>
					</Alert>
				)}

				<DialogFooter>
					<Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
						Cancel
					</Button>
					<Button
						type="button"
						variant="destructive"
						onClick={handleConfirm}
						disabled={!user || isSubmitting}
					>
						{isSubmitting ? 'Deleting...' : 'Delete'}
					</Button>
				</DialogFooter>
			</DialogContent>
		</Dialog>
	)
}
