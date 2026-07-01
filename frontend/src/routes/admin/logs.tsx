import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { useEffect, useMemo, useState } from 'react'
import { z } from 'zod'

import { AuditsTable } from '@/features/admin/logs/components/audits-table';
import { AUDIT_EVENT_TYPES, useAdminAudits } from '@/features/admin/logs/hooks'
import {
  Alert,
  AlertDescription,
  AlertTitle,
  Button,
  Card,
  CardContent,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui'

const AUDIT_EVENT_TYPE_FILTERS = ['all', ...AUDIT_EVENT_TYPES] as const

const logsSearchSchema = z.object({
  eventType: z.enum(AUDIT_EVENT_TYPE_FILTERS).catch('all'),
  userId: z.string().catch(''),
  from: z.string().catch(''),
  to: z.string().catch(''),
  limit: z.coerce.number().int().min(1).max(200).catch(50),
  offset: z.coerce.number().int().min(0).catch(0),
})

export const Route = createFileRoute('/admin/logs')({
  component: LogsView,
  validateSearch: logsSearchSchema,
});

const toLocalDatetimeValue = (value: string) => {
  if (!value) {
    return ''
  }

  const date = new Date(value)

  if (Number.isNaN(date.getTime())) {
    return ''
  }

  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000)
  return local.toISOString().slice(0, 16)
}

const toIsoFromLocalDatetimeValue = (value: string) => {
  if (!value) {
    return ''
  }

  const date = new Date(value)

  if (Number.isNaN(date.getTime())) {
    return ''
  }

  return date.toISOString()
}

function LogsView() {
  const navigate = useNavigate()
  const search = Route.useSearch()

  const [eventTypeFilter, setEventTypeFilter] = useState(search.eventType)
  const [userIdFilter, setUserIdFilter] = useState(search.userId)
  const [fromFilter, setFromFilter] = useState(toLocalDatetimeValue(search.from))
  const [toFilter, setToFilter] = useState(toLocalDatetimeValue(search.to))
  const [limitFilter, setLimitFilter] = useState(String(search.limit))
  const [offsetFilter, setOffsetFilter] = useState(String(search.offset))

  useEffect(() => {
    setEventTypeFilter(search.eventType)
    setUserIdFilter(search.userId)
    setFromFilter(toLocalDatetimeValue(search.from))
    setToFilter(toLocalDatetimeValue(search.to))
    setLimitFilter(String(search.limit))
    setOffsetFilter(String(search.offset))
  }, [search])

  const auditParams = useMemo(
    () => ({
      eventType: eventTypeFilter === 'all' ? null : eventTypeFilter,
      userId: userIdFilter.trim() || null,
      from: fromFilter ? toIsoFromLocalDatetimeValue(fromFilter) : null,
      to: toFilter ? toIsoFromLocalDatetimeValue(toFilter) : null,
      limit: Number(limitFilter) || 50,
      offset: Number(offsetFilter) || 0,
    }),
    [eventTypeFilter, fromFilter, limitFilter, offsetFilter, toFilter, userIdFilter],
  )

  const { audits, isLoading, isError, error, refetch } = useAdminAudits(auditParams)

  const auditsCountLabel =
    auditParams.eventType || auditParams.userId || auditParams.from || auditParams.to
      ? 'Filtered audits'
      : 'All audits'

  const applyFilters = () => {
    navigate({
      to: '/admin/logs',
      search: {
        eventType: eventTypeFilter,
        userId: userIdFilter.trim(),
        from: fromFilter ? toIsoFromLocalDatetimeValue(fromFilter) : '',
        to: toFilter ? toIsoFromLocalDatetimeValue(toFilter) : '',
        limit: Number(limitFilter) || 50,
        offset: Number(offsetFilter) || 0,
      },
      replace: true,
    })
  }

  const resetFilters = () => {
    setEventTypeFilter('all')
    setUserIdFilter('')
    setFromFilter('')
    setToFilter('')
    setLimitFilter('50')
    setOffsetFilter('0')

    navigate({
      to: '/admin/logs',
      search: {
        eventType: 'all',
        userId: '',
        from: '',
        to: '',
        limit: 50,
        offset: 0,
      },
      replace: true,
    })
  }

  return (
    <>
      <div className="flex-1 space-y-6 p-4 md:p-6">
        <div className="space-y-4">
          <h1 className="text-4xl font-bold tracking-tight">Logs</h1>
          <div className="bg-border/50 h-px w-full" />
        </div>

        <div className="w-full space-y-3">
          {/* Sync Errors and Face Matching Logs are currently disabled until the backend endpoints are linked. */}

          <p className="text-muted-foreground text-sm">
            System audit trail from /admin/audits
          </p>

          <Card className="border-border/60">
            <CardContent className="space-y-4 p-4">
              <div className="grid grid-cols-1 gap-3 lg:grid-cols-2 xl:grid-cols-3">
                <div className="space-y-2">
                  <label className="text-sm font-medium">Event type</label>
                  <Select
                    value={eventTypeFilter}
                    onValueChange={(value) => setEventTypeFilter(value as typeof eventTypeFilter)}
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue placeholder="All event types" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All event types</SelectItem>
                      {AUDIT_EVENT_TYPES.map((eventType) => (
                        <SelectItem key={eventType} value={eventType}>
                          {eventType}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="audit-user-id">
                    User ID
                  </label>
                  <Input
                    id="audit-user-id"
                    value={userIdFilter}
                    onChange={(event) => setUserIdFilter(event.target.value)}
                    placeholder="3fa85f64-5717-4562-b3fc-2c963f66afa6"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="audit-limit">
                    Limit
                  </label>
                  <Input
                    id="audit-limit"
                    type="number"
                    min={1}
                    max={200}
                    value={limitFilter}
                    onChange={(event) => setLimitFilter(event.target.value)}
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="audit-from">
                    From
                  </label>
                  <Input
                    id="audit-from"
                    type="datetime-local"
                    value={fromFilter}
                    onChange={(event) => setFromFilter(event.target.value)}
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="audit-to">
                    To
                  </label>
                  <Input
                    id="audit-to"
                    type="datetime-local"
                    value={toFilter}
                    onChange={(event) => setToFilter(event.target.value)}
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="audit-offset">
                    Offset
                  </label>
                  <Input
                    id="audit-offset"
                    type="number"
                    min={0}
                    value={offsetFilter}
                    onChange={(event) => setOffsetFilter(event.target.value)}
                  />
                </div>
              </div>

              <div className="flex flex-wrap gap-2">
                <Button onClick={applyFilters}>Apply filters</Button>
                <Button variant="outline" onClick={resetFilters}>
                  Reset
                </Button>
                <Button variant="ghost" onClick={() => void refetch()} disabled={isLoading}>
                  Refresh
                </Button>
              </div>

              <div className="text-muted-foreground flex flex-wrap items-center justify-between gap-2 text-sm">
                <p>
                  Showing {audits.length} {auditsCountLabel.toLowerCase()}
                </p>
                <p className="text-xs uppercase tracking-[0.2em]">
                  Cookie auth: access_token
                </p>
              </div>

              {isError ? (
                <Alert variant="destructive">
                  <AlertTitle>Failed to load audits</AlertTitle>
                  <AlertDescription>
                    {error instanceof Error ? error.message : 'Unable to load audits.'}
                  </AlertDescription>
                </Alert>
              ) : isLoading ? (
                <div className="text-muted-foreground text-sm">Loading...</div>
              ) : (
                <AuditsTable audits={audits} />
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </>
  );
}
