import { Card, CardContent } from '@/shared/ui/card'
import type { LucideIcon } from 'lucide-react'

interface StatsCardProps {
  title: string
  value: string
  icon: LucideIcon
  className?: string
}

export function StatsCard({ title, value, icon: Icon, className = "" }: StatsCardProps) {
  return (
    <Card className={`border-sidebar-border ${className}`}>
      <CardContent className="p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <Icon className="h-6 w-6 text-sidebar-foreground/60" />
            <div className="text-3xl font-bold text-sidebar-foreground">{value}</div>
          </div>
        </div>
        <div className="mt-2 text-sm text-sidebar-foreground/60">{title}</div>
      </CardContent>
    </Card>
  )
}