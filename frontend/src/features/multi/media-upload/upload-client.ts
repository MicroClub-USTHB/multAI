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
