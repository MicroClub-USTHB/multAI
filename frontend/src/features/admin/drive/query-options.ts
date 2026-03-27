import { queryOptions } from '@tanstack/react-query';

import { getDriveSettings } from './api';
import { DRIVE_SETTINGS_QUERY_KEY } from './constants';

export const driveSettingsQueryOptions = () =>
  queryOptions({
    queryKey: DRIVE_SETTINGS_QUERY_KEY,
    queryFn: getDriveSettings,
  });
