import { PauseCircle, PlayCircle, RotateCcw } from 'lucide-react'

import { Alert, AlertDescription, AlertTitle, Button, Progress, ProgressTrack, ProgressIndicator } from '@/shared/ui'

import type { UploadStats } from '../types'

interface UploadSummaryProps {
	stats: UploadStats
	isPaused: boolean
	onRetryFailed: () => void
	onPauseAll: () => void
	onContinueAll: () => void
}

export function UploadSummary({
	stats,
	isPaused,
	onRetryFailed,
	onPauseAll,
	onContinueAll,
}: UploadSummaryProps) {
	if (stats.total === 0) return null

	const done = stats.success + stats.failed
	const percent = stats.total === 0 ? 0 : Math.round((done / stats.total) * 100)
	const isActive = stats.uploading > 0 || stats.pending > 0

	return (
		<div className="space-y-3">
			{stats.failed > 0 ? (
				<Alert variant="destructive">
					<AlertTitle>
						{stats.failed} {stats.failed === 1 ? 'file' : 'files'} failed to upload
					</AlertTitle>
					<AlertDescription className="flex items-center justify-between gap-4">
						<span>Fix your connection if needed, then retry the failed files.</span>
						<Button size="sm" variant="outline" onClick={onRetryFailed}>
							<RotateCcw className="size-4" />
							Retry failed
						</Button>
					</AlertDescription>
				</Alert>
			) : null}

			{stats.paused > 0 ? (
				<Alert>
					<AlertTitle>Upload paused</AlertTitle>
					<AlertDescription className="flex items-center justify-between gap-4">
						<span>{stats.paused} files are waiting to continue.</span>
						<Button size="sm" variant="outline" onClick={onContinueAll}>
							<PlayCircle className="size-4" />
							Continue
						</Button>
					</AlertDescription>
				</Alert>
			) : null}

			<div className="space-y-1">
				<div className="text-muted-foreground flex items-center justify-between text-sm">
					<span>
						{stats.success} uploaded, {stats.uploading} uploading, {stats.pending} queued
						{stats.failed > 0 ? `, ${stats.failed} failed` : ''}
						{stats.paused > 0 ? `, ${stats.paused} paused` : ''} &middot; {stats.total} total
					</span>
					<div className="flex items-center gap-2">
						<span>{percent}%</span>
						{isActive ? (
							<Button size="icon-sm" variant="ghost" onClick={onPauseAll} aria-label="Pause all">
								<PauseCircle className="size-4" />
							</Button>
						) : stats.paused > 0 ? (
							<Button size="icon-sm" variant="ghost" onClick={onContinueAll} aria-label="Continue all">
								<PlayCircle className="size-4" />
							</Button>
						) : null}
					</div>
				</div>
				<Progress value={percent}>
					<ProgressTrack>
						<ProgressIndicator />
					</ProgressTrack>
				</Progress>
			</div>

			{isPaused ? (
				<p className="text-muted-foreground text-xs">Uploading is paused.</p>
			) : null}
		</div>
	)
}
