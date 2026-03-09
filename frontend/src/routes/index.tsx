import { Button } from '@/shared/ui/button';
import { createFileRoute, Link } from '@tanstack/react-router';

export const Route = createFileRoute('/')({ component: App });

function App() {
  return (
    <div className='p-8 space-x-4'>
      <Link to='/admin'>
        <Button variant='secondary'>Admin Dashboard</Button>
      </Link>
      <Link to='/multi'>
        <Button>Multi Dashboard</Button>
      </Link>
    </div>
  );
}
