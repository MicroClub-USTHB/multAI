import { env } from '@/env';
import { cn } from '@/shared/utils/helpers';

function McidMark({ className }: { className?: string }) {
  const stroke = {
    strokeWidth: 12,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
  };
  return (
    <svg viewBox='0 0 120 120' fill='none' aria-hidden className={className}>
      <g transform='translate(12 12) scale(0.8)'>
        <path d='M 38 100 A 22 22 0 0 1 16 78 V 60 A 44 44 0 0 1 104 60 V 78 A 22 22 0 0 1 82 100' stroke='#fafafa' {...stroke} />
        <path d='M 38 82 V 60 A 22 22 0 0 1 60 38 A 22 22 0 0 1 82 60 V 82' stroke='#d9ddff' {...stroke} />
        <path d='M 60 56 V 100' stroke='#fafafa' {...stroke} />
      </g>
    </svg>
  );
}

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const apiBase = (env.VITE_API_BASE_URL || '/api').replace(/\/+$/, '');
  const mcdiLoginUrl = `${apiBase}/admin/auth/mcdi/login`;

  return (
    <div className={cn('flex flex-col', className)} {...props}>
      <h2 className='text-[2rem] font-semibold leading-tight tracking-[-0.03em]'>
        Sign in
      </h2>
      <p className='mt-2 text-[15px] leading-relaxed text-[#00012C]/60'>
        Use your MicroClub Digital Identity to continue.
      </p>

      <a
        href={mcdiLoginUrl}
        className='group mt-8 flex h-12 items-center justify-between rounded-xl bg-[#00012C] px-5 text-[15px] font-semibold text-[#F9FAFF] shadow-[0_8px_20px_-8px_rgba(0,1,44,0.6)] transition-all hover:bg-[#12136b] active:scale-[0.99] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#4f46e5]'
      >
        <span className='flex items-center gap-3'>
          Continue with MCDI
        </span>
        <span className='flex h-8 w-8 items-center justify-center rounded-lg bg-[#0a0a0a] ring-1 ring-[#D9DDFF]/25 transition-transform duration-200 group-hover:scale-105'>
          <McidMark className='h-8 w-8' />
        </span>
      </a>

      <div className='my-7 h-px bg-[#00012C]/10' />

      <dl className='space-y-3 text-sm'>
        <div className='flex justify-between gap-4'>
          <dt className='text-[#00012C]/50'>Access</dt>
          <dd className='font-medium'>Admin, Multi, Team lead</dd>
        </div>
        <div className='flex justify-between gap-4'>
          <dt className='text-[#00012C]/50'>You'll be sent to</dt>
          <dd className='font-medium'>MCDI, then back here</dd>
        </div>
      </dl>
    </div>
  );
}
