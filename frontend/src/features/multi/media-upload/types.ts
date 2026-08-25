export type UploadItemStatus = 'pending' | 'uploading' | 'success' | 'failed' | 'paused'

export interface UploadItem {
	id: string
	file: File
	fileName: string
	sizeBytes: number
	status: UploadItemStatus
	progress: number
	error: string | null
	photoId: string | null
	uploadUrl: string | null
}

export interface UploadStats {
	total: number
	pending: number
	uploading: number
	success: number
	failed: number
	paused: number
}
