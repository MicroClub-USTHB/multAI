import { Mascot } from '@/components/Mascot';
import { cn } from '@/shared/utils/helpers';

interface EmptyStateProps {
  title: string;
  description?: string;
  className?: string;
}

/**
 * Empty-state illustration: the mascot with two photo prints behind it,
 * drawn in the login palette (navy, lavender, periwinkle).
 */
export function EmptyState({ title, description, className }: EmptyStateProps) {
  return (
    <div
      className={cn('flex flex-col items-center px-4 py-10 text-center', className)}
    >
      <div aria-hidden className='relative h-44 w-64'>
        <svg viewBox='0 0 256 176' fill='none' className='absolute inset-0 h-full w-full'>
          <defs>
            <linearGradient id='empty-sky' x1='0' y1='0' x2='1' y2='1'>
              <stop offset='0' stopColor='#F4F5FF' />
              <stop offset='1' stopColor='#B7BCFF' />
            </linearGradient>
          </defs>
          <g transform='rotate(-9 78 72)'>
            <rect x='30' y='22' width='96' height='80' rx='12' fill='var(--card)' stroke='var(--border)' strokeWidth='1.5' />
            <rect x='38' y='30' width='80' height='56' rx='7' fill='url(#empty-sky)' />
            <path d='M38 78 L66 52 L84 68 L98 56 L118 76 V86 H38 Z' fill='#5B63E8' fillOpacity='0.85' />
            <circle cx='98' cy='44' r='6' fill='#F9FAFF' />
          </g>
          <g transform='rotate(8 182 78)'>
            <rect x='134' y='26' width='96' height='80' rx='12' fill='var(--card)' stroke='var(--border)' strokeWidth='1.5' />
            <rect x='142' y='34' width='80' height='56' rx='7' fill='#00012C' />
            <path d='M142 82 L168 58 L186 72 L200 62 L222 80 V90 H142 Z' fill='#8E94E8' fillOpacity='0.8' />
            <circle cx='204' cy='48' r='6' fill='#D9DDFF' />
          </g>
          <ellipse cx='128' cy='168' rx='46' ry='6' fill='#00012C' fillOpacity='0.10' />
        </svg>
        <Mascot className='absolute bottom-3 left-1/2 h-24 w-auto -translate-x-1/2 drop-shadow-[0_6px_10px_rgba(0,1,44,0.18)]' />
      </div>
      <p className='mt-2 text-lg font-semibold tracking-[-0.02em]'>{title}</p>
      {description ? (
        <p className='text-muted-foreground mt-1 max-w-sm text-sm'>{description}</p>
      ) : null}
    </div>
  );
}
