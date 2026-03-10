import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/multi/team')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/multi/team"!</div>
}
