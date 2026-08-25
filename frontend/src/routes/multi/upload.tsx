import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';

import { EventSelect } from '@/features/multi/media-upload/components/event-select';
import { UploadDropzone } from '@/features/multi/media-upload/components/upload-dropzone';
import { UploadList } from '@/features/multi/media-upload/components/upload-list';
import { UploadSummary } from '@/features/multi/media-upload/components/upload-summary';
import { useBulkUpload } from '@/features/multi/media-upload/hooks';
import { Alert, AlertDescription, AlertTitle } from '@/shared/ui';

export const Route = createFileRoute('/multi/upload')({
  component: RouteComponent,
});

function RouteComponent() {
  const [eventId, setEventId] = useState<string | null>(null);
  const { items, stats, addFiles, retryOne, retryFailed, removeItem } =
    useBulkUpload(eventId);

  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="space-y-2">
        <h1 className="text-4xl font-bold tracking-tight">Upload &amp; Storage</h1>
        <p className="text-muted-foreground max-w-2xl text-sm">
          Upload event photos directly from your computer instead of Google
          Drive. Pick an event, then drag in as many photos as you need.
        </p>
      </div>

      <EventSelect value={eventId} onChange={setEventId} />

      {!eventId ? (
        <Alert>
          <AlertTitle>Choose an event first</AlertTitle>
          <AlertDescription>
            Photos are uploaded straight into the event you select above.
          </AlertDescription>
        </Alert>
      ) : (
        <>
          <UploadDropzone onFilesSelected={(files) => addFiles(files)} />
          <UploadSummary stats={stats} onRetryFailed={retryFailed} />
          <UploadList items={items} onRetry={retryOne} onRemove={removeItem} />
        </>
      )}
    </div>
  );
}
