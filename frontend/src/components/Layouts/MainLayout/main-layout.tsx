import type { NavData } from '@/shared/utils/types';

import { AppSidebar } from '@/components/Sidebar';
import { SidebarInset, SidebarProvider } from '@/shared/ui';

import { MultiHeader } from './multi-header';

export default function MainLayout({
  children,
  navData,
}: {
  children: React.ReactNode;
  navData: NavData;
}) {
  return (
    <SidebarProvider className="h-svh overflow-hidden">
      <AppSidebar navData={navData} />
      <SidebarInset className="h-svh overflow-hidden">
        <MultiHeader />
        <main className="flex-1 overflow-y-auto p-4">{children}</main>
      </SidebarInset>
    </SidebarProvider>
  );
}
