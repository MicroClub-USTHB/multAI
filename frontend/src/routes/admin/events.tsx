import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { Plus } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { z } from 'zod'

import { AdminEventsApiError } from '@/features/admin/events/api'
import {
	CreateEventDialog,
	EventsFilters,
	EventsStatsCards,
	EventsTable,
} from '@/features/admin/events/components'
import { useAdminEvents } from '@/features/admin/events/hooks'
import { EVENT_STATUSES, type AdminEvent, type EventStatus } from '@/features/admin/events/types'
import {
	Alert,
	AlertDescription,
	AlertTitle,
	Button,
	Card,
	CardContent,
	Skeleton,
} from '@/shared/ui'

const EVENT_STATUS_FILTERS = ['all', ...EVENT_STATUSES] as const

const eventsSearchSchema = z.object({
	name: z.string().catch(''),
	status: z.enum(EVENT_STATUS_FILTERS).catch('all'),
})

export const Route = createFileRoute('/admin/events')({
	component: EventsPage,
	validateSearch: eventsSearchSchema,
})

function EventsPage() {
	const navigate = useNavigate()
	const { name, status } = Route.useSearch()

	const [searchInput, setSearchInput] = useState(name)
	const [statusFilter, setStatusFilter] = useState<'all' | EventStatus>(status)
	const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
	const [actionError, setActionError] = useState<string | null>(null)

	useEffect(() => {
		setSearchInput(name)
	}, [name])

	useEffect(() => {
		setStatusFilter(status)
	}, [status])

	const queryParams = useMemo(
		() => ({
			limit: 50,
			offset: 0,
			name: name.trim() || undefined,
			status,
		}),
		[name, status],
	)

	const {
		events,
		isLoading,
		isError,
		error,
		createEvent,
		scheduleEvent,
		archiveEvent,
		draftEvent,
		isMutating,
		refetch,
	} = useAdminEvents(queryParams)

	const stats = useMemo(() => {
		const draft = events.filter((event) => event.status === 'draft').length
		const scheduled = events.filter((event) => event.status === 'scheduled').length
		const archived = events.filter((event) => event.status === 'archived').length

		return {
			total: events.length,
			draft,
			scheduled,
			archived,
		}
	}, [events])

	const activeFilterLabel =
		status === 'all'
			? 'all statuses'
			: `${status[0].toUpperCase()}${status.slice(1)}`

	const errorMessage =
		error instanceof AdminEventsApiError && error.status === 401
			? 'Session admin absente. Connecte-toi puis reessaie.'
			: error instanceof Error
				? error.message
				: 'Unknown error'

	const handleApplyFilters = () => {
		setActionError(null)
		navigate({
			to: '/admin/events',
			search: {
				name: searchInput.trim(),
				status: statusFilter,
			},
			replace: true,
		})
	}

	const handleResetFilters = () => {
		setActionError(null)
		setSearchInput('')
		setStatusFilter('all')
		navigate({
			to: '/admin/events',
			search: {
				name: '',
				status: 'all',
			},
			replace: true,
		})
	}

	const handleCreateEvent = async ({
		name: eventName,
		eventDate,
		status: nextStatus,
	}: {
		name: string
		eventDate: string
		status?: EventStatus
	}) => {
		setActionError(null)

		if (!eventName.trim()) {
			setActionError("Le nom de l'event est obligatoire.")
			return
		}

		try {
			await createEvent({
				name: eventName,
				eventDate,
				status: nextStatus,
			})

			setIsCreateDialogOpen(false)
		} catch (mutationError) {
			setActionError(
				mutationError instanceof Error
					? mutationError.message
					: "Impossible de creer l'event.",
			)
		}
	}

	const handleStatusChange = async (
		eventItem: AdminEvent,
		nextStatus: EventStatus,
	) => {
		setActionError(null)

		try {
			if (nextStatus === 'scheduled') {
				await scheduleEvent(eventItem.id)
				return
			}

			if (nextStatus === 'archived') {
				await archiveEvent(eventItem.id)
				return
			}

			await draftEvent(eventItem.id)
		} catch (mutationError) {
			setActionError(
				mutationError instanceof Error
					? mutationError.message
					: 'Impossible de mettre a jour le statut.',
			)
		}
	}

	return (
		<div className='flex-1 space-y-6 p-4 md:p-6'>
			<div className='flex flex-col gap-4 md:flex-row md:items-end md:justify-between'>
				<div className='space-y-2'>
					<p className='text-muted-foreground text-sm font-medium uppercase tracking-[0.2em]'>
						Admin events
					</p>
					<h1 className='text-4xl font-bold tracking-tight'>Events</h1>
					<p className='text-muted-foreground max-w-2xl text-sm'>
						Manage events from the backend admin endpoints. Search by name,
						filter by status, create new events, and move them through the
						lifecycle.
					</p>
				</div>

				<div className='flex flex-wrap gap-2'>
					<Button
						variant='outline'
						onClick={() => {
							void refetch()
						}}
						disabled={isLoading || isMutating}
					>
						Refresh
					</Button>
					<Button onClick={() => setIsCreateDialogOpen(true)} disabled={isMutating}>
						<Plus />
						Create event
					</Button>
				</div>
			</div>

			<EventsStatsCards {...stats} />

			<Card className='gap-4 py-4'>
				<CardContent className='space-y-4 px-4'>
					<EventsFilters
						searchInput={searchInput}
						statusFilter={statusFilter}
						isBusy={isLoading || isMutating}
						onSearchInputChange={setSearchInput}
						onStatusFilterChange={setStatusFilter}
						onApply={handleApplyFilters}
						onReset={handleResetFilters}
					/>

					<div className='text-muted-foreground flex flex-wrap items-center justify-between gap-2 text-sm'>
						<p>
							Showing {events.length} events for{' '}
							<span className='font-medium'>{activeFilterLabel}</span>
							{name.trim() ? ` matching "${name.trim()}"` : ''}
						</p>
						<p className='text-xs uppercase tracking-[0.2em]'>Filtered list</p>
					</div>

					{actionError ? (
						<Alert variant='destructive'>
							<AlertTitle>Action failed</AlertTitle>
							<AlertDescription>{actionError}</AlertDescription>
						</Alert>
					) : null}

					{isError ? (
						<Alert variant='destructive'>
							<AlertTitle>Failed to load events</AlertTitle>
							<AlertDescription>{errorMessage}</AlertDescription>
						</Alert>
					) : isLoading ? (
						<div className='space-y-2'>
							<Skeleton className='h-10 w-full' />
							<Skeleton className='h-10 w-full' />
							<Skeleton className='h-10 w-full' />
						</div>
					) : (
						<div className='border-border/40 overflow-hidden rounded-md border'>
							<EventsTable
								events={events}
								onStatusChange={(eventItem, nextStatus) => {
									void handleStatusChange(eventItem, nextStatus)
								}}
							/>
						</div>
					)}
				</CardContent>
			</Card>

			<CreateEventDialog
				open={isCreateDialogOpen}
				isSubmitting={isMutating}
				onOpenChange={setIsCreateDialogOpen}
				onSubmit={handleCreateEvent}
			/>
		</div>
	)
}
