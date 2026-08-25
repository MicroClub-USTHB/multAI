import { createFileRoute } from '@tanstack/react-router';

import { EventCard } from '@/features/multi/events/components/event-card';
import { EventForm } from '@/features/multi/events/components/event-form';
import { useMultiEvents } from '@/features/multi/events/hooks';
import { useAuth } from '@/hooks/useAuth';
import { Alert, AlertDescription, AlertTitle, Skeleton } from '@/shared/ui';

export const Route = createFileRoute('/multi/events')({
  component: RouteComponent,
});

function RouteComponent() {
  const { user } = useAuth();
  const isTeamLead = user?.role === 'multi_team_lead';
  const { events, isLoading, isError, error, createEvent, isMutating } =
    useMultiEvents();

  const errorMessage = error instanceof Error ? error.message : 'Unknown error';

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="space-y-2">
        <h1 className="text-4xl font-bold tracking-tight">Events</h1>
        <p className="text-muted-foreground max-w-2xl text-sm">
          Events your team is running. Share the code below with attendees to
          let them join from the mobile app.
        </p>
      </div>

      {isTeamLead ? (
        <EventForm
          isSubmitting={isMutating}
          onSubmit={async (input) => {
            await createEvent(input);
          }}
        />
      ) : null}

      {isError ? (
        <Alert variant="destructive">
          <AlertTitle>Failed to load events</AlertTitle>
          <AlertDescription>{errorMessage}</AlertDescription>
        </Alert>
      ) : isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-32 w-full" />
        </div>
      ) : events.length === 0 ? (
        <p className="text-muted-foreground text-sm">No events yet.</p>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {events.map((event) => (
            <EventCard key={event.id} event={event} />
          ))}
        </div>
      )}
    </div>
  );
}
