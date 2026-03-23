import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/shared/ui';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui';

import { type SyncInterval, SYNC_INTERVALS } from '../types';

interface Props {
  value: SyncInterval;
  onChange: (minutes: SyncInterval) => void;
}

export function SyncFrequencyCard({ value, onChange }: Props) {
  return (
    <Card className="border-border/40 bg-card/60 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="text-xl">Sync Frequency</CardTitle>
        <CardDescription>Auto-sync configuration</CardDescription>
      </CardHeader>
      <CardContent className="space-y-5">
        <div className="space-y-5">
          <label className="mb-3 text-sm font-medium">Sync every</label>
          <Select
            value={value.toString()}
            onValueChange={(v) => onChange(Number(v) as SyncInterval)}
          >
            <SelectTrigger className="w-full max-w-xs">
              <SelectValue placeholder="Select interval" />
            </SelectTrigger>
            <SelectContent>
              {SYNC_INTERVALS.map((min) => (
                <SelectItem key={min} value={min.toString()}>
                  {min} minutes
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <p className="text-muted-foreground text-sm italic">
          Files will automatically sync with Google Drive every {value} minutes.
          This keeps your media library up to date.
        </p>
      </CardContent>
    </Card>
  );
}
