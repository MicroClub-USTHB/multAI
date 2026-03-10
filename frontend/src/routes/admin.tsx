import { MainLayout } from '@/components/Layouts/MainLayout';
import { ADMIN_NAV_DATA } from '@/shared/utils/constants';
import { createFileRoute, Outlet } from '@tanstack/react-router';

export const Route = createFileRoute('/admin')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <MainLayout navData={ADMIN_NAV_DATA}>
      <Outlet />
    </MainLayout>
  );
}
