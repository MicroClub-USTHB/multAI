import { createServerFn } from '@tanstack/react-start';

import type { DriveSettings, SyncInterval } from './types';

import {
  connectGoogleDriveInput,
  updateOutputFolderInput,
  updateSyncFrequencyInput,
} from './schemas';

const MOCK_LATENCY_MS = 400;

let mockDriveSettings: DriveSettings = {
  isConnected: false,
  syncInterval: 5,
  outputFolder: '/media/processed',
  connectedAt: null,
  updatedAt: new Date().toISOString(),
};

const sleep = (ms: number) =>
  new Promise((resolve) => {
    setTimeout(resolve, ms);
  });

const cloneSettings = (): DriveSettings => ({ ...mockDriveSettings });

export const getDriveSettings = createServerFn({ method: 'GET' }).handler(
  async (): Promise<DriveSettings> => {
    await sleep(MOCK_LATENCY_MS);
    return cloneSettings();
  },
);

export const connectGoogleDrive = createServerFn({ method: 'POST' })
  .validator((data: unknown) => connectGoogleDriveInput.parse(data))
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  .handler(async (_: { data: any }): Promise<DriveSettings> => {
    await sleep(MOCK_LATENCY_MS);

    const now = new Date().toISOString();
    mockDriveSettings = {
      ...mockDriveSettings,
      isConnected: true,
      connectedAt: now,
      updatedAt: now,
    };

    return cloneSettings();
  });

export const updateSyncFrequency = createServerFn({ method: 'POST' })
  .validator((data: unknown) => updateSyncFrequencyInput.parse(data))
  .handler(async ({ data: input }: { data: any }): Promise<DriveSettings> => {
    await sleep(MOCK_LATENCY_MS);

    mockDriveSettings = {
      ...mockDriveSettings,
      syncInterval: input.syncInterval as SyncInterval,
      updatedAt: new Date().toISOString(),
    };

    return cloneSettings();
  });

export const updateOutputFolder = createServerFn({ method: 'POST' })
  .validator((data: unknown) => updateOutputFolderInput.parse(data))
  .handler(async ({ data: input }: { data: any }): Promise<DriveSettings> => {
    const normalizedPath = input.outputFolder.trim();

    await sleep(MOCK_LATENCY_MS);

    mockDriveSettings = {
      ...mockDriveSettings,
      outputFolder: normalizedPath,
      updatedAt: new Date().toISOString(),
    };

    return cloneSettings();
  });
