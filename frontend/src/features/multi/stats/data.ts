import type {
  AlertData,
  EventSummary,
  MultiStats,
  ProcessingJob,
} from './types';

export const mockMultiStats: MultiStats = {
  activeEvents: 3,
  photosUploaded: 4384,
  processed: 3704,
  inQueue: 472,
  lastUpdated: new Date(),
};
export const mockAlerts: AlertData = {
  alerts: [
    {
      id: '1',
      type: 'error',
      title: 'Storage Critical',
      message:
        'Drive storage is at 94% capacity. Consider cleaning up old files.',
      timestamp: new Date(),
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
      timestamp: new Date(),
      isRead: false,
      isActionable: true,
      actionText: 'View Queue',
    },
    {
      id: '3',
      type: 'info',
      title: 'Backup Complete',
      message: 'Weekly backup completed successfully. All data is secure.',
      timestamp: new Date(),
      isRead: true,
    },
    {
      id: '4',
      type: 'success',
      title: 'Event Published',
      message:
        'New event "Tech Conference 2026" has been published successfully.',
      timestamp: new Date(),
      isRead: true,
    },
  ],
  unreadCount: 2,
  lastUpdated: new Date(),
};

export const mockEventSummary: EventSummary = {
  events: [
    { eventName: 'Micro Hack 3.0', uploaded: 80, processing: 50 },
    { eventName: 'Hack Ops', uploaded: 130, processing: 95 },
    { eventName: 'MCTF', uploaded: 90, processing: 65 },
    // { eventName: 'idk', uploaded: 125, processing: 90 },
    // { eventName: 'idk 2', uploaded: 110, processing: 80 },
  ],
  lastUpdated: new Date(),
};

export const mockProcessingJobs: ProcessingJob[] = [
  {
    id: 'job-1',
    eventId: 'MicroCode',
    photoId: 'img_23',
    status: 'completed',
    startedAt: new Date('2026-03-21T08:35:00'),
    completedAt: new Date('2026-03-21T08:38:00'),
  },
  {
    id: 'job-2',
    eventId: 'MicroCode',
    photoId: 'img_03',
    status: 'queued',
    startedAt: new Date('2026-03-21T08:39:00'),
  },
  {
    id: 'job-3',
    eventId: 'HackOps',
    photoId: 'img_14',
    status: 'processing',
    startedAt: new Date('2026-03-21T08:41:00'),
  },
  {
    id: 'job-4',
    eventId: 'MCTF',
    photoId: 'img_09',
    status: 'completed',
    startedAt: new Date('2026-03-21T08:44:00'),
    completedAt: new Date('2026-03-21T08:46:00'),
  },
  {
    id: 'job-5',
    eventId: 'HackOps',
    photoId: 'img_31',
    status: 'failed',
    startedAt: new Date('2026-03-21T08:48:00'),
  },
];
