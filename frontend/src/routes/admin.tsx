import { createFileRoute, Outlet } from '@tanstack/react-router';
import { useEffect } from 'react';

import { MainLayout } from '@/components/Layouts/MainLayout';
import { useAuth } from '@/hooks/useAuth';
import { LoadingPage } from '@/shared/ui/loading';
import { ADMIN_NAV_DATA } from '@/shared/utils/constants';

export const Route = createFileRoute('/admin')({
  component: RouteComponent,
});

function RouteComponent() {
  const { isAuthenticated, isLoading } = useAuth();

  useEffect(() => {
    if (isLoading || isAuthenticated) {
      return;
    }

    const redirect = window.location.pathname + window.location.search;
    const search = new URLSearchParams({ redirect });
    window.location.assign(`/auth/login?${search.toString()}`);
  }, [isAuthenticated, isLoading]);

  if (isLoading) {
    return <LoadingPage message="Checking session..." />;
  }

  if (!isAuthenticated) {
    return null;
  }

  return (
    <MainLayout navData={ADMIN_NAV_DATA}>
      <Outlet />
    </MainLayout>
  );
}
