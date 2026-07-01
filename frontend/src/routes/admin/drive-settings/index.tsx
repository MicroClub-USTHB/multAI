import { createFileRoute, useNavigate } from '@tanstack/react-router';
import { useEffect } from 'react';

import { LoadingPage } from '@/shared/ui/loading';

export const Route = createFileRoute('/admin/drive-settings/')({
  component: RouteComponent,
});

function RouteComponent() {
  const navigate = useNavigate();

  useEffect(() => {
    navigate({ to: '/multi/drive-settings', replace: true });
  }, [navigate]);

  return <LoadingPage message="Redirecting to drive settings..." />;
}
