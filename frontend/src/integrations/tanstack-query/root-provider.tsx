import type { ReactNode } from 'react';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { ApiError } from '@/shared/utils/api-client';

let queryClient: QueryClient | undefined;

export function getQueryClient() {
  if (!queryClient) {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          staleTime: 1000 * 60 * 5,
          gcTime: 1000 * 60 * 10,
          refetchOnWindowFocus: import.meta.env.PROD,
          retry: (failureCount, error) => {
            if (error instanceof ApiError && error.status === 401) return false;
            return failureCount < 2;
          },
        },
        mutations: {
          retry: (failureCount, error) => {
            if (error instanceof ApiError && error.status === 401) return false;
            return failureCount < 1;
          },
        },
      },
    });
  }
  return queryClient;
}

export default function TanStackQueryProvider({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <QueryClientProvider client={getQueryClient()}>
      {children}
    </QueryClientProvider>
  );
}
