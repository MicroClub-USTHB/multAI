import { env } from '@/env';

const BASE_URL = env.VITE_API_BASE_URL;

export class ApiError extends Error {
  constructor(
    public status: number,
    public body: unknown,
  ) {
    const msg =
      typeof body === 'object' && body !== null && 'detail' in body
        ? String((body as { detail: unknown }).detail)
        : `Request failed with status ${status}`;
    super(msg);
    this.name = 'ApiError';
  }
}

async function handleResponse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => null);
    throw new ApiError(res.status, body);
  }

  return res.json() as Promise<T>;
}

function joinUrl(base: string, path: string) {
  const normalizedBase = base.endsWith('/') ? base.slice(0, -1) : base;
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  return `${normalizedBase}${normalizedPath}`;
}

function getOriginForAbsoluteUrl() {
  if (typeof window !== 'undefined' && window.location?.origin) return window.location.origin;
  if (env.SERVER_URL) return env.SERVER_URL;
  return null;
}

function buildUrl(path: string) {
  const origin = getOriginForAbsoluteUrl();
  if (!origin) {
    throw new Error(
      'Cannot build absolute API URL during SSR. Set SERVER_URL (e.g. https://app.example.com) in the server environment.',
    );
  }

  return new URL(joinUrl(BASE_URL, path), origin).toString();
}

export const api = {
  get<T>(path: string, params?: Record<string, string | number | undefined | null>): Promise<T> {
    const url = new URL(buildUrl(path));
    if (params) {
      for (const [key, value] of Object.entries(params)) {
        if (value != null && value !== '') {
          url.searchParams.set(key, String(value));
        }
      }
    }

    return fetch(url.toString(), {
      credentials: 'include',
    }).then(handleResponse<T>);
  },

  post<T>(path: string, body?: unknown): Promise<T> {
    return fetch(buildUrl(path), {
      method: 'POST',
      credentials: 'include',
      headers: body != null ? { 'Content-Type': 'application/json' } : undefined,
      body: body != null ? JSON.stringify(body) : undefined,
    }).then(handleResponse<T>);
  },

  patch<T>(path: string, body?: unknown): Promise<T> {
    return fetch(buildUrl(path), {
      method: 'PATCH',
      credentials: 'include',
      headers: body != null ? { 'Content-Type': 'application/json' } : undefined,
      body: body != null ? JSON.stringify(body) : undefined,
    }).then(handleResponse<T>);
  },

  put<T>(path: string, body?: unknown): Promise<T> {
    return fetch(buildUrl(path), {
      method: 'PUT',
      credentials: 'include',
      headers: body != null ? { 'Content-Type': 'application/json' } : undefined,
      body: body != null ? JSON.stringify(body) : undefined,
    }).then(handleResponse<T>);
  },

  delete<T>(path: string): Promise<T> {
    return fetch(buildUrl(path), {
      method: 'DELETE',
      credentials: 'include',
    }).then(handleResponse<T>);
  },

  blobUrl(path: string): string {
    return buildUrl(path);
  },
};
