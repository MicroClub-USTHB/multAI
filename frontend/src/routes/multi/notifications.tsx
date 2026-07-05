import { createFileRoute } from '@tanstack/react-router'
import { Bell, CheckCheck, RefreshCcw } from 'lucide-react'
import { useMemo, useState } from 'react'

import { MultiNotificationsApiError } from '@/features/multi/notifications/api'
import { useMultiNotifications } from '@/features/multi/notifications/hooks'
import type { MultiNotification } from '@/features/multi/notifications/types'
import {
	Alert,
	AlertDescription,
	AlertTitle,
	Badge,
	Button,
	Card,
	CardContent,
	CardHeader,
	CardTitle,
	Skeleton,
	Separator,
} from '@/shared/ui'
import { ScrollArea } from '@/shared/ui/layout/scroll-area'
import { cn } from '@/shared/utils/helpers'

export const Route = createFileRoute('/multi/notifications')({
	component: MultiNotificationsPage,
})

function MultiNotificationsPage() {
	const {
		notifications,
		isLoading,
		isError,
		error,
		refetch,
		markAsRead,
		isMutating,
	} = useMultiNotifications()

	const [view, setView] = useState<'all' | 'unread' | 'read'>('all')

	const unreadNotifications = useMemo(
		() => notifications.filter((notification) => !notification.readAt),
		[notifications],
	)
	const readNotifications = useMemo(
		() => notifications.filter((notification) => notification.readAt),
		[notifications],
	)
	const visibleNotifications = useMemo(() => {
		if (view === 'unread') {
			return unreadNotifications
		}

		if (view === 'read') {
			return readNotifications
		}

		return notifications
	}, [notifications, readNotifications, unreadNotifications, view])

	const errorMessage =
		error instanceof MultiNotificationsApiError && error.status === 401
			? 'Session staff absente. Reconnecte-toi puis reessaie.'
			: error instanceof Error
				? error.message
				: 'Unable to load notifications.'

	const handleMarkRead = async (notificationIds: string[]) => {
		if (notificationIds.length === 0) {
			return
		}

		await markAsRead(notificationIds)
	}

	return (
		<div className='flex-1 space-y-4 p-4 md:p-6'>
			<div className='flex flex-col gap-3 md:flex-row md:items-end md:justify-between'>
				<div className='space-y-2'>
					<p className='text-muted-foreground text-xs font-medium uppercase tracking-[0.2em]'>
						Multi user
					</p>
					<h1 className='text-3xl font-semibold tracking-tight'>Notifications</h1>
					<p className='text-muted-foreground max-w-2xl text-sm'>
						See your latest notifications and mark them as read.
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
						<RefreshCcw />
						Refresh
					</Button>
					<Button
						onClick={() => {
							void handleMarkRead(
								unreadNotifications.map((notification) => notification.id),
							)
						}}
						disabled={unreadNotifications.length === 0 || isMutating}
					>
						<CheckCheck />
						Mark all read
					</Button>
				</div>
			</div>

			<div className='grid gap-3 md:grid-cols-3'>
				<SummaryCard
					label='Total'
					value={notifications.length.toString()}
				/>
				<SummaryCard
					label='Unread'
					value={unreadNotifications.length.toString()}
					accent='warning'
				/>
				<SummaryCard
					label='Read'
					value={readNotifications.length.toString()}
					accent='success'
				/>
			</div>

			<Card className='border-border/60'>
				<CardHeader className='space-y-2 border-b pb-3'>
					<CardTitle className='flex items-center gap-2 text-lg'>
						<Bell className='size-4' />
						Notifications
					</CardTitle>
				</CardHeader>
				<CardContent className='space-y-4 pt-4'>
					<div className='flex flex-wrap gap-2'>
						{(['all', 'unread', 'read'] as const).map((nextView) => (
							<Button
								key={nextView}
								variant={view === nextView ? 'default' : 'outline'}
								size='sm'
								onClick={() => setView(nextView)}
							>
								{nextView === 'all'
									? 'All'
									: nextView === 'unread'
										? 'Unread'
										: 'Read'}
							</Button>
						))}
					</div>

					{isError ? (
						<Alert variant='destructive'>
							<AlertTitle>Failed to load notifications</AlertTitle>
							<AlertDescription>{errorMessage}</AlertDescription>
						</Alert>
					) : isLoading ? (
						<div className='space-y-3'>
							<Skeleton className='h-24 w-full rounded-xl' />
							<Skeleton className='h-24 w-full rounded-xl' />
							<Skeleton className='h-24 w-full rounded-xl' />
						</div>
					) : notifications.length === 0 ? (
						<div className='border-border/60 rounded-lg border border-dashed p-6 text-center'>
							<p className='text-base font-medium'>No notifications yet</p>
						</div>
					) : visibleNotifications.length === 0 ? (
						<div className='border-border/60 rounded-lg border border-dashed p-6 text-center'>
							<p className='text-base font-medium'>No items here</p>
						</div>
					) : (
						<ScrollArea className='h-[640px] pr-3'>
							<div className='space-y-3'>
								{visibleNotifications.map((notification, index) => (
									<div key={notification.id}>
										<NotificationRow
											notification={notification}
											onMarkRead={() => {
												void handleMarkRead([notification.id])
											}}
											isMarking={isMutating}
										/>
										{index < visibleNotifications.length - 1 ? (
											<Separator className='mt-3' />
										) : null}
									</div>
								))}
							</div>
						</ScrollArea>
					)}
				</CardContent>
			</Card>
		</div>
	)
}

