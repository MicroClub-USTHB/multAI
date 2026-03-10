import { MainLayout } from '@/components/Layouts/MainLayout';
import { MULTI_NAV_LINKS } from '@/shared/utils/constants';
import { createFileRoute, Outlet } from '@tanstack/react-router';

export const Route = createFileRoute('/multi')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <MainLayout navData={MULTI_NAV_LINKS}>
      <Outlet />
    </MainLayout>
  );
}
