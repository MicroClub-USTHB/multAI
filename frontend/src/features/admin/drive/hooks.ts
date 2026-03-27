import {
  useMutation,
  useQueryClient,
  useSuspenseQuery,
} from '@tanstack/react-query';

import type {
  ConnectGoogleDriveInput,
  UpdateOutputFolderInput,
  UpdateSyncFrequencyInput,
} from './types';

import {
  connectGoogleDrive,
  updateOutputFolder,
  updateSyncFrequency,
} from './api';
import { DRIVE_SETTINGS_QUERY_KEY } from './constants';
import { driveSettingsQueryOptions } from './query-options';

export function useDriveSettingsQuery() {
  return useSuspenseQuery(driveSettingsQueryOptions());
}

export function useConnectGoogleDriveMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: ConnectGoogleDriveInput) =>
      connectGoogleDrive({ data: input }),
    onSuccess: (settings) => {
      queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings);
    },
  });
}

export function useUpdateSyncFrequencyMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: UpdateSyncFrequencyInput) =>
      updateSyncFrequency({ data: input }),
    onSuccess: (settings) => {
      queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings);
      queryClient.invalidateQueries({ queryKey: DRIVE_SETTINGS_QUERY_KEY });
    },
  });
}

export function useUpdateOutputFolderMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: UpdateOutputFolderInput) =>
      updateOutputFolder({ data: input }),
    onSuccess: (settings) => {
      queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings);
      queryClient.invalidateQueries({ queryKey: DRIVE_SETTINGS_QUERY_KEY });
    },
  });
}

export function useDriveSettings() {
  const settingsQuery = useDriveSettingsQuery();
  const connectMutation = useConnectGoogleDriveMutation();
  const syncMutation = useUpdateSyncFrequencyMutation();
  const outputFolderMutation = useUpdateOutputFolderMutation();

  const latestMutation = [
    {
      type: 'connect' as const,
      submittedAt: connectMutation.submittedAt,
      isSuccess: connectMutation.isSuccess,
      isError: connectMutation.isError,
      error: connectMutation.error,
    },
    {
      type: 'sync' as const,
      submittedAt: syncMutation.submittedAt,
      isSuccess: syncMutation.isSuccess,
      isError: syncMutation.isError,
      error: syncMutation.error,
    },
    {
      type: 'output' as const,
      submittedAt: outputFolderMutation.submittedAt,
      isSuccess: outputFolderMutation.isSuccess,
      isError: outputFolderMutation.isError,
      error: outputFolderMutation.error,
    },
  ].reduce((latest, current) =>
    current.submittedAt > latest.submittedAt ? current : latest,
  );

  const actionFeedback =
    latestMutation.submittedAt === 0
      ? null
      : latestMutation.isError
        ? {
            tone: 'error' as const,
            message:
              latestMutation.error instanceof Error
                ? latestMutation.error.message
                : latestMutation.type === 'connect'
                  ? 'Unable to connect Google Drive.'
                  : latestMutation.type === 'sync'
                    ? 'Unable to update sync frequency.'
                    : 'Unable to update output folder.',
          }
        : latestMutation.isSuccess
          ? {
              tone: 'success' as const,
              message:
                latestMutation.type === 'connect'
                  ? 'Google Drive connected successfully.'
                  : latestMutation.type === 'sync'
                    ? 'Sync frequency updated successfully.'
                    : 'Output folder updated successfully.',
            }
          : null;

  return {
    settings: settingsQuery.data,
    isLoading: settingsQuery.isLoading,
    isError: settingsQuery.isError,
    error: settingsQuery.error,
    refetch: settingsQuery.refetch,

    isConnecting: connectMutation.isPending,
    isUpdatingSync: syncMutation.isPending,
    isUpdatingOutputFolder: outputFolderMutation.isPending,

    connect: connectMutation.mutateAsync,
    updateSyncFrequency: syncMutation.mutateAsync,
    updateOutputFolder: outputFolderMutation.mutateAsync,

    isMutating:
      connectMutation.isPending ||
      syncMutation.isPending ||
      outputFolderMutation.isPending,

    connectIsLoading: connectMutation.isPending,
    connectIsError: connectMutation.isError,
    connectIsSuccess: connectMutation.isSuccess,
    connectError: connectMutation.error,

    syncIsLoading: syncMutation.isPending,
    syncIsError: syncMutation.isError,
    syncIsSuccess: syncMutation.isSuccess,
    syncError: syncMutation.error,

    outputIsLoading: outputFolderMutation.isPending,
    outputIsError: outputFolderMutation.isError,
    outputIsSuccess: outputFolderMutation.isSuccess,
    outputError: outputFolderMutation.error,

    actionFeedback,
  };
}
