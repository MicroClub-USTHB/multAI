import { createFileRoute, Outlet, useNavigate } from '@tanstack/react-router';
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
  const navigate = useNavigate();

  useEffect(() => {
    if (isLoading || isAuthenticated) {
      return;
    }

    const currentPath = window.location.pathname + window.location.search;
    navigate({
      to: '/auth/login',
      search: { redirect: currentPath },
      replace: true,
    });
  }, [isAuthenticated, isLoading, navigate]);

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
