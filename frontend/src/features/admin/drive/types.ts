export const SYNC_INTERVALS = [5, 10, 15, 30, 60] as const;

export type SyncInterval = (typeof SYNC_INTERVALS)[number];

export interface DriveSettings {
  isConnected: boolean;
  syncInterval: SyncInterval;
  outputFolder: string;
  connectedAt: string | null;
  updatedAt: string;
}

export interface ConnectGoogleDriveInput {
  apiKey: string;
}

export interface UpdateSyncFrequencyInput {
  syncInterval: SyncInterval;
}

export interface UpdateOutputFolderInput {
  outputFolder: string;
}
