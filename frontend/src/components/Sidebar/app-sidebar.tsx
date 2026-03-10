import * as React from 'react';

import { NavMain, NavSecondary, NavUser } from './index';
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from '@/shared/ui/sidebar';
import type { NavData } from '@/shared/utils/types';
import { Badge } from '@/shared/ui/badge';
import { Link } from '@tanstack/react-router';
import { GlobalSearch, SearchTrigger } from '@/shared/ui/global-search';

export function AppSidebar({
  navData,
  ...props
}: React.ComponentProps<typeof Sidebar> & { navData: NavData }) {
  const [searchOpen, setSearchOpen] = React.useState(false);

  return (
    <>
      <Sidebar variant='inset' {...props}>
        <SidebarHeader>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton size='lg' render={<Link to='/' />}>
                <div className='flex items-center justify-center space-x-2 flex-1 text-sm leading-tight'>
                  <span className='truncate font-medium text-xl'>MultAI</span>
                  {navData.isAdmin && (
                    <Badge variant='secondary' className='truncate text-xs'>
                      Admin
                    </Badge>
                  )}
                </div>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
          <div className='py-2 group-data-[collapsible=icon]:flex group-data-[collapsible=icon]:justify-center'>
            <SearchTrigger onClick={() => setSearchOpen(true)} />
          </div>
        </SidebarHeader>
        <SidebarContent>
          <NavMain items={navData.main} />
          <NavSecondary items={navData.secondary} className='mt-auto' />
        </SidebarContent>
        <SidebarFooter>
          <NavUser user={navData.user} />
        </SidebarFooter>
      </Sidebar>
      <GlobalSearch open={searchOpen} onOpenChange={setSearchOpen} />
    </>
  );
}
