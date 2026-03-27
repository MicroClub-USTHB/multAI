import { queryOptions } from '@tanstack/react-query';

import {
  getAdminStats,
  getAlerts,
  getDriveUsage,
  getProcessingLoad,
} from './api';
import {
  ADMIN_ALERTS_QUERY_KEY,
  ADMIN_DRIVE_USAGE_QUERY_KEY,
  ADMIN_PROCESSING_LOAD_QUERY_KEY,
  ADMIN_STATS_QUERY_KEY,
} from './constants';

export const adminStatsQueryOptions = () =>
  queryOptions({
    queryKey: ADMIN_STATS_QUERY_KEY,
    queryFn: getAdminStats,
  });

export const driveUsageQueryOptions = () =>
  queryOptions({
    queryKey: ADMIN_DRIVE_USAGE_QUERY_KEY,
    queryFn: getDriveUsage,
  });

export const alertsQueryOptions = () =>
  queryOptions({
    queryKey: ADMIN_ALERTS_QUERY_KEY,
    queryFn: getAlerts,
  });

export const processingLoadQueryOptions = () =>
  queryOptions({
    queryKey: ADMIN_PROCESSING_LOAD_QUERY_KEY,
    queryFn: getProcessingLoad,
  });
