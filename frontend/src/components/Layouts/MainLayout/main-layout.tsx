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
        <main className="app-dots flex-1 overflow-y-auto">
          <div className="mx-auto w-full max-w-[1320px] p-2 md:p-4">{children}</div>
        </main>
      </SidebarInset>
    </SidebarProvider>
  );
}
