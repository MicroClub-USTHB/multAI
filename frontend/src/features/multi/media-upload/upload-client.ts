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

/**
 * PUTs a file straight to a presigned storage URL (bypasses our backend for
 * the actual bytes). Uses XHR instead of fetch because fetch has no
 * upload-progress event.
 */
export function putToPresignedUrl(
	uploadUrl: string,
	file: File,
	onProgress: (percent: number) => void,
	signal?: AbortSignal,
): Promise<void> {
	return new Promise((resolve, reject) => {
		const xhr = new XMLHttpRequest()
		xhr.open('PUT', uploadUrl)

		xhr.upload.onprogress = (event) => {
			if (event.lengthComputable) {
				onProgress(Math.round((event.loaded / event.total) * 100))
			}
		}

		xhr.onload = () => {
			if (xhr.status >= 200 && xhr.status < 300) {
				resolve()
			} else {
				reject(new UploadFailedError(`Storage rejected the upload (HTTP ${xhr.status}).`))
			}
		}

		xhr.onerror = () => reject(new UploadFailedError('Network error while uploading.'))
		xhr.ontimeout = () => reject(new UploadFailedError('Upload timed out.'))

		if (signal) {
			if (signal.aborted) {
				reject(new UploadAbortedError())
				return
			}
			signal.addEventListener('abort', () => {
				xhr.abort()
				reject(new UploadAbortedError())
			})
		}

		xhr.send(file)
	})
}

const RETRY_DELAYS_MS = [1000, 3000, 6000]

const delay = (ms: number, signal?: AbortSignal) =>
	new Promise<void>((resolve, reject) => {
		if (signal?.aborted) {
			reject(new UploadAbortedError())
			return
		}
		const timeout = setTimeout(resolve, ms)
		signal?.addEventListener('abort', () => {
			clearTimeout(timeout)
			reject(new UploadAbortedError())
		})
	})

/**
 * Same as putToPresignedUrl, but transparently retries transient failures
 * (network blips, storage hiccups) a few times with backoff before giving
 * up. Never retries an intentional abort (pause/cancel) — that propagates
 * immediately.
 */
export async function putToPresignedUrlWithRetry(
	uploadUrl: string,
	file: File,
	onProgress: (percent: number) => void,
	signal?: AbortSignal,
): Promise<void> {
	let lastError: unknown

	for (let attempt = 0; attempt <= RETRY_DELAYS_MS.length; attempt += 1) {
		try {
			await putToPresignedUrl(uploadUrl, file, onProgress, signal)
			return
		} catch (error) {
			if (error instanceof UploadAbortedError) throw error
			lastError = error
			if (attempt < RETRY_DELAYS_MS.length) {
				onProgress(0)
				await delay(RETRY_DELAYS_MS[attempt], signal)
			}
		}
	}

	throw lastError
}
