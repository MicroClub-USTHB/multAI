export type AppRole = 'admin' | 'multi' | 'multi_team_lead';

export const getRoleLandingPath = (role?: string | null) => {
  if (role === 'admin') {
    return '/admin';
  }

  if (role === 'multi' || role === 'multi_team_lead') {
    return '/multi';
  }

  return '/admin';
};

export const isPathAllowedForRole = (path: string, role?: string | null) => {
  if (role === 'admin') {
    return path === '/admin' || path.startsWith('/admin/');
  }

  if (role === 'multi' || role === 'multi_team_lead') {
    return path === '/multi' || path.startsWith('/multi/');
  }

  return false;
};

export const getAuthRedirectPath = ({
  redirect,
  role,
}: {
  redirect?: string | null;
  role?: string | null;
}) => {
  const landingPath = getRoleLandingPath(role);

  if (!redirect?.startsWith('/')) {
    return landingPath;
  }

  return isPathAllowedForRole(redirect, role) ? redirect : landingPath;
};
