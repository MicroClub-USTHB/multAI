import type { UseMutationResult } from '@tanstack/react-query';

import { createContext, useContext } from 'react';

import type { AdminAuthResponse, AdminProfile } from '@/features/admin/auth/types';
import type { LoginInput } from '@/features/common/auth/types';

interface AuthContextType {
  user: AdminProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: UseMutationResult<AdminAuthResponse, Error, LoginInput>;
  logout: UseMutationResult<void, Error, void>;
}

export const AuthContext = createContext<AuthContextType | undefined>(
  undefined,
);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
