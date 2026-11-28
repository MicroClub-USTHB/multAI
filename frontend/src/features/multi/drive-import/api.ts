import { apiPost } from '@/shared/utils/api-client';

import type {
  DriveImportInput,
  DriveImportResponseDto,
  DriveImportResult,
} from './types';

import { toDriveImportResult } from './types';

export async function importDriveUrls(
  input: DriveImportInput,
): Promise<DriveImportResult> {
  const response = await apiPost<DriveImportResponseDto, DriveImportInput>(
    '/staff/drive/import-urls',
    input,
    {
      credentials: 'include',
      fallbackErrorMessage: 'Unable to import Drive files.',
    },
  );

  return toDriveImportResult(response);
}
