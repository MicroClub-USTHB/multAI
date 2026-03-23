import { Badge } from '@/shared/ui/badge';
import { Card, CardHeader, CardContent, CardTitle } from '@/shared/ui/card';
import { Progress } from '@/shared/ui/progress';

import type { DriveUsage } from '../types';

import {
  calculateStorageMetrics,
  formatStorageSize,
  mockDriveUsage,
} from '../types';

interface DriveStorageStatusProps {
  data?: DriveUsage;
  isLoading?: boolean;
  className?: string;
}

export function DriveStorageStatus({
  data,
  isLoading = false,
  className = '',
}: DriveStorageStatusProps) {
  // Loading state
  if (isLoading) {
    return (
      <Card className={`border-sidebar-border ${className}`}>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="bg-sidebar-accent h-6 w-48 animate-pulse rounded"></div>
            <div className="bg-sidebar-accent h-5 w-12 animate-pulse rounded"></div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="bg-sidebar-accent h-3 w-full animate-pulse rounded-full"></div>
            <div className="flex justify-between">
              <div className="bg-sidebar-accent h-4 w-20 animate-pulse rounded"></div>
              <div className="bg-sidebar-accent h-4 w-20 animate-pulse rounded"></div>
            </div>
            <div className="bg-sidebar-accent mx-auto h-3 w-16 animate-pulse rounded"></div>
          </div>
        </CardContent>
      </Card>
    );
  }

  const storageData = data || mockDriveUsage;

  const metrics = calculateStorageMetrics(storageData);

  return (
    <Card className={`border-sidebar-border ${className}`}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Drive Storage Status</CardTitle>
          <Badge variant="secondary">
            {formatStorageSize(metrics.totalGB)}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Progress bar*/}
          <Progress value={metrics.percentageUsed} className="h-3" />

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
          <div className="text-sidebar-foreground/60 text-center text-xs">
            {metrics.percentageUsed.toFixed(1)}% used
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
