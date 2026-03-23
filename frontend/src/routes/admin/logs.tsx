import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';

import { FaceMatchingLogsTable } from '@/features/admin/logs/components/face-matching-logs-table';
import {
  LogDetailsDialog,
  type LogDetailsState,
} from '@/features/admin/logs/components/log-details-dialog';
import { SyncErrorsTable } from '@/features/admin/logs/components/sync-errors-table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/shared/ui/tabs';

export const Route = createFileRoute('/admin/logs')({
  component: LogsView,
});

function LogsView() {
  const [logDetails, setLogDetails] = useState<LogDetailsState>(null);

  return (
    <>
      <div className="flex-1 space-y-6 p-4 md:p-6">
        <div className="space-y-4">
          <h1 className="text-4xl font-bold tracking-tight">Logs</h1>
          <div className="bg-border/50 h-px w-full" />
        </div>

        <Tabs defaultValue="sync" className="w-full">
          <TabsList
            variant="line"
            className="border-border/60 h-auto rounded-none border-b p-0"
          >
            <TabsTrigger value="sync">Sync Errors</TabsTrigger>
            <TabsTrigger value="face">Face Matching Logs</TabsTrigger>
          </TabsList>

          <TabsContent value="sync" className="mt-3 space-y-3">
            <p className="text-muted-foreground text-sm">
              Synchronization errors between system and storage services
            </p>
            <SyncErrorsTable
              onRowClick={(log) => setLogDetails({ type: 'sync', data: log })}
            />
          </TabsContent>

          <TabsContent value="face" className="mt-3 space-y-3">
            <p className="text-muted-foreground text-sm">
              AI face recognition processing results
            </p>
            <FaceMatchingLogsTable
              onRowClick={(log) => setLogDetails({ type: 'face', data: log })}
            />
          </TabsContent>
        </Tabs>
      </div>

      <LogDetailsDialog
        details={logDetails}
        onOpenChange={(open) => {
          if (!open) setLogDetails(null);
        }}
      />
    </>
  );
}
