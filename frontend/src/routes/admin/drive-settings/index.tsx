import { createFileRoute } from '@tanstack/react-router';
import { CheckCircle2 } from 'lucide-react';

import type { SyncInterval } from '@/features/admin/drive/types';

import { GoogleDriveAuthCard } from '@/features/admin/drive/components/google-auth-card';
import { OutputFolderCard } from '@/features/admin/drive/components/output-folder-card';
import { SyncFrequencyCard } from '@/features/admin/drive/components/sync-frequency-card';
import { useDriveSettings } from '@/features/admin/drive/hooks';
import { driveSettingsQueryOptions } from '@/features/admin/drive/query-options';

import DriveSettingsError from './-error';
import DriveSettingsPending from './-pending';

export const Route = createFileRoute('/admin/drive-settings/')({
  loader: async ({ context }) => {
    await context.queryClient.ensureQueryData(driveSettingsQueryOptions());
  },
  pendingComponent: DriveSettingsPending,
  errorComponent: DriveSettingsError,
  component: RouteComponent,
});

function RouteComponent() {
  const {
    settings,
    connect,
    updateSyncFrequency,
    updateOutputFolder,
    connectIsLoading,
    syncIsLoading,
    outputIsLoading,
    actionFeedback,
  } = useDriveSettings();

  const handleConnect = async (apiKey: string) => {
    await connect({ apiKey });
  };

  const handleSyncChange = async (minutes: SyncInterval) => {
    await updateSyncFrequency({ syncInterval: minutes });
  };

  const handleOutputPathSave = async (path: string) => {
    await updateOutputFolder({ outputFolder: path });
  };

  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div>
          <h1 className="text-3xl font-bold">Drive Settings</h1>
          <p className="text-muted-foreground mt-1">
            Configure Google Drive integration and synchronization.
          </p>
        </div>

        {actionFeedback?.tone === 'error' ? (
          <div className="border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm">
            {actionFeedback.message}
          </div>
        ) : null}

        {actionFeedback?.tone === 'success' ? (
          <div className="flex items-center gap-2 rounded-lg border border-emerald-500/30 bg-emerald-500/10 p-4 text-sm text-emerald-300">
            <CheckCircle2 className="h-4 w-4" />
            {actionFeedback.message}
          </div>
        ) : null}

        <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
          <GoogleDriveAuthCard
            isConnected={settings.isConnected}
            isLoading={connectIsLoading}
            onConnect={handleConnect}
          />

          <SyncFrequencyCard
            value={settings.syncInterval}
            isLoading={syncIsLoading}
            onChange={handleSyncChange}
          />

          <OutputFolderCard
            value={settings.outputFolder}
            isLoading={outputIsLoading}
            onSave={handleOutputPathSave}
          />
        </div>
      </div>
    </div>
  );
}
