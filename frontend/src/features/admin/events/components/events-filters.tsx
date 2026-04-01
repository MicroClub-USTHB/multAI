import { Search } from 'lucide-react'

import { Input } from '@/shared/ui'
import { Button } from '@/shared/ui'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui'

import { EVENT_STATUSES, type EventStatus } from '../types'

const STATUS_LABELS: Record<EventStatus, string> = {
  draft: 'Draft',
  scheduled: 'Scheduled',
  archived: 'Archived',
}

interface EventsFiltersProps {
  searchInput: string
  statusFilter: 'all' | EventStatus
  onSearchInputChange: (value: string) => void
  onStatusFilterChange: (value: 'all' | EventStatus) => void
  onApply: () => void
  onReset: () => void
}

export function EventsFilters({
  searchInput,
  statusFilter,
  onSearchInputChange,
  onStatusFilterChange,
  onApply,
  onReset,
}: EventsFiltersProps) {
  return (
    <div className="grid grid-cols-1 gap-3 lg:grid-cols-[1fr_220px_auto_auto]">
      <div className="relative">
        <Search className="pointer-events-none absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          value={searchInput}
          onChange={event => onSearchInputChange(event.target.value)}
          placeholder="Search by event name"
          className="pl-9"
        />
      </div>

      <Select
        value={statusFilter}
        onValueChange={value => onStatusFilterChange(value as 'all' | EventStatus)}
      >
        <SelectTrigger className="w-full">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All statuses</SelectItem>
          {EVENT_STATUSES.map(status => (
            <SelectItem key={status} value={status}>
              {STATUS_LABELS[status]}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      <Button variant="outline" onClick={onApply}>
        Apply
      </Button>

      <Button variant="ghost" onClick={onReset}>
        Reset
      </Button>
    </div>
  )
}
