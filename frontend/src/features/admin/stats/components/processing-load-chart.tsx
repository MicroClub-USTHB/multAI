import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/shared/ui/chart'
import { Cell, Pie, PieChart } from 'recharts'
import type { ProcessingLoad } from '../types'

interface ProcessingLoadChartProps {
  data?: ProcessingLoad
  isLoading?: boolean
}

const chartConfig = {
  completed: {
    label: 'Completed',
    color: 'hsl(120, 70%, 50%)',
  },
  processing: {
    label: 'Processing',
    color: 'hsl(var(--chart-2))',
  },
  queued: {
    label: 'Queued',
    color: 'hsl(var(--chart-3))',
  },
} satisfies ChartConfig

export function ProcessingLoadChart({ data, isLoading = false }: ProcessingLoadChartProps) {
  const displayData = data ?? {
    completed: 65.4,
    processing: 15.8,
    queued: 18.8,
  }

  if (isLoading) {
    return (
      <Card className="border-sidebar-border">
        <CardHeader>
          <CardTitle>Queue & AI Processing Load</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex h-48 items-center justify-center text-sm text-sidebar-foreground/60">
            Loading...
          </div>
        </CardContent>
      </Card>
    )
  }

  const chartData = [
    { name: 'completed', value: displayData.completed, fill: '#3b82f6' },
    { name: 'processing', value: displayData.processing, fill: '#f59e0b' },
    { name: 'queued', value: displayData.queued, fill: '#ef4444' },
  ]

  return (
    <Card className="border-sidebar-border">
      <CardHeader>
        <CardTitle>Queue & AI Processing Load</CardTitle>
      </CardHeader>
      <CardContent>
        <ChartContainer config={chartConfig} className="mx-auto h-48 w-full max-w-[240px]">
          <PieChart>
            <ChartTooltip content={<ChartTooltipContent hideLabel />} />
            <Pie
              data={chartData}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              innerRadius={45}
              outerRadius={75}
              strokeWidth={4}
              isAnimationActive={false}
            >
              {chartData.map((entry) => (
                <Cell key={entry.name} fill={entry.fill} />
              ))}
            </Pie>
          </PieChart>
        </ChartContainer>

        <div className="mt-6 space-y-2">
          <div className="flex items-center space-x-2">
            <div className="h-3 w-3 rounded-full" style={{ backgroundColor: '#3b82f6' }} />
            <span className="text-sm text-sidebar-foreground/70">
              Completed ({displayData.completed})
            </span>
          </div>

          <div className="flex items-center space-x-2">
            <div className="h-3 w-3 rounded-full" style={{ backgroundColor: '#f59e0b' }} />
            <span className="text-sm text-sidebar-foreground/70">
              Processing ({displayData.processing})
            </span>
          </div>

          <div className="flex items-center space-x-2">
            <div className="h-3 w-3 rounded-full" style={{ backgroundColor: '#ef4444' }} />
            <span className="text-sm text-sidebar-foreground/70">
              Queued ({displayData.queued})
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}