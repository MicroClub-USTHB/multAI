import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const isItemActive = (href: string, pathname: string) => {
  if (href === '/multi') {
    return pathname === href;
  }
  return pathname === href || pathname.startsWith(href + '/');
};

export const getInitials = (name: string) => {
  const names = name.split(' ');
  const initials = names.map((n) => n.charAt(0).toUpperCase()).join('');
  return initials.slice(0, 2);
};
