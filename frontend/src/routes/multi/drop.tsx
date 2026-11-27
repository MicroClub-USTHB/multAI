import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'

import { DriveDropForm } from '@/features/multi/drive-drop/components/drive-drop-form'
import { DriveDropProgress } from '@/features/multi/drive-drop/components/drive-drop-progress'
import { useDropDriveFolder, useDropProgress } from '@/features/multi/drive-drop/hooks'

export const Route = createFileRoute('/multi/drop')({
  component: RouteComponent,
})

function RouteComponent() {
  const [groupId, setGroupId] = useState<string | null>(null)
  const drop = useDropDriveFolder()
  const progress = useDropProgress(groupId)

  return (
    <div className="mx-auto w-full max-w-xl flex-1 space-y-6 p-4 md:p-6">
      <div className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">Drop a Drive</h1>
        <p className="text-sm text-muted-foreground">
          Paste a folder link. Every photo is imported, checked for faces, and sent to the people
          in them. No review step. Admin only.
        </p>
      </div>

      {groupId ? (
        <DriveDropProgress
          group={progress.data}
          onReset={() => {
            setGroupId(null)
            drop.reset()
          }}
        />
      ) : (
        <DriveDropForm
          isSubmitting={drop.isPending}
          error={drop.error ? drop.error.message : null}
          onSubmit={(input) =>
            drop.mutate(input, { onSuccess: (res) => setGroupId(res.group_id) })
          }
        />
      )}
    </div>
  )
}
