import type { ReactNode } from 'react';

import { BrandLogoMark } from '@/components/BrandLogo';
import { cn } from '@/shared/utils/helpers';

interface PageHeaderProps {
  /** Small pill above the title, like "Staff dashboard" on the login screen. */
  eyebrow?: string;
  title: string;
  description?: string;
  /** Buttons shown on the right (below the text on small screens). */
  actions?: ReactNode;
  /** `lg` is the big landing headline, `md` the compact page banner. */
  size?: 'md' | 'lg';
  className?: string;
}

/**
 * Page banner shared by every dashboard page. It is the login screen's navy
 * brand side as a panel: faded logo mark, tight headline, light text.
 */
export function PageHeader({
  eyebrow,
  title,
  description,
  actions,
  size = 'md',
  className,
}: PageHeaderProps) {
  const large = size === 'lg';

  return (
    <section
      className={cn(
        'relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#00012C] via-[#070A4D] to-[#2B31A8] text-[#F9FAFF] dark:border dark:border-white/10',
        large ? 'px-8 py-12 md:px-12 md:py-16' : 'px-8 py-8 md:px-10 md:py-10',
        className,
      )}
    >
      <BrandLogoMark
        className={cn(
          'pointer-events-none absolute w-auto opacity-[0.18]',
          large
            ? '-right-16 -bottom-24 h-[420px]'
            : '-right-10 -bottom-16 h-[260px]',
        )}
      />
      <div className='relative flex flex-col gap-6 md:flex-row md:items-end md:justify-between'>
        <div className='space-y-4'>
          {eyebrow ? (
            <span className='inline-flex rounded-full border border-[#D9DDFF]/20 px-3 py-1 text-xs font-medium text-[#D9DDFF]/70'>
              {eyebrow}
            </span>
          ) : null}
          <h1
            className={cn(
              'font-semibold tracking-[-0.035em]',
              large
                ? 'text-[clamp(2.4rem,4.4vw,4rem)] leading-[1.02]'
                : 'text-[clamp(1.8rem,3vw,2.5rem)] leading-[1.05]',
            )}
          >
            {title}
          </h1>
          {description ? (
            <p className='max-w-md text-base leading-relaxed text-[#D9DDFF]/60'>
              {description}
            </p>
          ) : null}
        </div>
        {actions ? (
          <div className='flex flex-wrap gap-2'>{actions}</div>
        ) : null}
      </div>
    </section>
  );
}
