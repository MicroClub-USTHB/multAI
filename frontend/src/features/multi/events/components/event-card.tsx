import { Calendar, Check, Copy, Download, QrCode } from 'lucide-react'
import { useState } from 'react'
import QRCode from 'react-qr-code'

import {
	Button,
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
} from '@/shared/ui'

import type { MultiEvent } from '../types'

import { exportEventPdf } from '../utils/export-event-pdf'
import { EventStatusBadge } from './event-status-badge'

const formatDateTime = (value: string) =>
	new Date(value).toLocaleString(undefined, {
		year: 'numeric',
		month: 'short',
		day: '2-digit',
		hour: '2-digit',
		minute: '2-digit',
	})

interface EventCardProps {
	event: MultiEvent
}

export function EventCard({ event }: EventCardProps) {
	const [isQrOpen, setIsQrOpen] = useState(false)
	const [isExporting, setIsExporting] = useState(false)
	const [isCopied, setIsCopied] = useState(false)

	const handleCopyCode = async () => {
		try {
			if (navigator.clipboard?.writeText) {
				await navigator.clipboard.writeText(event.eventCode)
			} else {
				const textarea = document.createElement('textarea')
				textarea.value = event.eventCode
				textarea.style.position = 'fixed'
				textarea.style.opacity = '0'
				document.body.appendChild(textarea)
				textarea.select()
				document.execCommand('copy')
				document.body.removeChild(textarea)
			}
			setIsCopied(true)
			setTimeout(() => setIsCopied(false), 1500)
		} catch {
			// clipboard access denied by the browser; nothing more we can do here
		}
	}

	const handleExportPdf = async () => {
		setIsExporting(true)
		try {
			await exportEventPdf(event)
		} finally {
			setIsExporting(false)
		}
	}

	return (
		<Card>
			<CardHeader className="flex flex-row items-start justify-between gap-2">
				<CardTitle className="text-base">{event.name}</CardTitle>
				<EventStatusBadge status={event.status} />
			</CardHeader>
			<CardContent className="space-y-3">
				<div className="text-muted-foreground flex items-center gap-2 text-sm">
					<Calendar className="size-4" />
					<span>{formatDateTime(event.eventDate)}</span>
				</div>
				<div className="flex items-center justify-between gap-2 rounded-md border border-border/70 bg-muted/30 px-3 py-2">
					<span className="font-mono text-sm">{event.eventCode}</span>
					<div className="flex items-center gap-1">
						<Button
							variant="ghost"
							size="icon-sm"
							type="button"
							onClick={() => setIsQrOpen(true)}
							aria-label="Show QR code"
						>
							<QrCode className="size-4" />
						</Button>
						<Button
							variant="ghost"
							size="icon-sm"
							type="button"
							onClick={() => void handleCopyCode()}
							aria-label="Copy event code"
						>
							{isCopied ? (
								<Check className="size-4 text-green-600" />
							) : (
								<Copy className="size-4" />
							)}
						</Button>
					</div>
				</div>
			</CardContent>

			<Dialog open={isQrOpen} onOpenChange={setIsQrOpen}>
				<DialogContent className="sm:max-w-xs">
					<DialogHeader>
						<DialogTitle>{event.name}</DialogTitle>
						<DialogDescription>
							Scan to get the join code for this event.
						</DialogDescription>
					</DialogHeader>
					<div className="flex flex-col items-center gap-4 py-2">
						<div className="rounded-md bg-white p-4">
							<QRCode value={event.eventCode} size={192} />
						</div>
						<span className="font-mono text-sm">{event.eventCode}</span>
					</div>
					<CardFooter className="justify-center px-0">
						<Button
							type="button"
							variant="outline"
							disabled={isExporting}
							onClick={() => void handleExportPdf()}
						>
							<Download className="size-4" />
							{isExporting ? 'Exporting...' : 'Export as PDF'}
						</Button>
					</CardFooter>
				</DialogContent>
			</Dialog>
		</Card>
	)
}
