import { Link } from '@tanstack/react-router';
import * as React from 'react';

import type { NavData } from '@/shared/utils/types';

import { useAuth } from '@/hooks/useAuth';
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
  const { user } = useAuth();

  const userLabel = user?.email?.trim() || 'Multi member';

  const userSubtitle =
    user?.role === 'admin'
      ? 'Admin'
      : user?.role === 'multi_team_lead'
        ? 'Multi team lead'
        : user?.role === 'multi'
          ? 'Multi member'
          : 'Multi member';

  return (
    <>
      <Sidebar variant="inset" {...props}>
        <SidebarHeader>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton size="lg" render={<Link to="/" />}>
                <div className="flex flex-1 items-center justify-center space-x-4 text-sm leading-tight">
                  <span className="truncate text-xl font-medium">MultAI</span>
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
          <NavUser
            user={{
              name: userLabel,
              subtitle: userSubtitle,
              avatar: navData.user.avatar,
            }}
          />
        </SidebarFooter>
      </Sidebar>
      <GlobalSearch open={searchOpen} onOpenChange={setSearchOpen} />
    </>
  );
}
