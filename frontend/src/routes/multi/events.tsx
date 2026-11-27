import { createFileRoute } from '@tanstack/react-router';
import { ExternalLink, Search } from 'lucide-react';
import { useMemo, useState } from 'react';

import type { EventStatus } from '@/features/multi/events/types';

import { EmptyState } from '@/components/EmptyState';
import { PageHeader } from '@/components/PageHeader';
import { env } from '@/env';
import { EventCard } from '@/features/multi/events/components/event-card';
import { useMultiEvents } from '@/features/multi/events/hooks';
import {
  Alert,
  AlertDescription,
  AlertTitle,
  Button,
  Input,
  Skeleton,
  Tabs,
  TabsList,
  TabsTrigger,
} from '@/shared/ui';

export const Route = createFileRoute('/multi/events')({
  component: RouteComponent,
});

type Filter = EventStatus | 'all';

const FILTERS: { value: Filter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'scheduled', label: 'Live' },
  { value: 'draft', label: 'Draft' },
  { value: 'archived', label: 'Archived' },
];

function RouteComponent() {
  const { events, isLoading, isError, error } = useMultiEvents();
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');
  const hrEventsUrl = env.VITE_HR_EVENTS_URL || 'https://hr.microclub.info';

  const errorMessage = error instanceof Error ? error.message : 'Unknown error';

  const counts = useMemo(() => {
    const result: Record<Filter, number> = {
      all: events.length,
      scheduled: 0,
      draft: 0,
      archived: 0,
    };
    for (const event of events) result[event.status] += 1;
    return result;
  }, [events]);

  const visible = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return events.filter(
      (event) =>
        (filter === 'all' || event.status === filter) &&
        (needle === '' ||
          event.name.toLowerCase().includes(needle) ||
          event.eventCode.toLowerCase().includes(needle)),
    );
  }, [events, filter, query]);

  return (
    <div className='space-y-6 p-4 md:p-6'>
      <PageHeader
        eyebrow='Staff dashboard'
        title='Events'
        description='Pick an event to add photos. Share its code with attendees so they can join from the mobile app.'
        actions={
          <Button
            type='button'
            className='bg-[#F9FAFF] text-[#00012C] hover:bg-white'
            onClick={() => window.open(hrEventsUrl, '_blank')}
          >
            <ExternalLink className='mr-2 size-4' />
            Create in HR-Events
          </Button>
        }
      />

      {isError ? (
        <Alert variant='destructive'>
          <AlertTitle>Failed to load events</AlertTitle>
          <AlertDescription>{errorMessage}</AlertDescription>
        </Alert>
      ) : isLoading ? (
        <div className='grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3'>
          <Skeleton className='h-44 w-full rounded-2xl' />
          <Skeleton className='h-44 w-full rounded-2xl' />
          <Skeleton className='h-44 w-full rounded-2xl' />
        </div>
      ) : events.length === 0 ? (
        <EmptyState
          title='No events yet'
          description='Events created in HR-Events show up here once they sync.'
        />
      ) : (
        <>
          <div className='flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between'>
            <Tabs value={filter} onValueChange={(value) => setFilter(value as Filter)}>
              <TabsList>
                {FILTERS.map((item) => (
                  <TabsTrigger key={item.value} value={item.value}>
                    {item.label}
                    <span className='text-muted-foreground ml-1.5 text-xs tabular-nums'>
                      {counts[item.value]}
                    </span>
                  </TabsTrigger>
                ))}
              </TabsList>
            </Tabs>
            <div className='relative w-full sm:w-72'>
              <Search className='text-muted-foreground pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2' />
              <Input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder='Search name or code'
                className='bg-card pl-9'
              />
            </div>
          </div>

          {visible.length === 0 ? (
            <EmptyState
              title='No matching events'
              description='Try another filter or a different search.'
            />
          ) : (
            <div className='grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3'>
              {visible.map((event) => (
                <EventCard key={event.id} event={event} />
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}
