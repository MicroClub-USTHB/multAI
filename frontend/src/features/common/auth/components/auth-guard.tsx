import type React from 'react';

import { useEffect } from 'react';
import { useNavigate } from '@tanstack/react-router';

import { useAuth } from '@/hooks/useAuth';
import { LoadingPage } from '@/shared/ui/loading';

import { getRoleLandingPath } from '../utils';

type AuthGuardProps = {
  children: React.ReactNode;
  allowedRoles: readonly string[];
  loadingMessage?: string;
};

const hasAllowedRole = (
  role: string | null | undefined,
  allowedRoles: readonly string[],
) => role !== null && role !== undefined && allowedRoles.includes(role);

export function AuthGuard({
  children,
  allowedRoles,
  loadingMessage = 'Checking session...',
}: AuthGuardProps) {
  const { isAuthenticated, isLoading, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (isLoading) {
      return;
    }

    if (!isAuthenticated) {
      const redirect =
        window.location.pathname + window.location.search + window.location.hash;

      navigate({
        to: '/auth/login',
        search: { redirect },
        replace: true,
      });
      return;
    }

    if (!user || hasAllowedRole(user.role, allowedRoles)) {
      return;
    }

    navigate({
      to: getRoleLandingPath(user.role),
      replace: true,
    });
  }, [allowedRoles, isAuthenticated, isLoading, navigate, user]);

  if (isLoading) {
    return <LoadingPage message={loadingMessage} />;
  }

  if (!isAuthenticated) {
    return null;
  }

  if (!user || !hasAllowedRole(user.role, allowedRoles)) {
    return <LoadingPage message="Redirecting..." />;
  }

  return <>{children}</>;
}
