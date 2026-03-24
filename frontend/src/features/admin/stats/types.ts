import type { LucideIcon } from 'lucide-react';

const MOCK_TIMESTAMP = new Date('2026-03-12T10:44:00Z');
export interface DriveUsage {
  usedGB: number;
  totalGB: number;
  lastUpdated?: Date;
}

export interface DriveUsageResponse {
  used_bytes: number;
  total_bytes: number;
  timestamp: string;
}

export const mockDriveUsage: DriveUsage = {
  usedGB: 629,
  totalGB: 1000,
  lastUpdated: MOCK_TIMESTAMP,
};

export interface AdminStatsData {
  activeEvents: number;
  photosUploaded: number;
  processed: number;
  inQueue: number;
  lastUpdated?: Date;
}

export interface AdminStatsResponse {
  active_events: number;
  photos_uploaded: number;
  processed_photos: number;
  queue_size: number;
  timestamp: string;
}

export const mockAdminStats: AdminStatsData = {
  activeEvents: 3,
  photosUploaded: 4384,
  processed: 3704,
  inQueue: 472,
  lastUpdated: MOCK_TIMESTAMP,
};

//Alertes

export interface Alert {
  id: string;
  type: 'error' | 'warning' | 'info' | 'success';
  title: string;
  message: string;
  timestamp: Date;
  isRead: boolean;
  isActionable?: boolean;
  actionText?: string;
}

export interface AlertData {
  alerts: Alert[];
  unreadCount: number;
  lastUpdated?: Date;
}

export interface AlertResponse {
  alerts: Array<{
    id: string;
    type: string;
    title: string;
    message: string;
    created_at: string;
    is_read: boolean;
    is_actionable?: boolean;
    action_text?: string;
  }>;
  unread_count: number;
  timestamp: string;
}

export const mockAlerts: AlertData = {
  alerts: [
    {
      id: '1',
      type: 'error',
      title: 'Storage Critical',
      message:
        'Drive storage is at 94% capacity. Consider cleaning up old files.',
      timestamp: MOCK_TIMESTAMP,
      isRead: false,
      isActionable: true,
      actionText: 'Manage Storage',
    },
    {
      id: '2',
      type: 'warning',
      title: 'Processing Queue',
      message:
        '472 photos are waiting to be processed. Processing may be slower than usual.',
      timestamp: MOCK_TIMESTAMP,
      isRead: false,
      isActionable: true,
      actionText: 'View Queue',
    },
    {
      id: '3',
      type: 'info',
      title: 'Backup Complete',
      message: 'Weekly backup completed successfully. All data is secure.',
      timestamp: MOCK_TIMESTAMP,
      isRead: true,
    },
    {
      id: '4',
      type: 'success',
      title: 'Event Published',
      message:
        'New event "Tech Conference 2026" has been published successfully.',
      timestamp: MOCK_TIMESTAMP,
      isRead: true,
    },
  ],
  unreadCount: 2,
  lastUpdated: MOCK_TIMESTAMP,
};

// processing load
export interface ProcessingLoad {
  completed: number;
  processing: number;
  queued: number;
}

export const mockProcessingLoad: ProcessingLoad = {
  completed: 65.4,
  processing: 15.8,
  queued: 18.8,
};

// Drive Storage Utils

export interface StatsCardData {
  title: string;
  value: string;
  icon: LucideIcon;
}

export function calculateStorageMetrics(data: DriveUsage) {
  const freeGB = data.totalGB - data.usedGB;
  const percentageUsed = (data.usedGB / data.totalGB) * 100;
  return { ...data, freeGB, percentageUsed };
}

export function formatStorageSize(gb: number): string {
  if (gb >= 1000) {
    return `${(gb / 1000).toFixed(gb % 1000 === 0 ? 0 : 1)}TB`;
  }
  return `${gb}GB`;
}

export function transformToStatsCards(data: AdminStatsData): StatsCardData[] {
  return [
    {
      title: 'Active events',
      value: data.activeEvents.toString(),
      icon: null as any,
    },
    {
      title: 'Photos Uploaded',
      value: data.photosUploaded.toLocaleString(),
      icon: null as any,
    },
    {
      title: 'Processed',
      value: data.processed.toLocaleString(),
      icon: null as any,
    },
    { title: 'In Queue', value: data.inQueue.toString(), icon: null as any },
  ];
}

export function formatNumber(num: number): string {
  if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`;
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`;
  return num.toString();
}

// Alerts Utils

export function transformAlertsResponse(response: AlertResponse): AlertData {
  return {
    alerts: response.alerts.map((alert) => ({
      id: alert.id,
      type: alert.type as Alert['type'],
      title: alert.title,
      message: alert.message,
      timestamp: new Date(alert.created_at),
      isRead: alert.is_read,
      isActionable: alert.is_actionable,
      actionText: alert.action_text,
    })),
    unreadCount: response.unread_count,
    lastUpdated: new Date(response.timestamp),
  };
}

export function formatTimeAgo(timestamp: Date): string {
  const diff = Date.now() - timestamp.getTime();
  const minutes = Math.floor(diff / (1000 * 60));
  const hours = Math.floor(diff / (1000 * 60 * 60));
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));

  if (minutes < 1) return 'Just now';
  if (minutes < 60) return `${minutes}m ago`;
  if (hours < 24) return `${hours}h ago`;
  return `${days}d ago`;
}
