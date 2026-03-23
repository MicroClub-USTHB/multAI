import { Folder } from 'lucide-react';
import { useState } from 'react';

import { Button } from '@/shared/ui';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/shared/ui';
import { Input } from '@/shared/ui';

interface Props {
  value: string;
  onSave: (path: string) => Promise<void>;
}

export function OutputFolderCard({ value, onSave }: Props) {
  const [path, setPath] = useState(value);
  const [saving, setSaving] = useState(false);
  const hasChanged = path !== value;

  const handleSave = async () => {
    if (!path.trim() || !hasChanged) return;
    setSaving(true);

    try {
      await onSave(path.trim());
    } finally {
      setSaving(false);
    }
  };

  return (
    <Card className="border-border/40 bg-card/60 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="text-xl">Output Folders</CardTitle>
        <CardDescription>Storage configuration</CardDescription>
      </CardHeader>

      <CardContent className="space-y-5">
        <div className="space-y-2">
          <label className="text-sm font-medium">Current path</label>
          <div className="bg-muted/40 flex items-center gap-2 rounded-md border px-3 py-2 font-mono text-sm text-gray-400/90">
            <Folder className="h-4 w-4" />
            {value || '/media/processed'}
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">New output path</label>
          <Input
            value={path}
            onChange={(e) => setPath(e.target.value)}
            placeholder="/media/Processed"
            className="font-mono"
          />
          <p className="text-muted-foreground text-xs">
            Processed photos will be automatically saved to this location
          </p>
        </div>
      </CardContent>

      <CardFooter>
        <Button
          onClick={handleSave}
          disabled={saving || !hasChanged || !path.trim()}
          className="w-full"
        >
          {saving ? 'Saving...' : 'Save Path'}
        </Button>
      </CardFooter>
    </Card>
  );
}
