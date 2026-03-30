import { MoreHorizontal, UserX } from 'lucide-react'

import {
	Avatar,
	AvatarFallback,
	Badge,
	Button,
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuGroup,
	DropdownMenuItem,
	DropdownMenuLabel,
	DropdownMenuSeparator,
	DropdownMenuTrigger,
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from '@/shared/ui'
import { cn, getInitials } from '@/shared/utils/helpers'

import {
	ADMIN_USER_EDITABLE_ROLES,
	type AdminUser,
	type EditableAdminUserRole,
} from '../types'

const roleClasses: Record<AdminUser['role'], string> = {
	admin: 'border-blue-500/80 text-blue-400',
	multi_team_lead: 'border-cyan-500/80 text-cyan-400',
	multi: 'border-violet-500/80 text-violet-400',
}

const roleLabels: Record<AdminUser['role'], string> = {
	admin: 'admin',
	multi_team_lead: 'multi team lead',
	multi: 'multi',
}

type UsersTableProps = {
	users: AdminUser[]
	onRoleChange: (user: AdminUser, role: EditableAdminUserRole) => void
	onDeleteUser: (user: AdminUser) => void
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
	onDeleteUser,
	isMutating = false,
}: UsersTableProps) {
	return (
		<div className="rounded-md border border-border/40">
			<Table>
				<TableHeader className="bg-transparent">
					<TableRow>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">
							User
						</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">
							Role
						</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground">
							Created At
						</TableHead>
						<TableHead className="h-9 px-2 text-xs font-medium text-muted-foreground text-right">
							Actions
						</TableHead>
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
											<p className="truncate text-sm font-medium text-foreground">
												{user.fullName}
											</p>
											<p className="truncate text-xs text-muted-foreground">
												{user.email || '-'}
											</p>
										</div>
									</div>
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top">
									<Badge
										variant="outline"
										className={cn(
											'h-6 rounded-sm bg-transparent px-3 text-xs',
											roleClasses[user.role],
										)}
									>
										{roleLabels[user.role]}
									</Badge>
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top text-sm text-muted-foreground">
									{formatDate(user.createdAt)}
								</TableCell>
								<TableCell className="px-2 py-2.5 align-top text-right">
									<DropdownMenu>
										<DropdownMenuTrigger
											render={
												<Button
													variant="ghost"
													size="icon-sm"
													disabled={isMutating}
													aria-label={`Actions for ${user.fullName}`}
												/>
											}
										>
											<MoreHorizontal />
										</DropdownMenuTrigger>
										<DropdownMenuContent align="end" className="w-52">
											{user.role !== 'admin' && (
												<DropdownMenuGroup>
													<DropdownMenuLabel>Change role</DropdownMenuLabel>
													{ADMIN_USER_EDITABLE_ROLES.map(role => (
														<DropdownMenuItem
															key={role}
															onClick={() => onRoleChange(user, role)}
														>
															{role.replace('_', ' ')}
														</DropdownMenuItem>
													))}
												</DropdownMenuGroup>
											)}
											<DropdownMenuSeparator />
											<DropdownMenuItem
												onClick={() => onDeleteUser(user)}
												className="text-destructive focus:text-destructive"
											>
												<UserX />
												Delete user
											</DropdownMenuItem>
										</DropdownMenuContent>
									</DropdownMenu>
								</TableCell>
							</TableRow>
						))
					) : (
						<TableRow>
							<TableCell colSpan={4} className="h-24 text-center text-sm text-muted-foreground">
								No users found.
							</TableCell>
						</TableRow>
					)}
				</TableBody>
			</Table>
		</div>
	)
}
