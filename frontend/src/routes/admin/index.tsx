import { createFileRoute } from '@tanstack/react-router'
import { StatsCard } from '@/features/common/components/stats-card'
import { DriveStorageStatus } from '@/features/admin/stats/components/drive-storage-status'
import { ProcessingLoadChart } from '@/features/admin/stats/components/processing-load-chart'
import { useAdminStats, useDriveUsage, useAlerts, useProcessingLoad } from '@/features/admin/stats/hooks'
import {
  Calendar,
  Users,
  Settings,
  ListOrdered,
} from 'lucide-react'
import { AlertsPanel } from '@/features/admin/stats/components/alerts-panel'

export const Route = createFileRoute('/admin/')({
  component: RouteComponent,
})

function RouteComponent() {
  const { data: adminStatsData, isLoading: statsLoading } = useAdminStats()
  const { data: driveData, isLoading: driveLoading } = useDriveUsage()
  const { data: alertsData, isLoading: alertsLoading } = useAlerts()
  const { data: processingLoadData, isLoading: processingLoading } = useProcessingLoad()

  const statsCards = adminStatsData
    ? [
        { title: 'Active events', value: adminStatsData.activeEvents.toString(), icon: Calendar },
        { title: 'Photos Uploaded', value: adminStatsData.photosUploaded.toLocaleString(), icon: Users },
        { title: 'Processed', value: adminStatsData.processed.toLocaleString(), icon: Settings },
        { title: 'In Queue', value: adminStatsData.inQueue.toString(), icon: ListOrdered },
      ]
    : []

  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div className="flex items-center justify-between">
          <h1 className="text-3xl font-bold text-sidebar-foreground">Welcome Back, Admin!</h1>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
          {statsLoading ? (
            Array.from({ length: 4 }).map((_, index) => (
              <div key={index} className="rounded-lg border border-sidebar-border p-6 animate-pulse">
                <div className="flex items-center space-x-3">
                  <div className="h-6 w-6 rounded bg-sidebar-accent"></div>
                  <div className="h-8 w-16 rounded bg-sidebar-accent"></div>
                </div>
                <div className="mt-2 h-4 w-20 rounded bg-sidebar-accent"></div>
              </div>
            ))
          ) : (
            statsCards.map((stat, index) => (
              <StatsCard key={index} {...stat} />
            ))
          )}
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <DriveStorageStatus data={driveData} isLoading={driveLoading} />
            <ProcessingLoadChart data={processingLoadData} isLoading={processingLoading} />
          </div>

          <div className="lg:sticky lg:top-6 lg:self-start">
            <AlertsPanel data={alertsData} isLoading={alertsLoading} />
          </div>
        </div>
      </div>
    </div>
  )
}