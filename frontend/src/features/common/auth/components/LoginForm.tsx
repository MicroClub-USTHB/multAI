import { useForm } from '@tanstack/react-form';
import { Lock, Mail } from 'lucide-react';

import { useAuth } from '@/hooks/useAuth';
import {
  Button,
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from '@/shared/ui';
import { Label } from '@/shared/ui/label';
import { Message } from '@/shared/ui/message';
import { cn } from '@/shared/utils/helpers';

import type { LoginDto } from '../types';

import { LoginSchema } from '../schemas';

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const { login } = useAuth();

  const form = useForm({
    defaultValues: {
      email: '',
      password: '',
    } satisfies LoginDto,
    validators: {
      onSubmit: LoginSchema,
    },
    onSubmit: async ({ value }) => {
      await login.mutateAsync({
        email: value.email,
        password: value.password,
      });
    },
  });

  const isSubmitting = form.state.isSubmitting || login.isPending;

  const error = login.error?.message;

  return (
    <div className={cn('flex flex-col gap-6', className)} {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Sign in</CardTitle>
          <p className='text-sm text-muted-foreground'>
            Use your staff credentials to access the dashboard.
          </p>
        </CardHeader>

        <CardContent>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              form.handleSubmit();
            }}
          >
            <div className='grid gap-6'>
              <form.Field name='email'>
                {(field) => (
                  <div className='grid gap-3'>
                    <Label htmlFor='email'>Email</Label>

                    <InputGroup>
                      <InputGroupAddon>
                        <Mail className='h-4 w-4' />
                      </InputGroupAddon>
                      <InputGroupInput
                        id='email'
                        type='email'
                        placeholder='m@example.com'
                        autoComplete='email'
                        disabled={isSubmitting}
                        value={field.state.value}
                        onChange={(e) => field.handleChange(e.target.value)}
                        onBlur={field.handleBlur}
                        aria-invalid={Boolean(field.state.meta.errors?.length)}
                      />
                    </InputGroup>

                    {field.state.meta.errors?.[0]?.message ? (
                      <Message className='text-destructive'>
                        {field.state.meta.errors[0].message}
                      </Message>
                    ) : null}
                  </div>
                )}
              </form.Field>

              <form.Field name='password'>
                {(field) => (
                  <div className='grid gap-3'>
                    <div className='flex items-center'>
                      <Label htmlFor='password'>Password</Label>
                    </div>

                    <InputGroup>
                      <InputGroupAddon>
                        <Lock className='h-4 w-4' />
                      </InputGroupAddon>
                      <InputGroupInput
                        id='password'
                        type='password'
                        autoComplete='current-password'
                        disabled={isSubmitting}
                        value={field.state.value}
                        onChange={(e) => field.handleChange(e.target.value)}
                        onBlur={field.handleBlur}
                        aria-invalid={Boolean(field.state.meta.errors?.length)}
                      />
                    </InputGroup>

                    {field.state.meta.errors?.[0]?.message ? (
                      <Message className='text-destructive'>
                        {field.state.meta.errors[0].message}
                      </Message>
                    ) : null}
                  </div>
                )}
              </form.Field>

              <Button
                type='submit'
                className='w-full'
                isLoading={isSubmitting}
                disabled={isSubmitting}
              >
                Sign in
              </Button>

              {error && (
                <Message className='text-destructive -my-2'>{error}</Message>
              )}
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
