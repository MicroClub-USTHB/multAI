export function AdminIndexPending() {
  return Array.from({ length: 4 }).map((_, index) => (
    <div
      key={index}
      className="border-sidebar-border animate-pulse rounded-lg border p-6"
    >
      <div className="flex items-center space-x-3">
        <div className="bg-sidebar-accent h-6 w-6 rounded" />
        <div className="bg-sidebar-accent h-8 w-16 rounded" />
      </div>
      <div className="bg-sidebar-accent mt-2 h-4 w-20 rounded" />
    </div>
  ));
}
