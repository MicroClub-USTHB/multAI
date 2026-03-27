import { queryOptions } from '@tanstack/react-query';

import { getDriveSettings } from './api';

export const driveSettingsQueryOptions = () =>
  queryOptions({
    queryKey: ['driveSettings'],
    queryFn: getDriveSettings,
  });
