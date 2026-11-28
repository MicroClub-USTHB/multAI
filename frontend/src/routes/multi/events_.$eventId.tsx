import { useQueryClient } from '@tanstack/react-query'
import { createFileRoute, Link } from '@tanstack/react-router'
import { ArrowLeft, FolderInput } from 'lucide-react'
import { useEffect } from 'react'

import { PageHeader } from '@/components/PageHeader'
import { EventPhotoGrid } from '@/features/multi/event-photos/components/event-photo-grid'
import { eventPhotosKey, useEventPhotos } from '@/features/multi/event-photos/hooks'
import { EventStatusBadge } from '@/features/multi/events/components/event-status-badge'
import { useMultiEvents } from '@/features/multi/events/hooks'
import { UploadDropzone } from '@/features/multi/media-upload/components/upload-dropzone'
import { UploadList } from '@/features/multi/media-upload/components/upload-list'
import { UploadSummary } from '@/features/multi/media-upload/components/upload-summary'
import { useBulkUpload } from '@/features/multi/media-upload/hooks'
import { Button, Skeleton } from '@/shared/ui'

export const Route = createFileRoute('/multi/events_/$eventId')({
  component: RouteComponent,
})

function RouteComponent() {
  const { eventId } = Route.useParams()
  const queryClient = useQueryClient()
  const { events, isLoading: eventsLoading } = useMultiEvents()
  const event = events.find((e) => e.id === eventId)

  const photos = useEventPhotos(eventId)
  const upload = useBulkUpload(eventId)

  // Refresh the grid as uploads finish.
  const finished = upload.stats.success
  useEffect(() => {
    if (finished > 0) {
      void queryClient.invalidateQueries({ queryKey: eventPhotosKey(eventId) })
    }
  }, [finished, eventId, queryClient])

  return (
    <div className="space-y-8 p-4 md:p-6">
      <PageHeader
        eyebrow="Event"
        title={event?.name ?? (eventsLoading ? 'Loading…' : 'Event')}
        description={
          event
            ? `Join code ${event.eventCode}. Archived events still accept photos.`
            : 'Photos of this event.'
        }
        actions={
          <div className="flex flex-wrap items-center gap-2">
            {event ? <EventStatusBadge status={event.status} /> : null}
            <Button
              render={<Link to="/multi/drop" />}
              className="bg-[#F9FAFF] text-[#00012C] hover:bg-white"
            >
              <FolderInput className="mr-2 size-4" />
              Drop a Drive
            </Button>
          </div>
        }
      />

      <Link
        to="/multi/events"
        className="text-muted-foreground hover:text-foreground inline-flex items-center gap-1.5 text-sm"
      >
        <ArrowLeft className="size-4" />
        All events
      </Link>

      <section className="space-y-3">
        <h2 className="text-muted-foreground text-xs font-semibold tracking-[0.14em] uppercase">
          Photos {photos.isLoading ? '' : `· ${photos.total}`}
        </h2>
        {eventsLoading && !event ? (
          <Skeleton className="h-40 rounded-2xl" />
        ) : (
          <EventPhotoGrid
            eventId={eventId}
            photos={photos.photos}
            total={photos.total}
            isLoading={photos.isLoading}
            isFetchingMore={photos.isFetchingNextPage}
            hasMore={photos.hasNextPage}
            onLoadMore={() => void photos.fetchNextPage()}
          />
        )}
      </section>

      <section className="space-y-3">
        <h2 className="text-muted-foreground text-xs font-semibold tracking-[0.14em] uppercase">
          Add photos
        </h2>
        <UploadDropzone onFilesSelected={upload.addFiles} />
        <UploadSummary
          stats={upload.stats}
          isPaused={upload.isPaused}
          onRetryFailed={() => void upload.retryFailed()}
          onPauseAll={upload.pauseAll}
          onContinueAll={upload.continueAll}
        />
        <UploadList
          items={upload.items}
          onRetry={upload.retryOne}
          onRemove={upload.removeItem}
        />
      </section>
    </div>
  )
}
