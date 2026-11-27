import { Fingerprint } from 'lucide-react';

import { env } from '@/env';
import {
  Button,
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from '@/shared/ui';
import { cn } from '@/shared/utils/helpers';

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const apiBase = (env.VITE_API_BASE_URL || '/api').replace(/\/+$/, '');
  const mcdiLoginUrl = `${apiBase}/admin/auth/mcdi/login`;

  return (
    <div className={cn('flex flex-col gap-6', className)} {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Sign in</CardTitle>
          <p className='text-sm text-muted-foreground'>
            Use your MicroClub Digital Identity to access the dashboard.
          </p>
        </CardHeader>
        <CardContent>
          <Button
            type='button'
            className='w-full flex items-center gap-2'
            onClick={() => { window.location.href = mcdiLoginUrl; }}
          >
            <Fingerprint className='h-4 w-4' />
            Sign in with MCDI
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
