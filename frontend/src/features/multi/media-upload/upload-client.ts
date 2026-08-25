/**
 * Upload transport seam.
 *
 * The backend endpoint for direct (non-Drive) bulk photo upload doesn't
 * exist yet — see docs/backend-gap-checklist.md. This file is the ONLY
 * place that needs to change once it does. Everything above it (hooks,
 * components) only knows about `uploadFile(...)` returning a Promise and
 * reporting progress via `onProgress`; it doesn't care how the bytes
 * actually get to storage.
 *
 * Swap the body of `uploadFile` for a real call once the backend exposes
 * either:
 *   - a presigned-URL flow (fetch a presigned PUT URL for this event +
 *     filename, then PUT the file directly to MinIO, then confirm), or
 *   - a multipart POST straight to a FastAPI endpoint.
 */

export interface UploadFileParams {
	eventId: string
	file: File
	onProgress: (percent: number) => void
	signal?: AbortSignal
}

export class UploadAbortedError extends Error {
	constructor() {
		super('Upload aborted')
		this.name = 'UploadAbortedError'
	}
}

export class UploadFailedError extends Error {
	constructor(message = 'Upload failed') {
		super(message)
		this.name = 'UploadFailedError'
	}
}

// --- MOCK IMPLEMENTATION (remove once the real backend endpoint lands) ---
const MOCK_FAILURE_RATE = 0.08
const MOCK_UPLOAD_MS_PER_MB = 120

export async function uploadFile({ file, onProgress, signal }: UploadFileParams): Promise<void> {
	const totalSteps = Math.max(8, Math.min(40, Math.round((file.size / (1024 * 1024)) * 4)))
	const stepDelay = Math.max(20, (MOCK_UPLOAD_MS_PER_MB * (file.size / (1024 * 1024))) / totalSteps)
	const willFail = Math.random() < MOCK_FAILURE_RATE

	for (let step = 1; step <= totalSteps; step += 1) {
		if (signal?.aborted) {
			throw new UploadAbortedError()
		}

		await new Promise((resolve) => setTimeout(resolve, stepDelay))
		onProgress(Math.round((step / totalSteps) * 100))
	}

	if (willFail) {
		throw new UploadFailedError('Network error while uploading. Please retry.')
	}
}
// --- END MOCK IMPLEMENTATION ---
