import type { AuditEvent } from '@/features/admin/logs/types'

import { Badge } from '@/shared/ui'
import {
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableHeader,
	TableRow,
} from '@/shared/ui'
import { cn } from '@/shared/utils/helpers'

import { splitTimestamp } from '../utils'

const eventTypeVariants: Record<string, string> = {
	'user.signup': 'border-emerald-500/80 text-emerald-400',
	'user.login': 'border-blue-500/80 text-blue-400',
	'user.logout': 'border-slate-500/80 text-slate-300',
	'upload_request.created': 'border-purple-500/80 text-purple-300',
	'upload_request.approved': 'border-emerald-500/80 text-emerald-400',
	'upload_request.rejected': 'border-red-500/80 text-red-400',
	'photo.processed': 'border-amber-500/80 text-amber-300',
	'photo_approval.decided': 'border-cyan-500/80 text-cyan-300',
}

const formatMetadata = (metadata: AuditEvent['metadata']) => {
	if (!metadata) {
		return '—'
	}

	try {
		return JSON.stringify(metadata)
	} catch {
		return '—'
	}
}

export function AuditsTable({ audits }: { audits: AuditEvent[] }) {
	return (
		<div className="border-border/40 rounded-md border">
			<Table>
				<TableHeader className="bg-transparent">
					<TableRow>
						<TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
							Timestamp
						</TableHead>
						<TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
							Event Type
						</TableHead>
						<TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
							Actor
						</TableHead>
						<TableHead className="text-muted-foreground h-9 px-2 text-xs font-medium">
							Metadata
						</TableHead>
					</TableRow>
				</TableHeader>

				<TableBody>
					{audits.length ? (
						audits.map((audit) => {
							const [date, time] = splitTimestamp(audit.createdAt)
							const actorName =
								audit.actor?.displayName ?? audit.actor?.email ?? '—'

							return (
								<TableRow key={audit.id} className="border-border/40">
									<TableCell className="px-2 py-2.5 align-top">
										<div className="text-foreground/90 font-mono text-sm leading-tight whitespace-nowrap">
											<div>{date}</div>
											<div>{time}</div>
										</div>
									</TableCell>
									<TableCell className="px-2 py-2.5 align-top">
										<Badge
											variant="outline"
											className={cn(
												'h-6 rounded-sm bg-transparent px-2.5 text-xs',
												eventTypeVariants[audit.eventType] ??
													'border-border/60 text-muted-foreground',
											)}
										>
											{audit.eventType}
										</Badge>
									</TableCell>
									<TableCell className="text-foreground/90 px-2 py-2.5 text-sm align-top">
										{actorName}
									</TableCell>
									<TableCell className="text-muted-foreground px-2 py-2.5 text-sm align-top">
										{formatMetadata(audit.metadata)}
									</TableCell>
								</TableRow>
							)
						})
					) : (
						<TableRow>
							<TableCell colSpan={4} className="h-24 text-center text-sm">
								No results.
							</TableCell>
						</TableRow>
					)}
				</TableBody>
			</Table>
		</div>
	)
}
