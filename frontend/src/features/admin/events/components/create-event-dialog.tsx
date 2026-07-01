import { CalendarDays } from 'lucide-react'
import { useMemo, useState } from 'react'

import { Button } from '@/shared/ui'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui'
import { Input } from '@/shared/ui'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui'

import { EVENT_STATUSES, type CreateAdminEventInput, type EventStatus } from '../types'

const STATUS_LABELS: Record<EventStatus, string> = {
  draft: 'Draft',
  scheduled: 'Scheduled',
  archived: 'Archived',
}

const toLocalDateParts = (isoString: string) => {
  const date = new Date(isoString)
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000)
  const isoLocal = local.toISOString()

  return {
    day: isoLocal.slice(0, 10),
    time: isoLocal.slice(11, 16),
  }
}

const toIsoFromLocalParts = (day: string, time: string) =>
  new Date(`${day}T${time}`).toISOString()

interface CreateEventDialogProps {
  open: boolean
  isSubmitting: boolean
  onOpenChange: (open: boolean) => void
  onSubmit: (input: CreateAdminEventInput) => Promise<void>
}

export function CreateEventDialog({
  open,
  isSubmitting,
  onOpenChange,
  onSubmit,
}: CreateEventDialogProps) {
  const initialDateParts = useMemo(
    () => toLocalDateParts(new Date().toISOString()),
    [],
  )

  const [eventName, setEventName] = useState('')
  const [eventDay, setEventDay] = useState(initialDateParts.day)
  const [eventTime, setEventTime] = useState(initialDateParts.time)
  const [eventStatus, setEventStatus] = useState<EventStatus>('draft')

  const resetForm = () => {
    const now = toLocalDateParts(new Date().toISOString())
    setEventName('')
    setEventDay(now.day)
    setEventTime(now.time)
    setEventStatus('draft')
  }

  const prettyDate = useMemo(() => {
    return new Date(toIsoFromLocalParts(eventDay, eventTime)).toLocaleString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    })
  }, [eventDay, eventTime])

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()

    await onSubmit({
      name: eventName,
      eventDate: toIsoFromLocalParts(eventDay, eventTime),
      status: eventStatus,
    })

    resetForm()
  }

  return (
    <Dialog open={open} onOpenChange={nextOpen => {
      onOpenChange(nextOpen)
      if (!nextOpen) {
        resetForm()
      }
    }}>
      <DialogContent>
        <form className="space-y-4" onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Create Event</DialogTitle>
            <DialogDescription>
              Creates a new event via /admin/events/.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="event-name">
              Event name
            </label>
            <Input
              id="event-name"
              value={eventName}
              onChange={event => setEventName(event.target.value)}
              placeholder="MicroCode 2026"
              required
            />
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Event date and time</label>
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <Input
                type="date"
                value={eventDay}
                onChange={event => setEventDay(event.target.value)}
                required
              />
              <Input
                type="time"
                value={eventTime}
                onChange={event => setEventTime(event.target.value)}
                required
              />
            </div>
            <div className="flex items-center gap-2 rounded-md border border-border/70 bg-muted/30 px-3 py-2 text-sm text-muted-foreground">
              <CalendarDays className="size-4" />
              <span>Planned for {prettyDate}</span>
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="event-status-trigger">
              Initial status
            </label>
            <Select
              value={eventStatus}
              onValueChange={value => setEventStatus(value as EventStatus)}
            >
              <SelectTrigger id="event-status-trigger" className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {EVENT_STATUSES.map(status => (
                  <SelectItem key={status} value={status}>
                    {STATUS_LABELS[status]}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <DialogFooter>
            <Button
              variant="ghost"
              type="button"
              onClick={() => {
                onOpenChange(false)
                resetForm()
              }}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              Create
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
