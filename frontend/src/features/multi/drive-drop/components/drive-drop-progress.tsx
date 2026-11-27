import type { UploadRequestGroup } from '@/features/multi/uploads/types'

import { Alert, AlertDescription, Button } from '@/shared/ui'

interface DriveDropProgressProps {
  group: UploadRequestGroup | undefined
  onReset: () => void
}

export function DriveDropProgress({ group, onReset }: DriveDropProgressProps) {
  const total = group?.total_photo_count ?? 0
  const done = group?.processed_photo_count ?? 0
  const failed = group?.processing_status === 'failed'
  const imported = group?.processing_status === 'completed'
  const approved = imported && group?.status !== 'pending'

  const percent = total > 0 ? Math.round((done / total) * 100) : 0
  const steps = [
    { label: 'Reading the folder', complete: total > 0 || imported },
    { label: total > 0 ? `Copying photos (${done} / ${total})` : 'Copying photos', complete: imported },
    { label: 'Queued for face matching', complete: approved },
  ]

  return (
    <div className="space-y-6 rounded-xl border bg-card p-6">
      {failed ? (
        <Alert variant="destructive">
          <AlertDescription>
            {group?.error_message ?? 'The import failed. Check the folder link and sharing.'}
          </AlertDescription>
        </Alert>
      ) : (
        <>
          <ol className="space-y-3">
            {steps.map((step) => (
              <li key={step.label} className="flex items-center gap-3 text-sm">
                <span
                  className={
                    'flex size-5 items-center justify-center rounded-full border text-[10px] ' +
                    (step.complete ? 'border-primary bg-primary text-primary-foreground' : 'text-muted-foreground')
                  }
                >
                  {step.complete ? '✓' : ''}
                </span>
                <span className={step.complete ? '' : 'text-muted-foreground'}>{step.label}</span>
              </li>
            ))}
          </ol>
          <div className="h-2 overflow-hidden rounded-full bg-muted">
            <div
              className="h-full bg-primary transition-all duration-500"
              style={{ width: `${approved ? 100 : percent}%` }}
            />
          </div>
          {approved ? (
            <p className="text-sm text-muted-foreground">
              {total} photos are in. Face matching runs in the background, and matched people are
              notified as it goes.
            </p>
          ) : null}
        </>
      )}
      <Button variant="outline" onClick={onReset} disabled={!failed && !approved}>
        Drop another folder
      </Button>
    </div>
  )
}
