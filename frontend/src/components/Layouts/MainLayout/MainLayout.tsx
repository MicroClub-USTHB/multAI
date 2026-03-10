import type { NavData } from '@/shared/utils/types';
import { AppSidebar } from '@/components/Sidebar';
import { SidebarInset, SidebarProvider } from '@/shared/ui/sidebar';
import { AdminHeader } from './AdminHeader';
import { MultiHeader } from './MultiHeader';

export default function MainLayout({
  children,
  navData,
}: {
  children: React.ReactNode;
  navData: NavData;
}) {
  return (
    <SidebarProvider>
      <AppSidebar navData={navData} />
      <SidebarInset>
        {navData.isAdmin ? <AdminHeader /> : <MultiHeader />}
        <main className='flex-1 p-4'>{children}</main>
      </SidebarInset>
    </SidebarProvider>
  );
}
