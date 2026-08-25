import { RotateCcw } from 'lucide-react'

import { Alert, AlertDescription, AlertTitle, Button, Progress, ProgressTrack, ProgressIndicator } from '@/shared/ui'

import type { UploadStats } from '../types'

interface UploadSummaryProps {
	stats: UploadStats
	onRetryFailed: () => void
}

export function UploadSummary({ stats, onRetryFailed }: UploadSummaryProps) {
	if (stats.total === 0) return null

	const done = stats.success + stats.failed
	const percent = stats.total === 0 ? 0 : Math.round((done / stats.total) * 100)

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

			<div className="space-y-1">
				<div className="text-muted-foreground flex items-center justify-between text-sm">
					<span>
						{stats.success} uploaded, {stats.uploading} uploading, {stats.pending} queued
						{stats.failed > 0 ? `, ${stats.failed} failed` : ''} &middot; {stats.total} total
					</span>
					<span>{percent}%</span>
				</div>
				<Progress value={percent}>
					<ProgressTrack>
						<ProgressIndicator />
					</ProgressTrack>
				</Progress>
			</div>
		</div>
	)
}
