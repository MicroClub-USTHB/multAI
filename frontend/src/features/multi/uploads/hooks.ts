import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import {
  approveUploadGroup,
  getUploadGroupDetails,
  listUploadGroups,
  rejectUploadGroup,
} from './api'

const uploadGroupsKey = ['multi', 'upload-groups'] as const
const uploadGroupDetailsKey = (groupId: string) =>
  ['multi', 'upload-groups', groupId] as const

export function useUploadGroups(scope: 'my' | 'all') {
  const query = useQuery({
    queryKey: [...uploadGroupsKey, scope],
    queryFn: () => listUploadGroups(scope),
  })

  return {
    groups: query.data?.items ?? [],
    isLoading: query.isPending,
    isError: query.isError,
    error: query.error,
    refetch: query.refetch,
  }
}

export function useUploadGroupDetails(groupId: string | null) {
  const query = useQuery({
    queryKey: groupId ? uploadGroupDetailsKey(groupId) : ['multi', 'upload-groups', 'none'],
    queryFn: () => getUploadGroupDetails(groupId as string),
    enabled: Boolean(groupId),
  })

  return {
    group: query.data ?? null,
    isLoading: query.isPending,
    isError: query.isError,
    error: query.error,
  }
}

export function useApproveUploadGroupMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (groupId: string) => approveUploadGroup(groupId),
    onSuccess: (updatedGroup) => {
      queryClient.invalidateQueries({ queryKey: uploadGroupsKey })
      queryClient.setQueryData(uploadGroupDetailsKey(updatedGroup.id), updatedGroup)
    },
  })
}

export function useRejectUploadGroupMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ groupId, reason }: { groupId: string; reason?: string }) =>
      rejectUploadGroup(groupId, reason),
    onSuccess: (updatedGroup) => {
      queryClient.invalidateQueries({ queryKey: uploadGroupsKey })
      queryClient.setQueryData(uploadGroupDetailsKey(updatedGroup.id), updatedGroup)
    },
  })
}