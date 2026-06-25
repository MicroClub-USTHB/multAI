import { describe, expect, it } from 'vitest';

import {
  getAuthRedirectPath,
  getRoleLandingPath,
  isPathAllowedForRole,
} from './utils';

describe('auth utils', () => {
  it('maps roles to their landing page', () => {
    expect(getRoleLandingPath('admin')).toBe('/admin');
    expect(getRoleLandingPath('multi')).toBe('/multi');
    expect(getRoleLandingPath('multi_team_lead')).toBe('/multi');
    expect(getRoleLandingPath('unknown')).toBe('/admin');
  });

  it('checks role access against route prefixes', () => {
    expect(isPathAllowedForRole('/admin/users', 'admin')).toBe(true);
    expect(isPathAllowedForRole('/multi/team', 'admin')).toBe(false);
    expect(isPathAllowedForRole('/multi/team', 'multi')).toBe(true);
    expect(isPathAllowedForRole('/multi/team', 'multi_team_lead')).toBe(true);
  });

  it('uses the redirect only when it matches the role scope', () => {
    expect(
      getAuthRedirectPath({
        role: 'admin',
        redirect: '/admin/events',
      }),
    ).toBe('/admin/events');

    expect(
      getAuthRedirectPath({
        role: 'multi',
        redirect: '/admin/events',
      }),
    ).toBe('/multi');

    expect(
      getAuthRedirectPath({
        role: 'multi',
        redirect: 'admin/events',
      }),
    ).toBe('/multi');
  });
});
