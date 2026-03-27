import type { FaceMatchingLog, SyncError } from '@/features/admin/logs/types';

import { Badge } from '@/shared/ui';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

const sourceVariants = {
  Drive: 'border-blue-500/80 text-blue-400',
  Storage: 'border-violet-500/80 text-violet-400',
  Worker: 'border-amber-500/80 text-amber-400',
};

const statusVariants = {
  Resolved: 'border-emerald-500/90 text-emerald-400',
  Investigating: 'border-yellow-500/90 text-yellow-300',
  Unresolved: 'border-red-500/90 text-red-400',
};

const resultVariants = {
  Success: 'border-emerald-500/90 text-emerald-400',
  Partial: 'border-yellow-500/90 text-yellow-300',
  Failed: 'border-red-500/90 text-red-400',
};

type LogDetailsState =
  | { type: 'sync'; data: SyncError }
  | { type: 'face'; data: FaceMatchingLog }
  | null;

type LogDetailsDialogProps = {
  details: LogDetailsState;
  onOpenChange: (open: boolean) => void;
};

function RowField({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[110px_1fr] items-start gap-2 text-sm">
      <span className="text-muted-foreground">{label}</span>
      <div className="min-w-0">{value}</div>
    </div>
  );
}

export function LogDetailsDialog({
  details,
  onOpenChange,
}: LogDetailsDialogProps) {
  const detailsTitle = !details
    ? ''
    : details.type === 'sync'
      ? 'Sync Error Details'
      : 'Face Matching Details';

  return (
    <Dialog open={Boolean(details)} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-xl">
        <DialogHeader>
          <DialogTitle>{detailsTitle}</DialogTitle>
          <DialogDescription>
            Detailed information for the selected log row.
          </DialogDescription>
        </DialogHeader>

        {details?.type === 'sync' && (
          <div className="space-y-3">
            <RowField label="Timestamp" value={details.data.timestamp} />
            <RowField
              label="Source"
              value={
                <Badge
                  variant="outline"
                  className={cn(
                    'h-6 rounded-sm bg-transparent px-3 text-xs',
                    sourceVariants[details.data.source],
                  )}
                >
                  {details.data.source}
                </Badge>
              }
            />
            <RowField
              label="Status"
              value={
                <Badge
                  variant="outline"
                  className={cn(
                    'h-6 rounded-sm bg-transparent px-3 text-xs',
                    statusVariants[details.data.status],
                  )}
                >
                  {details.data.status}
                </Badge>
              }
            />
            <RowField
              label="Message"
              value={
                <p className="text-foreground/90 leading-relaxed">
                  {details.data.errorMessage}
                </p>
              }
            />
          </div>
        )}

        {details?.type === 'face' && (
          <div className="space-y-3">
            <RowField label="Timestamp" value={details.data.timestamp} />
            <RowField label="Photo ID" value={details.data.photoId} />
            <RowField
              label="Faces"
              value={details.data.facesDetected.toString()}
            />
            <RowField
              label="Matched Users"
              value={
                details.data.matchedUsers.length ? (
                  <div className="flex flex-wrap gap-1">
                    {details.data.matchedUsers.map((user) => (
                      <Badge
                        key={user}
                        variant="outline"
                        className="border-border/70 text-muted-foreground h-6 rounded-sm bg-transparent px-2.5 text-xs"
                      >
                        {user}
                      </Badge>
                    ))}
                  </div>
                ) : (
                  <span className="text-muted-foreground">No matches</span>
                )
              }
            />
            <RowField
              label="Result"
              value={
                <Badge
                  variant="outline"
                  className={cn(
                    'h-6 rounded-sm bg-transparent px-3 text-xs',
                    resultVariants[details.data.result],
                  )}
                >
                  {details.data.result}
                </Badge>
              }
            />
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}

export type { LogDetailsState };
