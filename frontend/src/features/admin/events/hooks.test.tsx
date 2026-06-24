import { renderHook, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { createQueryWrapper, createTestQueryClient } from '@/test/query-client';

import { useAdminEvents, useCreateAdminEventMutation, useScheduleAdminEventMutation } from './hooks';
import * as api from './api';

vi.mock('./api', () => ({
  archiveAdminEvent: vi.fn(),
  createAdminEvent: vi.fn(),
  draftAdminEvent: vi.fn(),
  listAdminEvents: vi.fn(),
  scheduleAdminEvent: vi.fn(),
}));

const createAdminEventMock = vi.mocked(api.createAdminEvent);
const scheduleAdminEventMock = vi.mocked(api.scheduleAdminEvent);
const listAdminEventsMock = vi.mocked(api.listAdminEvents);

describe('admin events hooks', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('loads events with the expected default params', async () => {
    const queryClient = createTestQueryClient();
    const wrapper = createQueryWrapper(queryClient);

    listAdminEventsMock.mockResolvedValue([
      {
        id: 'event-1',
        name: 'Demo Day',
        eventCode: 'EVT-001',
        eventDate: '2026-06-01T10:00:00.000Z',
        status: 'draft',
        createdBy: 'admin-1',
        createdAt: '2026-05-01T10:00:00.000Z',
        archivedAt: null,
      },
    ]);

    const { result } = renderHook(() => useAdminEvents(), { wrapper });

    await waitFor(() => {
      expect(result.current.events).toHaveLength(1);
    });

    expect(listAdminEventsMock).toHaveBeenCalledWith({
      limit: 50,
      offset: 0,
      status: 'all',
      name: '',
    });
    expect(result.current.events[0]?.name).toBe('Demo Day');
  });

  it('prepends a newly created event into the cache', async () => {
    const params = { limit: 50, offset: 0, status: 'all' as const, name: '' };
    const queryClient = createTestQueryClient();
    const wrapper = createQueryWrapper(queryClient);

    queryClient.setQueryData(['admin', 'events', params], [
      {
        id: 'event-1',
        name: 'Existing event',
        eventCode: 'EVT-000',
        eventDate: '2026-06-01T10:00:00.000Z',
        status: 'draft',
        createdBy: 'admin-1',
        createdAt: '2026-05-01T10:00:00.000Z',
        archivedAt: null,
      },
    ]);

    createAdminEventMock.mockResolvedValue({
      id: 'event-2',
      name: 'New event',
      eventCode: 'EVT-002',
      eventDate: '2026-07-01T10:00:00.000Z',
      status: 'scheduled',
      createdBy: 'admin-1',
      createdAt: '2026-06-01T12:00:00.000Z',
      archivedAt: null,
    });

    const { result } = renderHook(() => useCreateAdminEventMutation(params), {
      wrapper,
    });

    await result.current.mutateAsync({
      name: 'New event',
      eventDate: '2026-07-01T10:00:00.000Z',
      status: 'scheduled',
    });

    expect(createAdminEventMock).toHaveBeenCalledWith({
      name: 'New event',
      eventDate: '2026-07-01T10:00:00.000Z',
      status: 'scheduled',
    });
    expect(
      queryClient.getQueryData([
        'admin',
        'events',
        params,
      ]),
    ).toEqual([
      {
        id: 'event-2',
        name: 'New event',
        eventCode: 'EVT-002',
        eventDate: '2026-07-01T10:00:00.000Z',
        status: 'scheduled',
        createdBy: 'admin-1',
        createdAt: '2026-06-01T12:00:00.000Z',
        archivedAt: null,
      },
      {
        id: 'event-1',
        name: 'Existing event',
        eventCode: 'EVT-000',
        eventDate: '2026-06-01T10:00:00.000Z',
        status: 'draft',
        createdBy: 'admin-1',
        createdAt: '2026-05-01T10:00:00.000Z',
        archivedAt: null,
      },
    ]);
  });

  it('updates an event status inside the cached list', async () => {
    const params = { limit: 50, offset: 0, status: 'all' as const, name: '' };
    const queryClient = createTestQueryClient();
    const wrapper = createQueryWrapper(queryClient);

    queryClient.setQueryData(['admin', 'events', params], [
      {
        id: 'event-1',
        name: 'Existing event',
        eventCode: 'EVT-000',
        eventDate: '2026-06-01T10:00:00.000Z',
        status: 'draft',
        createdBy: 'admin-1',
        createdAt: '2026-05-01T10:00:00.000Z',
        archivedAt: null,
      },
    ]);

    scheduleAdminEventMock.mockResolvedValue({
      id: 'event-1',
      name: 'Existing event',
      eventCode: 'EVT-000',
      eventDate: '2026-06-01T10:00:00.000Z',
      status: 'scheduled',
      createdBy: 'admin-1',
      createdAt: '2026-05-01T10:00:00.000Z',
      archivedAt: null,
    });

    const { result } = renderHook(() => useScheduleAdminEventMutation(params), {
      wrapper,
    });

    await result.current.mutateAsync('event-1');

    expect(scheduleAdminEventMock).toHaveBeenCalledWith('event-1');
    expect(
      queryClient.getQueryData([
        'admin',
        'events',
        params,
      ]),
    ).toEqual([
      {
        id: 'event-1',
        name: 'Existing event',
        eventCode: 'EVT-000',
        eventDate: '2026-06-01T10:00:00.000Z',
        status: 'scheduled',
        createdBy: 'admin-1',
        createdAt: '2026-05-01T10:00:00.000Z',
        archivedAt: null,
      },
    ]);
  });
});
