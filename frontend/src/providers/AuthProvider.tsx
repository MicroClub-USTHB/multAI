import type React from 'react';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useState } from 'react';

import type { AdminProfile } from '@/features/admin/auth/types';
import type { LoginInput } from '@/features/common/auth/types';

import {
  AdminAuthApiError,
  getAdminMe,
  loginAdmin,
  logoutAdmin,
} from '@/features/admin/auth/api';
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

  const login = useMutation({
    mutationFn: async (input: LoginInput) => {
      const response = await loginAdmin({
        email: input.email,
        password: input.password,
      });

      if (!response.accessToken) {
        throw new AdminAuthApiError('Login response did not include a token.', 500);
      }

      try {
        const profile = await queryClient.fetchQuery({
          queryKey: ['currentUser'] as const,
          queryFn: getAdminMe,
          staleTime: 5 * 60 * 1000,
        });
        queryClient.setQueryData(['currentUser'], profile);

        return response;
      } catch (error) {
        clearSessionState();

        if (error instanceof AdminAuthApiError) {
          throw error;
        }

        throw new AdminAuthApiError(
          'Unable to complete sign in.',
          500,
          error,
        );
      }
    },
  });

  const currentUser = (currentUserQuery.data as AdminProfile | null) ?? null;

  const isCheckingSession = !isMounted || currentUserQuery.isPending;

  const value = {
    user: currentUser,
    isAuthenticated: Boolean(currentUser),
    isLoading: isCheckingSession,
    login,
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
