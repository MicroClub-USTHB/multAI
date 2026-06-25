import { createFileRoute, Outlet } from '@tanstack/react-router';

import { MainLayout } from '@/components/Layouts/MainLayout';
import { AuthGuard } from '@/features/common/auth/components/auth-guard';
import { ADMIN_NAV_DATA } from '@/shared/utils/constants';

const ADMIN_ALLOWED_ROLES = ['admin'] as const;

export const Route = createFileRoute('/admin')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <AuthGuard allowedRoles={ADMIN_ALLOWED_ROLES}>
      <MainLayout navData={ADMIN_NAV_DATA}>
        <Outlet />
      </MainLayout>
    </AuthGuard>
  );
}
