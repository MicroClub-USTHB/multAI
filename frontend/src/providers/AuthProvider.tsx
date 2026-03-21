import { AuthContext } from '@/hooks/useAuth';
import type {
  LoginInput,
  LoginResponse,
  UserProfile,
} from '@/features/common/auth/types';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { LoadingPage } from '@/shared/ui/loading';
import { useServerFn } from '@tanstack/react-start';
import type React from 'react';

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const queryClient = useQueryClient();
  const getCurrentUser = useServerFn(async () => {
    await new Promise((res) => setTimeout(res, 500));
    throw new Error('Not implemented');
  });
  const loginRequest = useServerFn(async (data: { data: LoginInput }) => {
    await new Promise((res) => setTimeout(res, 500));
    throw new Error('Not implemented');
  });
  const logoutRequest = useServerFn(async () => {
    await new Promise((res) => setTimeout(res, 500));
    throw new Error('Not implemented');
  });

  const currentUserQuery = useQuery({
    queryKey: ['currentUser'],
    queryFn: () => getCurrentUser(),
    retry: false,
    staleTime: 5 * 60 * 1000,
  });

  const logout = useMutation({
    mutationFn: () => logoutRequest(),
    onError: (error) => {
      console.error(
        'Logout failed on server, proceeding with client-side cleanup.',
        error,
      );
    },
    onSettled: () => {
      queryClient.setQueryData(['currentUser'], null);
    },
  });

  const login = useMutation({
    mutationFn: (input: LoginInput) => loginRequest({ data: input }),
    onSuccess: (data: LoginResponse) => {
      queryClient.setQueryData(['currentUser'], data.user);
    },
  });

  const value = {
    user:
      (currentUserQuery.data as unknown as Partial<UserProfile> | null) ?? null,
    isAuthenticated: !!currentUserQuery.data,
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
