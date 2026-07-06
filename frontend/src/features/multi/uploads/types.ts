export type UploadStatus = 'pending' | 'approved' | 'rejected'

export type GroupProcessingStatus = 'pending' | 'running' | 'completed' | 'failed'

export type PhotoStatus = 'staged' | 'approved' | 'rejected'

export interface UploadRequestPhoto {
  id: string
  drive_file_id: string
  file_name: string
  mime_type: string
  size_bytes: number
  taken_at: string | null
  day_number: number | null
  visibility: string
  status: PhotoStatus
  created_at: string
}

export interface UploadRequest {
  id: string
  event_id: string
  group_id: string | null
  drive_file_id: string | null
  requested_by: string
  approved_by: string | null
  status: UploadStatus
  photo_count: number
  created_at: string
  approved_at: string | null
  rejection_reason: string | null
  photos: UploadRequestPhoto[]
}

export interface UploadRequestGroupSummary {
  id: string
  event_id: string
  folder_id: string
  status: UploadStatus
  processing_status: GroupProcessingStatus
  total_photo_count: number
  batch_count: number
  processed_photo_count: number
  failed_photo_count: number
  created_at: string
  approved_at: string | null
  rejection_reason: string | null
  error_message: string | null
}

export interface UploadRequestGroup extends UploadRequestGroupSummary {
  requested_by: string
  approved_by: string | null
  requests: UploadRequest[]
}

interface ListResponse<T> {
  items: T[]
}

export type UploadRequestGroupListResponse = ListResponse<UploadRequestGroupSummary>
