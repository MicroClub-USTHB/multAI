import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';

import type { UploadRequestGroupSummary } from '@/features/multi/uploads/types';

import { UploadGroupReviewDialog } from '@/features/multi/uploads/components/upload-group-review-dialog';
import { UploadGroupsTable } from '@/features/multi/uploads/components/upload-groups-table';
import { useUploadGroups } from '@/features/multi/uploads/hooks';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';

export const Route = createFileRoute('/multi/requests')({
  component: RouteComponent,
});

function RouteComponent() {
  const { user } = useAuth();
  const canModerate = user?.role === 'multi_team_lead' || user?.role === 'admin';
  const { groups, isLoading, isError } = useUploadGroups(
    canModerate ? 'all' : 'my',
  );
  const [reviewingGroupId, setReviewingGroupId] = useState<string | null>(null);

  const handleReview = (group: UploadRequestGroupSummary) => {
    setReviewingGroupId(group.id);
  };

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Upload Requests</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-muted-foreground py-8 text-center text-sm">
              Loading…
            </div>
          ) : isError ? (
            <div className="py-8 text-center text-sm text-red-400">
              Failed to load upload groups.
            </div>
          ) : (
            <UploadGroupsTable
              groups={groups}
              onReview={handleReview}
              canModerate={canModerate}
            />
          )}
        </CardContent>
      </Card>

      <UploadGroupReviewDialog
        groupId={reviewingGroupId}
        onOpenChange={(open) => {
          if (!open) setReviewingGroupId(null);
        }}
        canModerate={canModerate}
      />
    </div>
  );
}
