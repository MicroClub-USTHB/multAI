export function AdminUsersPending() {
  return (
    <div className="flex-1 space-y-6 p-4 md:p-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div className="space-y-2">
          <div className="h-10 w-44 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-80 animate-pulse rounded-md bg-muted" />
        </div>
        <div className="h-10 w-32 animate-pulse rounded-md bg-muted" />
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <div key={index} className="rounded-lg border p-4">
            <div className="h-3 w-20 animate-pulse rounded bg-muted" />
            <div className="mt-3 h-7 w-16 animate-pulse rounded bg-muted" />
          </div>
        ))}
      </div>

      <div className="rounded-lg border p-4">
        <div className="mb-4 grid grid-cols-1 gap-3 lg:grid-cols-[1fr_220px]">
          <div className="h-10 animate-pulse rounded-md bg-muted" />
          <div className="h-10 animate-pulse rounded-md bg-muted" />
        </div>
        <div className="space-y-2">
          <div className="h-10 animate-pulse rounded-md bg-muted" />
          <div className="h-10 animate-pulse rounded-md bg-muted" />
          <div className="h-10 animate-pulse rounded-md bg-muted" />
        </div>
      </div>
    </div>
  )
}
