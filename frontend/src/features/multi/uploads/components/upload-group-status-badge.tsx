import { Badge } from '@/shared/ui'
import { cn } from '@/shared/utils/helpers'

import type { UploadStatus } from '../types'

const STATUS_CLASSES: Record<UploadStatus, string> = {
  pending: 'border-yellow-500/90 text-yellow-300',
  approved: 'border-emerald-500/90 text-emerald-400',
  rejected: 'border-red-500/90 text-red-400',
}

const STATUS_LABELS: Record<UploadStatus, string> = {
  pending: 'Pending',
  approved: 'Approved',
  rejected: 'Rejected',
}

export function UploadGroupStatusBadge({ status }: { status: UploadStatus }) {
  return (
    <Badge
      variant="outline"
      className={cn('h-6 rounded-sm bg-transparent px-3 text-xs', STATUS_CLASSES[status])}
    >
      {STATUS_LABELS[status]}
    </Badge>
  )
}