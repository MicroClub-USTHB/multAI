import { createFileRoute } from '@tanstack/react-router'
import { useState } from 'react'

import { PageHeader } from '@/components/PageHeader'
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
    <div className="mx-auto w-full max-w-3xl space-y-6 p-4 md:p-6">
      <PageHeader
        eyebrow="Admin only"
        title="Drop a Drive"
        description="Paste a folder link. Every photo is imported, checked for faces, and sent to the people in them. There is no review step."
      />

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
