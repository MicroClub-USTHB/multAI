export function AdminIndexPending() {
  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div className="bg-sidebar-accent/40 h-10 w-80 animate-pulse rounded-md" />

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, index) => (
            <div
              key={index}
              className="border-sidebar-border animate-pulse rounded-lg border p-6 py-12"
            >
              <div className="flex items-center space-x-3">
                <div className="bg-sidebar-accent h-6 w-6 rounded" />
                <div className="bg-sidebar-accent h-8 w-16 rounded" />
              </div>
              <div className="bg-sidebar-accent mt-2 h-4 w-20 rounded" />
            </div>
          ))}
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <div className="border-sidebar-border bg-card/40 h-72 animate-pulse rounded-lg border" />
            <div className="border-sidebar-border bg-card/40 h-72 animate-pulse rounded-lg border" />
          </div>
          <div className="border-sidebar-border bg-card/40 h-[600px] animate-pulse rounded-lg border" />
        </div>
      </div>
    </div>
  );
}
