import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/admin/drive-settings')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/admin/drive-settings"!</div>
}
