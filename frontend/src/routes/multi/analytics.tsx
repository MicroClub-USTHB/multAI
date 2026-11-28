import { createFileRoute } from '@tanstack/react-router';
import { CalendarCheck, Clock3, Images, ScanFace } from 'lucide-react';
import { Bar, BarChart, CartesianGrid, XAxis } from 'recharts';

import { EmptyState } from '@/components/EmptyState';
import { PageHeader } from '@/components/PageHeader';
import { StatsCard } from '@/features/common/components/stats-card';
import { useAnalytics } from '@/features/multi/analytics/use-analytics';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/shared/ui';

export const Route = createFileRoute('/multi/analytics')({
  component: RouteComponent,
});

const chartConfig = {
  photos: { label: 'Photos imported', color: 'var(--chart-1)' },
} satisfies ChartConfig;

const CARD =
  'border-border rounded-2xl border bg-card shadow-[0_1px_0_rgba(0,1,44,0.04),0_24px_48px_-28px_rgba(0,1,44,0.28)]';

const percent = (part: number, whole: number) =>
  whole > 0 ? Math.round((part / whole) * 100) : 0;

function RouteComponent() {
  const a = useAnalytics();
  const hasData = a.imported > 0 || a.perEvent.length > 0;

  return (
    <div className='space-y-6 p-4 md:p-6'>
      <PageHeader
        eyebrow='Staff dashboard'
        title='Analytics'
        description='Live numbers from your events and imports. Nothing here is a sample.'
      />

      <div className='grid grid-cols-2 gap-4 lg:grid-cols-4'>
        <StatsCard
          title={`Live events (of ${a.totalEvents})`}
          value={a.liveEvents.toString()}
          icon={CalendarCheck}
          tone='periwinkle'
        />
        <StatsCard
          title='Photos imported'
          value={a.imported.toLocaleString()}
          icon={Images}
          tone='navy'
        />
        <StatsCard
          title={`Faces matched (${percent(a.processed, a.imported)}%)`}
          value={a.processed.toLocaleString()}
          icon={ScanFace}
          tone='lavender'
        />
        <StatsCard
          title={a.failed > 0 ? `Waiting review · ${a.failed} failed` : 'Waiting review'}
          value={a.pendingReview.toString()}
          icon={Clock3}
          tone='indigo'
        />
      </div>

      {a.isLoading ? (
        <div className='bg-muted h-64 animate-pulse rounded-2xl' />
      ) : !hasData ? (
        <Card className={CARD}>
          <EmptyState
            title='No imports yet'
            description='Import photos to an event and the numbers will appear here.'
          />
        </Card>
      ) : (
        <div className='grid gap-6 lg:grid-cols-5'>
          <Card className={`${CARD} lg:col-span-3`}>
            <CardHeader>
              <CardTitle>Photos imported, last 14 days</CardTitle>
            </CardHeader>
            <CardContent>
              <ChartContainer config={chartConfig} className='h-60 w-full'>
                <BarChart data={a.perDay} margin={{ top: 8, right: 8, left: 8, bottom: 0 }}>
                  <CartesianGrid vertical={false} strokeOpacity={0.2} />
                  <XAxis
                    dataKey='day'
                    tickLine={false}
                    axisLine={false}
                    interval={1}
                    tick={{ fill: 'var(--muted-foreground)', fontSize: 11 }}
                  />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <Bar dataKey='photos' fill='var(--color-photos)' radius={[6, 6, 0, 0]} />
                </BarChart>
              </ChartContainer>
            </CardContent>
          </Card>

          <Card className={`${CARD} lg:col-span-2`}>
            <CardHeader>
              <CardTitle>By event</CardTitle>
            </CardHeader>
            <CardContent className='space-y-5'>
              {a.perEvent.length === 0 ? (
                <p className='text-muted-foreground text-sm'>No events with imports yet.</p>
              ) : (
                a.perEvent.map((row) => (
                  <div key={row.eventId} className='space-y-1.5'>
                    <div className='flex items-baseline justify-between gap-3 text-sm'>
                      <span className='truncate font-medium'>{row.name}</span>
                      <span className='text-muted-foreground shrink-0 tabular-nums'>
                        {row.processed.toLocaleString()} / {row.imported.toLocaleString()}
                      </span>
                    </div>
                    <div className='bg-muted flex h-2 overflow-hidden rounded-full'>
                      <div
                        className='h-full bg-[#5B63E8]'
                        style={{ width: `${percent(row.processed, row.imported)}%` }}
                      />
                      <div
                        className='h-full bg-red-400'
                        style={{ width: `${percent(row.failed, row.imported)}%` }}
                      />
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </div>
      )}

      {a.recent.length > 0 ? (
        <Card className={CARD}>
          <CardHeader>
            <CardTitle>Recent imports</CardTitle>
          </CardHeader>
          <CardContent className='divide-border divide-y'>
            {a.recent.map(({ group, eventName }) => (
              <div key={group.id} className='flex items-center justify-between gap-4 py-3 text-sm'>
                <div className='min-w-0'>
                  <p className='truncate font-medium'>{eventName}</p>
                  <p className='text-muted-foreground truncate font-mono text-xs'>
                    {group.folder_id}
                  </p>
                </div>
                <div className='text-muted-foreground shrink-0 text-right tabular-nums'>
                  <p>
                    {group.processed_photo_count} / {group.total_photo_count} photos
                  </p>
                  <p className='text-xs capitalize'>
                    {group.status === 'approved' ? group.processing_status : group.status}
                  </p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}
