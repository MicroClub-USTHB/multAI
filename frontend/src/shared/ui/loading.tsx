import { Loader2 } from 'lucide-react';

import { BrandSplash } from '@/components/BrandSplash';
import { cn } from '@/shared/utils/helpers';

interface LoadingSpinnerProps {
  /** Size of the spinner */
  size?: 'sm' | 'md' | 'lg';
  /** Custom className */
  className?: string;
  /** Loading text */
  text?: string;
  /** Show text below spinner */
  showText?: boolean;
}

export function LoadingSpinner({
  size = 'md',
  className,
  text = 'Loading...',
  showText = false,
}: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-6 w-6',
    lg: 'h-8 w-8',
  };

  const textSizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  };

  return (
    <div className={cn('flex items-center justify-center', className)}>
      <div className='flex flex-col items-center gap-2'>
        <Loader2
          className={cn(
            'animate-spin text-muted-foreground',
            sizeClasses[size],
          )}
        />
        {showText && (
          <p className={cn('text-muted-foreground', textSizeClasses[size])}>
            {text}
          </p>
        )}
      </div>
    </div>
  );
}

interface LoadingPageProps {
  /** Loading message */
  message?: string;
  /** Custom className */
  className?: string;
}

export function LoadingPage({
  message = 'Loading',
  className,
}: LoadingPageProps) {
  // The animated logo replaces the spinner and text; the message is read aloud only.
  return <BrandSplash label={message} className={className} />;
}

interface LoadingOverlayProps {
  /** Whether the overlay is visible */
  visible: boolean;
  /** Loading message */
  message?: string;
  /** Custom className */
  className?: string;
}

export function LoadingOverlay({
  visible,
  message = 'Loading...',
  className,
}: LoadingOverlayProps) {
  if (!visible) return null;

  return (
    <div
      className={cn(
        'absolute inset-0 bg-background/80 backdrop-blur-sm flex items-center justify-center z-50',
        className,
      )}
    >
      <LoadingSpinner size='lg' text={message} showText />
    </div>
  );
}
