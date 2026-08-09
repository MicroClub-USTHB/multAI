import { StatsCard } from '@/features/common/components/stats-card';
import { AlertsPanel } from '@/features/multi/stats/components/alerts-panel';
import { EventSummaryChart } from '@/features/multi/stats/components/event-summary-chart';
import { ProcessingJobs } from '@/features/multi/stats/components/processing-jobs';
import {
  useAlerts,
  useEventSummary,
  useMultiStats,
} from '@/features/multi/stats/hooks';
import { createFileRoute } from '@tanstack/react-router';
import { Calendar, ListOrdered, Settings, Users } from 'lucide-react';

export const Route = createFileRoute('/multi/')({
  component: RouteComponent,
});

function RouteComponent() {
  const { data: statsData, isLoading: statsLoading } = useMultiStats();
  const { data: alertsData, isLoading: alertsLoading } = useAlerts();
  const { data: eventSummary, isLoading: eventSummaryLoading } =
    useEventSummary();

  const statsCards = statsData
    ? [
        {
          title: 'Active events',
          value: statsData.activeEvents.toString(),
          icon: Calendar,
        },
        {
          title: 'Photos Uploaded',
          value: statsData.photosUploaded.toLocaleString(),
          icon: Users,
        },
        {
          title: 'Processed',
          value: statsData.processed.toLocaleString(),
          icon: Settings,
        },
        {
          title: 'In Queue',
          value: statsData.inQueue.toString(),
          icon: ListOrdered,
        },
      ]
    : [];

  return (
    <div className='bg-sidebar text-sidebar-foreground'>
      <div className='space-y-6 p-6'>
        <div className='flex items-center justify-between'>
          <h1 className='text-3xl font-bold text-sidebar-foreground'>
            Welcome Back, Staff!
          </h1>
        </div>

        <div className='grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4'>
          {statsLoading
            ? Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className='rounded-lg border border-sidebar-border p-6 animate-pulse'
                >
                  <div className='flex items-center space-x-3'>
                    <div className='h-6 w-6 rounded bg-sidebar-accent'></div>
                    <div className='h-8 w-16 rounded bg-sidebar-accent'></div>
                  </div>
                  <div className='mt-2 h-4 w-20 rounded bg-sidebar-accent'></div>
                </div>
              ))
            : statsCards.map((stat, index) => (
                <StatsCard key={index} {...stat} />
              ))}
        </div>

        <div className='flex flex-col lg:flex-row gap-6'>
          <div className='space-y-6 flex-1'>
            <EventSummaryChart
              data={eventSummary}
              isLoading={eventSummaryLoading}
            />
            <ProcessingJobs />
          </div>
          <AlertsPanel
            className='h-full w-full lg:w-1/3'
            data={alertsData}
            isLoading={alertsLoading}
          />
        </div>
      </div>
    </div>
  );
}
