import type React from 'react';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useState } from 'react';

import type { AdminProfile } from '@/features/common/auth/session-types';

import {
  getAdminMe,
  logoutAdmin,
} from '@/features/common/auth/session-api';
import { AuthContext } from '@/hooks/useAuth';
import { LoadingPage } from '@/shared/ui/loading';

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const queryClient = useQueryClient();

  const clearSessionState = useCallback(() => {
    queryClient.removeQueries({ queryKey: ['currentUser'] });
  }, [queryClient]);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  const currentUserQuery = useQuery({
    queryKey: ['currentUser'] as const,
    queryFn: getAdminMe,
    enabled: isMounted,
    retry: false,
    staleTime: 5 * 60 * 1000,
  });

  const logout = useMutation({
    mutationFn: () => logoutAdmin(),
    onError: (error) => {
      console.error(
        'Logout failed on server, proceeding with client-side cleanup.',
        error,
      );
    },
    onSettled: () => {
      clearSessionState();
    },
  });


  const currentUser = (currentUserQuery.data as AdminProfile | null) ?? null;

  const isCheckingSession = !isMounted || currentUserQuery.isPending;

  const value = {
    user: currentUser,
    isAuthenticated: Boolean(currentUser),
    isLoading: isCheckingSession,
    logout,
  };

  return (
    <AuthContext.Provider value={value}>
      {isCheckingSession ? (
        <LoadingPage message='Initializing...' />
      ) : (
        children
      )}
    </AuthContext.Provider>
  );
};
