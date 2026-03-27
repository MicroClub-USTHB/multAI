import { createFileRoute } from '@tanstack/react-router';
import { Calendar, Users, Settings, ListOrdered } from 'lucide-react';

import { AlertsPanel } from '@/features/admin/stats/components/alerts-panel';
import { DriveStorageStatus } from '@/features/admin/stats/components/drive-storage-status';
import { ProcessingLoadChart } from '@/features/admin/stats/components/processing-load-chart';
import {
  useAdminStats,
  useAlerts,
  useDriveUsage,
  useProcessingLoad,
} from '@/features/admin/stats/hooks';
import {
  adminStatsQueryOptions,
  alertsQueryOptions,
  driveUsageQueryOptions,
  processingLoadQueryOptions,
} from '@/features/admin/stats/query-options';
import { StatsCard } from '@/features/common/components/stats-card';

import { AdminIndexError } from './-admin-index-error';
import { AdminIndexPending } from './-admin-index-pending';

export const Route = createFileRoute('/admin/')({
  loader: async ({ context }) => {
    await Promise.all([
      context.queryClient.ensureQueryData(adminStatsQueryOptions()),
      context.queryClient.ensureQueryData(driveUsageQueryOptions()),
      context.queryClient.ensureQueryData(alertsQueryOptions()),
      context.queryClient.ensureQueryData(processingLoadQueryOptions()),
    ]);
  },
  pendingComponent: AdminIndexPending,
  errorComponent: AdminIndexError,
  component: RouteComponent,
});

function RouteComponent() {
  const { data: adminStatsData } = useAdminStats();
  const { data: driveData } = useDriveUsage();
  const { data: alertsData } = useAlerts();
  const { data: processingLoadData } = useProcessingLoad();

  const statsCards = adminStatsData
    ? [
        {
          title: 'Active events',
          value: adminStatsData.activeEvents.toString(),
          icon: Calendar,
        },
        {
          title: 'Photos Uploaded',
          value: adminStatsData.photosUploaded.toLocaleString(),
          icon: Users,
        },
        {
          title: 'Processed',
          value: adminStatsData.processed.toLocaleString(),
          icon: Settings,
        },
        {
          title: 'In Queue',
          value: adminStatsData.inQueue.toString(),
          icon: ListOrdered,
        },
      ]
    : [];

  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div className="flex items-center justify-between">
          <h1 className="text-sidebar-foreground text-3xl font-bold">
            Welcome Back, Admin!
          </h1>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
          {statsCards.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <DriveStorageStatus data={driveData} />
            <ProcessingLoadChart data={processingLoadData} />
          </div>

          <div className="lg:sticky lg:top-6 lg:self-start">
            <AlertsPanel data={alertsData} />
          </div>
        </div>
      </div>
    </div>
  );
}
