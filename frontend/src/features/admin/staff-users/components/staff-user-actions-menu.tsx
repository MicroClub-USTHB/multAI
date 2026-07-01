import { MoreHorizontal, PencilLine, Trash2 } from 'lucide-react'

import { Button } from '@/shared/ui'
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuTrigger,
} from '@/shared/ui'

interface StaffUserActionsMenuProps {
	isBusy?: boolean
	onEdit: () => void
	onDelete: () => void
}

export function StaffUserActionsMenu({
	isBusy = false,
	onEdit,
	onDelete,
}: StaffUserActionsMenuProps) {
	return (
		<DropdownMenu>
			<DropdownMenuTrigger
				render={<Button variant='outline' size='icon-sm' className='ml-auto' />}
			>
				<MoreHorizontal />
			</DropdownMenuTrigger>
			<DropdownMenuContent align='end' className='min-w-40'>
				<DropdownMenuItem disabled={isBusy} onClick={onEdit}>
					<PencilLine />
					Edit staff user
				</DropdownMenuItem>
				<DropdownMenuItem
					variant='destructive'
					disabled={isBusy}
					onClick={onDelete}
				>
					<Trash2 />
					Delete staff user
				</DropdownMenuItem>
			</DropdownMenuContent>
		</DropdownMenu>
	)
}
