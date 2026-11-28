import { ImageOff } from 'lucide-react'
import { useState } from 'react'

import { Button, Skeleton } from '@/shared/ui'

import type { EventPhoto } from '../types'

import { eventPhotoImageUrl } from '../api'

interface EventPhotoGridProps {
  eventId: string
  photos: EventPhoto[]
  total: number
  isLoading: boolean
  isFetchingMore: boolean
  hasMore: boolean
  onLoadMore: () => void
}

function PhotoTile({ eventId, photo }: { eventId: string; photo: EventPhoto }) {
  const [failed, setFailed] = useState(false)

  return (
    <div className="bg-muted relative aspect-square overflow-hidden rounded-xl">
      {failed ? (
        <div className="text-muted-foreground flex h-full flex-col items-center justify-center gap-1 text-xs">
          <ImageOff className="size-5" />
          Unavailable
        </div>
      ) : (
        <img
          src={eventPhotoImageUrl(eventId, photo.id)}
          alt=""
          loading="lazy"
          decoding="async"
          className="size-full object-cover"
          onError={() => setFailed(true)}
        />
      )}
      <div className="absolute inset-x-0 bottom-0 flex items-center justify-between gap-1 bg-gradient-to-t from-black/60 to-transparent px-2 pt-6 pb-1.5 text-[10px] font-medium text-white">
        <span>{photo.status}</span>
        <span>
          {photo.face_count} {photo.face_count === 1 ? 'face' : 'faces'}
        </span>
      </div>
    </div>
  )
}

export function EventPhotoGrid({
  eventId,
  photos,
  total,
  isLoading,
  isFetchingMore,
  hasMore,
  onLoadMore,
}: EventPhotoGridProps) {
  if (isLoading) {
    return (
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5 xl:grid-cols-6">
        {Array.from({ length: 12 }).map((_, i) => (
          <Skeleton key={i} className="aspect-square rounded-xl" />
        ))}
      </div>
    )
  }

  if (photos.length === 0) {
    return (
      <div className="border-border text-muted-foreground rounded-2xl border border-dashed p-10 text-center text-sm">
        No photos in this event yet. Upload some below, or drop a Drive folder.
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5 xl:grid-cols-6">
        {photos.map((photo) => (
          <PhotoTile key={photo.id} eventId={eventId} photo={photo} />
        ))}
      </div>
      <div className="flex items-center justify-between">
        <p className="text-muted-foreground text-sm">
          Showing {photos.length} of {total}
        </p>
        {hasMore ? (
          <Button variant="outline" onClick={onLoadMore} disabled={isFetchingMore}>
            {isFetchingMore ? 'Loading…' : 'Load more'}
          </Button>
        ) : null}
      </div>
    </div>
  )
}
