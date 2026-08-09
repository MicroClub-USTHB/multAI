import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card';
import {
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/shared/ui/chart';
import { Bar, BarChart, CartesianGrid, XAxis } from 'recharts';
import type { EventSummary } from '../types';

interface EventSummaryChartProps {
  data?: EventSummary;
  isLoading?: boolean;
}

const chartConfig = {
  uploaded: {
    label: 'Uploaded',
    color: '#14b8a6',
  },
  processing: {
    label: 'Processed',
    color: '#f97316',
  },
} satisfies ChartConfig;

export function EventSummaryChart({
  data,
  isLoading = false,
}: EventSummaryChartProps) {
  const displayData = data?.events;

  if (isLoading) {
    return (
      <Card className='border-sidebar-border'>
        <CardHeader>
          <CardTitle>Event Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className='flex h-48 items-center justify-center text-sm text-sidebar-foreground/60'>
            Loading...
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className='border-sidebar-border'>
      <CardHeader>
        <CardTitle>Event Summary</CardTitle>
      </CardHeader>
      <CardContent>
        <ChartContainer config={chartConfig} className='h-56 w-full'>
          <BarChart
            data={displayData}
            margin={{ top: 8, right: 12, left: 4, bottom: 0 }}
            barCategoryGap='33%'
          >
            <CartesianGrid vertical={false} strokeOpacity={0.2} />
            <XAxis
              dataKey='eventName'
              tickLine={false}
              axisLine={false}
              interval={0}
              height={44}
              tick={{
                fill: 'hsl(var(--sidebar-foreground) / 0.7)',
                fontSize: 11,
              }}
            />
            <ChartTooltip
              content={
                <ChartTooltipContent
                  formatter={(value, name) => [
                    value,
                    name === 'uploaded' ? ' Uploaded' : ' Processed',
                  ]}
                />
              }
            />
            <Bar
              dataKey='uploaded'
              fill='var(--color-uploaded)'
              radius={[4, 4, 0, 0]}
              maxBarSize={64}
            />
            <Bar
              dataKey='processing'
              fill='var(--color-processing)'
              radius={[4, 4, 0, 0]}
              maxBarSize={64}
            />
            <ChartLegend
              content={<ChartLegendContent className='justify-start pt-3' />}
            />
          </BarChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}
