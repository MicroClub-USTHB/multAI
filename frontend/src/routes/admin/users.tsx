import { createFileRoute } from '@tanstack/react-router'
import { Plus, Search, Shield, UserCog, Users } from 'lucide-react'
import { useMemo, useState } from 'react'

import { AdminUsersApiError } from '@/features/admin/users/api'
import {
  CreateUserDialog,
  DeleteUserConfirmDialog,
  UsersTable,
} from '@/features/admin/users/components'
import { useAdminUsers } from '@/features/admin/users/hooks'
import {
  ADMIN_USER_ROLES,
  type AdminUser,
  type AdminUserRole,
} from '@/features/admin/users/types'
import {
  Alert,
  AlertDescription,
  AlertTitle,
  Button,
  Card,
  CardContent,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Skeleton,
} from '@/shared/ui'

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
    createUser,
    deleteUser,
    isMutating,
  } = useAdminUsers()

  const [searchValue, setSearchValue] = useState('')
  const [roleFilter, setRoleFilter] = useState<'all' | AdminUserRole>('all')
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedUserToDelete, setSelectedUserToDelete] =
    useState<AdminUser | null>(null)

  const filteredUsers = useMemo(() => {
    const query = searchValue.trim().toLowerCase()

    return users.filter(user => {
      const matchesSearch =
        !query ||
        user.fullName.toLowerCase().includes(query) ||
        user.email.toLowerCase().includes(query)

      const matchesRole = roleFilter === 'all' || user.role === roleFilter

      return matchesSearch && matchesRole
    })
  }, [users, searchValue, roleFilter])

  const stats = useMemo(() => {
    const total = users.length
    const admins = users.filter(user => user.role === 'admin').length
    const teamLeads = users.filter(user => user.role === 'multi_team_lead').length
    const multis = users.filter(user => user.role === 'multi').length

    return { total, admins, teamLeads, multis }
  }, [users])

  const errorMessage =
    error instanceof AdminUsersApiError && error.status === 401
      ? 'Your admin session is missing or has expired. Please log in again to restore it.'
      : error instanceof Error
        ? error.message
        : 'Unknown error'

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-4xl font-bold tracking-tight">Users</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Manage staff users with the backend admin/staff-users endpoints.
          </p>
        </div>
        <Button onClick={() => setIsCreateDialogOpen(true)}>
          <Plus />
          Create user
        </Button>
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Total users" value={stats.total.toString()} icon={Users} />
        <StatCard label="Admins" value={stats.admins.toString()} icon={Shield} />
        <StatCard label="Team leads" value={stats.teamLeads.toString()} icon={UserCog} />
        <StatCard label="Multi" value={stats.multis.toString()} icon={Users} />
      </div>

      <Card className="gap-4 py-4">
        <CardContent className="space-y-4 px-4">
          <div className="grid grid-cols-1 gap-3 lg:grid-cols-[1fr_220px]">
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
          </div>

          {isError && (
            <Alert variant="destructive">
              <AlertTitle>Failed to load users</AlertTitle>
              <AlertDescription>{errorMessage}</AlertDescription>
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
              onRoleChange={(user, role) =>
                updateRole({ userId: user.id, role, email: user.email })
              }
              onDeleteUser={user => {
                setSelectedUserToDelete(user)
                setIsDeleteDialogOpen(true)
              }}
              isMutating={isMutating}
            />
          )}
        </CardContent>
      </Card>

      <CreateUserDialog
        open={isCreateDialogOpen}
        onOpenChange={setIsCreateDialogOpen}
        onSubmit={createUser}
        isSubmitting={isMutating}
      />

      <DeleteUserConfirmDialog
        open={isDeleteDialogOpen}
        user={selectedUserToDelete}
        onOpenChange={open => {
          setIsDeleteDialogOpen(open)
          if (!open) {
            setSelectedUserToDelete(null)
          }
        }}
        onConfirm={deleteUser}
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
