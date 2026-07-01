export type AuditEventType =
  | 'user.signup'
  | 'user.login'
  | 'user.logout'
  | 'upload_request.created'
  | 'upload_request.approved'
  | 'upload_request.rejected'
  | 'photo.processed'
  | 'photo_approval.decided'

export type AuditActor = {
  id: string
  email: string
  displayName: string | null
}

export type AuditEvent = {
  id: string
  eventType: AuditEventType
  metadata: Record<string, unknown> | null
  createdAt: string
  actor: AuditActor | null
}

type AuditActorApi = {
  id: string
  email: string
  display_name: string | null
}

type AuditEventApi = {
  id: string
  event_type: AuditEventType
  metadata: Record<string, unknown> | null
  created_at: string
  actor: AuditActorApi | null
}

export const toAuditEvent = (input: AuditEventApi): AuditEvent => ({
  id: input.id,
  eventType: input.event_type,
  metadata: input.metadata,
  createdAt: input.created_at,
  actor: input.actor
    ? {
      id: input.actor.id,
      email: input.actor.email,
      displayName: input.actor.display_name,
    }
    : null,
})

export type SyncError = {
  id: string;
  timestamp: string;
  errorMessage: string;
  source: 'Drive' | 'Storage' | 'Worker';
  status: 'Unresolved' | 'Investigating' | 'Resolved';
};

export type FaceMatchingLog = {
  id: string;
  timestamp: string;
  photoId: string;
  facesDetected: number;
  matchedUsers: string[];
  result: 'Success' | 'Partial' | 'Failed';
};

//mocks

export const syncErrorsMock: SyncError[] = [
  {
    id: 'err-001',
    timestamp: '2026-03-11 14:32:18',
    errorMessage:
      'Failed to sync: Permission denied for /events/MicroCode-2026',
    source: 'Drive',
    status: 'Unresolved',
  },
  {
    id: 'err-002',
    timestamp: '2026-03-11 13:45:02',
    errorMessage: 'Storage quota exceeded. Unable to upload batch of 45 photos',
    source: 'Storage',
    status: 'Investigating',
  },
  {
    id: 'err-003',
    timestamp: '2026-03-11 12:18:56',
    errorMessage:
      'Worker timeout: face detection process exceeded 5 minute limit',
    source: 'Worker',
    status: 'Resolved',
  },
  {
    id: 'err-004',
    timestamp: '2026-03-11 11:05:34',
    errorMessage:
      'Network error: Connection to Drive API failed after 3 retries',
    source: 'Drive',
    status: 'Resolved',
  },
  {
    id: 'err-005',
    timestamp: '2026-03-11 09:22:41',
    errorMessage: 'Invalid file format detected: corrupted_photo_2345.jpg',
    source: 'Storage',
    status: 'Resolved',
  },
  {
    id: 'err-006',
    timestamp: '2026-03-11 08:15:29',
    errorMessage:
      'Worker process crashed: Out of memory error during batch processing',
    source: 'Worker',
    status: 'Unresolved',
  },
];

export const faceLogsMock: FaceMatchingLog[] = [
  {
    id: 'face-001',
    timestamp: '2026-03-11 14:32:18',
    photoId: 'IMG_8742.jpg',
    facesDetected: 3,
    matchedUsers: ['Manel', 'Sahar', 'Alaa'],
    result: 'Success',
  },
  {
    id: 'face-002',
    timestamp: '2026-03-11 14:32:18',
    photoId: 'IMG_8742.jpg',
    facesDetected: 5,
    matchedUsers: ['Per', 'ddd'],
    result: 'Partial',
  },
  {
    id: 'face-003',
    timestamp: '2026-03-11 14:32:18',
    photoId: 'IMG_8742.jpg',
    facesDetected: 1,
    matchedUsers: [],
    result: 'Failed',
  },
  {
    id: 'face-004',
    timestamp: '2026-03-11 14:32:18',
    photoId: 'IMG_8742.jpg',
    facesDetected: 0,
    matchedUsers: [],
    result: 'Failed',
  },
];
