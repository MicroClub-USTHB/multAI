import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/multi/notifications')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/multi/notifications"!</div>
}
