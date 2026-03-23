import { Bell, BellRing, Eye } from 'lucide-react';
import { useState } from 'react';

import { Alert } from '@/features/common/components/alert';
import { Badge } from '@/shared/ui/badge';
import { Button } from '@/shared/ui/button';
import { cn } from '@/shared/utils/helpers';

import type { AlertData } from '../types';

interface AlertsPanelProps {
  data?: AlertData;
  isLoading?: boolean;
  className?: string;
}

export function AlertsPanel({ data, isLoading, className }: AlertsPanelProps) {
  const [alerts, setAlerts] = useState(data?.alerts ?? []);

  const handleMarkRead = (id: string) => {
    setAlerts((prev) =>
      prev.map((a) => (a.id === id ? { ...a, isRead: true } : a)),
    );
  };

  const handleDismiss = (id: string) => {
    setAlerts((prev) => prev.filter((a) => a.id !== id));
  };

  const handleMarkAllRead = () => {
    setAlerts((prev) => prev.map((a) => ({ ...a, isRead: true })));
  };

  const handleAction = (id: string) => {
    console.log('Action for alert:', id);
  };

  const unreadCount = alerts.filter((a) => !a.isRead).length;

  if (isLoading) {
    return (
      <div className={cn('space-y-3', className)}>
        <div className="flex items-center justify-between">
          <div className="bg-muted h-5 w-16 animate-pulse rounded" />
          <div className="bg-muted h-5 w-24 animate-pulse rounded" />
        </div>
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="animate-pulse rounded-lg border p-4">
            <div className="flex gap-3">
              <div className="bg-muted size-5 shrink-0 rounded" />
              <div className="flex-1 space-y-2">
                <div className="bg-muted h-4 w-1/3 rounded" />
                <div className="bg-muted h-3 w-full rounded" />
                <div className="bg-muted h-3 w-2/3 rounded" />
              </div>
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (!alerts.length) {
    return (
      <div className={cn('py-8 text-center', className)}>
        <Bell className="text-muted-foreground/40 mx-auto mb-3 size-10" />
        <p className="text-muted-foreground text-sm font-medium">No alerts</p>
        <p className="text-muted-foreground/60 mt-1 text-xs">
          You're all caught up!
        </p>
      </div>
    );
  }

  return (
    <div className={cn('space-y-4', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {unreadCount > 0 ? (
            <BellRing className="text-sidebar-foreground/80 size-5" />
          ) : (
            <Bell className="text-muted-foreground size-5" />
          )}
          <h3 className="text-sidebar-foreground font-semibold">Alerts</h3>
          {unreadCount > 0 && (
            <Badge variant="destructive">{unreadCount}</Badge>
          )}
        </div>

        {unreadCount > 0 && (
          <Button
            variant="ghost"
            size="xs"
            onClick={handleMarkAllRead}
            className="text-muted-foreground"
          >
            <Eye className="mr-1 size-3" />
            Mark all read
          </Button>
        )}
      </div>

      {/* Liste */}
      <div className="max-h-96 space-y-3 overflow-y-auto pr-1">
        {alerts.map((alert) => (
          <Alert
            key={alert.id}
            alert={alert}
            onMarkRead={handleMarkRead}
            onDismiss={handleDismiss}
            onAction={handleAction}
          />
        ))}
      </div>
    </div>
  );
}
