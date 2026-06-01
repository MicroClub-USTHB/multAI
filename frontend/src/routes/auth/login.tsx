import { ClientOnly, createFileRoute, useNavigate } from '@tanstack/react-router';
import { useEffect } from 'react';
import { z } from 'zod';

import Logo from '@/components/Logo';
import { LoginForm } from '@/features/common/auth/components/LoginForm';
import { useAuth } from '@/hooks/useAuth';
import { LoadingPage } from '@/shared/ui/loading';

const loginSearchSchema = z.object({
  redirect: z.string().optional(),
});

export const Route = createFileRoute('/auth/login')({
  component: RouteComponent,
  validateSearch: loginSearchSchema,
});

function RouteComponent() {
  const { isAuthenticated, isLoading } = useAuth();
  const navigate = useNavigate();
  const { redirect } = Route.useSearch();

  useEffect(() => {
    if (isLoading || !isAuthenticated) {
      return;
    }

    navigate({ to: redirect ?? '/admin', replace: true });
  }, [isAuthenticated, isLoading, navigate, redirect]);

  if (isLoading || isAuthenticated) {
    return <LoadingPage message="Checking session..." />;
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="flex w-full max-w-sm flex-col gap-6">
        <Logo />
        <ClientOnly fallback={<div>Loading...</div>}>
          <LoginForm />
        </ClientOnly>
      </div>
    </div>
  );
}
