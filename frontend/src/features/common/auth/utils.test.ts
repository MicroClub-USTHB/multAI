import { describe, expect, it } from 'vitest';

import {
  getAuthRedirectPath,
  getRoleLandingPath,
  isPathAllowedForRole,
} from './utils';

describe('auth utils', () => {
  it('sends every role to the multi dashboard', () => {
    expect(getRoleLandingPath('admin')).toBe('/multi');
    expect(getRoleLandingPath('multi')).toBe('/multi');
    expect(getRoleLandingPath('multi_team_lead')).toBe('/multi');
    expect(getRoleLandingPath('unknown')).toBe('/multi');
  });

  it('allows staff roles on multi routes only', () => {
    expect(isPathAllowedForRole('/multi/team', 'admin')).toBe(true);
    expect(isPathAllowedForRole('/multi/team', 'multi')).toBe(true);
    expect(isPathAllowedForRole('/multi/team', 'multi_team_lead')).toBe(true);
    expect(isPathAllowedForRole('/admin/users', 'admin')).toBe(false);
    expect(isPathAllowedForRole('/multi/team', 'unknown')).toBe(false);
  });

  it('uses the redirect only when it is an allowed multi path', () => {
    expect(
      getAuthRedirectPath({ role: 'multi', redirect: '/multi/team' }),
    ).toBe('/multi/team');
    expect(
      getAuthRedirectPath({ role: 'multi', redirect: '/admin/events' }),
    ).toBe('/multi');
    expect(
      getAuthRedirectPath({ role: 'multi', redirect: 'multi/team' }),
    ).toBe('/multi');
  });
});
