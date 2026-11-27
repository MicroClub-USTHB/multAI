import { ClientOnly, createFileRoute, useNavigate } from '@tanstack/react-router';
import { useEffect } from 'react';
import { z } from 'zod';

import { BrandLogoFull, BrandLogoMark } from '@/components/BrandLogo';
import { Mascot } from '@/components/Mascot';
import { LoginForm } from '@/features/common/auth/components/LoginForm';
import { getAuthRedirectPath } from '@/features/common/auth/utils';
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
  const { isAuthenticated, isLoading, user } = useAuth();
  const navigate = useNavigate();
  const { redirect } = Route.useSearch();
  const safeRedirect = getAuthRedirectPath({
    redirect,
    role: user?.role,
  });

  useEffect(() => {
    if (isLoading || !isAuthenticated) {
      return;
    }

    navigate({ to: safeRedirect, replace: true });
  }, [isAuthenticated, isLoading, navigate, safeRedirect]);

  if (isLoading || isAuthenticated) {
    return <LoadingPage message="Checking session..." />;
  }

  return (
    <div className="grid min-h-screen bg-[#00012C] text-[#F9FAFF] lg:grid-cols-[1.25fr_1fr]">
      {/* brand side */}
      <section className="relative hidden overflow-hidden lg:block">
        <BrandLogoMark className="absolute -bottom-32 -left-24 h-[760px] w-auto opacity-[0.14]" />
        <div className="relative flex h-full flex-col justify-between p-16">
          <BrandLogoFull className="h-12 w-auto self-start" />
          <div>
            <p className="text-[clamp(2.75rem,4.6vw,4.5rem)] font-semibold leading-[1.02] tracking-[-0.035em]">
              Photos find
              <br />
              their people.
            </p>
            <p className="mt-6 max-w-sm text-base leading-relaxed text-[#D9DDFF]/60">
              Dashboard for the multimedia team. Upload, review, publish.
            </p>
          </div>
        </div>
      </section>

      {/* form side */}
      <section
        className="relative flex flex-col bg-[#F9FAFF] px-6 text-[#00012C] sm:px-12"
        style={{
          backgroundImage:
            'radial-gradient(rgba(0,1,44,0.09) 1px, transparent 1px)',
          backgroundSize: '22px 22px',
        }}
      >
        <header className="flex items-center justify-between py-8">
          <BrandLogoMark className="h-8 w-auto [&_circle]:fill-[#F9FAFF] [&_path]:fill-[#00012C] lg:invisible" />
          <span className="rounded-full border border-[#00012C]/15 bg-[#F9FAFF] px-3 py-1 text-xs font-medium text-[#00012C]/60">
            Staff dashboard
          </span>
        </header>

        <div className="flex flex-1 items-center justify-center pb-16 pt-16">
          <div className="relative w-full max-w-[400px] rounded-2xl border border-[#00012C]/10 bg-white p-8 shadow-[0_1px_0_rgba(0,1,44,0.04),0_24px_48px_-24px_rgba(0,1,44,0.25)] sm:p-10">
            <Mascot className="absolute bottom-full left-1/2 -mb-[3px] h-24 w-auto -translate-x-1/2 drop-shadow-[0_6px_10px_rgba(0,1,44,0.18)]" />
            <ClientOnly fallback={<div className="text-sm text-[#00012C]/60">Loading...</div>}>
              <LoginForm />
            </ClientOnly>
          </div>
        </div>

        <footer className="pb-8 text-center text-xs text-[#00012C]/45">
          Having trouble? Contact your team lead.
        </footer>
      </section>
    </div>
  );
}
