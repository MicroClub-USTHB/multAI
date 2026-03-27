import type z from 'zod';

import {
  connectGoogleDriveInput,
  updateSyncFrequencyInput,
  updateOutputFolderInput,
} from './schemas';

export const SYNC_INTERVALS = [5, 10, 15, 30, 60] as const;

export type SyncInterval = (typeof SYNC_INTERVALS)[number];

export interface DriveSettings {
  isConnected: boolean;
  syncInterval: SyncInterval;
  outputFolder: string;
  connectedAt: string | null;
  updatedAt: string;
}

export type ConnectGoogleDriveInput = z.infer<typeof connectGoogleDriveInput>;

export type UpdateSyncFrequencyInput = z.infer<typeof updateSyncFrequencyInput>;

export type UpdateOutputFolderInput = z.infer<typeof updateOutputFolderInput>;
