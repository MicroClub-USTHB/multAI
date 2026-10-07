import { render } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { AuthContext, useAuth } from '@/hooks/useAuth';

function Probe() {
  useAuth();
  return null;
}

describe('useAuth', () => {
  it('throws when used outside AuthProvider', () => {
    expect(() => render(<Probe />)).toThrow(
      'useAuth must be used within an AuthProvider',
    );
  });

  it('reads the auth context when provided', () => {
    const value = {
      user: null,
      isAuthenticated: false,
      isLoading: false,
      logout: {} as never,
    };

    function ContextProbe() {
      const auth = useAuth();
      return <span>{auth.isAuthenticated ? 'yes' : 'no'}</span>;
    }

    const { getByText } = render(
      <AuthContext.Provider value={value}>
        <ContextProbe />
      </AuthContext.Provider>,
    );

    expect(getByText('no')).toBeTruthy();
  });
});
