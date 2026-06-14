import { splitTimestamp } from '@/features/admin/logs/utils'
import { Badge, Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/shared/ui'

import type { AdminUser } from '../types'

import { UserActionsMenu } from './user-actions-menu'

interface UsersTableProps {
	users: AdminUser[]
	isBusy?: boolean
	onViewDetails: (user: AdminUser) => void
	onEdit: (user: AdminUser) => void
	onDelete: (user: AdminUser) => void
	onToggleBlocked: (user: AdminUser) => void
}

export function UsersTable({
	users,
	isBusy = false,
	onViewDetails,
	onEdit,
	onDelete,
	onToggleBlocked,
}: UsersTableProps) {
	return (
		<Table>
			<TableHeader className='bg-transparent'>
				<TableRow>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Email
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Display name
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Status
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-xs font-medium'>
						Created
					</TableHead>
					<TableHead className='text-muted-foreground h-9 px-2 text-right text-xs font-medium'>
						Actions
					</TableHead>
				</TableRow>
			</TableHeader>
			<TableBody>
				{users.length ? (
					users.map((user) => {
						const [date, time] = splitTimestamp(user.createdAt)

						return (
							<TableRow key={user.id} className='border-border/40'>
								<TableCell className='px-2 py-2.5 text-sm'>
									{user.email}
								</TableCell>
								<TableCell className='text-muted-foreground px-2 py-2.5 text-sm'>
									{user.displayName ?? '-'}
								</TableCell>
								<TableCell className='px-2 py-2.5'>
									<Badge
										variant='outline'
										className={
											user.blocked
												? 'border-red-500/80 text-red-400'
												: 'border-emerald-500/80 text-emerald-400'
										}
									>
										{user.blocked ? 'Blocked' : 'Active'}
									</Badge>
								</TableCell>
								<TableCell className='px-2 py-2.5 text-sm'>
									<div className='text-foreground/90 font-mono leading-tight whitespace-nowrap'>
										<div>{date}</div>
										<div>{time}</div>
									</div>
								</TableCell>
								<TableCell className='px-2 py-2.5 text-right'>
									<UserActionsMenu
										user={user}
										isBusy={isBusy}
										onViewDetails={() => onViewDetails(user)}
										onEdit={() => onEdit(user)}
										onDelete={() => onDelete(user)}
										onToggleBlocked={() => onToggleBlocked(user)}
									/>
								</TableCell>
							</TableRow>
						)
					})
				) : (
					<TableRow>
						<TableCell colSpan={5} className='h-24 text-center text-sm'>
							No users found.
						</TableCell>
					</TableRow>
				)}
			</TableBody>
		</Table>
	)
}
