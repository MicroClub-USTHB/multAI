import {
	type ConnectGoogleDriveInput,
	type DriveSettings,
	SYNC_INTERVALS,
	type UpdateOutputFolderInput,
	type UpdateSyncFrequencyInput,
} from './types'

const MOCK_LATENCY_MS = 400

let mockDriveSettings: DriveSettings = {
	isConnected: false,
	syncInterval: 5,
	outputFolder: '/media/processed',
	connectedAt: null,
	updatedAt: new Date().toISOString(),
}

const sleep = (ms: number) =>
	new Promise(resolve => {
		setTimeout(resolve, ms)
	})

const cloneSettings = (): DriveSettings => ({ ...mockDriveSettings })

const assertSyncInterval = (interval: number) => {
	if (!SYNC_INTERVALS.includes(interval as (typeof SYNC_INTERVALS)[number])) {
		throw new Error('Invalid sync interval')
	}
}

export async function getDriveSettings(): Promise<DriveSettings> {
	await sleep(MOCK_LATENCY_MS)
	return cloneSettings()
}

export async function connectGoogleDrive(
	input: ConnectGoogleDriveInput,
): Promise<DriveSettings> {
	const apiKey = input.apiKey.trim()

	if (apiKey.length < 10) {
		throw new Error('API key is too short')
	}

	await sleep(MOCK_LATENCY_MS)

	const now = new Date().toISOString()
	mockDriveSettings = {
		...mockDriveSettings,
		isConnected: true,
		connectedAt: now,
		updatedAt: now,
	}

	return cloneSettings()
}

export async function updateSyncFrequency(
	input: UpdateSyncFrequencyInput,
): Promise<DriveSettings> {
	assertSyncInterval(input.syncInterval)

	await sleep(MOCK_LATENCY_MS)

	mockDriveSettings = {
		...mockDriveSettings,
		syncInterval: input.syncInterval,
		updatedAt: new Date().toISOString(),
	}

	return cloneSettings()
}

export async function updateOutputFolder(
	input: UpdateOutputFolderInput,
): Promise<DriveSettings> {
	const normalizedPath = input.outputFolder.trim()

	if (!normalizedPath.startsWith('/')) {
		throw new Error('Output folder must be an absolute path')
	}

	await sleep(MOCK_LATENCY_MS)

	mockDriveSettings = {
		...mockDriveSettings,
		outputFolder: normalizedPath,
		updatedAt: new Date().toISOString(),
	}

	return cloneSettings()
}

