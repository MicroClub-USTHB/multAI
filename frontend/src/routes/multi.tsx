import { createFileRoute, Outlet } from '@tanstack/react-router';

import { MainLayout } from '@/components/Layouts/MainLayout';
import { AuthGuard } from '@/features/common/auth/components/auth-guard';
import { MULTI_NAV_LINKS } from '@/shared/utils/constants';

const MULTI_ALLOWED_ROLES = ['admin', 'multi', 'multi_team_lead'] as const;

export const Route = createFileRoute('/multi')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <AuthGuard allowedRoles={MULTI_ALLOWED_ROLES}>
      <MainLayout navData={MULTI_NAV_LINKS}>
        <Outlet />
      </MainLayout>
    </AuthGuard>
  );
}
