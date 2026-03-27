import { createServerFn } from '@tanstack/react-start';

import type { DriveSettings, SyncInterval } from './types';

import { SYNC_INTERVALS } from './constants';
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

const assertSyncInterval = (interval: number) => {
  if (!SYNC_INTERVALS.includes(interval as SyncInterval)) {
    throw new Error('Invalid sync interval');
  }
};

export const getDriveSettings = createServerFn({ method: 'GET' }).handler(
  async (): Promise<DriveSettings> => {
    await sleep(MOCK_LATENCY_MS);
    return cloneSettings();
  },
);

export const connectGoogleDrive = createServerFn({ method: 'POST' })
  .inputValidator(connectGoogleDriveInput)
  .handler(async ({ data: input }): Promise<DriveSettings> => {
    const apiKey = input.apiKey.trim();

    if (apiKey.length < 10) {
      throw new Error('API key is too short');
    }

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
  .inputValidator(updateSyncFrequencyInput)
  .handler(async ({ data: input }): Promise<DriveSettings> => {
    assertSyncInterval(input.syncInterval);

    await sleep(MOCK_LATENCY_MS);

    mockDriveSettings = {
      ...mockDriveSettings,
      syncInterval: input.syncInterval as SyncInterval,
      updatedAt: new Date().toISOString(),
    };

    return cloneSettings();
  });

export const updateOutputFolder = createServerFn({ method: 'POST' })
  .inputValidator(updateOutputFolderInput)
  .handler(async ({ data: input }): Promise<DriveSettings> => {
    const normalizedPath = input.outputFolder.trim();

    if (!normalizedPath.startsWith('/')) {
      throw new Error('Output folder must be an absolute path');
    }

    await sleep(MOCK_LATENCY_MS);

    mockDriveSettings = {
      ...mockDriveSettings,
      outputFolder: normalizedPath,
      updatedAt: new Date().toISOString(),
    };

    return cloneSettings();
  });
