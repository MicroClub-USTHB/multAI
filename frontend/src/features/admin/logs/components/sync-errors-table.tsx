import type { ColumnDef } from '@tanstack/react-table';

import {
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table';
import { Clock3 } from 'lucide-react';

import { Badge } from '@/shared/ui';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

import { syncErrorsMock, type SyncError } from '../types';
import { splitTimestamp } from '../utils';

type SyncErrorsTableProps = {
  onRowClick?: (log: SyncError) => void;
};

const sourceVariants = {
  Drive: 'border-blue-500/80 text-blue-400',
  Storage: 'border-violet-500/80 text-violet-400',
  Worker: 'border-amber-500/80 text-amber-400',
};

const statusVariants = {
  Resolved: 'border-emerald-500/90 text-emerald-400',
  Investigating: 'border-yellow-500/90 text-yellow-300',
  Unresolved: 'border-red-500/90 text-red-400',
};

const columns: ColumnDef<SyncError>[] = [
  {
    id: 'icon',
    header: () => <span className="sr-only">Row marker</span>,
    cell: () => (
      <div className="flex items-center">
        <Clock3
          aria-hidden="true"
          className="text-muted-foreground/80 h-3.5 w-3.5"
        />
      </div>
    ),
    size: 28,
  },
  {
    accessorKey: 'timestamp',
    header: 'Timestamp',
    cell: ({ row }) => {
      const raw = row.getValue('timestamp') as string;
      const [date, time] = splitTimestamp(raw);

      return (
        <div className="text-foreground/90 font-mono text-sm leading-tight whitespace-nowrap">
          <div>{date}</div>
          <div>{time}</div>
        </div>
      );
    },
  },
  {
    accessorKey: 'errorMessage',
    header: 'Error Message',
    cell: ({ row }) => (
      <div className="text-foreground/90 text-sm whitespace-normal">
        {row.getValue('errorMessage')}
      </div>
    ),
  },
  {
    accessorKey: 'source',
    header: 'Source',
    cell: ({ row }) => {
      const value = row.getValue('source') as keyof typeof sourceVariants;

      return (
        <Badge
          variant="outline"
          className={cn(
            'h-6 rounded-sm bg-transparent px-3 text-xs',
            sourceVariants[value],
          )}
        >
          {value}
        </Badge>
      );
    },
  },
  {
    accessorKey: 'status',
    header: 'Status',
    cell: ({ row }) => {
      const value = row.getValue('status') as keyof typeof statusVariants;

      return (
        <Badge
          variant="outline"
          className={cn(
            'h-6 rounded-sm bg-transparent px-3 text-xs',
            statusVariants[value],
          )}
        >
          {value}
        </Badge>
      );
    },
  },
];

export function SyncErrorsTable({ onRowClick }: SyncErrorsTableProps) {
  const table = useReactTable({
    data: syncErrorsMock,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="border-border/40 rounded-md border">
      <Table>
        <TableHeader className="bg-transparent">
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead
                  key={header.id}
                  className="text-muted-foreground h-9 px-2 text-xs font-medium"
                >
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext(),
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
                  onRowClick &&
                    'focus-visible:ring-ring/60 cursor-pointer focus-visible:ring-2 focus-visible:outline-none',
                )}
                tabIndex={onRowClick ? 0 : undefined}
                role={onRowClick ? 'button' : undefined}
                onClick={
                  onRowClick ? () => onRowClick(row.original) : undefined
                }
                onKeyDown={
                  onRowClick
                    ? (event) => {
                        if (event.key === 'Enter' || event.key === ' ') {
                          event.preventDefault();
                          onRowClick(row.original);
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
              <TableCell colSpan={columns.length} className="h-24 text-center">
                No results.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
}
