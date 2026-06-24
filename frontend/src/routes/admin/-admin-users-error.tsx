import { useRouter } from '@tanstack/react-router'
import { AlertTriangle } from 'lucide-react'

import { Button } from '@/shared/ui'

interface AdminUsersErrorProps {
  error: unknown
}

export function AdminUsersError({ error }: AdminUsersErrorProps) {
  const router = useRouter()

  return (
    <div className="flex-1 p-4 md:p-6">
      <div className="rounded-lg border border-destructive/40 bg-destructive/10 p-4 text-sm text-destructive">
        <div className="mb-2 flex items-center gap-2 font-medium">
          <AlertTriangle className="h-4 w-4" />
          Failed to load users
        </div>
        <p>{error instanceof Error ? error.message : 'Unknown error.'}</p>
        <Button className="mt-4" variant="outline" onClick={() => router.invalidate()}>
          Retry
        </Button>
      </div>
    </div>
  )
}
