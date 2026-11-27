import { useState } from 'react'

import { useMultiEventsQuery } from '@/features/multi/events/hooks'
import {
  Alert,
  AlertDescription,
  Button,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui'

import type { DriveDropInput } from '../types'

interface DriveDropFormProps {
  isSubmitting: boolean
  error: string | null
  onSubmit: (input: DriveDropInput) => void
}

export function DriveDropForm({ isSubmitting, error, onSubmit }: DriveDropFormProps) {
  const { data: events, isLoading } = useMultiEventsQuery()
  const [folderUrl, setFolderUrl] = useState('')
  const [mode, setMode] = useState<'existing' | 'new'>('existing')
  const [eventId, setEventId] = useState<string | null>(null)
  const [eventName, setEventName] = useState('')
  const [visibility, setVisibility] = useState<'private' | 'public'>('private')

  const eventReady = mode === 'existing' ? eventId !== null : eventName.trim().length > 0
  const canSubmit = folderUrl.trim().length > 0 && eventReady && !isSubmitting

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!canSubmit) return
    onSubmit({
      folder_url: folderUrl.trim(),
      visibility,
      ...(mode === 'existing'
        ? { event_id: eventId as string }
        : { new_event: { name: eventName.trim() } }),
    })
  }

  return (
    <form onSubmit={submit} className="space-y-6 rounded-xl border bg-card p-6">
      <div className="space-y-2">
        <label htmlFor="folder-url" className="text-sm font-medium">
          Google Drive folder link
        </label>
        <Input
          id="folder-url"
          placeholder="https://drive.google.com/drive/folders/…"
          value={folderUrl}
          onChange={(e) => setFolderUrl(e.target.value)}
          disabled={isSubmitting}
          autoComplete="off"
        />
        <p className="text-xs text-muted-foreground">
          Share the folder with the Google account connected in Drive settings. Subfolders are
          included.
        </p>
      </div>

      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium">Event</span>
          <button
            type="button"
            className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
            onClick={() => setMode(mode === 'existing' ? 'new' : 'existing')}
            disabled={isSubmitting}
          >
            {mode === 'existing' ? 'Create a new event instead' : 'Use an existing event'}
          </button>
        </div>
        {mode === 'existing' ? (
          <Select
            value={eventId ?? undefined}
            onValueChange={setEventId}
            disabled={isSubmitting || isLoading}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder={isLoading ? 'Loading events…' : 'Choose an event'} />
            </SelectTrigger>
            <SelectContent>
              {(events ?? []).map((event) => (
                <SelectItem key={event.id} value={event.id}>
                  {event.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        ) : (
          <Input
            placeholder="New event name"
            value={eventName}
            onChange={(e) => setEventName(e.target.value)}
            disabled={isSubmitting}
          />
        )}
      </div>

      <div className="space-y-2">
        <span className="text-sm font-medium">Who can see these photos</span>
        <div className="grid grid-cols-2 gap-2">
          {(['private', 'public'] as const).map((option) => (
            <button
              key={option}
              type="button"
              onClick={() => setVisibility(option)}
              disabled={isSubmitting}
              aria-pressed={visibility === option}
              className={
                'rounded-lg border px-3 py-2 text-left text-sm transition-colors ' +
                (visibility === option
                  ? 'border-primary bg-primary/5 font-medium'
                  : 'hover:bg-muted')
              }
            >
              {option === 'private' ? 'Only the people in them' : 'Everyone in the event'}
            </button>
          ))}
        </div>
      </div>

      {error ? (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      ) : null}

      <Button type="submit" className="w-full" disabled={!canSubmit}>
        {isSubmitting ? 'Starting…' : 'Import and match faces'}
      </Button>
    </form>
  )
}
