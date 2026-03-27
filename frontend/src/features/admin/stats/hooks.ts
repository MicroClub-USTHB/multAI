import { useSuspenseQuery } from '@tanstack/react-query';

import {
  adminStatsQueryOptions,
  alertsQueryOptions,
  driveUsageQueryOptions,
  processingLoadQueryOptions,
} from './query-options';

export function useDriveUsage() {
  return useSuspenseQuery(driveUsageQueryOptions());
}

export function useAdminStats() {
  return useSuspenseQuery(adminStatsQueryOptions());
}

export function useAlerts() {
  return useSuspenseQuery(alertsQueryOptions());
}

export function useProcessingLoad() {
  return useSuspenseQuery(processingLoadQueryOptions());
}

export function useAdminDashboard() {
  const driveData = useDriveUsage();
  const statsData = useAdminStats();
  const alertsData = useAlerts();
  const processingLoadData = useProcessingLoad();

  return {
    drive: driveData,
    stats: statsData,
    alerts: alertsData,
    processingLoad: processingLoadData,
  };
}
