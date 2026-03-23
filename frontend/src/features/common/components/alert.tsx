import {
  AlertCircle,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Info,
  X,
} from 'lucide-react';

import type { Alert as AlertType } from '@/features/admin/stats/types';

import { formatTimeAgo } from '@/features/admin/stats/types';
import { Badge } from '@/shared/ui';
import { Button } from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

const alertConfig = {
  error: {
    icon: AlertCircle,
    classes:
      'bg-red-50 border-red-200 text-red-900 dark:bg-red-950/50 dark:border-red-800 dark:text-red-100',
    iconClass: 'text-red-600 dark:text-red-400',
  },
  warning: {
    icon: AlertTriangle,
    classes:
      'bg-yellow-50 border-yellow-200 text-yellow-900 dark:bg-yellow-950/50 dark:border-yellow-800 dark:text-yellow-100',
    iconClass: 'text-yellow-600 dark:text-yellow-400',
  },
  info: {
    icon: Info,
    classes:
      'bg-blue-50 border-blue-200 text-blue-900 dark:bg-blue-950/50 dark:border-blue-800 dark:text-blue-100',
    iconClass: 'text-blue-600 dark:text-blue-400',
  },
  success: {
    icon: CheckCircle2,
    classes:
      'bg-green-50 border-green-200 text-green-900 dark:bg-green-950/50 dark:border-green-800 dark:text-green-100',
    iconClass: 'text-green-600 dark:text-green-400',
  },
} as const;

interface AlertProps {
  alert: AlertType;
  onMarkRead?: (id: string) => void;
  onDismiss?: (id: string) => void;
  onAction?: (id: string) => void;
  className?: string;
}

export function Alert({
  alert,
  onMarkRead,
  onDismiss,
  onAction,
  className,
}: AlertProps) {
  const config = alertConfig[alert.type];
  const Icon = config.icon;

  return (
    <div
      className={cn(
        'group/alert relative rounded-lg border p-4 transition-all duration-200',
        config.classes,
        alert.isRead && 'opacity-60',
        className,
      )}
    >
      {/* Header */}
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-1 items-start gap-3">
          <Icon className={cn('mt-0.5 size-5 shrink-0', config.iconClass)} />

          <div className="min-w-0 flex-1">
            <div className="mb-1 flex items-center gap-2">
              <h4 className="text-sm font-medium">{alert.title}</h4>
              {!alert.isRead && (
                <Badge variant="default" className="size-2 rounded-full p-0" />
              )}
            </div>
            <p className="truncate text-[12px] leading-relaxed opacity-80">
              {alert.message}
            </p>
          </div>
        </div>

        {/* Actions (visibles au hover) */}
        <div className="flex shrink-0 items-center gap-1 opacity-0 transition-opacity group-hover/alert:opacity-100">
          {!alert.isRead && onMarkRead && (
            <Button
              variant="ghost"
              size="icon-xs"
              onClick={() => onMarkRead(alert.id)}
            >
              <CheckCircle2 className="size-3" />
            </Button>
          )}
          {onDismiss && (
            <Button
              variant="ghost"
              size="icon-xs"
              onClick={() => onDismiss(alert.id)}
            >
              <X className="size-3" />
            </Button>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="mt-3 flex items-center justify-between gap-3">
        <div className="flex items-center gap-1.5 text-xs opacity-70">
          <Clock className="size-3" />
          <span>{formatTimeAgo(alert.timestamp)}</span>
        </div>

        {alert.isActionable && alert.actionText && onAction && (
          <Button variant="ghost" size="xs" onClick={() => onAction(alert.id)}>
            {alert.actionText}
          </Button>
        )}
      </div>
    </div>
  );
}
