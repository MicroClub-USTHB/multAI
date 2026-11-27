import { createFileRoute, Link } from '@tanstack/react-router';

import { Button } from '@/shared/ui';

export const Route = createFileRoute('/')({ component: App });

function App() {
  return (
    <div className="space-x-4 p-8">
      <Link to="/multi">
        <Button>Dashboard</Button>
      </Link>
    </div>
  );
}
