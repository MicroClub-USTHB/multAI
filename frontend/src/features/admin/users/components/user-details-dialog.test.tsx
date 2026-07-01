import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

vi.mock('../hooks', () => ({
  useAdminUserQuery: () => ({
    data: {
      id: 'user-1',
      email: 'jane@example.com',
      displayName: 'Jane Doe',
      blocked: false,
      createdAt: '2026-06-01T10:00:00.000Z',
      updatedAt: '2026-06-01T11:00:00.000Z',
    },
    isLoading: false,
    isError: false,
    error: null,
  }),
}));

vi.mock('@/features/admin/logs/utils', () => ({
  splitTimestamp: () => ['2026-06-01', '10:00'],
}));

import { UserDetailsDialog } from './user-details-dialog';

describe('UserDetailsDialog', () => {
  it('renders the selected user details', () => {
    render(
      <UserDetailsDialog
        userId="user-1"
        open
        onOpenChange={() => undefined}
      />,
    );

    expect(
      screen.getByRole('heading', { name: 'jane@example.com' }),
    ).toBeTruthy();
    expect(screen.getAllByText('jane@example.com')).toHaveLength(2);
    expect(screen.getByText('Jane Doe')).toBeTruthy();
    expect(screen.getByText('Active')).toBeTruthy();
    expect(screen.getByText('user-1')).toBeTruthy();
  });
});
