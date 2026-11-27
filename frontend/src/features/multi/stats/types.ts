export interface MultiStats {
  activeEvents: number;
  photosUploaded: number;
  processed: number;
  inQueue: number;
  lastUpdated?: Date;
}

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
  alerts: Alert[]
  unreadCount: number
  lastUpdated?: Date
}

export interface EventSummary {
  events: {
    eventName: string;
    uploaded: number;
    processing: number;
  }[];
  lastUpdated?: Date;
}

export interface ProcessingJob {
  id: string;
  eventId: string;
  photoId: string;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  startedAt?: Date;
  completedAt?: Date;
}
