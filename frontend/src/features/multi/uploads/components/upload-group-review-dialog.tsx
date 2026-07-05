import { useState } from 'react'

import { ApiError } from '@/shared/api/client'
import {
  Button,
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Textarea,
} from '@/shared/ui'

import { getPhotoPreviewUrl } from '../api'
import { useApproveUploadGroupMutation, useRejectUploadGroupMutation, useUploadGroupDetails } from '../hooks'

interface UploadGroupReviewDialogProps {
  groupId: string | null
  onOpenChange: (open: boolean) => void
  canModerate: boolean
}

function getErrorMessage(error: unknown, fallback: string): string {
  if (error instanceof ApiError && error.status === 403) {
    return 'You need multi team lead access to do this.'
  }
  return error instanceof Error ? error.message : fallback
}

export function UploadGroupReviewDialog({ groupId, onOpenChange, canModerate }: UploadGroupReviewDialogProps) {
  const [reason, setReason] = useState('')
  const [actionError, setActionError] = useState<string | null>(null)
  const { group, isLoading } = useUploadGroupDetails(groupId)
  const approveMutation = useApproveUploadGroupMutation()
  const rejectMutation = useRejectUploadGroupMutation()

  const isBusy = approveMutation.isPending || rejectMutation.isPending

  const handleApprove = () => {
    if (!groupId) return
    setActionError(null)
    approveMutation.mutate(groupId, {
      onSuccess: () => onOpenChange(false),
      onError: (error) => setActionError(getErrorMessage(error, 'Failed to approve upload group.')),
    })
  }

  const handleReject = () => {
    if (!groupId) return
    setActionError(null)
    rejectMutation.mutate(
      { groupId, reason: reason.trim() || undefined },
      {
        onSuccess: () => onOpenChange(false),
        onError: (error) => setActionError(getErrorMessage(error, 'Failed to reject upload group.')),
      },
    )
  }

  return (
    <Dialog
      open={Boolean(groupId)}
      onOpenChange={(open) => {
        if (!open) setActionError(null)
        onOpenChange(open)
      }}
    >
      <DialogContent className="max-w-3xl">
        <DialogHeader>
          <DialogTitle>Review Upload Group</DialogTitle>
          <DialogDescription>
            {group ? `Folder: ${group.folder_id}` : 'Loading group details…'}
          </DialogDescription>
        </DialogHeader>

        {isLoading || !group ? (
          <div className="text-muted-foreground py-8 text-center text-sm">Loading photos…</div>
        ) : (
          <>
            <div className="grid max-h-[420px] grid-cols-3 gap-3 overflow-y-auto sm:grid-cols-4">
              {group.requests.flatMap((request) =>
                request.photos.map((photo) => (
                  <div key={photo.id} className="space-y-1">
                    <img
                      src={getPhotoPreviewUrl(request.id, photo.id)}
                      alt={photo.file_name}
                      className="aspect-square w-full rounded-md border object-cover"
                      loading="lazy"
                    />
                    <p className="text-muted-foreground truncate text-xs">{photo.file_name}</p>
                  </div>
                )),
              )}
            </div>

            {canModerate && (
              <div className="space-y-1.5 pt-2">
                <label className="text-sm font-medium">Rejection reason (optional)</label>
                <Textarea
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Only needed if rejecting"
                  rows={2}
                />
              </div>
            )}

            {actionError && (
              <p className="text-sm text-red-400">{actionError}</p>
            )}
          </>
        )}

        {canModerate && (
          <DialogFooter>
            <Button
              variant="destructive"
              disabled={isBusy || !group}
              isLoading={rejectMutation.isPending}
              loadingText="Rejecting…"
              onClick={handleReject}
            >
              Reject
            </Button>
            <Button
              disabled={isBusy || !group}
              isLoading={approveMutation.isPending}
              loadingText="Approving…"
              onClick={handleApprove}
            >
              Approve
            </Button>
          </DialogFooter>
        )}
      </DialogContent>
    </Dialog>
  )
}