import { createFileRoute, useNavigate } from '@tanstack/react-router';
import { useEffect } from 'react';

import { getRoleLandingPath } from '@/features/common/auth/utils';
import { useAuth } from '@/hooks/useAuth';
import { LoadingPage } from '@/shared/ui/loading';

export const Route = createFileRoute('/')({ component: App });

/** The site root has no content: signed-in staff go to their page, everyone else to the login. */
function App() {
  const { isAuthenticated, isLoading, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (isLoading) return;

    if (isAuthenticated) {
      navigate({ to: getRoleLandingPath(user?.role), replace: true });
    } else {
      navigate({ to: '/auth/login', replace: true });
    }
  }, [isAuthenticated, isLoading, navigate, user?.role]);

  return <LoadingPage message='Redirecting' />;
}
