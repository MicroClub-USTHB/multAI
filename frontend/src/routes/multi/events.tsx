import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/multi/events')({
  component: RouteComponent,
});

function RouteComponent() {
  return <div>Hello "/multi/events"!</div>;
}
