import { createFileRoute, redirect } from '@tanstack/react-router';

// Events is the first page; analytics lives on its own page.
export const Route = createFileRoute('/multi/')({
  beforeLoad: () => {
    throw redirect({ to: '/multi/events', replace: true });
  },
});
