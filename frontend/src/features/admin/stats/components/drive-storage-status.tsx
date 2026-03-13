import { Card, CardHeader, CardContent, CardTitle } from '@/shared/ui/card'
import { Badge } from '@/shared/ui/badge'
import { Progress } from '@/shared/ui/progress'
import type { DriveUsage } from '../types'
import { calculateStorageMetrics, formatStorageSize, mockDriveUsage } from '../types'

interface DriveStorageStatusProps {
  data?: DriveUsage
  isLoading?: boolean
  className?: string
}

export function DriveStorageStatus({ 
  data, 
  isLoading = false,
  className = "" 
}: DriveStorageStatusProps) {
  // Loading state
  if (isLoading) {
    return (
      <Card className={`border-sidebar-border ${className}`}>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="h-6 w-48 bg-sidebar-accent rounded animate-pulse"></div>
            <div className="h-5 w-12 bg-sidebar-accent rounded animate-pulse"></div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="w-full bg-sidebar-accent rounded-full h-3 animate-pulse"></div>
            <div className="flex justify-between">
              <div className="h-4 w-20 bg-sidebar-accent rounded animate-pulse"></div>
              <div className="h-4 w-20 bg-sidebar-accent rounded animate-pulse"></div>
            </div>
            <div className="h-3 w-16 bg-sidebar-accent rounded animate-pulse mx-auto"></div>
          </div>
        </CardContent>
      </Card>
    )
  }

  const storageData = data || mockDriveUsage
  
  const metrics = calculateStorageMetrics(storageData)

  return (
    <Card className={`border-sidebar-border ${className}`}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Drive Storage Status</CardTitle>
          <Badge variant="secondary">{formatStorageSize(metrics.totalGB)}</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Progress bar*/}
          <Progress 
            value={metrics.percentageUsed} 
            className="h-3"
          />
          
          {/* Info */}
          <div className="flex justify-between text-sm">
            <span className="text-sidebar-foreground/80">
              {formatStorageSize(metrics.usedGB)} used
            </span>
            <span className="text-sidebar-foreground/80">
              {formatStorageSize(metrics.freeGB)} Free
            </span>
          </div>

          {/* % used */}
          <div className="text-center text-xs text-sidebar-foreground/60">
            {metrics.percentageUsed.toFixed(1)}% used
          </div>

        </div>
      </CardContent>
    </Card>
  )
}