import { useMutation, useQueryClient } from '@tanstack/react-query';

import { MULTI_EVENTS_QUERY_KEY } from '@/features/multi/events/hooks';

import type { DriveImportInput } from './types';

import { importDriveUrls } from './api';

const MULTI_UPLOAD_GROUPS_QUERY_KEY = ['multi', 'upload-groups'] as const;

export function useImportDriveUrlsMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: DriveImportInput) => importDriveUrls(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: MULTI_EVENTS_QUERY_KEY });
      queryClient.invalidateQueries({
        queryKey: MULTI_UPLOAD_GROUPS_QUERY_KEY,
      });
    },
  });
}
