import { useInfiniteQuery } from '@tanstack/react-query'

import { EVENT_PHOTOS_PAGE_SIZE, listEventPhotos } from './api'

export const eventPhotosKey = (eventId: string) =>
  ['multi', 'event-photos', eventId] as const

export function useEventPhotos(eventId: string) {
  const query = useInfiniteQuery({
    queryKey: eventPhotosKey(eventId),
    queryFn: ({ pageParam }) => listEventPhotos(eventId, pageParam),
    initialPageParam: 0,
    getNextPageParam: (last, pages) => {
      const loaded = pages.length * EVENT_PHOTOS_PAGE_SIZE
      return loaded < last.total ? loaded : undefined
    },
  })

  return {
    ...query,
    photos: query.data?.pages.flatMap((page) => page.items) ?? [],
    total: query.data?.pages[0]?.total ?? 0,
  }
}
