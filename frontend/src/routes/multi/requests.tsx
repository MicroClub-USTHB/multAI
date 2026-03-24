import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/multi/requests')({
  component: RouteComponent,
});

function RouteComponent() {
  return <div>Hello "/multi/requests"!</div>;
}
