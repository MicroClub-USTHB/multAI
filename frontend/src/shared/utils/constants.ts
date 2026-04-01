import {
  Bell,
  CloudUpload,
  LayoutDashboard,
  ListChecks,
  Megaphone,
  ScrollText,
  Settings,
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
      title: 'Drive Settings',
      url: '/admin/drive-settings',
      icon: CloudUpload,
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
  secondary: [
    {
      title: 'Settings',
      url: '/admin/settings',
      icon: Settings,
    },
  ],
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
      items: [
        { title: 'MicoCode', url: '/multi/events/micocode' },
        { title: 'HackOPS', url: '/multi/events/hackops' },
        { title: 'Visual Crew', url: '/multi/events/visualcrew' },
      ],
    },
    {
      title: 'Upload & Storage',
      url: '/multi/upload',
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
    {
      title: 'Settings',
      url: '/multi/settings',
      icon: Settings,
    },
  ],
  user: {
    name: 'Staff User',
    avatar: '',
  },
};
