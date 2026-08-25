import {
  Bell,
  CloudUpload,
  LayoutDashboard,
  ListChecks,
  Megaphone,
  ScrollText,
  UsersRound,
} from 'lucide-react';

import type { NavData } from './types';

export const ADMIN_NAV_DATA: NavData = {
  isAdmin: true,
  main: [
    {
      title: 'Dashboard',
      url: '/admin',
      icon: LayoutDashboard,
    },
    {
      title: 'Events',
      url: '/admin/events',
      icon: Megaphone,
    },
    {
      title: 'Users',
      url: '/admin/users',
      icon: UsersRound,
    },
    {
      title: 'Logs',
      url: '/admin/logs',
      icon: ScrollText,
    },
  ],
  secondary: [],
  user: {
    name: 'Admin User',
    avatar: '',
  },
};
export const MULTI_NAV_LINKS: NavData = {
  main: [
    {
      title: 'Dashboard',
      url: '/multi',
      icon: LayoutDashboard,
    },
    {
      title: 'Events',
      url: '/multi/events',
      icon: Megaphone,
    },
    {
      title: 'Upload & Storage',
      url: '/multi/upload',
      icon: CloudUpload,
    },
    {
      title: 'Drive Settings',
      url: '/multi/drive-settings',
      icon: CloudUpload,
    },
    {
      title: 'Requests',
      url: '/multi/requests',
      icon: ListChecks,
    },
    {
      title: 'Team Management',
      url: '/multi/team',
      icon: UsersRound,
    },
  ],
  secondary: [
    {
      title: 'Notifications',
      url: '/multi/notifications',
      icon: Bell,
    },
  ],
  user: {
    name: 'Staff User',
    avatar: '',
  },
};
