import { useCallback, useRef, useState } from 'react'

import {
	confirmDirectUpload,
	createDirectGroup,
	DIRECT_UPLOAD_MAX_BATCH_SIZE,
	failDirectUpload,
	registerDirectBatch,
	resumeDirectGroup,
	type DirectFileInput,
} from './api'
import type { UploadItem, UploadItemStatus, UploadStats } from './types'
import { putToPresignedUrl, UploadAbortedError } from './upload-client'

const CONCURRENCY = 4

const genId = () =>
	typeof crypto !== 'undefined' && 'randomUUID' in crypto
		? crypto.randomUUID()
		: `${Date.now()}-${Math.random().toString(36).slice(2)}`

const toUploadItem = (file: File): UploadItem => ({
	id: genId(),
	file,
	fileName: file.name,
	sizeBytes: file.size,
	status: 'pending',
	progress: 0,
	error: null,
	photoId: null,
	uploadUrl: null,
})

const toDirectFileInput = (item: UploadItem): DirectFileInput => ({
	file_name: item.file.name,
	mime_type: item.file.type || 'application/octet-stream',
	size_bytes: item.file.size,
})

const chunk = <T,>(items: T[], size: number): T[][] => {
	const chunks: T[][] = []
	for (let i = 0; i < items.length; i += size) {
		chunks.push(items.slice(i, i + size))
	}
	return chunks
}

export function computeStats(items: UploadItem[]): UploadStats {
	const stats: UploadStats = {
		total: items.length,
		pending: 0,
		uploading: 0,
		success: 0,
		failed: 0,
		paused: 0,
	}
	for (const item of items) {
		stats[item.status] += 1
	}
	return stats
}

