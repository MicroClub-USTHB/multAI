import { MoreHorizontal, PencilLine, ShieldAlert, ShieldCheck, Trash2 } from 'lucide-react'

import { Button } from '@/shared/ui'
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuTrigger,
} from '@/shared/ui'

import type { AdminUser } from '../types'

interface UserActionsMenuProps {
	user: AdminUser
	isBusy?: boolean
	onEdit: () => void
	onDelete: () => void
	onToggleBlocked: () => void
}

export function UserActionsMenu({
	user,
	isBusy = false,
	onEdit,
	onDelete,
	onToggleBlocked,
}: UserActionsMenuProps) {
	const blockLabel = user.blocked ? 'Unblock user' : 'Block user'

	return (
		<DropdownMenu>
			<DropdownMenuTrigger
				render={<Button variant='outline' size='icon-sm' className='ml-auto' />}
			>
				<MoreHorizontal />
			</DropdownMenuTrigger>
			<DropdownMenuContent align='end' className='min-w-44'>
				<DropdownMenuItem disabled={isBusy} onClick={onEdit}>
					<PencilLine />
					Edit user
				</DropdownMenuItem>
				<DropdownMenuItem disabled={isBusy} onClick={onToggleBlocked}>
					{user.blocked ? <ShieldCheck /> : <ShieldAlert />}
					{blockLabel}
				</DropdownMenuItem>
				<DropdownMenuItem variant='destructive' disabled={isBusy} onClick={onDelete}>
					<Trash2 />
					Delete user
				</DropdownMenuItem>
			</DropdownMenuContent>
		</DropdownMenu>
	)
}
