import { createFileRoute } from '@tanstack/react-router';
import { AlertTriangle, CheckCircle2 } from 'lucide-react';

import { GoogleDriveAuthCard } from '@/features/admin/drive/components/google-auth-card';
import { OutputFolderCard } from '@/features/admin/drive/components/output-folder-card';
import { SyncFrequencyCard } from '@/features/admin/drive/components/sync-frequency-card';
import { useDriveSettings } from '@/features/admin/drive/hooks';
import { type SyncInterval } from '@/features/admin/drive/types';
import { Button } from '@/shared/ui';

export const Route = createFileRoute('/admin/drive-settings')({
  component: RouteComponent,
});

function RouteComponent() {
  const {
    settings,
    isLoading,
    isError,
    error,
    refetch,
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

  if (isLoading) {
    return (
      <div className="bg-sidebar text-sidebar-foreground">
        <div className="space-y-6 p-6">
          <div>
            <div className="bg-sidebar-accent/40 h-10 w-56 animate-pulse rounded-md" />
            <div className="bg-sidebar-accent/30 mt-2 h-5 w-96 animate-pulse rounded-md" />
          </div>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {Array.from({ length: 3 }).map((_, index) => (
              <div
                key={index}
                className="border-border/40 bg-card/40 h-[320px] animate-pulse rounded-lg border"
              />
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (isError || !settings) {
    return (
      <div className="bg-sidebar text-sidebar-foreground">
        <div className="space-y-6 p-6">
          <h1 className="text-3xl font-bold">Drive Settings</h1>

          <div className="border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm">
            <div className="mb-3 flex items-center gap-2 font-medium">
              <AlertTriangle className="h-4 w-4" />
              Failed to load Drive settings
            </div>
            <p>{error instanceof Error ? error.message : 'Unknown error.'}</p>
            <Button
              className="mt-4"
              variant="outline"
              onClick={() => refetch()}
            >
              Retry
            </Button>
          </div>
        </div>
      </div>
    );
  }

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
