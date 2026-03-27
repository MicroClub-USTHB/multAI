import { AlertTriangle } from 'lucide-react';

interface AdminIndexErrorProps {
  error: unknown;
}

export function AdminIndexError({ error }: AdminIndexErrorProps) {
  return (
    <div className="rounded-lg border border-destructive/40 bg-destructive/10 p-4 text-sm text-destructive">
      <div className="mb-2 flex items-center gap-2 font-medium">
        <AlertTriangle className="h-4 w-4" />
        Failed to load admin dashboard data
      </div>
      <p>{error instanceof Error ? error.message : 'Unknown error.'}</p>
    </div>
  );
}
