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
  isConnected: boolean;
  isLoading?: boolean;
  onConnect: (key: string) => Promise<void>;
}

export function GoogleDriveAuthCard({
  isConnected,
  isLoading = false,
  onConnect,
}: Props) {
  const [apiKey, setApiKey] = useState('');

  const handleConnect = async () => {
    if (!apiKey.trim()) return;

    await onConnect(apiKey);
    setApiKey('');
  };

  return (
    <Card className="border-border/40 bg-card/60 backdrop-blur-sm">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-xl">
          Google Drive Auth
        </CardTitle>
        <CardDescription>API Key configuration</CardDescription>
      </CardHeader>

      <CardContent>
        {isConnected ? (
          <div className="py-8 text-center">
            <div className="inline-flex items-center gap-2 text-lg font-medium text-green-500">
              <span>Connected</span> ✓
            </div>
          </div>
        ) : (
          <div className="mt-5 space-y-4">
            <Input
              type="password"
              placeholder="Enter your Google Drive API key"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              className="bg-background/70"
            />
            <p className="text-muted-foreground text-xs">
              This key will only be used for authentication.
            </p>
          </div>
        )}
      </CardContent>

      {!isConnected && (
        <CardFooter>
          <Button
            onClick={handleConnect}
            disabled={isLoading || !apiKey.trim()}
            className="bg-primary hover:bg-primary/90 mt-5 w-full"
          >
            {isLoading ? 'Connecting...' : 'Connect'}
          </Button>
        </CardFooter>
      )}
    </Card>
  );
}
