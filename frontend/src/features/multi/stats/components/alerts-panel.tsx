import { Bell, BellRing, Eye } from 'lucide-react'
import { useState } from 'react'

import { Alert } from '@/features/common/components/alert'
import { Badge, Button } from '@/shared/ui';
import { cn } from '@/shared/utils/helpers'

import type { AlertData } from '../types'

interface AlertsPanelProps {
  data?: AlertData
  isLoading?: boolean
  className?: string
}

export function AlertsPanel({ data, isLoading, className }: AlertsPanelProps) {
  const [alerts, setAlerts] = useState(data?.alerts ?? [])

  const handleMarkRead = (id: string) => {
    setAlerts(prev => prev.map(a => a.id === id ? { ...a, isRead: true } : a))
  }

  const handleDismiss = (id: string) => {
    setAlerts(prev => prev.filter(a => a.id !== id))
  }

  const handleMarkAllRead = () => {
    setAlerts(prev => prev.map(a => ({ ...a, isRead: true })))
  }

  const handleAction = (id: string) => {
    console.log('Action for alert:', id)
  }

  const unreadCount = alerts.filter(a => !a.isRead).length

  if (isLoading) {
    return (
      <div className={cn('space-y-3', className)}>
        <div className="flex items-center justify-between">
          <div className="h-5 w-16 bg-muted animate-pulse rounded" />
          <div className="h-5 w-24 bg-muted animate-pulse rounded" />
        </div>
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="p-4 border rounded-lg animate-pulse">
            <div className="flex gap-3">
              <div className="size-5 bg-muted rounded shrink-0" />
              <div className="flex-1 space-y-2">
                <div className="h-4 bg-muted rounded w-1/3" />
                <div className="h-3 bg-muted rounded w-full" />
                <div className="h-3 bg-muted rounded w-2/3" />
              </div>
            </div>
          </div>
        ))}
      </div>
    )
  }

  if (!alerts.length) {
    return (
      <div className={cn('text-center py-8', className)}>
        <Bell className="size-10 mx-auto text-muted-foreground/40 mb-3" />
        <p className="text-sm font-medium text-muted-foreground">No alerts</p>
        <p className="text-xs text-muted-foreground/60 mt-1">You're all caught up!</p>
      </div>
    )
  }

  return (
    <div className={cn('space-y-4', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {unreadCount > 0
            ? <BellRing className="size-5 text-sidebar-foreground/80" />
            : <Bell className="size-5 text-muted-foreground" />
          }
          <h3 className="font-semibold text-sidebar-foreground">Alerts</h3>
          {unreadCount > 0 && (
            <Badge variant="destructive">{unreadCount}</Badge>
          )}
        </div>

        {unreadCount > 0 && (
          <Button variant="ghost" size="xs" onClick={handleMarkAllRead} className="text-muted-foreground">
            <Eye className="size-3 mr-1" />
            Mark all read
          </Button>
        )}
      </div>

      {/* Liste */}
      <div className="space-y-3 max-h-full overflow-y-auto pr-1">
        {alerts.map(alert => (
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
  )
}