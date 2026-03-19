import {
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table'
import type { ColumnDef } from '@tanstack/react-table'
import { Badge } from '@/shared/ui/badge'
import { Clock3 } from 'lucide-react'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui/table'
import { faceLogsMock, type FaceMatchingLog } from '../types'
import { splitTimestamp } from '../utils'
import { cn } from '@/lib/utils'

type FaceMatchingLogsTableProps = {
  onRowClick?: (log: FaceMatchingLog) => void
}

const resultVariants = {
  Success: 'border-emerald-500/90 text-emerald-400',
  Partial: 'border-yellow-500/90 text-yellow-300',
  Failed: 'border-red-500/90 text-red-400',
}

const columns: ColumnDef<FaceMatchingLog>[] = [
  {
    id: 'icon',
    header: () => <span className="sr-only">Row marker</span>,
    cell: () => (
      <div className="flex items-center">
        <Clock3 aria-hidden="true" className="h-3.5 w-3.5 text-muted-foreground/80" />
      </div>
    ),
    size: 28,
  },
  {
    accessorKey: 'timestamp',
    header: 'Timestamp',
    cell: ({ row }) => {
      const raw = row.getValue('timestamp') as string
      const [date, time] = splitTimestamp(raw)

      return (
        <div className="font-mono text-sm text-foreground/90 whitespace-nowrap leading-tight">
          <div>{date}</div>
          <div>{time}</div>
        </div>
      )
    },
  },
  {
    accessorKey: 'photoId',
    header: 'Photo ID',
    cell: ({ row }) => (
      <div className="text-sm text-muted-foreground">{row.getValue('photoId')}</div>
    ),
  },
  {
    accessorKey: 'facesDetected',
    header: 'Faces Detected',
    cell: ({ row }) => (
      <div className="text-sm text-foreground/90">{String(row.getValue('facesDetected'))}</div>
    ),
  },
  {
    accessorKey: 'matchedUsers',
    header: 'Matched Users',
    cell: ({ row }) => {
      const users = row.getValue('matchedUsers') as string[]

      if (!users.length) {
        return <span className="text-sm text-muted-foreground">No matches</span>
      }

      return (
        <div className="flex flex-wrap gap-1">
          {users.map((user) => (
            <Badge
              key={user}
              variant="outline"
              className="h-6 rounded-sm border-border/70 bg-transparent px-2.5 text-xs text-muted-foreground"
            >
              {user}
            </Badge>
          ))}
        </div>
      )
    },
  },
  {
    accessorKey: 'result',
    header: 'Result',
    cell: ({ row }) => {
      const value = row.getValue('result') as keyof typeof resultVariants

      return (
        <Badge
          variant="outline"
          className={cn('h-6 rounded-sm bg-transparent px-3 text-xs', resultVariants[value])}
        >
          {value}
        </Badge>
      )
    },
  },
]

export function FaceMatchingLogsTable({ onRowClick }: FaceMatchingLogsTableProps) {
  const table = useReactTable({
    data: faceLogsMock,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <div className="rounded-md border border-border/40">
      <Table>
        <TableHeader className="bg-transparent">
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id} className="h-9 px-2 text-xs font-medium text-muted-foreground">
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>

        <TableBody>
          {table.getRowModel().rows.length ? (
            table.getRowModel().rows.map((row) => (
              <TableRow
                key={row.id}
                className={cn(
                  'border-border/40 hover:bg-muted/10',
                  onRowClick && 'cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/60'
                )}
                tabIndex={onRowClick ? 0 : undefined}
                role={onRowClick ? 'button' : undefined}
                onClick={onRowClick ? () => onRowClick(row.original) : undefined}
                onKeyDown={
                  onRowClick
                    ? (event) => {
                        if (event.key === 'Enter' || event.key === ' ') {
                          event.preventDefault()
                          onRowClick(row.original)
                        }
                      }
                    : undefined
                }
              >
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id} className="px-2 py-2.5 align-top">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={columns.length} className="h-24 text-center text-sm text-muted-foreground">
                No results.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  )
}
