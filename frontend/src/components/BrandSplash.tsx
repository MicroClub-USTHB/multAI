import { useId } from 'react';

import { BLOB, WORDMARK } from '@/components/BrandLogo';
import { cn } from '@/shared/utils/helpers';

interface BrandSplashProps {
  /** Spoken to screen readers only; the screen shows the animation, not text. */
  label?: string;
  className?: string;
}

/**
 * Full-screen splash: the MultiAI face hops like a ball, squashing and
 * stretching over a flat shadow, while its eyes look around and blink.
 * Pure CSS animation (see styles.css); it stands still when the visitor asks
 * for reduced motion.
 */
export function BrandSplash({
  label = 'Loading',
  className,
}: BrandSplashProps) {
  const uid = useId().replace(/:/g, '');
  const mask = `sm${uid}`;
  const blur = `sf${uid}`;

  return (
    <div
      role='status'
      aria-live='polite'
      className={cn(
        'flex min-h-screen flex-col items-center justify-center gap-8 bg-[#00012C] text-[#F9FAFF]',
        className,
      )}
    >
      <span className='sr-only'>{label}</span>

      <div aria-hidden className='flex flex-col items-center'>
        <div className='splash-hop'>
          <svg viewBox='62 47 140 143' fill='none' className='h-36 w-auto overflow-visible'>
            <path d={BLOB} fillRule='evenodd' clipRule='evenodd' fill='#D9DDFF' />
            <mask
              id={mask}
              style={{ maskType: 'alpha' }}
              maskUnits='userSpaceOnUse'
              x='62'
              y='47'
              width='140'
              height='143'
            >
              <path d={BLOB} fillRule='evenodd' clipRule='evenodd' fill='#D9DDFF' />
            </mask>
            <g mask={`url(#${mask})`}>
              <g filter={`url(#${blur})`}>
                <circle cx='131.939' cy='117.898' r='87.9648' fill='#00012C' />
              </g>
            </g>
            <g className='splash-look'>
              <g className='splash-blink'>
                <ellipse cx='142.02' cy='117.838' rx='14.3936' ry='20.2944' transform='rotate(-11.2564 142.02 117.838)' fill='#F9FAFF' />
                <ellipse cx='166.306' cy='118.584' rx='9.56591' ry='18.7516' transform='rotate(3.31606 166.306 118.584)' fill='#F9FAFF' />
                <path d='M149.098 130.526C151.323 130.526 153.128 127.902 153.128 124.665C153.128 123.898 153.026 123.165 152.842 122.493C152.194 122.938 151.409 123.199 150.563 123.199C148.635 123.199 147.022 121.844 146.626 120.035C145.678 121.107 145.068 122.782 145.068 124.665C145.068 127.902 146.872 130.526 149.098 130.526Z' fill='black' />
                <path d='M163.752 130.76C165.977 130.76 167.782 128.135 167.782 124.898C167.782 124.131 167.68 123.398 167.496 122.727C166.848 123.172 166.063 123.433 165.217 123.433C163.289 123.433 161.676 122.078 161.28 120.268C160.332 121.341 159.722 123.016 159.722 124.898C159.722 128.135 161.526 130.76 163.752 130.76Z' fill='black' />
              </g>
            </g>
            <defs>
              <filter id={blur} x='-26' y='-40' width='316' height='316' filterUnits='userSpaceOnUse' colorInterpolationFilters='sRGB'>
                <feGaussianBlur stdDeviation='35' />
              </filter>
            </defs>
          </svg>
        </div>
        <div className='splash-shadow' />
      </div>

      <svg
        aria-hidden
        viewBox='216 68 486 104'
        fill='none'
        className='splash-word h-7 w-auto overflow-visible'
      >
        <path d={WORDMARK} fill='#F9FAFF' />
      </svg>
    </div>
  );
}
