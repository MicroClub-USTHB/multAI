import type { LucideIcon } from 'lucide-react';

import { Card, CardContent } from '@/shared/ui/card';

interface StatsCardProps {
  title: string;
  value: string;
  icon: LucideIcon;
  className?: string;
}

export function StatsCard({
  title,
  value,
  icon: Icon,
  className = '',
}: StatsCardProps) {
  return (
    <Card className={`border-sidebar-border ${className}`}>
      <CardContent className="p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <Icon className="text-sidebar-foreground/60 h-6 w-6" />
            <div className="text-sidebar-foreground text-3xl font-bold">
              {value}
            </div>
          </div>
        </div>
        <div className="text-sidebar-foreground/60 mt-2 text-sm">{title}</div>
      </CardContent>
    </Card>
  );
}
