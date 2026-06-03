import type React from 'react';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useState } from 'react';

import type { AdminProfile } from '@/features/admin/auth/types';
import type { LoginInput } from '@/features/common/auth/types';

import {
  ADMIN_AUTH_TOKEN_KEY,
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

  const normalizeToken = (value: string | null) => {
    if (!value || value === 'null' || value === 'undefined') {
      return null;
    }

    return value;
  };

  const readStoredToken = () =>
    typeof window === 'undefined' ?
      null :
      normalizeToken(
        window.localStorage.getItem(ADMIN_AUTH_TOKEN_KEY) ??
          window.sessionStorage.getItem(ADMIN_AUTH_TOKEN_KEY),
      );

  const clearStoredToken = () => {
    if (typeof window === 'undefined') {
      return;
    }

    window.localStorage.removeItem(ADMIN_AUTH_TOKEN_KEY);
    window.sessionStorage.removeItem(ADMIN_AUTH_TOKEN_KEY);
  };

  const clearAuthCookie = () => {
    if (typeof document === 'undefined') {
      return;
    }

    document.cookie = 'access_token=; Max-Age=0; path=/; SameSite=Lax';
  };

  const clearSessionState = useCallback(() => {
    clearStoredToken();
    clearAuthCookie();
    setToken(null);
    queryClient.removeQueries({ queryKey: ['currentUser'] });
  }, [queryClient]);

  const writeAuthCookie = (value: string, rememberMe: boolean) => {
    if (typeof document === 'undefined') {
      return;
    }

    const maxAge = rememberMe ? '; Max-Age=2592000' : '';

    document.cookie = `access_token=${encodeURIComponent(
      value,
    )}; path=/; SameSite=Lax${maxAge}`;
  };

  const writeStoredToken = (value: string, rememberMe: boolean) => {
    if (typeof window === 'undefined') {
      return;
    }

    const targetStorage = rememberMe ? window.localStorage : window.sessionStorage;
    const otherStorage = rememberMe ? window.sessionStorage : window.localStorage;

    otherStorage.removeItem(ADMIN_AUTH_TOKEN_KEY);
    targetStorage.setItem(ADMIN_AUTH_TOKEN_KEY, value);
  };

  const [token, setToken] = useState<string | null>(null);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
    setToken(readStoredToken());
  }, []);

  useEffect(() => {
    if (!isMounted) {
      return;
    }

    const storedToken = readStoredToken();

    if (!storedToken && token) {
      setToken(null);
      queryClient.removeQueries({ queryKey: ['currentUser'] });
      return;
    }

    if (storedToken && storedToken !== token) {
      setToken(storedToken);
    }
  }, [isMounted, queryClient, token]);

  useEffect(() => {
    if (!isMounted || typeof window === 'undefined') {
      return;
    }

    const handleStorage = (event: StorageEvent) => {
      if (event.key && event.key !== ADMIN_AUTH_TOKEN_KEY) {
        return;
      }

      const storedToken = readStoredToken();

      if (!storedToken) {
        clearSessionState();
        return;
      }

      if (storedToken !== token) {
        setToken(storedToken);
      }
    };

    window.addEventListener('storage', handleStorage);

    return () => window.removeEventListener('storage', handleStorage);
  }, [isMounted, token, clearSessionState]);

  const currentUserQueryKey = ['currentUser', token] as const;

  const currentUserQuery = useQuery({
    queryKey: currentUserQueryKey,
    queryFn: () => getAdminMe(),
    enabled: isMounted && Boolean(token),
    retry: false,
    staleTime: 5 * 60 * 1000,
  });

  useEffect(() => {
    const error = currentUserQuery.error;

    if (!(error instanceof AdminAuthApiError) || error.status !== 401) {
      return;
    }

    clearSessionState();
  }, [clearSessionState, currentUserQuery.error]);

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

      const nextToken = normalizeToken(response.accessToken);

      if (!nextToken) {
        throw new AdminAuthApiError('Login response did not include a token.', 500);
      }

      writeStoredToken(nextToken, input.rememberMe);
      writeAuthCookie(nextToken, input.rememberMe);
      setToken(nextToken);

      try {
        const profile = await queryClient.fetchQuery({
          queryKey: ['currentUser', nextToken],
          queryFn: () => getAdminMe(),
        });
        queryClient.setQueryData(['currentUser', nextToken], profile);

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

  const currentUser = token ? ((currentUserQuery.data as AdminProfile | null) ?? null) : null;

  const isCheckingSession =
    !isMounted || (Boolean(token) && currentUserQuery.isPending);

  const value = {
    user: currentUser,
    isAuthenticated: Boolean(token && currentUser),
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
