import type { LucideIcon } from 'lucide-react';

import { Card, CardContent } from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

interface StatsCardProps {
  title: string;
  value: string;
  icon: LucideIcon;
  className?: string;
  /** Icon tile colour, all taken from the login palette. */
  tone?: 'navy' | 'periwinkle' | 'lavender' | 'indigo';
}

const TONES = {
  navy: 'bg-[#00012C] text-[#D9DDFF] dark:bg-[#D9DDFF] dark:text-[#00012C]',
  periwinkle: 'bg-gradient-to-br from-[#8E94E8] to-[#5B63E8] text-white',
  lavender: 'bg-[#D9DDFF] text-[#00012C]',
  indigo: 'bg-gradient-to-br from-[#3A40B8] to-[#00012C] text-[#D9DDFF]',
} as const;

export function StatsCard({
  title,
  value,
  icon: Icon,
  className = '',
  tone = 'navy',
}: StatsCardProps) {
  return (
    <Card
      className={cn(
        'border-border rounded-2xl border bg-card shadow-[0_1px_0_rgba(0,1,44,0.04),0_24px_48px_-28px_rgba(0,1,44,0.28)]',
        className,
      )}
    >
      <CardContent className='p-6'>
        <div className={cn('grid size-10 place-items-center rounded-xl', TONES[tone])}>
          <Icon className='size-5' />
        </div>
        <div className='mt-6 text-4xl font-semibold tracking-[-0.035em]'>
          {value}
        </div>
        <div className='text-muted-foreground mt-1 text-sm'>{title}</div>
      </CardContent>
    </Card>
  );
}
