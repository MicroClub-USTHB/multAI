import { createServerFn } from '@tanstack/react-start';

import {
	mockAdminStats,
	mockAlerts,
	mockDriveUsage,
	mockProcessingLoad,
	type AdminStatsData,
	type AlertData,
	type DriveUsage,
	type ProcessingLoad,
} from './types';

const MOCK_LATENCY_MS = 1500;

const sleep = (ms: number) =>
	new Promise((resolve) => {
		setTimeout(resolve, ms);
	});

const cloneDriveUsage = (): DriveUsage => ({ ...mockDriveUsage });

const cloneAdminStats = (): AdminStatsData => ({ ...mockAdminStats });

const cloneAlerts = (): AlertData => ({
	...mockAlerts,
	alerts: mockAlerts.alerts.map((alert) => ({ ...alert })),
});

const cloneProcessingLoad = (): ProcessingLoad => ({ ...mockProcessingLoad });

export const getDriveUsage = createServerFn({ method: 'GET' }).handler(
	async (): Promise<DriveUsage> => {
		await sleep(MOCK_LATENCY_MS);
		return cloneDriveUsage();
	},
);

export const getAdminStats = createServerFn({ method: 'GET' }).handler(
	async (): Promise<AdminStatsData> => {
		await sleep(MOCK_LATENCY_MS);
		return cloneAdminStats();
	},
);

export const getAlerts = createServerFn({ method: 'GET' }).handler(
	async (): Promise<AlertData> => {
		await sleep(MOCK_LATENCY_MS);
		return cloneAlerts();
	},
);

export const getProcessingLoad = createServerFn({ method: 'GET' }).handler(
	async (): Promise<ProcessingLoad> => {
		await sleep(MOCK_LATENCY_MS);
		return cloneProcessingLoad();
	},
);
