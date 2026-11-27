import { CalendarPlus, ExternalLink } from 'lucide-react'

import { env } from '@/env'
import {
	Button,
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from '@/shared/ui'

import type { CreateMultiEventInput } from '../types'

interface EventFormProps {
	onSubmit?: (input: CreateMultiEventInput) => Promise<void>
	isSubmitting?: boolean
}

export function EventForm({}: EventFormProps) {
	const hrEventsUrl = env.VITE_HR_EVENTS_URL || 'https://hr.microclub.info'

	return (
		<Card className="border-dashed border-primary/30 bg-primary/5">
			<CardHeader className="pb-2">
				<CardTitle className="flex items-center gap-2 text-base text-primary">
					<CalendarPlus className="size-4" />
					Create New Event
				</CardTitle>
			</CardHeader>
			<CardContent className="space-y-2 text-sm text-muted-foreground">
				<p>
					Events are now managed centrally in <strong>HR-Events</strong>. 
					New events created in HR-Events are automatically synced here for media uploads and attendee check-ins.
				</p>
			</CardContent>
			<CardFooter>
				<Button
					type="button"
					onClick={() => window.open(hrEventsUrl, '_blank')}
				>
					<ExternalLink className="mr-2 size-4" />
					Open HR-Events
				</Button>
			</CardFooter>
		</Card>
	)
}
