import { renderHook, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { createQueryWrapper, createTestQueryClient } from '@/test/query-client';

import { useCreateStaffUserMutation, useStaffUsers } from './hooks';
import * as api from './api';

vi.mock('./api', () => ({
  createStaffUser: vi.fn(),
  deleteStaffUser: vi.fn(),
  listStaffUsers: vi.fn(),
  updateStaffUser: vi.fn(),
}));

const listStaffUsersMock = vi.mocked(api.listStaffUsers);
const createStaffUserMock = vi.mocked(api.createStaffUser);

describe('staff-users hooks', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('loads staff users with the expected query params', async () => {
    const queryClient = createTestQueryClient();
    const wrapper = createQueryWrapper(queryClient);

    listStaffUsersMock.mockResolvedValue([
      {
        id: 'staff-1',
        email: 'staff@example.com',
        role: 'admin',
        createdAt: '2026-06-01T10:00:00.000Z',
        updatedAt: '2026-06-01T11:00:00.000Z',
      },
    ]);

    const { result } = renderHook(() => useStaffUsers(), { wrapper });

    await waitFor(() => {
      expect(result.current.users).toHaveLength(1);
    });

    expect(listStaffUsersMock).toHaveBeenCalledWith({
      limit: 20,
      offset: 0,
      sortBy: 'created_at',
      sortDirection: 'desc',
    });
    expect(result.current.users[0]?.email).toBe('staff@example.com');
  });

  it('invalidates the staff users list after creating a user', async () => {
    const queryClient = createTestQueryClient();
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');
    const wrapper = createQueryWrapper(queryClient);

    createStaffUserMock.mockResolvedValue({
      id: 'staff-2',
      email: 'new@example.com',
      role: 'multi',
      createdAt: '2026-06-02T10:00:00.000Z',
      updatedAt: '2026-06-02T10:00:00.000Z',
    });

    const { result } = renderHook(() => useCreateStaffUserMutation(), {
      wrapper,
    });

    await result.current.mutateAsync({
      email: 'new@example.com',
      password: 'secret',
      role: 'multi',
    });

    expect(createStaffUserMock).toHaveBeenCalledWith({
      email: 'new@example.com',
      password: 'secret',
      role: 'multi',
    });
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: ['admin', 'staff-users'],
    });
  });
});
