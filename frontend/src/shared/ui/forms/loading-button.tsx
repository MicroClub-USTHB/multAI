import { Loader2Icon } from 'lucide-react';

import { Button, type ButtonProps } from './button';

interface LoadingButtonProps extends ButtonProps {
  isLoading?: boolean;
  loadingText?: string;
  showLoader?: React.ReactNode;
  customLoader?: React.ReactNode;
}

export function LoadingButton({
  isLoading,
  loadingText,
  showLoader = true,
  customLoader,
  ...props
}: LoadingButtonProps) {
  return (
    <Button
      {...props}
      disabled={isLoading || props.disabled}
      className={`${props.className} ${isLoading ? 'cursor-not-allowed opacity-70' : ''}`}
    >
      {isLoading &&
        showLoader &&
        (customLoader || <Loader2Icon className="animate-spin" />)}
      {isLoading ? loadingText || 'Loading...' : props.children}
    </Button>
  );
}
