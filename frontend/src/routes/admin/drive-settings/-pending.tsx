export default function DriveSettingsPending() {
  return (
    <div className="bg-sidebar text-sidebar-foreground">
      <div className="space-y-6 p-6">
        <div>
          <div className="bg-sidebar-accent/40 h-10 w-56 animate-pulse rounded-md" />
          <div className="bg-sidebar-accent/30 mt-2 h-5 w-96 animate-pulse rounded-md" />
        </div>

        <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <div
              key={index}
              className="border-border/40 bg-card/40 h-[320px] animate-pulse rounded-lg border"
            />
          ))}
        </div>
      </div>
    </div>
  );
}
