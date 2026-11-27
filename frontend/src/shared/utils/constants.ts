import {
  Bell,
  ChartNoAxesColumn,
  CloudUpload,
  FolderInput,
  HardDrive,
  ListChecks,
  Megaphone,
} from 'lucide-react';

import type { NavData } from './types';

export const MULTI_NAV_LINKS: NavData = {
  main: [
    {
      title: 'Events',
      url: '/multi/events',
      icon: Megaphone,
    },
    {
      title: 'Upload photos',
      url: '/multi/upload',
      icon: CloudUpload,
    },
    {
      title: 'Drop a Drive',
      url: '/multi/drop',
      icon: FolderInput,
      adminOnly: true,
    },
    {
      title: 'Requests',
      url: '/multi/requests',
      icon: ListChecks,
    },
    {
      title: 'Analytics',
      url: '/multi/analytics',
      icon: ChartNoAxesColumn,
    },
    {
      title: 'Drive settings',
      url: '/multi/drive-settings',
      icon: HardDrive,
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
