import { useForm } from '@tanstack/react-form';
import { Lock, Mail } from 'lucide-react';
import { useState } from 'react';

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
import { Checkbox } from '@/shared/ui/checkbox';
import { Label } from '@/shared/ui/label';
import { Message } from '@/shared/ui/message';
import { cn } from '@/shared/utils/helpers';

import type { LoginDto } from '../types';

import { LoginSchema } from '../schemas';

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const [rememberMe, setRememberMe] = useState(true);
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
        rememberMe,
      });

      const redirectTo =
        new URLSearchParams(window.location.search).get('redirect') || '/';

      window.location.assign(redirectTo);
    },
  });

  const error = login.error?.message;

  return (
    <div className={cn('flex flex-col gap-6', className)} {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Welcome back</CardTitle>
        </CardHeader>

        <CardContent>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              form.handleSubmit();
            }}
          >
            <div className='grid gap-6'>
              {/* EMAIL FIELD */}
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
                        type='text'
                        placeholder='m@example.com'
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

              {/* PASSWORD FIELD */}
              <form.Field name='password'>
                {(field) => (
                  <div className='grid gap-3'>
                    <div className='flex items-center'>
                      <Label htmlFor='password'>Password</Label>

                      <a
                        href='#'
                        className='ml-auto text-sm underline-offset-4 hover:underline'
                      >
                        Forgot your password?
                      </a>
                    </div>

                    <InputGroup>
                      <InputGroupAddon>
                        <Lock className='h-4 w-4' />
                      </InputGroupAddon>
                      <InputGroupInput
                        id='password'
                        type='password'
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

              {/* REMEMBER ME */}
              <div className='flex items-center gap-3'>
                <Checkbox
                  id='remember-me'
                  checked={rememberMe}
                  onCheckedChange={(e) => setRememberMe(!!e)}
                />
                <Label htmlFor='remember-me'>Remember me</Label>
              </div>

              {/* SUBMIT */}
              <Button
                type='submit'
                className='w-full'
                isLoading={form.state.isSubmitting}
              >
                Login
              </Button>

              {/* LOGIN ERROR */}
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
