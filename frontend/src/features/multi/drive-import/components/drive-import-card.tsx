import { Link } from '@tanstack/react-router';
import { CheckCircle2, Link2 } from 'lucide-react';
import { type FormEvent, useState } from 'react';

import {
  Alert,
  AlertDescription,
  AlertTitle,
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
  Textarea,
} from '@/shared/ui';

import type { DriveImportVisibility } from '../types';

import { useImportDriveUrlsMutation } from '../hooks';

const MAX_URLS = 100;

const parseUrlList = (raw: string) =>
  raw
    .split(/[\n,]+/)
    .map((value) => value.trim())
    .filter(Boolean);

const toIsoString = (value: string) =>
  value ? new Date(value).toISOString() : undefined;

export function DriveImportCard() {
  const [eventName, setEventName] = useState('');
  const [eventDate, setEventDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [urls, setUrls] = useState('');
  const [visibility, setVisibility] =
    useState<DriveImportVisibility>('private');
  const [formError, setFormError] = useState<string | null>(null);
  const mutation = useImportDriveUrlsMutation();

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setFormError(null);

    const fileUrls = parseUrlList(urls);

    if (!eventName.trim()) {
      setFormError('Give the new event a name.');
      return;
    }
    if (fileUrls.length === 0) {
      setFormError('Add at least one Google Drive file link.');
      return;
    }
    if (fileUrls.length > MAX_URLS) {
      setFormError(`You can import at most ${MAX_URLS} links at once.`);
      return;
    }
    if (eventDate && endDate && new Date(endDate) < new Date(eventDate)) {
      setFormError('End date must not be before the start date.');
      return;
    }

    try {
      await mutation.mutateAsync({
        event: {
          name: eventName.trim(),
          event_date: toIsoString(eventDate),
          end_date: toIsoString(endDate),
        },
        file_urls: fileUrls,
        visibility,
      });
      setUrls('');
    } catch {
      // Surfaced through mutation.error below.
    }
  };

  const errorMessage =
    formError ?? (mutation.isError ? mutation.error.message : null);
  const result = mutation.data;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Link2 className="size-4" />
          Import from Google Drive links
        </CardTitle>
        <CardDescription>
          Paste individual Drive file links to create a new event. Files are
          copied into MinIO and automatically approved, then face processing
          starts. Uses the Drive account connected to MultiAI.
        </CardDescription>
      </CardHeader>

      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-3">
            <div className="space-y-1.5">
              <label
                htmlFor="drive-import-event-name"
                className="text-sm font-medium"
              >
                Event name
              </label>
              <Input
                id="drive-import-event-name"
                value={eventName}
                onChange={(event) => setEventName(event.target.value)}
                placeholder="Gala 2026"
                maxLength={255}
                disabled={mutation.isPending}
              />
            </div>

            <div className="space-y-1.5">
              <label
                htmlFor="drive-import-start"
                className="text-sm font-medium"
              >
                Start
              </label>
              <Input
                id="drive-import-start"
                type="datetime-local"
                value={eventDate}
                onChange={(event) => setEventDate(event.target.value)}
                disabled={mutation.isPending}
              />
            </div>

            <div className="space-y-1.5">
              <label htmlFor="drive-import-end" className="text-sm font-medium">
                End
              </label>
              <Input
                id="drive-import-end"
                type="datetime-local"
                value={endDate}
                onChange={(event) => setEndDate(event.target.value)}
                disabled={mutation.isPending}
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <label htmlFor="drive-import-urls" className="text-sm font-medium">
              Drive file links
            </label>
            <Textarea
              id="drive-import-urls"
              value={urls}
              onChange={(event) => setUrls(event.target.value)}
              placeholder={
                'https://drive.google.com/file/d/…/view\nhttps://drive.google.com/open?id=…'
              }
              rows={5}
              disabled={mutation.isPending}
            />
            <p className="text-muted-foreground text-xs">
              One individual file link per line (or comma-separated). Folder
              links are not supported. JPEG, PNG or WebP, up to 20 MB each and
              {` ${MAX_URLS} `}files per import.
            </p>
          </div>

          <div className="space-y-1.5">
            <span className="text-sm font-medium">Visibility</span>
            <Select
              value={visibility}
              onValueChange={(value) =>
                setVisibility(value === 'public' ? 'public' : 'private')
              }
              disabled={mutation.isPending}
            >
              <SelectTrigger className="w-full sm:w-48">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="private">
                  Private (matched members)
                </SelectItem>
                <SelectItem value="public">Public (all attendees)</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {errorMessage ? (
            <Alert variant="destructive">
              <AlertTitle>
                {formError ? 'Check the form' : 'Import failed'}
              </AlertTitle>
              <AlertDescription>{errorMessage}</AlertDescription>
            </Alert>
          ) : null}

          {result ? (
            <Alert>
              <CheckCircle2 />
              <AlertTitle>
                Imported {result.importedPhotoCount}{' '}
                {result.importedPhotoCount === 1 ? 'photo' : 'photos'}
              </AlertTitle>
              <AlertDescription>
                Created “{result.eventName}” ({result.eventCode}).{' '}
                <Link
                  to="/multi/events"
                  className="underline underline-offset-3"
                >
                  View events
                </Link>
              </AlertDescription>
            </Alert>
          ) : null}
        </CardContent>

        <CardFooter className="justify-end">
          <Button
            type="submit"
            isLoading={mutation.isPending}
            loadingText="Importing…"
          >
            Import into new event
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}
