import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'
import { GoogleDriveAuthCard } from '@/features/admin/drive/components/google-auth-card'
import { OutputFolderCard } from '@/features/admin/drive/components/output-folder-card'
import { SyncFrequencyCard } from '@/features/admin/drive/components/sync-frequency-card'
import { useDriveSettings } from '@/features/admin/drive/hooks'
import { type SyncInterval } from '@/features/admin/drive/types'
import { Button } from '@/shared/ui/button'
import { AlertTriangle, CheckCircle2 } from 'lucide-react'

export const Route = createFileRoute('/admin/drive-settings')({
  component: RouteComponent,
})

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
  } = useDriveSettings()

  const [actionError, setActionError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  const clearMessages = () => {
    setActionError(null)
    setSuccessMessage(null)
  }

  const handleConnect = async (apiKey: string) => {
    clearMessages()

    try {
      await connect({ apiKey })
      setSuccessMessage('Google Drive connected successfully.')
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'Unable to connect Google Drive.')
    }
  }

  const handleSyncChange = async (minutes: SyncInterval) => {
    clearMessages()

    try {
      await updateSyncFrequency({ syncInterval: minutes })
      setSuccessMessage(`Sync frequency updated to every ${minutes} minutes.`)
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'Unable to update sync frequency.')
    }
  }

  const handleOutputPathSave = async (path: string) => {
    clearMessages()

    try {
      await updateOutputFolder({ outputFolder: path })
      setSuccessMessage('Output folder updated successfully.')
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'Unable to update output folder.')
    }
  }

  if (isLoading) {
    return (
      <div className="bg-sidebar text-sidebar-foreground">
        <div className="space-y-6 p-6">
          <div>
            <div className="h-10 w-56 animate-pulse rounded-md bg-sidebar-accent/40" />
            <div className="mt-2 h-5 w-96 animate-pulse rounded-md bg-sidebar-accent/30" />
          </div>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {Array.from({ length: 3 }).map((_, index) => (
              <div
                key={index}
                className="h-[320px] animate-pulse rounded-lg border border-border/40 bg-card/40"
              />
            ))}
          </div>
        </div>
      </div>
    )
  }

  if (isError || !settings) {
    return (
      <div className="bg-sidebar text-sidebar-foreground">
        <div className="space-y-6 p-6">
          <h1 className="text-3xl font-bold">Drive Settings</h1>

          <div className="rounded-lg border border-destructive/40 bg-destructive/10 p-4 text-sm text-destructive">
            <div className="mb-3 flex items-center gap-2 font-medium">
              <AlertTriangle className="h-4 w-4" />
              Failed to load Drive settings
            </div>
            <p>{error instanceof Error ? error.message : 'Unknown error.'}</p>
            <Button className="mt-4" variant="outline" onClick={() => refetch()}>
              Retry
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div>
          <h1 className="text-3xl font-bold">Drive Settings</h1>
          <p className="mt-1 text-muted-foreground">
            Configure Google Drive integration and synchronization.
          </p>
        </div>

        {actionError ? (
          <div className="rounded-lg border border-destructive/40 bg-destructive/10 p-4 text-sm text-destructive">
            {actionError}
          </div>
        ) : null}

        {successMessage ? (
          <div className="flex items-center gap-2 rounded-lg border border-emerald-500/30 bg-emerald-500/10 p-4 text-sm text-emerald-300">
            <CheckCircle2 className="h-4 w-4" />
            {successMessage}
          </div>
        ) : null}

        <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
          <GoogleDriveAuthCard
            isConnected={settings.isConnected}
            onConnect={handleConnect}
          />

          <SyncFrequencyCard
            value={settings.syncInterval}
            onChange={handleSyncChange}
          />

          <OutputFolderCard
            value={settings.outputFolder}
            onSave={handleOutputPathSave}
          />
        </div>
      </div>
    </div>
  )
}
