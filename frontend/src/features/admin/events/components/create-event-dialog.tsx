import { CalendarPlus, ExternalLink } from 'lucide-react'

import { env } from '@/env'
import { Button } from '@/shared/ui'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui'

import type { CreateAdminEventInput } from '../types'

interface CreateEventDialogProps {
  open: boolean
  isSubmitting?: boolean
  onOpenChange: (open: boolean) => void
  onSubmit?: (input: CreateAdminEventInput) => Promise<void>
}

export function CreateEventDialog({
  open,
  onOpenChange,
}: CreateEventDialogProps) {
  const hrEventsUrl = env.VITE_HR_EVENTS_URL || 'https://hr.microclub.info'

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <div className="flex items-center gap-2 text-primary">
            <CalendarPlus className="size-5" />
            <DialogTitle>Create New Event</DialogTitle>
          </div>
          <DialogDescription>
            Event creation is now managed through HR-Events.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-3 py-2 text-sm text-muted-foreground">
          <p>
            To keep team assignments, schedules, and club attendance aligned, all events must be created directly on the <strong>HR-Events</strong> platform.
          </p>
          <p>
            Once an event is created in HR-Events, it will automatically synchronize to MultAI with its generated attendee join code, face-matching pipeline, and photo gallery.
          </p>
        </div>

        <DialogFooter className="flex-row justify-end gap-2 sm:justify-end">
          <Button
            variant="outline"
            type="button"
            onClick={() => onOpenChange(false)}
          >
            Close
          </Button>
          <Button
            type="button"
            onClick={() => {
              window.open(hrEventsUrl, '_blank')
              onOpenChange(false)
            }}
          >
            <ExternalLink className="mr-2 size-4" />
            Open HR-Events
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
