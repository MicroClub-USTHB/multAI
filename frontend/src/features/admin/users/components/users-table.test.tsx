import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import type { AdminUser } from '../types';

import { UsersTable } from './users-table';

vi.mock('./user-actions-menu', () => ({
  UserActionsMenu: ({
    onViewDetails,
    onEdit,
    onDelete,
    onToggleBlocked,
  }: {
    onViewDetails: () => void;
    onEdit: () => void;
    onDelete: () => void;
    onToggleBlocked: () => void;
  }) => (
    <div>
      <button type="button" onClick={onViewDetails}>
        view
      </button>
      <button type="button" onClick={onEdit}>
        edit
      </button>
      <button type="button" onClick={onDelete}>
        delete
      </button>
      <button type="button" onClick={onToggleBlocked}>
        toggle
      </button>
    </div>
  ),
}));

const user: AdminUser = {
  id: 'user-1',
  email: 'jane@example.com',
  displayName: 'Jane Doe',
  blocked: false,
  createdAt: '2026-06-01T10:00:00.000Z',
  updatedAt: '2026-06-01T11:00:00.000Z',
};

describe('UsersTable', () => {
  it('renders users and forwards row actions', () => {
    const onViewDetails = vi.fn();
    const onEdit = vi.fn();
    const onDelete = vi.fn();
    const onToggleBlocked = vi.fn();

    render(
      <UsersTable
        users={[user]}
        onViewDetails={onViewDetails}
        onEdit={onEdit}
        onDelete={onDelete}
        onToggleBlocked={onToggleBlocked}
      />,
    );

    expect(screen.getByText('jane@example.com')).toBeTruthy();
    expect(screen.getByText('Jane Doe')).toBeTruthy();
    expect(screen.getByText('Active')).toBeTruthy();

    fireEvent.click(screen.getByText('view'));
    fireEvent.click(screen.getByText('edit'));
    fireEvent.click(screen.getByText('delete'));
    fireEvent.click(screen.getByText('toggle'));

    expect(onViewDetails).toHaveBeenCalledWith(user);
    expect(onEdit).toHaveBeenCalledWith(user);
    expect(onDelete).toHaveBeenCalledWith(user);
    expect(onToggleBlocked).toHaveBeenCalledWith(user);
  });
});
