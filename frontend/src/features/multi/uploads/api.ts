import { api } from '@/shared/api/client'

import type { UploadRequestGroup, UploadRequestGroupListResponse } from './types'

export function listUploadGroups(scope: 'my' | 'all') {
  return api.get<UploadRequestGroupListResponse>('/staff/uploads/groups', { scope })
}

export function getUploadGroupDetails(groupId: string) {
  return api.get<UploadRequestGroup>(`/staff/uploads/groups/${groupId}`)
}

export function approveUploadGroup(groupId: string) {
  return api.post<UploadRequestGroup>(`/staff/uploads/groups/${groupId}/approve`)
}

export function rejectUploadGroup(groupId: string, reason?: string) {
  return api.post<UploadRequestGroup>(`/staff/uploads/groups/${groupId}/reject`, {
    reason: reason ?? null,
  })
}

export function getPhotoPreviewUrl(requestId: string, photoId: string) {
  return api.blobUrl(`/staff/uploads/${requestId}/photos/${photoId}/preview`)
}
