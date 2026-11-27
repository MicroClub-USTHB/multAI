import type { UseMutationResult } from '@tanstack/react-query';

import { createContext, useContext } from 'react';

import type { AdminProfile } from '@/features/common/auth/session-types';

interface AuthContextType {
  user: AdminProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
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
