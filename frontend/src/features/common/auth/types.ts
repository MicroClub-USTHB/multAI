import type { LoginSchema } from './schemas';
import type z from 'zod';

export type UserProfile = {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string;
};

// DTOs for API requests
export type LoginDto = z.infer<typeof LoginSchema>;

export type LoginInput = LoginDto & {
  rememberMe: boolean;
};

export interface LoginResponse {
  user: Partial<UserProfile>;
}

export interface BackendLoginResponse extends LoginResponse {
  token: string;
}

export interface VerifyTokenResponse {
  valid: true;
  user: Partial<UserProfile>;
}
