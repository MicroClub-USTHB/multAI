import z from 'zod';

import { SYNC_INTERVALS } from './constants';
import { type SyncInterval } from './types';

export const connectGoogleDriveInput = z.object({
  apiKey: z.string().min(10, 'API key must be at least 10 characters'),
});

export const updateSyncFrequencyInput = z.object({
  syncInterval: z
    .number()
    .refine((val) => SYNC_INTERVALS.includes(val as SyncInterval), {
      message: `Sync interval must be one of: ${SYNC_INTERVALS.join(', ')}`,
    }),
});

export const updateOutputFolderInput = z.object({
  outputFolder: z
    .string()
    .min(1, 'Output folder cannot be empty')
    .refine((val) => val.trim().startsWith('/'), {
      message: 'Output folder must be an absolute path starting with "/"',
    }),
});