type SummaryCardProps = {
	label: string
	value: string
	accent?: 'default' | 'warning' | 'success'
}

function SummaryCard({
	label,
	value,
	accent = 'default',
}: SummaryCardProps) {
	return (
		<Card
			className={cn(
				'border-border/60',
				accent === 'warning' && 'border-amber-400/25 bg-amber-500/5',
				accent === 'success' && 'border-emerald-400/25 bg-emerald-500/5',
			)}
		>
			<CardContent className='space-y-1 p-4'>
				<p className='text-muted-foreground text-xs uppercase tracking-[0.2em]'>
					{label}
				</p>
				<p className='text-2xl font-semibold tracking-tight'>{value}</p>
			</CardContent>
		</Card>
	)
}

type NotificationRowProps = {
	notification: MultiNotification
	onMarkRead: () => void
	isMarking: boolean
}

function NotificationRow({
	notification,
	onMarkRead,
	isMarking,
}: NotificationRowProps) {
	const isRead = Boolean(notification.readAt)

	return (
		<div
			className={cn(
				'rounded-lg border p-4 transition-colors',
				isRead
					? 'border-border/60 bg-background/60'
					: 'border-primary/20 bg-primary/5',
			)}
		>
			<div className='flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between'>
				<div className='min-w-0 space-y-2'>
					<div className='flex flex-wrap items-center gap-2'>
						<Badge variant={isRead ? 'secondary' : 'default'}>
							{isRead ? 'Read' : 'New'}
						</Badge>
						<Badge variant='outline' className='font-mono uppercase'>
							{notification.type}
						</Badge>
						<span className='text-muted-foreground text-xs'>
							{formatRelativeTime(notification.createdAt)}
						</span>
					</div>

					<p className='text-sm font-medium break-words'>
						{renderNotificationTitle(notification)}
					</p>
					{renderNotificationPayload(notification.payload) ? (
						<p className='text-muted-foreground text-sm break-words'>
							{renderNotificationPayload(notification.payload)}
						</p>
					) : null}
				</div>

				<div className='flex shrink-0 items-center gap-2'>
					{!isRead ? (
						<Button
							variant='outline'
							onClick={onMarkRead}
							disabled={isMarking}
						>
							<CheckCheck />
							Mark read
						</Button>
					) : null}
				</div>
			</div>
		</div>
	)
}

function renderNotificationTitle(notification: MultiNotification) {
	return (
		formatNotificationField(notification.payload.title) ??
		formatNotificationField(notification.payload.subject) ??
		formatNotificationField(notification.payload.message) ??
		notification.type
	)
}

function renderNotificationPayload(payload: Record<string, unknown>) {
	const entries = Object.entries(payload)

	if (entries.length === 0) {
		return ''
	}

	const summary = entries
		.slice(0, 2)
		.map(([key, value]) => `${key}: ${formatPayloadValue(value)}`)
		.join(' | ')

	return summary.length > 120 ? `${summary.slice(0, 120)}...` : summary
}

function formatNotificationField(value: unknown) {
	if (typeof value === 'string') {
		return value
	}

	if (typeof value === 'number' || typeof value === 'boolean') {
		return String(value)
	}

	return null
}

function formatPayloadValue(value: unknown) {
	if (value === null || value === undefined) {
		return 'null'
	}

	if (typeof value === 'string') {
		return value
	}

	if (typeof value === 'number' || typeof value === 'boolean') {
		return String(value)
	}

	try {
		return JSON.stringify(value)
	} catch {
		return '[unserializable]'
	}
}

function formatRelativeTime(value: string) {
	const date = new Date(value)

	if (Number.isNaN(date.getTime())) {
		return 'Unknown time'
	}

	const diffInSeconds = Math.round((date.getTime() - Date.now()) / 1000)
	const absSeconds = Math.abs(diffInSeconds)
	const rtf = new Intl.RelativeTimeFormat('en', { numeric: 'auto' })

	if (absSeconds < 60) {
		return rtf.format(diffInSeconds, 'second')
	}

	const diffInMinutes = Math.round(diffInSeconds / 60)
	if (Math.abs(diffInMinutes) < 60) {
		return rtf.format(diffInMinutes, 'minute')
	}

	const diffInHours = Math.round(diffInSeconds / 3600)
	if (Math.abs(diffInHours) < 24) {
		return rtf.format(diffInHours, 'hour')
	}

	const diffInDays = Math.round(diffInSeconds / 86400)
	return rtf.format(diffInDays, 'day')
}
