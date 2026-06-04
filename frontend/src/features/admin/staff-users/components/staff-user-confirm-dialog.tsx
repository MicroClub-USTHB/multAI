import type React from 'react'

import { Button } from '@/shared/ui'
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
} from '@/shared/ui'

interface StaffUserConfirmDialogProps {
	open: boolean
	title: string
	description: React.ReactNode
	confirmLabel: string
	isSubmitting?: boolean
	onOpenChange: (open: boolean) => void
	onConfirm: () => Promise<void>
}

export function StaffUserConfirmDialog({
	open,
	title,
	description,
	confirmLabel,
	isSubmitting = false,
	onOpenChange,
	onConfirm,
}: StaffUserConfirmDialogProps) {
	const handleConfirm = async () => {
		await onConfirm()
		onOpenChange(false)
	}

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className='sm:max-w-md'>
				<div className='space-y-5'>
					<DialogHeader>
						<DialogTitle>{title}</DialogTitle>
						<DialogDescription>{description}</DialogDescription>
					</DialogHeader>

					<DialogFooter>
						<Button
							type='button'
							variant='outline'
							onClick={() => onOpenChange(false)}
							disabled={isSubmitting}
						>
							Cancel
						</Button>
						<Button
							type='button'
							variant='destructive'
							onClick={() => {
								void handleConfirm()
							}}
							isLoading={isSubmitting}
						>
							{confirmLabel}
						</Button>
					</DialogFooter>
				</div>
			</DialogContent>
		</Dialog>
	)
}
