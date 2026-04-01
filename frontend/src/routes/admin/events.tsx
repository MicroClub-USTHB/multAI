import { createFileRoute } from '@tanstack/react-router'
import { Plus } from 'lucide-react'
import { useMemo, useState } from 'react'

import { AdminEventsApiError } from '@/features/admin/events/api'
import {
  CreateEventDialog,
  EventsFilters,
  EventsStatsCards,
  EventsTable,
} from '@/features/admin/events/components'
import { useAdminEvents } from '@/features/admin/events/hooks'
import { type AdminEvent, type EventStatus } from '@/features/admin/events/types'
import { Alert, AlertDescription, AlertTitle, Button, Card, CardContent, Skeleton } from '@/shared/ui'

export const Route = createFileRoute('/admin/events')({
  component: EventsPage,
})

function EventsPage() {
  const [searchInput, setSearchInput] = useState('')
  const [appliedSearch, setAppliedSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState<'all' | EventStatus>('all')
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [actionError, setActionError] = useState<string | null>(null)

  const queryParams = useMemo(
    () => ({
      limit: 50,
      offset: 0,
      name: appliedSearch.trim() || undefined,
      status: statusFilter,
    }),
    [appliedSearch, statusFilter],
  )

  const {
    events,
    isLoading,
    isError,
    error,
    createEvent,
    scheduleEvent,
    archiveEvent,
    draftEvent,
    isMutating,
  } = useAdminEvents(queryParams)

  const stats = useMemo(() => {
    const draft = events.filter(event => event.status === 'draft').length
    const scheduled = events.filter(event => event.status === 'scheduled').length
    const archived = events.filter(event => event.status === 'archived').length

    return {
      total: events.length,
      draft,
      scheduled,
      archived,
    }
  }, [events])

  const errorMessage =
    error instanceof AdminEventsApiError && error.status === 401
      ? 'Session admin absente. Connecte-toi puis reessaie.'
      : error instanceof Error
        ? error.message
        : 'Unknown error'

  const handleCreateEvent = async ({
    name,
    eventDate,
    status,
  }: {
    name: string
    eventDate: string
    status?: EventStatus
  }) => {
    setActionError(null)

    if (!name.trim()) {
      setActionError('Le nom de l\'event est obligatoire.')
      return
    }

    try {
      await createEvent({
        name,
        eventDate,
        status,
      })

      setIsCreateDialogOpen(false)
    } catch (mutationError) {
      setActionError(
        mutationError instanceof Error
          ? mutationError.message
          : 'Impossible de creer l\'event.',
      )
    }
  }

  const handleStatusChange = async (eventItem: AdminEvent, nextStatus: EventStatus) => {
    setActionError(null)

    try {
      if (nextStatus === 'scheduled') {
        await scheduleEvent(eventItem.id)
        return
      }

      if (nextStatus === 'archived') {
        await archiveEvent(eventItem.id)
        return
      }

      await draftEvent(eventItem.id)
    } catch (mutationError) {
      setActionError(
        mutationError instanceof Error
          ? mutationError.message
          : 'Impossible de mettre a jour le statut.',
      )
    }
  }

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-4xl font-bold tracking-tight">Events</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Manage events from backend admin/events endpoints.
          </p>
        </div>

        <Button onClick={() => setIsCreateDialogOpen(true)}>
          <Plus />
          Create event
        </Button>
      </div>

      <EventsStatsCards {...stats} />

      <Card className="gap-4 py-4">
        <CardContent className="space-y-4 px-4">
          <EventsFilters
            searchInput={searchInput}
            statusFilter={statusFilter}
            onSearchInputChange={setSearchInput}
            onStatusFilterChange={setStatusFilter}
            onApply={() => setAppliedSearch(searchInput)}
            onReset={() => {
              setSearchInput('')
              setAppliedSearch('')
              setStatusFilter('all')
            }}
          />

          {actionError && (
            <Alert variant="destructive">
              <AlertTitle>Action failed</AlertTitle>
              <AlertDescription>{actionError}</AlertDescription>
            </Alert>
          )}

          {isError && (
            <Alert variant="destructive">
              <AlertTitle>Failed to load events</AlertTitle>
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
            <EventsTable
              events={events}
              onStatusChange={(eventItem, nextStatus) => {
                void handleStatusChange(eventItem, nextStatus)
              }}
            />
          )}
        </CardContent>
      </Card>

      <CreateEventDialog
        open={isCreateDialogOpen}
        isSubmitting={isMutating}
        onOpenChange={setIsCreateDialogOpen}
        onSubmit={handleCreateEvent}
      />
    </div>
  )
}
