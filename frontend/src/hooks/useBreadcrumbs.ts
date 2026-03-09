import { useMatches } from '@tanstack/react-router';

export interface BreadcrumbSegment {
  path: string;
  label: string;
}

/**
 * Generate breadcrumb segments from the current route path
 * @param pathPrefix - Optional prefix to filter segments (e.g., '/admin', '/multi')
 * @returns Array of breadcrumb segments with path and label
 */
export function useBreadcrumbs(pathPrefix?: string): BreadcrumbSegment[] {
  const matches = useMatches();
  const currentRoute = matches[matches.length - 1];

  // Parse the route path to create breadcrumb segments
  let finalSegments: BreadcrumbSegment[] = [];
  const pathSegments = currentRoute.pathname
    .split('/')
    .filter(Boolean)
    .map((segment, index, arr) => {
      const path = '/' + arr.slice(0, index + 1).join('/');
      const label = segment.charAt(0).toUpperCase() + segment.slice(1);
      return { path, label };
    });

  if (currentRoute.pathname === pathPrefix + '/') {
    finalSegments = [...pathSegments, { path: '', label: 'Dashboard' }];
  }

  // Filter segments if a prefix is provided
  if (pathPrefix) {
    finalSegments = pathSegments.filter((seg) =>
      seg.path.startsWith(pathPrefix),
    );
  }
  const [first, ...rest] = finalSegments;
  return rest;
}
