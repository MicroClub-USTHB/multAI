import { createFileRoute } from '@tanstack/react-router'
import { useMemo, useState } from 'react'
import { Alert, AlertDescription, AlertTitle } from '@/shared/ui/alert'
import { Card, CardContent } from '@/shared/ui/card'
import { Input } from '@/shared/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui/select'
import { Skeleton } from '@/shared/ui/skeleton'
import { UsersTable } from '@/features/admin/users/components/users-table'
import { useAdminUsers } from '@/features/admin/users/hooks'
import {
  ADMIN_USER_ROLES,
  ADMIN_USER_STATUSES,
  type AdminUser,
  type AdminUserRole,
  type AdminUserStatus,
} from '@/features/admin/users/types'
import { Search, Shield, UserCheck, UserPlus, Users } from 'lucide-react'
import { AssignEventDialog } from '@/features/admin/users/components/assign-event-dialog'

export const Route = createFileRoute('/admin/users')({
  component: UsersPage,
})

function UsersPage() {
  const {
    users,
    isLoading,
    isError,
    error,
    updateRole,
    updateStatus,
    resendInvite,
    assignNewEvent,
    isMutating,
  } = useAdminUsers()

  const [searchValue, setSearchValue] = useState('')
  const [roleFilter, setRoleFilter] = useState<'all' | AdminUserRole>('all')
  const [statusFilter, setStatusFilter] = useState<'all' | AdminUserStatus>('all')
  const [selectedMultiUser, setSelectedMultiUser] = useState<AdminUser | null>(null)
  const [isAssignDialogOpen, setIsAssignDialogOpen] = useState(false)
  const filteredUsers = useMemo(() => {
    const query = searchValue.trim().toLowerCase()

    return users.filter(user => {
      const matchesSearch =
        !query ||
        user.fullName.toLowerCase().includes(query) ||
        user.email.toLowerCase().includes(query)

      const matchesRole = roleFilter === 'all' || user.role === roleFilter
      const matchesStatus = statusFilter === 'all' || user.status === statusFilter

      return matchesSearch && matchesRole && matchesStatus
    })
  }, [users, searchValue, roleFilter, statusFilter])

  const stats = useMemo(() => {
    const total = users.length
    const members = users.filter(user => user.status === 'member').length
    const invited = users.filter(user => user.status === 'invited').length
    const admins = users.filter(user => user.role === 'admin').length

    return { total, members, invited, admins }
  }, [users])

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-4xl font-bold tracking-tight">Users</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Manage roles and statuses with mock data until backend integration.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Total users" value={stats.total.toString()} icon={Users} />
        <StatCard label="Members" value={stats.members.toString()} icon={UserCheck} />
        <StatCard label="Invited" value={stats.invited.toString()} icon={UserPlus} />
        <StatCard label="Admins" value={stats.admins.toString()} icon={Shield} />
      </div>

      <Card className="gap-4 py-4">
        <CardContent className="space-y-4 px-4">
          <div className="grid grid-cols-1 gap-3 lg:grid-cols-[1fr_180px_180px]">
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                value={searchValue}
                onChange={event => setSearchValue(event.target.value)}
                placeholder="Search by name or email"
                className="pl-9"
              />
            </div>

            <Select
              value={roleFilter}
              onValueChange={value => setRoleFilter(value as 'all' | AdminUserRole)}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All roles</SelectItem>
                {ADMIN_USER_ROLES.map(role => (
                  <SelectItem key={role} value={role}>
                    {role}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Select
              value={statusFilter}
              onValueChange={value => setStatusFilter(value as 'all' | AdminUserStatus)}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All statuses</SelectItem>
                {ADMIN_USER_STATUSES.map(status => (
                  <SelectItem key={status} value={status}>
                    {status}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {isError && (
            <Alert variant="destructive">
              <AlertTitle>Failed to load users</AlertTitle>
              <AlertDescription>
                {error instanceof Error ? error.message : 'Unknown error'}
              </AlertDescription>
            </Alert>
          )}

          {isLoading ? (
            <div className="space-y-2">
              <Skeleton className="h-10 w-full" />
              <Skeleton className="h-10 w-full" />
              <Skeleton className="h-10 w-full" />
            </div>
          ) : (
            <UsersTable
              users={filteredUsers}
              onRoleChange={(userId, role) => updateRole({ userId, role })}
              onStatusChange={(userId, status) => updateStatus({ userId, status })}
              onResendInvite={userId => resendInvite(userId)}
              onAssignNewEvent={user => {
                setSelectedMultiUser(user)
                setIsAssignDialogOpen(true)
              }}
              onDeactivateAccount={userId => updateStatus({ userId, status: 'suspended' })}
              isMutating={isMutating}
            />
          )}
        </CardContent>
      </Card>

      <AssignEventDialog
        user={selectedMultiUser}
        open={isAssignDialogOpen}
        onOpenChange={open => {
          setIsAssignDialogOpen(open)
          if (!open) {
            setSelectedMultiUser(null)
          }
        }}
        onSubmit={assignNewEvent}
        isSubmitting={isMutating}
      />
    </div>
  )
}

function StatCard({
  label,
  value,
  icon: Icon,
}: {
  label: string
  value: string
  icon: React.ComponentType<{ className?: string }>
}) {
  return (
    <Card className="gap-3 py-4">
      <CardContent className="flex items-center justify-between px-4">
        <div>
          <p className="text-xs uppercase tracking-wide text-muted-foreground">{label}</p>
          <p className="mt-1 text-2xl font-semibold text-foreground">{value}</p>
        </div>
        <div className="rounded-md border border-border/60 p-2 text-muted-foreground">
          <Icon className="size-5" />
        </div>
      </CardContent>
    </Card>
  )
}
