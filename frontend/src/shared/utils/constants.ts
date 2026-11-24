import {
  Bell,
  CloudUpload,
  LayoutDashboard,
  ListChecks,
  Megaphone,
  UsersRound,
} from 'lucide-react';

import type { NavData } from './types';

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
