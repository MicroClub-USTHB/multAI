import { CalendarDays, Check } from 'lucide-react';

import { useMultiEventsQuery } from '@/features/multi/events/hooks';
import { Skeleton } from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

interface EventPickerProps {
  value: string | null;
  onChange: (eventId: string) => void;
  disabled?: boolean;
}

const formatDate = (value: string) =>
  new Date(value).toLocaleDateString(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });

/** Events as cards, so the target of an upload is always visible. */
export function EventPicker({ value, onChange, disabled }: EventPickerProps) {
  const { data: events, isLoading } = useMultiEventsQuery();
  const options = (events ?? []).filter((event) => event.status !== 'archived');

  if (isLoading) {
    return (
      <div className='grid gap-3 sm:grid-cols-2 lg:grid-cols-3'>
        <Skeleton className='h-20 rounded-2xl' />
        <Skeleton className='h-20 rounded-2xl' />
        <Skeleton className='h-20 rounded-2xl' />
      </div>
    );
  }

  if (options.length === 0) {
    return (
      <p className='text-muted-foreground text-sm'>
        No open events. Create one in HR-Events first.
      </p>
    );
  }

  return (
    <div className='grid gap-3 sm:grid-cols-2 lg:grid-cols-3'>
      {options.map((event) => {
        const selected = event.id === value;
        return (
          <button
            key={event.id}
            type='button'
            disabled={disabled}
            onClick={() => onChange(event.id)}
            aria-pressed={selected}
            className={cn(
              'border-border bg-card flex items-start justify-between gap-3 rounded-2xl border p-4 text-left transition-all disabled:opacity-60',
              selected
                ? 'border-[#5B63E8] ring-2 ring-[#5B63E8]/30'
                : 'hover:border-foreground/30',
            )}
          >
            <span className='min-w-0'>
              <span className='block truncate font-semibold tracking-[-0.01em]'>
                {event.name}
              </span>
              <span className='text-muted-foreground mt-1 flex items-center gap-1.5 text-xs'>
                <CalendarDays className='size-3.5' />
                {formatDate(event.eventDate)}
              </span>
            </span>
            <span
              className={cn(
                'grid size-6 shrink-0 place-items-center rounded-full border',
                selected
                  ? 'border-[#5B63E8] bg-[#5B63E8] text-white'
                  : 'border-border text-transparent',
              )}
            >
              <Check className='size-3.5' />
            </span>
          </button>
        );
      })}
    </div>
  );
}
