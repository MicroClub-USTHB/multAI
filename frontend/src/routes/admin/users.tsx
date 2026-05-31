import { createFileRoute } from '@tanstack/react-router';

import { useAdminUsers } from '@/features/admin/users/hooks';
import { Badge } from '@/shared/ui';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui';
import { splitTimestamp } from '@/features/admin/logs/utils';

export const Route = createFileRoute('/admin/users')({
  component: RouteComponent,
});

function RouteComponent() {
  const { users, isLoading, isError, error } = useAdminUsers();

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="space-y-2">
        <h1 className="text-4xl font-bold tracking-tight">Users</h1>
        <p className="text-muted-foreground text-sm">
          Manage end users from admin/users endpoints.
        </p>
      </div>

      {isError ? (
        <div className="border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm">
          {error instanceof Error ? error.message : 'Unable to load users.'}
        </div>
      ) : isLoading ? (
        <div className="text-muted-foreground text-sm">Loading...</div>
      ) : (
        <div className="border-border/40 rounded-md border">
          <Table>
            <TableHeader className="bg-transparent">
              <TableRow>
                <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
                  Email
                </TableHead>
                <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
                  Name
                </TableHead>
                <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
                  Status
                </TableHead>
                <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
                  Created
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {users.length ? (
                users.map((user) => {
                  const [date, time] = splitTimestamp(user.createdAt);

                  return (
                    <TableRow key={user.id} className="border-border/40">
                      <TableCell className="px-2 py-2.5 text-sm">
                        {user.email}
                      </TableCell>
                      <TableCell className="text-muted-foreground px-2 py-2.5 text-sm">
                        {user.displayName ?? '—'}
                      </TableCell>
                      <TableCell className="px-2 py-2.5">
                        <Badge
                          variant="outline"
                          className={
                            user.blocked
                              ? 'border-red-500/80 text-red-400'
                              : 'border-emerald-500/80 text-emerald-400'
                          }
                        >
                          {user.blocked ? 'Blocked' : 'Active'}
                        </Badge>
                      </TableCell>
                      <TableCell className="px-2 py-2.5 text-sm">
                        <div className="text-foreground/90 font-mono leading-tight whitespace-nowrap">
                          <div>{date}</div>
                          <div>{time}</div>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })
              ) : (
                <TableRow>
                  <TableCell colSpan={4} className="h-24 text-center text-sm">
                    No results.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </div>
      )}
    </div>
  );
}
