import { AlertCircle, CheckCircle2, Loader2, PauseCircle, RotateCcw, X } from 'lucide-react'

import { Button, Progress, ProgressTrack, ProgressIndicator } from '@/shared/ui'

import type { UploadItem } from '../types'

const formatSize = (bytes: number) => {
	if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`
	return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

interface UploadItemRowProps {
	item: UploadItem
	onRetry: (id: string) => void
	onRemove: (id: string) => void
}

export function UploadItemRow({ item, onRetry, onRemove }: UploadItemRowProps) {
	return (
		<div className="flex items-center gap-3 border-b border-border/40 px-3 py-2 last:border-b-0">
			<div className="min-w-0 flex-1">
				<div className="flex items-center gap-2">
					<span className="truncate text-sm font-medium">{item.fileName}</span>
					<span className="text-muted-foreground shrink-0 text-xs">
						{formatSize(item.sizeBytes)}
					</span>
				</div>
				{item.status === 'uploading' ? (
					<Progress value={item.progress} className="mt-1">
						<ProgressTrack className="h-1">
							<ProgressIndicator />
						</ProgressTrack>
					</Progress>
				) : item.status === 'failed' ? (
					<p className="text-destructive mt-0.5 text-xs">{item.error ?? 'Upload failed'}</p>
				) : null}
			</div>

			<div className="flex shrink-0 items-center gap-1">
				{item.status === 'success' ? (
					<CheckCircle2 className="size-4 text-green-600" />
				) : item.status === 'uploading' ? (
					<Loader2 className="text-muted-foreground size-4 animate-spin" />
				) : item.status === 'failed' ? (
					<>
						<AlertCircle className="text-destructive size-4" />
						<Button
							variant="ghost"
							size="icon-sm"
							type="button"
							onClick={() => onRetry(item.id)}
							aria-label="Retry upload"
						>
							<RotateCcw className="size-4" />
						</Button>
					</>
				) : item.status === 'paused' ? (
					<PauseCircle className="text-muted-foreground size-4" />
				) : (
					<span className="text-muted-foreground text-xs">Queued</span>
				)}
				<Button
					variant="ghost"
					size="icon-sm"
					type="button"
					onClick={() => onRemove(item.id)}
					aria-label="Remove"
					disabled={item.status === 'uploading'}
				>
					<X className="size-4" />
				</Button>
			</div>
		</div>
	)
}
