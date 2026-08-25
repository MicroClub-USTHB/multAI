import { useState } from 'react'
import { Plus } from 'lucide-react'

import {
	Button,
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
	Input,
} from '@/shared/ui'

import type { CreateMultiEventInput } from '../types'

interface EventFormProps {
	onSubmit: (input: CreateMultiEventInput) => Promise<void>
	isSubmitting: boolean
}

export function EventForm({ onSubmit, isSubmitting }: EventFormProps) {
	const [name, setName] = useState('')
	const [eventDate, setEventDate] = useState('')

	const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!name.trim() || !eventDate) return

		await onSubmit({ name: name.trim(), eventDate: new Date(eventDate).toISOString() })
		setName('')
		setEventDate('')
	}

	return (
		<Card>
			<CardHeader>
				<CardTitle className="flex items-center gap-2 text-base">
					<Plus className="size-4" />
					Create Event
				</CardTitle>
			</CardHeader>
			<form onSubmit={handleSubmit}>
				<CardContent className="space-y-4">
					<div className="space-y-1.5">
						<label className="text-sm font-medium" htmlFor="event-name">
							Event Name
						</label>
						<Input
							id="event-name"
							placeholder="e.g. HackOPS 2026"
							value={name}
							onChange={event => setName(event.target.value)}
							required
						/>
					</div>
					<div className="space-y-1.5">
						<label className="text-sm font-medium" htmlFor="event-date">
							Event Date
						</label>
						<Input
							id="event-date"
							type="datetime-local"
							value={eventDate}
							onChange={event => setEventDate(event.target.value)}
							required
						/>
					</div>
				</CardContent>
				<CardFooter>
					<Button type="submit" disabled={isSubmitting}>
						{isSubmitting ? 'Creating...' : 'Create Event'}
					</Button>
				</CardFooter>
			</form>
		</Card>
	)
}
