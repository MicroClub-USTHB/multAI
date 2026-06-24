import type React from 'react';

import { CloudUpload, FolderOpen, Image } from 'lucide-react';
import { useState } from 'react';

import {
  Button,
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui';

import type { PhotoVisibility } from '../types';

type UploadMode = 'folder' | 'photos';

interface UploaderProps {
  isConnected: boolean;
  isSubmitting: boolean;
  onConnectDrive: () => void;
  onSubmit: (data: {
    event_id: string;
    folder_id?: string;
    photos?: { drive_file_id: string; visibility: PhotoVisibility }[];
    visibility: PhotoVisibility;
    day_number?: number;
  }) => Promise<void> | void;
}

export function Uploader({
  isConnected,
  isSubmitting,
  onConnectDrive,
  onSubmit,
}: UploaderProps) {
  const [mode, setMode] = useState<UploadMode>('folder');
  const [eventId, setEventId] = useState('');
  const [folderId, setFolderId] = useState('');
  const [driveFileIds, setDriveFileIds] = useState('');
  const [visibility, setVisibility] = useState<PhotoVisibility>('private');
  const [dayNumber, setDayNumber] = useState('');

  if (!isConnected) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CloudUpload className="h-5 w-5" />
            Connect Google Drive
          </CardTitle>
          <CardDescription>
            Connect your Google Drive to import photos for upload requests.
          </CardDescription>
        </CardHeader>
        <CardFooter>
          <Button onClick={onConnectDrive}>Connect Drive</Button>
        </CardFooter>
      </Card>
    );
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!eventId.trim()) return;

    const base = {
      event_id: eventId.trim(),
      visibility,
      day_number: dayNumber ? Number(dayNumber) : undefined,
    };

    if (mode === 'folder') {
      if (!folderId.trim()) return;
      onSubmit({ ...base, folder_id: folderId.trim() });
    } else {
      const ids = driveFileIds
        .split('\n')
        .map((id) => id.trim())
        .filter(Boolean);
      if (ids.length === 0) return;
      onSubmit({
        ...base,
        photos: ids.map((id) => ({ drive_file_id: id, visibility })),
      });
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <CloudUpload className="h-5 w-5" />
          Create Upload Request
        </CardTitle>
        <CardDescription>
          Import photos from your connected Google Drive.
        </CardDescription>
      </CardHeader>
      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-4">
          <div className="space-y-1.5">
            <label className="text-sm font-medium">Event ID</label>
            <Input
              placeholder="Event UUID"
              value={eventId}
              onChange={(e) => setEventId(e.target.value)}
              required
            />
          </div>

          <div className="flex gap-2">
            <Button
              type="button"
              variant={mode === 'folder' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setMode('folder')}
            >
              <FolderOpen className="mr-1.5 h-4 w-4" />
              Folder
            </Button>
            <Button
              type="button"
              variant={mode === 'photos' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setMode('photos')}
            >
              <Image className="mr-1.5 h-4 w-4" />
              Individual Photos
            </Button>
          </div>

          {mode === 'folder' ? (
            <div className="space-y-1.5">
              <label className="text-sm font-medium">Drive Folder ID</label>
              <Input
                placeholder="Google Drive folder ID"
                value={folderId}
                onChange={(e) => setFolderId(e.target.value)}
                required
              />
              <p className="text-muted-foreground text-xs">
                All images in this folder will be imported in batches of 20.
              </p>
            </div>
          ) : (
            <div className="space-y-1.5">
              <label className="text-sm font-medium">Drive File IDs</label>
              <textarea
                className="border-input bg-background placeholder:text-muted-foreground flex min-h-[80px] w-full rounded-md border px-3 py-2 text-sm"
                placeholder="One Drive file ID per line (max 20)"
                value={driveFileIds}
                onChange={(e) => setDriveFileIds(e.target.value)}
                required
              />
              <p className="text-muted-foreground text-xs">
                Enter up to 20 Google Drive file IDs, one per line.
              </p>
            </div>
          )}

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium">Visibility</label>
              <Select
                value={visibility}
                onValueChange={(value) => {
                  if (!value) return;
                  setVisibility(value as PhotoVisibility);
                }}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="private">Private</SelectItem>
                  <SelectItem value="public">Public</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-medium">Day Number</label>
              <Input
                type="number"
                min={1}
                placeholder="Optional"
                value={dayNumber}
                onChange={(e) => setDayNumber(e.target.value)}
              />
            </div>
          </div>
        </CardContent>
        <CardFooter>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Submitting...' : 'Create Upload Request'}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}
