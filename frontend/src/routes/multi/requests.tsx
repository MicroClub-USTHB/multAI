import { createFileRoute } from '@tanstack/react-router';
import { useMemo, useState } from 'react';

import type { UploadRequestGroupSummary } from '@/features/multi/uploads/types';

import { PageHeader } from '@/components/PageHeader';
import { UploadGroupReviewDialog } from '@/features/multi/uploads/components/upload-group-review-dialog';
import { UploadGroupsTable } from '@/features/multi/uploads/components/upload-groups-table';
import { useUploadGroups } from '@/features/multi/uploads/hooks';
import { useAuth } from '@/hooks/useAuth';
import { Card, CardContent, Tabs, TabsList, TabsTrigger } from '@/shared/ui';

export const Route = createFileRoute('/multi/requests')({
  component: RouteComponent,
});

type Filter = 'all' | 'pending' | 'approved' | 'rejected';

const FILTERS: { value: Filter; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'all', label: 'All' },
];

function RouteComponent() {
  const { user } = useAuth();
  const canModerate = user?.role === 'multi_team_lead' || user?.role === 'admin';
  const { groups, isLoading, isError } = useUploadGroups(
    canModerate ? 'all' : 'my',
  );
  const [reviewingGroupId, setReviewingGroupId] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>(canModerate ? 'pending' : 'all');

  const counts = useMemo(() => {
    const result: Record<Filter, number> = {
      all: groups.length,
      pending: 0,
      approved: 0,
      rejected: 0,
    };
    for (const group of groups) result[group.status] += 1;
    return result;
  }, [groups]);
  const visible = filter === 'all' ? groups : groups.filter((group) => group.status === filter);

  const handleReview = (group: UploadRequestGroupSummary) => {
    setReviewingGroupId(group.id);
  };

  return (
    <div className="space-y-6 p-4 md:p-6">
      <PageHeader
        eyebrow="Staff dashboard"
        title="Requests"
        description="Photo upload requests waiting for a review."
      />
      <Tabs value={filter} onValueChange={(value) => setFilter(value as Filter)}>
        <TabsList>
          {FILTERS.map((item) => (
            <TabsTrigger key={item.value} value={item.value}>
              {item.label}
              <span className="text-muted-foreground ml-1.5 text-xs tabular-nums">
                {counts[item.value]}
              </span>
            </TabsTrigger>
          ))}
        </TabsList>
      </Tabs>
      <Card className="border-border rounded-2xl border bg-card shadow-[0_1px_0_rgba(0,1,44,0.04),0_24px_48px_-28px_rgba(0,1,44,0.28)]">
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
              groups={visible}
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
