import { Card, CardContent } from '@/shared/ui'

interface EventsStatsCardsProps {
  total: number
  draft: number
  scheduled: number
  archived: number
}

function StatCard({
  label,
  value,
}: {
  label: string
  value: string
}) {
  return (
    <Card className="gap-3 py-4">
      <CardContent className="px-4">
        <p className="text-xs uppercase tracking-wide text-muted-foreground">{label}</p>
        <p className="mt-1 text-2xl font-semibold text-foreground">{value}</p>
      </CardContent>
    </Card>
  )
}

export function EventsStatsCards({
  total,
  draft,
  scheduled,
  archived,
}: EventsStatsCardsProps) {
  return (
    <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
      <StatCard label="Total events" value={total.toString()} />
      <StatCard label="Draft" value={draft.toString()} />
      <StatCard label="Scheduled" value={scheduled.toString()} />
      <StatCard label="Archived" value={archived.toString()} />
    </div>
  )
}
