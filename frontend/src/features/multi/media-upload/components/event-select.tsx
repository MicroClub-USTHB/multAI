import { useMultiEventsQuery } from '@/features/multi/events/hooks'
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/shared/ui'

interface EventSelectProps {
	value: string | null
	onChange: (eventId: string | null) => void
	disabled?: boolean
}

export function EventSelect({ value, onChange, disabled }: EventSelectProps) {
	const { data: events, isLoading } = useMultiEventsQuery()

	return (
		<Select value={value ?? undefined} onValueChange={onChange} disabled={disabled || isLoading}>
			<SelectTrigger className="w-full sm:w-80">
				<SelectValue placeholder={isLoading ? 'Loading events...' : 'Choose an event'} />
			</SelectTrigger>
			<SelectContent>
				{(events ?? [])
					.filter((event) => event.status !== 'archived')
					.map((event) => (
						<SelectItem key={event.id} value={event.id}>
							{event.name}
						</SelectItem>
					))}
			</SelectContent>
		</Select>
	)
}
