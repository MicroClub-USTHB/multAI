import { apiGet, apiPost } from '@/shared/utils/api-client'

export interface DirectFileInput {
	file_name: string
	mime_type: string
	size_bytes: number
	taken_at?: string | null
	day_number?: number | null
	visibility?: string
}

export interface DirectUploadFile {
	photo_id: string
	file_name: string
	upload_url: string
}

export interface RegisterBatchResult {
	group_id: string
	items: DirectUploadFile[]
}

export interface ResumeGroupResult {
	items: DirectUploadFile[]
}

export interface UploadGroupPhoto {
	id: string
	file_name: string
	status: string
	transfer_status?: string
}

export interface UploadGroupRequest {
	id: string
	photos: UploadGroupPhoto[]
}

export interface UploadGroupDetails {
	id: string
	event_id: string
	status: string
	processing_status: string
	total_photo_count: number
	processed_photo_count: number
	failed_photo_count: number
	requests: UploadGroupRequest[]
}

const BASE = '/staff/uploads/direct'

export const DIRECT_UPLOAD_MAX_BATCH_SIZE = 200

export function createDirectGroup(eventId: string): Promise<UploadGroupDetails> {
	return apiPost<UploadGroupDetails>(
		`${BASE}/groups`,
		{ event_id: eventId },
		{ fallbackErrorMessage: 'Unable to start upload session.' },
	)
}

export function registerDirectBatch(
	groupId: string,
	files: DirectFileInput[],
): Promise<RegisterBatchResult> {
	return apiPost<RegisterBatchResult>(
		`${BASE}/groups/${groupId}/batches`,
		{ files },
		{ fallbackErrorMessage: 'Unable to register files for upload.' },
	)
}

export function confirmDirectUpload(photoId: string): Promise<void> {
	return apiPost<void>(
		`${BASE}/photos/${photoId}/confirm`,
		{},
		{ fallbackErrorMessage: 'Unable to confirm upload.' },
	)
}

export function failDirectUpload(photoId: string): Promise<void> {
	return apiPost<void>(
		`${BASE}/photos/${photoId}/fail`,
		{},
		{ fallbackErrorMessage: 'Unable to mark upload as failed.' },
	)
}

export function resumeDirectGroup(groupId: string): Promise<ResumeGroupResult> {
	return apiPost<ResumeGroupResult>(
		`${BASE}/groups/${groupId}/resume`,
		{},
		{ fallbackErrorMessage: 'Unable to resume upload session.' },
	)
}

export function getDirectGroupStatus(groupId: string): Promise<UploadGroupDetails> {
	return apiGet<UploadGroupDetails>(`${BASE}/groups/${groupId}`, {
		fallbackErrorMessage: 'Unable to load upload session status.',
	})
}
