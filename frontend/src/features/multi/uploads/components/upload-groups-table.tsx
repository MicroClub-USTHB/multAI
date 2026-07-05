import { splitTimestamp } from '@/features/admin/logs/utils'
import {
  Badge,
  Button,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui'

import type { UploadRequestGroupSummary } from '../types'

import { UploadGroupStatusBadge } from './upload-group-status-badge'

interface UploadGroupsTableProps {
  groups: UploadRequestGroupSummary[]
  onReview: (group: UploadRequestGroupSummary) => void
  canModerate: boolean
}

export function UploadGroupsTable({ groups, onReview, canModerate }: UploadGroupsTableProps) {
  return (
    <Table>
      <TableHeader className="bg-transparent">
        <TableRow>
          <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
            Folder
          </TableHead>
          <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
            Photos
          </TableHead>
          <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
            Import
          </TableHead>
          <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
            Status
          </TableHead>
          <TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
            Created
          </TableHead>
          <TableHead className="text-muted-foreground h-9 px-2 text-right text-xs font-medium">
            Actions
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {groups.length ? (
          groups.map((group) => {
            const [date, time] = splitTimestamp(group.created_at)

            return (
              <TableRow key={group.id} className="border-border/40">
                <TableCell className="px-2 py-2.5 font-mono text-sm">
                  {group.folder_id}
                </TableCell>
                <TableCell className="px-2 py-2.5 text-sm">
                  {group.total_photo_count}
                  {group.failed_photo_count > 0 && (
                    <span className="text-red-400"> ({group.failed_photo_count} failed)</span>
                  )}
                </TableCell>
                <TableCell className="px-2 py-2.5">
                  <Badge variant="outline" className="h-6 rounded-sm bg-transparent px-3 text-xs">
                    {group.processing_status}
                  </Badge>
                </TableCell>
                <TableCell className="px-2 py-2.5">
                  <UploadGroupStatusBadge status={group.status} />
                </TableCell>
                <TableCell className="px-2 py-2.5 text-sm">
                  <div className="text-foreground/90 font-mono leading-tight whitespace-nowrap">
                    <div>{date}</div>
                    <div>{time}</div>
                  </div>
                </TableCell>
                <TableCell className="px-2 py-2.5 text-right">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={group.processing_status !== 'completed' || group.status !== 'pending'}
                    onClick={() => onReview(group)}
                  >
                    {canModerate ? 'Review' : 'View'}
                  </Button>
                </TableCell>
              </TableRow>
            )
          })
        ) : (
          <TableRow>
            <TableCell colSpan={6} className="h-24 text-center text-sm">
              No pending upload groups.
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  )
}