import { useCallback, useRef, useState } from 'react'

import type { UploadItem, UploadItemStatus, UploadStats } from './types'

import { uploadFile } from './upload-client'

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
})

export function computeStats(items: UploadItem[]): UploadStats {
	const stats: UploadStats = { total: items.length, pending: 0, uploading: 0, success: 0, failed: 0 }
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

	const updateItem = useCallback((id: string, patch: Partial<UploadItem>) => {
		setItems((previous) =>
			previous.map((item) => (item.id === id ? { ...item, ...patch } : item)),
		)
	}, [])

	const runOne = useCallback(
		(id: string) => {
			if (!eventId) return

			const item = itemsRef.current.find((candidate) => candidate.id === id)
			if (!item) return

			const controller = new AbortController()
			abortControllers.current.set(id, controller)
			runningCount.current += 1
			updateItem(id, { status: 'uploading', progress: 0, error: null })

			uploadFile({
				eventId,
				file: item.file,
				signal: controller.signal,
				onProgress: (percent) => updateItem(id, { progress: percent }),
			})
				.then(() => {
					updateItem(id, { status: 'success', progress: 100 })
				})
				.catch((error: unknown) => {
					const message = error instanceof Error ? error.message : 'Upload failed'
					updateItem(id, { status: 'failed', error: message })
				})
				.finally(() => {
					abortControllers.current.delete(id)
					runningCount.current -= 1
					drain()
				})
		},
		// eslint-disable-next-line react-hooks/exhaustive-deps
		[eventId, updateItem],
	)

	const drain = useCallback(() => {
		while (runningCount.current < CONCURRENCY && queue.current.length > 0) {
			const nextId = queue.current.shift()
			if (nextId) runOne(nextId)
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [runOne])

	const enqueue = useCallback(
		(ids: string[]) => {
			queue.current.push(...ids)
			drain()
		},
		[drain],
	)

	const addFiles = useCallback(
		(files: FileList | File[]) => {
			const newItems = Array.from(files).map(toUploadItem)
			setItems((previous) => [...previous, ...newItems])
			enqueue(newItems.map((item) => item.id))
		},
		[enqueue],
	)

	const retryOne = useCallback(
		(id: string) => {
			updateItem(id, { status: 'pending', progress: 0, error: null })
			enqueue([id])
		},
		[enqueue, updateItem],
	)

	const retryFailed = useCallback(() => {
		const failedIds = itemsRef.current
			.filter((item) => item.status === 'failed')
			.map((item) => item.id)
		if (failedIds.length === 0) return
		setItems((previous) =>
			previous.map((item) =>
				item.status === 'failed' ? { ...item, status: 'pending' as UploadItemStatus, error: null } : item,
			),
		)
		enqueue(failedIds)
	}, [enqueue])

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
		addFiles,
		retryOne,
		retryFailed,
		removeItem,
		clearCompleted,
	}
}
