import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

vi.mock('@/features/admin/logs/utils', () => ({
  splitTimestamp: () => ['2026-06-01', '10:00'],
}));

vi.mock('./staff-user-actions-menu', () => ({
  StaffUserActionsMenu: ({
    onEdit,
    onDelete,
  }: {
    onEdit: () => void;
    onDelete: () => void;
  }) => (
    <div>
      <button type="button" onClick={onEdit}>
        Edit
      </button>
      <button type="button" onClick={onDelete}>
        Delete
      </button>
    </div>
  ),
}));

import { StaffUsersTable } from './staff-users-table';

describe('StaffUsersTable', () => {
  it('renders staff user rows and action callbacks', () => {
    const user = {
      id: 'staff-1',
      email: 'staff@example.com',
      role: 'admin' as const,
      createdAt: '2026-06-01T10:00:00.000Z',
      updatedAt: '2026-06-01T11:00:00.000Z',
    };
    const onEdit = vi.fn();
    const onDelete = vi.fn();

    render(
      <StaffUsersTable
        users={[user]}
        onEdit={onEdit}
        onDelete={onDelete}
      />,
    );

    expect(screen.getByText('staff@example.com')).toBeTruthy();
    expect(screen.getByText('Admin')).toBeTruthy();
    expect(screen.getAllByText('2026-06-01')).toHaveLength(2);
    expect(screen.getAllByText('10:00')).toHaveLength(2);

    screen.getByRole('button', { name: 'Edit' }).click();
    screen.getByRole('button', { name: 'Delete' }).click();

    expect(onEdit).toHaveBeenCalledWith(user);
    expect(onDelete).toHaveBeenCalledWith(user);
  });
});
