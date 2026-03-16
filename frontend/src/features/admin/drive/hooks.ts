import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
	connectGoogleDrive,
	getDriveSettings,
	updateOutputFolder,
	updateSyncFrequency,
} from './api'
import type {
	ConnectGoogleDriveInput,
	DriveSettings,
	UpdateOutputFolderInput,
	UpdateSyncFrequencyInput,
} from './types'

export const DRIVE_SETTINGS_QUERY_KEY = ['admin', 'drive', 'settings'] as const

export function useDriveSettingsQuery() {
	return useQuery({
		queryKey: DRIVE_SETTINGS_QUERY_KEY,
		queryFn: getDriveSettings,
	})
}

export function useConnectGoogleDriveMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: ConnectGoogleDriveInput) => connectGoogleDrive(input),
		onSuccess: settings => {
			queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings)
		},
	})
}

export function useUpdateSyncFrequencyMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: UpdateSyncFrequencyInput) => updateSyncFrequency(input),
		onSuccess: settings => {
			queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings)
		},
	})
}

export function useUpdateOutputFolderMutation() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (input: UpdateOutputFolderInput) => updateOutputFolder(input),
		onSuccess: settings => {
			queryClient.setQueryData(DRIVE_SETTINGS_QUERY_KEY, settings)
		},
	})
}

export function useDriveSettings() {
	const settingsQuery = useDriveSettingsQuery()
	const connectMutation = useConnectGoogleDriveMutation()
	const syncMutation = useUpdateSyncFrequencyMutation()
	const outputFolderMutation = useUpdateOutputFolderMutation()

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
	}
}

export type DriveSettingsData = DriveSettings

