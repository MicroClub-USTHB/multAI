import { createFileRoute, Link } from '@tanstack/react-router';

import { Button } from '@/shared/ui/button';

export const Route = createFileRoute('/')({ component: App });

function App() {
  return (
    <div className="space-x-4 p-8">
      <Link to="/admin">
        <Button variant="secondary">Admin Dashboard</Button>
      </Link>
      <Link to="/multi">
        <Button>Multi Dashboard</Button>
      </Link>
    </div>
  );
}
