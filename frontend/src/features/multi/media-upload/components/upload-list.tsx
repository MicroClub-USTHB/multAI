import { useMemo, useState } from 'react'

import { Button } from '@/shared/ui'

import type { UploadItem } from '../types'

import { UploadItemRow } from './upload-item-row'

const PAGE_SIZE = 100

interface UploadListProps {
	items: UploadItem[]
	onRetry: (id: string) => void
	onRemove: (id: string) => void
}

export function UploadList({ items, onRetry, onRemove }: UploadListProps) {
	const [visibleCount, setVisibleCount] = useState(PAGE_SIZE)

	const { failed, rest } = useMemo(() => {
		const failedItems: UploadItem[] = []
		const restItems: UploadItem[] = []
		for (const item of items) {
			if (item.status === 'failed') failedItems.push(item)
			else restItems.push(item)
		}
		return { failed: failedItems, rest: restItems }
	}, [items])

	if (items.length === 0) return null

	const visibleRest = rest.slice(0, visibleCount)
	const remaining = rest.length - visibleRest.length

	return (
		<div className="space-y-4">
			{failed.length > 0 ? (
				<div className="rounded-md border border-destructive/40">
					<div className="border-b border-destructive/40 bg-destructive/5 px-3 py-1.5 text-sm font-medium">
						Failed ({failed.length}) &mdash; needs your attention
					</div>
					{failed.map((item) => (
						<UploadItemRow key={item.id} item={item} onRetry={onRetry} onRemove={onRemove} />
					))}
				</div>
			) : null}

			{rest.length > 0 ? (
				<div className="rounded-md border border-border/70">
					{visibleRest.map((item) => (
						<UploadItemRow key={item.id} item={item} onRetry={onRetry} onRemove={onRemove} />
					))}
					{remaining > 0 ? (
						<div className="flex justify-center border-t border-border/40 p-2">
							<Button
								variant="ghost"
								size="sm"
								onClick={() => setVisibleCount((count) => count + PAGE_SIZE)}
							>
								Show {Math.min(remaining, PAGE_SIZE)} more ({remaining} remaining)
							</Button>
						</div>
					) : null}
				</div>
			) : null}
		</div>
	)
}
