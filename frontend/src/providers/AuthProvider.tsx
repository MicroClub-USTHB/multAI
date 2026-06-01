import type React from 'react';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';

import type { AdminProfile } from '@/features/admin/auth/types';
import type { LoginInput } from '@/features/common/auth/types';

import {
  ADMIN_AUTH_TOKEN_KEY,
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
  const [token, setToken] = useState(() =>
    typeof window === 'undefined'
      ? null
      : window.localStorage.getItem(ADMIN_AUTH_TOKEN_KEY),
  );

  const currentUserQueryKey = ['currentUser', token] as const;

  const currentUserQuery = useQuery({
    queryKey: currentUserQueryKey,
    queryFn: () => getAdminMe(),
    enabled: Boolean(token),
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
      if (typeof window !== 'undefined') {
        window.localStorage.removeItem(ADMIN_AUTH_TOKEN_KEY);
      }
      setToken(null);
      queryClient.removeQueries({ queryKey: ['currentUser'] });
    },
  });

  const login = useMutation({
    mutationFn: async (input: LoginInput) => {
      const response = await loginAdmin({
        email: input.email,
        password: input.password,
      });

      if (typeof window !== 'undefined') {
        window.localStorage.setItem(ADMIN_AUTH_TOKEN_KEY, response.accessToken);
      }
      setToken(response.accessToken);

      return response;
    },
    onSuccess: async (response) => {
      const profile = await queryClient.fetchQuery({
        queryKey: ['currentUser', response.accessToken],
        queryFn: () => getAdminMe(),
      });
      queryClient.setQueryData(['currentUser', response.accessToken], profile);
    },
  });

  const value = {
    user: (currentUserQuery.data as AdminProfile | null) ?? null,
    isAuthenticated: Boolean(currentUserQuery.data),
    isLoading: currentUserQuery.isPending,
    login,
    logout,
  };

  return (
    <AuthContext.Provider value={value}>
      {currentUserQuery.isPending ? (
        <LoadingPage message='Initializing...' />
      ) : (
        children
      )}
    </AuthContext.Provider>
  );
};
