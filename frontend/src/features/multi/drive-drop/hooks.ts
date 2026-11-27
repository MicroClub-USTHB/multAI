import { useMutation, useQuery } from '@tanstack/react-query'

import { getUploadGroupDetails } from '@/features/multi/uploads/api'

import { dropDriveFolder } from './api'

export function useDropDriveFolder() {
  return useMutation({ mutationFn: dropDriveFolder })
}

/** Polls the import group until the import and approval have settled. */
export function useDropProgress(groupId: string | null) {
  return useQuery({
    queryKey: ['multi', 'drive-drop', groupId],
    queryFn: () => getUploadGroupDetails(groupId as string),
    enabled: groupId !== null,
    refetchInterval: (query) => {
      const group = query.state.data
      if (!group) return 2000
      const finished =
        group.processing_status === 'failed' ||
        (group.processing_status === 'completed' && group.status !== 'pending')
      return finished ? false : 2000
    },
  })
}
