import {
  mockAlerts,
  mockEventSummary,
  mockMultiStats,
  mockProcessingJobs,
} from './data';

export function useMultiStats() {
  return {
    data: mockMultiStats,
    isLoading: false,
    error: null,
  };
}

export function useAlerts() {
  return {
    data: mockAlerts,
    isLoading: false,
    error: null,
  };
}

export function useEventSummary() {
  return {
    data: mockEventSummary,
    isLoading: false,
    error: null,
  };
}

export function useProcessingJobs() {
  return {
    data: mockProcessingJobs,
    isLoading: false,
    error: null,
  };
}

export function useMultiDashboard() {
  const statsData = useMultiStats();
  const alertsData = useAlerts();
  const eventSummaryData = useEventSummary();
  const processingJobsData = useProcessingJobs();

  return {
    stats: statsData,
    alerts: alertsData,
    eventSummary: eventSummaryData,
    processingJobs: processingJobsData,
    isLoading:
      statsData.isLoading ||
      alertsData.isLoading ||
      eventSummaryData.isLoading ||
      processingJobsData.isLoading,
    hasError:
      !!statsData.error ||
      !!alertsData.error ||
      !!eventSummaryData.error ||
      !!processingJobsData.error,
  };
}
