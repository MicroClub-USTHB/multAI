import type z from 'zod';

import type { LoginSchema } from './schemas';

export type UserProfile = {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string;
};

// DTOs for API requests
export type LoginDto = z.infer<typeof LoginSchema>;

export type LoginInput = LoginDto;

export interface LoginResponse {
  access_token: string;
  user_id: string;
  role: string;
}

export type BackendLoginResponse = LoginResponse;

export interface VerifyTokenResponse {
  valid: true;
  user: Partial<UserProfile>;
}
