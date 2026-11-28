import { env } from '@/env'
import { api } from '@/shared/api/client'

import type { EventPhotosPage } from './types'

export const EVENT_PHOTOS_PAGE_SIZE = 24

export function listEventPhotos(eventId: string, offset: number) {
  return api.get<EventPhotosPage>(`/staff/events/${eventId}/photos`, {
    limit: EVENT_PHOTOS_PAGE_SIZE,
    offset,
  })
}

/** Same-origin URL, so the staff cookie authorises the <img> request. */
export function eventPhotoImageUrl(eventId: string, photoId: string) {
  const base = env.VITE_API_BASE_URL.replace(/\/+$/, '')
  return `${base}/staff/events/${eventId}/photos/${photoId}/image`
}
