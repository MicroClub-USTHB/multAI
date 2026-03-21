import type {
  LoginInput,
  LoginResponse,
  UserProfile,
} from '@/features/common/auth/types';
import type { UseMutationResult } from '@tanstack/react-query';
import { createContext, useContext } from 'react';

interface AuthContextType {
  user: Partial<UserProfile> | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: UseMutationResult<
    LoginResponse,
    Error,
    LoginInput
  >;
  logout: UseMutationResult<{ success: true }, Error, void>;
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
