import { queryOptions } from '@tanstack/react-query'

import { listAdminUsers } from './api'
import { ADMIN_USERS_QUERY_KEY } from './constants'

export const adminUsersQueryOptions = () =>
  queryOptions({
    queryKey: ADMIN_USERS_QUERY_KEY,
    queryFn: () => listAdminUsers(),
  })
