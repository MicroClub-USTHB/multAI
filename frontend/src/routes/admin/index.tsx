import { createFileRoute } from '@tanstack/react-router';
import { Calendar, Users, Settings, ListOrdered } from 'lucide-react';

import { AlertsPanel } from '@/features/admin/stats/components/alerts-panel';
import { DriveStorageStatus } from '@/features/admin/stats/components/drive-storage-status';
import { ProcessingLoadChart } from '@/features/admin/stats/components/processing-load-chart';
import {
  useAdminStats,
  useDriveUsage,
  useAlerts,
  useProcessingLoad,
} from '@/features/admin/stats/hooks';
import { StatsCard } from '@/features/common/components/stats-card';

export const Route = createFileRoute('/admin/')({
  component: RouteComponent,
});

function RouteComponent() {
  const { data: adminStatsData, isLoading: statsLoading } = useAdminStats();
  const { data: driveData, isLoading: driveLoading } = useDriveUsage();
  const { data: alertsData, isLoading: alertsLoading } = useAlerts();
  const { data: processingLoadData, isLoading: processingLoading } =
    useProcessingLoad();

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
          {statsLoading
            ? Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className="border-sidebar-border animate-pulse rounded-lg border p-6"
                >
                  <div className="flex items-center space-x-3">
                    <div className="bg-sidebar-accent h-6 w-6 rounded"></div>
                    <div className="bg-sidebar-accent h-8 w-16 rounded"></div>
                  </div>
                  <div className="bg-sidebar-accent mt-2 h-4 w-20 rounded"></div>
                </div>
              ))
            : statsCards.map((stat, index) => (
                <StatsCard key={index} {...stat} />
              ))}
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <DriveStorageStatus data={driveData} isLoading={driveLoading} />
            <ProcessingLoadChart
              data={processingLoadData}
              isLoading={processingLoading}
            />
          </div>

          <div className="lg:sticky lg:top-6 lg:self-start">
            <AlertsPanel data={alertsData} isLoading={alertsLoading} />
          </div>
        </div>
      </div>
    </div>
  );
}
