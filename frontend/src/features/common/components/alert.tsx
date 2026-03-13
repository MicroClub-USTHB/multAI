import { AlertCircle, AlertTriangle, CheckCircle2, Clock, Info, X } from 'lucide-react'
import { cn } from '@/shared/utils/helpers'
import { Button } from '@/shared/ui/button'
import { Badge } from '@/shared/ui/badge'
import type { Alert as AlertType } from '@/features/admin/stats/types'
import { formatTimeAgo } from '@/features/admin/stats/types'

const alertConfig = {
  error: {
    icon: AlertCircle,
    classes: 'bg-red-50 border-red-200 text-red-900 dark:bg-red-950/50 dark:border-red-800 dark:text-red-100',
    iconClass: 'text-red-600 dark:text-red-400',
  },
  warning: {
    icon: AlertTriangle,
    classes: 'bg-yellow-50 border-yellow-200 text-yellow-900 dark:bg-yellow-950/50 dark:border-yellow-800 dark:text-yellow-100',
    iconClass: 'text-yellow-600 dark:text-yellow-400',
  },
  info: {
    icon: Info,
    classes: 'bg-blue-50 border-blue-200 text-blue-900 dark:bg-blue-950/50 dark:border-blue-800 dark:text-blue-100',
    iconClass: 'text-blue-600 dark:text-blue-400',
  },
  success: {
    icon: CheckCircle2,
    classes: 'bg-green-50 border-green-200 text-green-900 dark:bg-green-950/50 dark:border-green-800 dark:text-green-100',
    iconClass: 'text-green-600 dark:text-green-400',
  },
} as const

interface AlertProps {
  alert: AlertType
  onMarkRead?: (id: string) => void
  onDismiss?: (id: string) => void
  onAction?: (id: string) => void
  className?: string
}

export function Alert({ alert, onMarkRead, onDismiss, onAction, className }: AlertProps) {
  const config = alertConfig[alert.type]
  const Icon = config.icon

  return (
    <div className={cn(
      'group/alert relative p-4 rounded-lg border transition-all duration-200',
      config.classes,
      alert.isRead && 'opacity-60',
      className
    )}>
      {/* Header */}
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-start gap-3 flex-1 min-w-0">
          <Icon className={cn('size-5 shrink-0 mt-0.5', config.iconClass)} />

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <h4 className="font-medium text-sm">{alert.title}</h4>
              {!alert.isRead && (
                <Badge variant="default" className="size-2 p-0 rounded-full" />
              )}
            </div>
            <p className="text-[12px] opacity-80 leading-relaxed truncate">{alert.message}</p>
          </div>
        </div>

        {/* Actions (visibles au hover) */}
        <div className="flex items-center gap-1 shrink-0 opacity-0 group-hover/alert:opacity-100 transition-opacity">
          {!alert.isRead && onMarkRead && (
            <Button variant="ghost" size="icon-xs" onClick={() => onMarkRead(alert.id)}>
              <CheckCircle2 className="size-3" />
            </Button>
          )}
          {onDismiss && (
            <Button variant="ghost" size="icon-xs" onClick={() => onDismiss(alert.id)}>
              <X className="size-3" />
            </Button>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between gap-3 mt-3">
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
  )
}