import { api } from '@/shared/api/client'

import type { DriveDropInput, DriveDropResult } from './types'

export function dropDriveFolder(input: DriveDropInput) {
  return api.post<DriveDropResult>('/staff/drive/drop', input)
}
