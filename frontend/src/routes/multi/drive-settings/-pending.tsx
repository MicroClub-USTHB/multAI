export default function DriveSettingsPending() {
  return (
    <div>
      <div className="space-y-6 p-4 md:p-6">
        <div>
          <div className="bg-muted h-10 w-56 animate-pulse rounded-md" />
          <div className="bg-muted mt-2 h-5 w-96 animate-pulse rounded-md" />
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
