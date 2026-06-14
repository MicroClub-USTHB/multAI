import type { ReactNode } from 'react'

import { splitTimestamp } from '@/features/admin/logs/utils'
import {
	Badge,
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/shared/ui'

import type { AdminUser } from '../types'
import { useAdminUserQuery } from '../hooks'

type UserDetailsDialogProps = {
	userId: string | null
	open: boolean
	onOpenChange: (open: boolean) => void
}

function DetailRow({
	label,
	value,
}: {
	label: string
	value: ReactNode
}) {
	return (
		<div className='grid grid-cols-[120px_1fr] items-start gap-3 text-sm'>
			<span className='text-muted-foreground'>{label}</span>
			<div className='min-w-0 break-words'>{value}</div>
		</div>
	)
}

function UserStatusBadge({ blocked }: Pick<AdminUser, 'blocked'>) {
	return (
		<Badge
			variant='outline'
			className={
				blocked
					? 'border-red-500/80 text-red-400'
					: 'border-emerald-500/80 text-emerald-400'
			}
		>
			{blocked ? 'Blocked' : 'Active'}
		</Badge>
	)
}

export function UserDetailsDialog({
	userId,
	open,
	onOpenChange,
}: UserDetailsDialogProps) {
	const { data: user, isLoading, isError, error } = useAdminUserQuery(
		userId,
		open,
	)

	const title = user ? user.email : 'User details'

	return (
		<Dialog open={open} onOpenChange={onOpenChange}>
			<DialogContent className='sm:max-w-lg'>
				<DialogHeader>
					<DialogTitle>{title}</DialogTitle>
					<DialogDescription>
						Complete information for the selected user.
					</DialogDescription>
				</DialogHeader>

				{isLoading ? (
					<div className='text-muted-foreground text-sm'>
						Loading user details...
					</div>
				) : isError ? (
					<div className='border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm'>
						{error instanceof Error ? error.message : 'Unable to load user.'}
					</div>
				) : user ? (
					<div className='space-y-3'>
						<DetailRow label='Email' value={user.email} />
						<DetailRow label='Display name' value={user.displayName ?? '-'} />
						<DetailRow
							label='Status'
							value={<UserStatusBadge blocked={user.blocked} />}
						/>
						<DetailRow
							label='User ID'
							value={<span className='font-mono text-xs'>{user.id}</span>}
						/>
						<DetailRow
							label='Created'
							value={
								<div className='font-mono text-xs leading-tight'>
									{splitTimestamp(user.createdAt).map((part) => (
										<div key={part}>{part}</div>
									))}
								</div>
							}
						/>
						<DetailRow
							label='Updated'
							value={
								<div className='font-mono text-xs leading-tight'>
									{splitTimestamp(user.updatedAt).map((part) => (
										<div key={part}>{part}</div>
									))}
								</div>
							}
						/>
					</div>
				) : null}
			</DialogContent>
		</Dialog>
	)
}
