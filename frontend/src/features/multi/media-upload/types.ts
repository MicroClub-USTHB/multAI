export type UploadItemStatus = 'pending' | 'uploading' | 'success' | 'failed'

export interface UploadItem {
	id: string
	file: File
	fileName: string
	sizeBytes: number
	status: UploadItemStatus
	progress: number
	error: string | null
}

export interface UploadStats {
	total: number
	pending: number
	uploading: number
	success: number
	failed: number
}
