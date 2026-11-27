import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';
import { z } from 'zod';

import { PageHeader } from '@/components/PageHeader';
import { EventPicker } from '@/features/multi/media-upload/components/event-picker';
import { UploadDropzone } from '@/features/multi/media-upload/components/upload-dropzone';
import { UploadList } from '@/features/multi/media-upload/components/upload-list';
import { UploadSummary } from '@/features/multi/media-upload/components/upload-summary';
import { useBulkUpload } from '@/features/multi/media-upload/hooks';

export const Route = createFileRoute('/multi/upload')({
  component: RouteComponent,
  validateSearch: z.object({ event: z.string().optional() }),
});

function RouteComponent() {
  const { event } = Route.useSearch();
  const [eventId, setEventId] = useState<string | null>(event ?? null);
  const {
    items,
    stats,
    isPaused,
    addFiles,
    retryOne,
    retryFailed,
    pauseAll,
    continueAll,
    removeItem,
  } = useBulkUpload(eventId);

  return (
    <div className="space-y-8 p-4 md:p-6">
      <PageHeader
        eyebrow="Staff dashboard"
        title="Upload photos"
        description="Choose the event, then drag in as many photos as you need. Uploads continue in the background."
      />

      <section className="space-y-3">
        <h2 className="text-muted-foreground text-xs font-semibold tracking-[0.14em] uppercase">
          1 · Choose an event
        </h2>
        <EventPicker value={eventId} onChange={setEventId} />
      </section>

      <section className="space-y-3">
        <h2 className="text-muted-foreground text-xs font-semibold tracking-[0.14em] uppercase">
          2 · Add photos
        </h2>
        {!eventId ? (
          <div className="border-border text-muted-foreground rounded-2xl border border-dashed p-8 text-center text-sm">
            Pick an event above to start uploading.
          </div>
        ) : (
          <>
            <UploadDropzone onFilesSelected={addFiles} />
            <UploadSummary
              stats={stats}
              isPaused={isPaused}
              onRetryFailed={() => void retryFailed()}
              onPauseAll={pauseAll}
              onContinueAll={continueAll}
            />
            <UploadList items={items} onRetry={retryOne} onRemove={removeItem} />
          </>
        )}
      </section>
    </div>
  );
}
