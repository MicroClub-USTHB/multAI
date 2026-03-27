import { Link } from '@tanstack/react-router';
import * as React from 'react';

import type { NavData } from '@/shared/utils/types';

import { Badge } from '@/shared/ui';
import { GlobalSearch } from '@/shared/ui';
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from '@/shared/ui';

import {
  NavMain,
  NavSecondary,
  NavUser,
} from '../../../components/Sidebar/index';

export function AppSidebar({
  navData,
  ...props
}: React.ComponentProps<typeof Sidebar> & { navData: NavData }) {
  const [searchOpen, setSearchOpen] = React.useState(false);

  return (
    <>
      <Sidebar variant="inset" {...props}>
        <SidebarHeader>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton size="lg" render={<Link to="/" />}>
                <div className="flex flex-1 items-center justify-center space-x-4 text-sm leading-tight">
                  <span className="truncate text-xl font-medium">MultAI</span>
                  {navData.isAdmin && (
                    <Badge variant="secondary" className="truncate text-xs">
                      Admin
                    </Badge>
                  )}
                </div>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarHeader>
        <SidebarContent>
          <NavMain items={navData.main} />
          <NavSecondary items={navData.secondary} className="mt-auto" />
        </SidebarContent>
        <SidebarFooter>
          <NavUser user={navData.user} />
        </SidebarFooter>
      </Sidebar>
      <GlobalSearch open={searchOpen} onOpenChange={setSearchOpen} />
    </>
  );
}
