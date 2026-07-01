import { splitTimestamp } from '@/features/admin/logs/utils'
import { Badge, Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/shared/ui'

import type { StaffUser } from '../types'

import { STAFF_ROLE_BADGE_CLASSES, STAFF_ROLE_LABELS } from '../constants'
import { StaffUserActionsMenu } from './staff-user-actions-menu'

interface StaffUsersTableProps {
	users: StaffUser[]
	isBusy?: boolean
	onEdit: (user: StaffUser) => void
	onDelete: (user: StaffUser) => void
}

export function StaffUsersTable({
	users,
	isBusy = false,
	onEdit,
	onDelete,
}: StaffUsersTableProps) {
	return (
		<Table>
			<TableHeader className='bg-transparent'>
				<TableRow>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Email
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Role
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Created
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Updated
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-right text-xs font-medium'>
						Actions
					</TableHead>
				</TableRow>
			</TableHeader>
			<TableBody>
				{users.length ? (
					users.map((user) => {
						const [createdDate, createdTime] = splitTimestamp(user.createdAt)
						const [updatedDate, updatedTime] = splitTimestamp(user.updatedAt)

						return (
							<TableRow key={user.id} className='border-border/40'>
								<TableCell className='px-2 py-2.5 text-sm'>
									{user.email ?? '—'}
								</TableCell>
								<TableCell className='px-2 py-2.5'>
									<Badge
										variant='outline'
										className={STAFF_ROLE_BADGE_CLASSES[user.role]}
									>
										{STAFF_ROLE_LABELS[user.role]}
									</Badge>
								</TableCell>
								<TableCell className='px-2 py-2.5 text-sm'>
									<div className='text-foreground/90 font-mono leading-tight whitespace-nowrap'>
										<div>{createdDate}</div>
										<div>{createdTime}</div>
									</div>
								</TableCell>
								<TableCell className='px-2 py-2.5 text-sm'>
									<div className='text-foreground/90 font-mono leading-tight whitespace-nowrap'>
										<div>{updatedDate}</div>
										<div>{updatedTime}</div>
									</div>
								</TableCell>
								<TableCell className='px-2 py-2.5 text-right'>
									<StaffUserActionsMenu
										isBusy={isBusy}
										onEdit={() => onEdit(user)}
										onDelete={() => onDelete(user)}
									/>
								</TableCell>
							</TableRow>
						)
					})
				) : (
					<TableRow>
						<TableCell colSpan={5} className='h-24 text-center text-sm'>
							No staff users found.
						</TableCell>
					</TableRow>
				)}
			</TableBody>
		</Table>
	)
}
