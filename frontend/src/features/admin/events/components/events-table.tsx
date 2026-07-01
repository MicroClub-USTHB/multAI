import { MoreHorizontal } from 'lucide-react'

import { Badge } from '@/shared/ui'
import { Button } from '@/shared/ui'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/shared/ui'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui'

import type { AdminEvent, EventStatus } from '../types'

const STATUS_LABELS: Record<EventStatus, string> = {
  draft: 'Draft',
  scheduled: 'Scheduled',
  archived: 'Archived',
}

const statusBadgeVariant = (status: EventStatus) => {
  if (status === 'scheduled') {
    return 'default'
  }

  if (status === 'archived') {
    return 'secondary'
  }

  return 'outline'
}

const formatDateTime = (value: string) =>
  new Date(value).toLocaleString('fr-FR', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })

interface EventsTableProps {
  events: AdminEvent[]
  onStatusChange: (event: AdminEvent, nextStatus: EventStatus) => void
}

export function EventsTable({ events, onStatusChange }: EventsTableProps) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Name</TableHead>
          <TableHead>Code</TableHead>
          <TableHead>Date</TableHead>
          <TableHead>Status</TableHead>
          <TableHead>Created</TableHead>
          <TableHead className="text-right">Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {events.length === 0 ? (
          <TableRow>
            <TableCell colSpan={6} className="h-20 text-center text-muted-foreground">
              No events found.
            </TableCell>
          </TableRow>
        ) : (
          events.map(eventItem => (
            <TableRow key={eventItem.id}>
              <TableCell className="font-medium">{eventItem.name}</TableCell>
              <TableCell>{eventItem.eventCode}</TableCell>
              <TableCell>{formatDateTime(eventItem.eventDate)}</TableCell>
              <TableCell>
                <Badge variant={statusBadgeVariant(eventItem.status)}>
                  {STATUS_LABELS[eventItem.status]}
                </Badge>
              </TableCell>
              <TableCell>{formatDateTime(eventItem.createdAt)}</TableCell>
              <TableCell className="text-right">
                <DropdownMenu>
                  <DropdownMenuTrigger
                    render={<Button variant="outline" size="icon-sm" className="ml-auto" />}
                  >
                    <MoreHorizontal />
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="min-w-40">
                    <DropdownMenuItem
                      disabled={eventItem.status === 'draft'}
                      onClick={() => onStatusChange(eventItem, 'draft')}
                    >
                      Move to draft
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      disabled={eventItem.status === 'scheduled'}
                      onClick={() => onStatusChange(eventItem, 'scheduled')}
                    >
                      Move to scheduled
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      disabled={eventItem.status === 'archived'}
                      onClick={() => onStatusChange(eventItem, 'archived')}
                    >
                      Archive event
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
            </TableRow>
          ))
        )}
      </TableBody>
    </Table>
  )
}
