import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/multi/upload')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/multi/upload"!</div>
}
