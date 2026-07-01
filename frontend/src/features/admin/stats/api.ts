import { createServerFn } from '@tanstack/react-start';

import { apiGet } from '@/shared/utils/api-client';

import {
  type AdminStatsData,
  type AdminStatsResponse,
  type AlertData,
  type AlertResponse,
  type DriveUsage,
  type DriveUsageResponse,
  type ProcessingLoad,
  transformAdminStatsResponse,
  transformAlertsResponse,
  transformDriveUsageResponse,
} from './types';

export const getDriveUsage = createServerFn({ method: 'GET' }).handler(
  async (): Promise<DriveUsage> => {
    const response = await apiGet<DriveUsageResponse>('/admin/stats/storage');
    return transformDriveUsageResponse(response);
  },
);

export const getAdminStats = createServerFn({ method: 'GET' }).handler(
  async (): Promise<AdminStatsData> => {
    const response = await apiGet<AdminStatsResponse>('/admin/stats/dashboard');
    return transformAdminStatsResponse(response);
  },
);

export const getAlerts = createServerFn({ method: 'GET' }).handler(
  async (): Promise<AlertData> => {
    const response = await apiGet<AlertResponse>('/admin/stats/alerts');
    return transformAlertsResponse(response);
  },
);

export const getProcessingLoad = createServerFn({ method: 'GET' }).handler(
  async (): Promise<ProcessingLoad> => {
    // No transformation needed, the schema matches exactly
    return apiGet<ProcessingLoad>('/admin/stats/processing-load');
  },
);
