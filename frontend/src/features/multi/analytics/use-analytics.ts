import { useMemo } from 'react';

import { useMultiEventsQuery } from '@/features/multi/events/hooks';
import { useUploadGroups } from '@/features/multi/uploads/hooks';
import { useAuth } from '@/hooks/useAuth';

const DAY_MS = 24 * 60 * 60 * 1000;
const DAYS = 14;

export interface EventRow {
  eventId: string;
  name: string;
  imported: number;
  processed: number;
  failed: number;
}

export interface DayPoint {
  day: string;
  photos: number;
}

/** Real numbers only: everything is derived from the events and upload groups the API returns. */
export function useAnalytics() {
  const { user } = useAuth();
  const canModerate = user?.role === 'multi_team_lead' || user?.role === 'admin';
  const groupsQuery = useUploadGroups(canModerate ? 'all' : 'my');
  const eventsQuery = useMultiEventsQuery();

  const data = useMemo(() => {
    const groups = groupsQuery.groups;
    const events = eventsQuery.data ?? [];
    const names = new Map(events.map((event) => [event.id, event.name]));

    const counted = groups.filter((group) => group.status !== 'rejected');
    const imported = counted.reduce((sum, g) => sum + g.total_photo_count, 0);
    const processed = counted.reduce((sum, g) => sum + g.processed_photo_count, 0);
    const failed = counted.reduce((sum, g) => sum + g.failed_photo_count, 0);

    const perEvent = new Map<string, EventRow>();
    for (const group of counted) {
      const row = perEvent.get(group.event_id) ?? {
        eventId: group.event_id,
        name: names.get(group.event_id) ?? 'Unknown event',
        imported: 0,
        processed: 0,
        failed: 0,
      };
      row.imported += group.total_photo_count;
      row.processed += group.processed_photo_count;
      row.failed += group.failed_photo_count;
      perEvent.set(group.event_id, row);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const perDay: DayPoint[] = Array.from({ length: DAYS }, (_, index) => {
      const date = new Date(today.getTime() - (DAYS - 1 - index) * DAY_MS);
      return {
        day: date.toLocaleDateString(undefined, { day: '2-digit', month: 'short' }),
        photos: 0,
      };
    });
    for (const group of counted) {
      const created = new Date(group.created_at);
      created.setHours(0, 0, 0, 0);
      const offset = Math.round((today.getTime() - created.getTime()) / DAY_MS);
      if (offset >= 0 && offset < DAYS) {
        perDay[DAYS - 1 - offset]!.photos += group.total_photo_count;
      }
    }

    return {
      liveEvents: events.filter((event) => event.status === 'scheduled').length,
      totalEvents: events.length,
      imported,
      processed,
      failed,
      pendingReview: groups.filter((group) => group.status === 'pending').length,
      inProgress: groups.filter(
        (group) =>
          group.status === 'approved' &&
          (group.processing_status === 'pending' || group.processing_status === 'running'),
      ).length,
      perEvent: [...perEvent.values()].sort((a, b) => b.imported - a.imported).slice(0, 8),
      perDay,
      recent: [...groups]
        .sort((a, b) => b.created_at.localeCompare(a.created_at))
        .slice(0, 6)
        .map((group) => ({ group, eventName: names.get(group.event_id) ?? 'Unknown event' })),
    };
  }, [groupsQuery.groups, eventsQuery.data]);

  return {
    ...data,
    isLoading: groupsQuery.isLoading || eventsQuery.isLoading,
    isError: groupsQuery.isError || eventsQuery.isError,
  };
}
