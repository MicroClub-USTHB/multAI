import { render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EventsTable } from './events-table';

describe('EventsTable', () => {
  beforeEach(() => {
    vi.spyOn(Date.prototype, 'toLocaleString').mockReturnValue('01 juin 2026, 10:00');
  });

  it('renders event rows and status labels', () => {
    const event = {
      id: 'event-1',
      name: 'Demo Day',
      eventCode: 'EVT-001',
      eventDate: '2026-06-01T10:00:00.000Z',
      status: 'scheduled' as const,
      createdBy: 'admin-1',
      createdAt: '2026-05-01T10:00:00.000Z',
      archivedAt: null,
    };
    const onStatusChange = vi.fn();

    render(<EventsTable events={[event]} onStatusChange={onStatusChange} />);

    expect(screen.getByText('Demo Day')).toBeTruthy();
    expect(screen.getByText('EVT-001')).toBeTruthy();
    expect(screen.getAllByText('01 juin 2026, 10:00')).toHaveLength(2);
    expect(screen.getByText('Scheduled')).toBeTruthy();
  });
});
