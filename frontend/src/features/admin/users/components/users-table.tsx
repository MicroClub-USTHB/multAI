import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuGroup,
	DropdownMenuItem,
	DropdownMenuLabel,
	DropdownMenuSeparator,
	DropdownMenuTrigger,
} from '@/shared/ui/dropdown-menu'
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from '@/shared/ui/table'
import { Avatar, AvatarFallback } from '@/shared/ui/avatar'
import { cn, getInitials } from '@/shared/utils/helpers'
import { CalendarPlus, MoreHorizontal, RotateCcw, UserX } from 'lucide-react'
import {
	ADMIN_USER_ROLES,
	ADMIN_USER_STATUSES,
	type AdminUser,
	type AdminUserRole,
	type AdminUserStatus,
} from '../types'

const roleClasses: Record<AdminUserRole, string> = {
	admin: 'border-blue-500/80 text-blue-400',
	multi: 'border-violet-500/80 text-violet-400',
	user: 'border-slate-500/80 text-slate-300',
}

const statusClasses: Record<AdminUserStatus, string> = {
	member: 'border-emerald-500/90 text-emerald-400',
	invited: 'border-yellow-500/90 text-yellow-300',
	suspended: 'border-red-500/90 text-red-400',
}

const roleLabels: Record<AdminUserRole, string> = {
	admin: 'admin',
	multi: 'multi',
	user: 'user',
}

const statusLabels: Record<AdminUserStatus, string> = {
	member: 'member',
	invited: 'invited',
	suspended: 'suspended',
}

type UsersTableProps = {
	users: AdminUser[]
	onRoleChange: (userId: string, role: AdminUserRole) => void
	onStatusChange: (userId: string, status: AdminUserStatus) => void
	onResendInvite: (userId: string) => void
	onAssignNewEvent: (user: AdminUser) => void
	onDeactivateAccount: (userId: string) => void
	isMutating?: boolean
}

function formatDate(value: string) {
	const date = new Date(value)
	if (Number.isNaN(date.getTime())) {
		return 'Unknown'
	}

	return new Intl.DateTimeFormat('en-GB', {
		year: 'numeric',
		month: 'short',
		day: '2-digit',
		hour: '2-digit',
		minute: '2-digit',
	}).format(date)
}

export function UsersTable({
	users,
	onRoleChange,
	onStatusChange,
	onResendInvite,
	onAssignNewEvent,
	onDeactivateAccount,
	isMutating = false,
}: UsersTableProps) {
	return (
		<div className="rounded-md border border-border/40">
			<Table>
				<TableHeader className="bg-transparent">
					<TableRow>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">User</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">Role</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">Status</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">Created At</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground text-right">Actions</TableHead>
					</TableRow>
				</TableHeader>
				<TableBody>
					{users.length ? (
						users.map(user => (
							<TableRow key={user.id} className="border-border/40 hover:bg-muted/10">
								<TableCell className="px-2 py-2.5 align-top">
									<div className="flex items-center gap-3">
										<Avatar size="sm">
											<AvatarFallback>{getInitials(user.fullName)}</AvatarFallback>
										</Avatar>
										<div className="min-w-0">
											<p className="truncate text-sm font-medium text-foreground">{user.fullName}</p>
											<p className="truncate text-xs text-muted-foreground">{user.email}</p>
											{user.role === 'multi' && (
												<p className="truncate text-xs text-muted-foreground/80">{user.assignedEventsCount} events assigned</p>
											)}
										</div>
									</div>
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top">
									<Badge variant="outline" className={cn('h-6 rounded-sm bg-transparent px-3 text-xs', roleClasses[user.role])}>
										{roleLabels[user.role]}
									</Badge>
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top">
									<Badge variant="outline" className={cn('h-6 rounded-sm bg-transparent px-3 text-xs', statusClasses[user.status])}>
										{statusLabels[user.status]}
									</Badge>
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top text-sm text-muted-foreground">{formatDate(user.createdAt)}</TableCell>
								<TableCell className="px-2 py-2.5 align-top text-right">
									<DropdownMenu>
										<DropdownMenuTrigger
											render={
												<Button variant="ghost" size="icon-sm" disabled={isMutating} aria-label={`Actions for ${user.fullName}`} />
											}
										>
											<MoreHorizontal />
										</DropdownMenuTrigger>
										<DropdownMenuContent align="end" className="w-48">
											<DropdownMenuGroup>
												<DropdownMenuLabel>Change role</DropdownMenuLabel>
												{ADMIN_USER_ROLES.map(role => (
													<DropdownMenuItem key={role} onClick={() => onRoleChange(user.id, role)}>
														{role}
													</DropdownMenuItem>
												))}
											</DropdownMenuGroup>
											<DropdownMenuSeparator />
											<DropdownMenuGroup>
												<DropdownMenuLabel>Change status</DropdownMenuLabel>
												{ADMIN_USER_STATUSES.map(status => (
													<DropdownMenuItem key={status} onClick={() => onStatusChange(user.id, status)}>
														{status}
													</DropdownMenuItem>
												))}
											</DropdownMenuGroup>
											{user.role === 'multi' && (
												<>
													<DropdownMenuSeparator />
													<DropdownMenuItem onClick={() => onAssignNewEvent(user)}>
														<CalendarPlus />
														Assign new event
													</DropdownMenuItem>
													{user.status !== 'suspended' && (
														<DropdownMenuItem
															onClick={() => onDeactivateAccount(user.id)}
															className="text-destructive focus:text-destructive"
														>
															<UserX />
															Deactivate account
														</DropdownMenuItem>
													)}
												</>
											)}
											{user.status === 'invited' && (
												<>
													<DropdownMenuSeparator />
													<DropdownMenuItem onClick={() => onResendInvite(user.id)}>
														<RotateCcw />
														Resend invite
													</DropdownMenuItem>
												</>
											)}
										</DropdownMenuContent>
									</DropdownMenu>
								</TableCell>
							</TableRow>
						))
					) : (
						<TableRow>
							<TableCell colSpan={5} className="h-24 text-center text-sm text-muted-foreground">
								No users found.
							</TableCell>
						</TableRow>
					)}
				</TableBody>
			</Table>
		</div>
	)
}
