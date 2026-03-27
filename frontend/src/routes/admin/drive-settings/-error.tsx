import { useRouter } from '@tanstack/react-router';
import { AlertTriangle } from 'lucide-react';

import { Button } from '@/shared/ui';

interface DriveSettingsErrorProps {
  error: unknown;
}

export default function DriveSettingsError({ error }: DriveSettingsErrorProps) {
  const router = useRouter();
  const onRetry = () => {
    router.invalidate();
  };

  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <h1 className="text-3xl font-bold">Drive Settings</h1>

        <div className="border-destructive/40 bg-destructive/10 text-destructive rounded-lg border p-4 text-sm">
          <div className="mb-3 flex items-center gap-2 font-medium">
            <AlertTriangle className="h-4 w-4" />
            Failed to load Drive settings
          </div>
          <p>{error instanceof Error ? error.message : 'Unknown error.'}</p>
          <Button className="mt-4" variant="outline" onClick={onRetry}>
            Retry
          </Button>
        </div>
      </div>
    </div>
  );
}
