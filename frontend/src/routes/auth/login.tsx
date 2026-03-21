import { ClientOnly, createFileRoute } from '@tanstack/react-router';

import Logo from '@/components/Logo';
import { LoginForm } from '@/features/common/auth/components/LoginForm';

export const Route = createFileRoute('/auth/login')({
  component: RouteComponent,
});

function RouteComponent() {
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
