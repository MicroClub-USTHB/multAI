import { Badge } from '@/shared/ui'

import type { EventStatus } from '../types'

const STATUS_LABELS: Record<EventStatus, string> = {
	draft: 'Draft',
	scheduled: 'Scheduled',
	archived: 'Archived',
}

const statusBadgeVariant = (status: EventStatus) => {
	if (status === 'scheduled') {
		return 'default'
	}

	if (status === 'archived') {
		return 'secondary'
	}

	return 'outline'
}

export function EventStatusBadge({ status }: { status: EventStatus }) {
	return <Badge variant={statusBadgeVariant(status)}>{STATUS_LABELS[status]}</Badge>
}