export function useBulkUpload(eventId: string | null) {
	const [items, setItems] = useState<UploadItem[]>([])
	const runningCount = useRef(0)
	const queue = useRef<string[]>([])
	const abortControllers = useRef(new Map<string, AbortController>())
	const itemsRef = useRef<UploadItem[]>([])
	itemsRef.current = items

	const isPaused = useRef(false)
	const groupIdRef = useRef<string | null>(null)
	const groupEventIdRef = useRef<string | null>(null)

	const updateItem = useCallback((id: string, patch: Partial<UploadItem>) => {
		setItems((previous) =>
			previous.map((item) => (item.id === id ? { ...item, ...patch } : item)),
		)
	}, [])

	const ensureGroup = useCallback(async (): Promise<string> => {
		if (!eventId) throw new Error('No event selected')
		if (groupIdRef.current && groupEventIdRef.current === eventId) {
			return groupIdRef.current
		}
		const group = await createDirectGroup(eventId)
		groupIdRef.current = group.id
		groupEventIdRef.current = eventId
		return group.id
	}, [eventId])

	const drain = useCallback(() => {
		if (isPaused.current) return
		while (runningCount.current < CONCURRENCY && queue.current.length > 0) {
			const nextId = queue.current.shift()
			if (nextId) runOne(nextId)
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [])

	const runOne = useCallback(
		(id: string) => {
			const item = itemsRef.current.find((candidate) => candidate.id === id)
			if (!item || !item.photoId || !item.uploadUrl) return

			const controller = new AbortController()
			abortControllers.current.set(id, controller)
			runningCount.current += 1
			updateItem(id, { status: 'uploading', progress: 0, error: null })

			putToPresignedUrl(item.uploadUrl, item.file, (percent) => updateItem(id, { progress: percent }), controller.signal)
				.then(async () => {
					await confirmDirectUpload(item.photoId!)
					updateItem(id, { status: 'success', progress: 100 })
				})
				.catch(async (error: unknown) => {
					if (error instanceof UploadAbortedError) {
						updateItem(id, { status: 'paused' })
						return
					}
					const message = error instanceof Error ? error.message : 'Upload failed'
					updateItem(id, { status: 'failed', error: message })
					try {
						await failDirectUpload(item.photoId!)
					} catch {
						// best-effort — the item is already marked failed locally
					}
				})
				.finally(() => {
					abortControllers.current.delete(id)
					runningCount.current -= 1
					drain()
				})
		},
		// eslint-disable-next-line react-hooks/exhaustive-deps
		[updateItem],
	)

	const enqueue = useCallback(
		(ids: string[]) => {
			queue.current.push(...ids)
			drain()
		},
		[drain],
	)

	const registerAndEnqueue = useCallback(
		async (pendingItems: UploadItem[]) => {
			if (pendingItems.length === 0) return
			const groupId = await ensureGroup()

			for (const batch of chunk(pendingItems, DIRECT_UPLOAD_MAX_BATCH_SIZE)) {
				try {
					const result = await registerDirectBatch(groupId, batch.map(toDirectFileInput))
					const readyIds: string[] = []
					result.items.forEach((registered, index) => {
						const localItem = batch[index]
						updateItem(localItem.id, {
							photoId: registered.photo_id,
							uploadUrl: registered.upload_url,
						})
						readyIds.push(localItem.id)
					})
					enqueue(readyIds)
				} catch (error) {
					const message = error instanceof Error ? error.message : 'Could not register files for upload'
					for (const localItem of batch) {
						updateItem(localItem.id, { status: 'failed', error: message })
					}
				}
			}
		},
		[ensureGroup, enqueue, updateItem],
	)

	const addFiles = useCallback(
		(files: FileList | File[]) => {
			const newItems = Array.from(files).map(toUploadItem)
			setItems((previous) => [...previous, ...newItems])
			void registerAndEnqueue(newItems)
		},
		[registerAndEnqueue],
	)

	const pauseAll = useCallback(() => {
		isPaused.current = true
		queue.current = []
		for (const controller of abortControllers.current.values()) {
			controller.abort()
		}
		setItems((previous) =>
			previous.map((item) =>
				item.status === 'pending' ? { ...item, status: 'paused' as UploadItemStatus } : item,
			),
		)
	}, [])

	const continueAll = useCallback(() => {
		isPaused.current = false
		const resumeIds = itemsRef.current
			.filter((item) => item.status === 'paused' && item.photoId && item.uploadUrl)
			.map((item) => item.id)
		setItems((previous) =>
			previous.map((item) =>
				item.status === 'paused' ? { ...item, status: 'pending' as UploadItemStatus } : item,
			),
		)
		enqueue(resumeIds)
	}, [enqueue])

	const retryFailed = useCallback(async () => {
		const failedWithPhoto = itemsRef.current.filter((item) => item.status === 'failed' && item.photoId)
		const failedWithoutPhoto = itemsRef.current.filter((item) => item.status === 'failed' && !item.photoId)

		if (failedWithPhoto.length > 0 && groupIdRef.current) {
			try {
				const result = await resumeDirectGroup(groupIdRef.current)
				const urlByPhotoId = new Map(result.items.map((entry) => [entry.photo_id, entry.upload_url]))
				const readyIds: string[] = []
				for (const item of failedWithPhoto) {
					const freshUrl = urlByPhotoId.get(item.photoId!)
					if (freshUrl) {
						updateItem(item.id, { status: 'pending', error: null, uploadUrl: freshUrl })
						readyIds.push(item.id)
					}
				}
				enqueue(readyIds)
			} catch (error) {
				const message = error instanceof Error ? error.message : 'Could not resume upload session'
				for (const item of failedWithPhoto) {
					updateItem(item.id, { error: message })
				}
			}
		}

		if (failedWithoutPhoto.length > 0) {
			for (const item of failedWithoutPhoto) {
				updateItem(item.id, { status: 'pending', error: null })
			}
			await registerAndEnqueue(failedWithoutPhoto)
		}
	}, [enqueue, registerAndEnqueue, updateItem])

	const retryOne = useCallback(
		(id: string) => {
			const item = itemsRef.current.find((candidate) => candidate.id === id)
			if (!item) return
			if (item.photoId && item.uploadUrl) {
				updateItem(id, { status: 'pending', progress: 0, error: null })
				enqueue([id])
			} else {
				updateItem(id, { status: 'pending', progress: 0, error: null })
				void registerAndEnqueue([item])
			}
		},
		[enqueue, registerAndEnqueue, updateItem],
	)

	const removeItem = useCallback((id: string) => {
		abortControllers.current.get(id)?.abort()
		abortControllers.current.delete(id)
		queue.current = queue.current.filter((queuedId) => queuedId !== id)
		setItems((previous) => previous.filter((item) => item.id !== id))
	}, [])

	const clearCompleted = useCallback(() => {
		setItems((previous) => previous.filter((item) => item.status !== 'success'))
	}, [])

	return {
		items,
		stats: computeStats(items),
		isPaused: isPaused.current,
		addFiles,
		retryOne,
		retryFailed,
		pauseAll,
		continueAll,
		removeItem,
		clearCompleted,
	}
}
