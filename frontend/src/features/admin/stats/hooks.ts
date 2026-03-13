import { mockDriveUsage, mockAdminStats, mockAlerts, mockProcessingLoad } from "./types"

export function useDriveUsage() {
  // Pour l'instant retourne mock data apres api calls 
  return {
    data: mockDriveUsage,
    isLoading: false,
    error: null
  }
}

export function useAdminStats() {
    // same comme l'autre 
  return {
    data: mockAdminStats,
    isLoading: false,
    error: null
  }
}

export function useAlerts(){
  return {
    data: mockAlerts,
    isLoading: false,
    error: null
  }
}

export function useProcessingLoad() {
  return {
    data: mockProcessingLoad,
    isLoading: false,
    error: null
  }
}

export function useAdminDashboard() {
  const driveData = useDriveUsage()
  const statsData = useAdminStats()
  const alertsData = useAlerts()
  const processingLoadData = useProcessingLoad()
  return {
    drive: driveData,
    stats: statsData,
    alerts: alertsData,
    processingLoad: processingLoadData,
    isLoading: driveData.isLoading || statsData.isLoading || alertsData.isLoading || processingLoadData.isLoading,
    hasError: !!driveData.error || !!statsData.error || !!alertsData.error || !!processingLoadData.error
  }
}