import { Link } from '@tanstack/react-router';
import { Bell, Search } from 'lucide-react';

import { useBreadcrumbs } from '@/hooks/use-breadcrumbs';
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/shared/ui';
import { Button } from '@/shared/ui';
import { Input } from '@/shared/ui';
import { Separator } from '@/shared/ui';
import { SidebarTrigger } from '@/shared/ui';

export function AdminHeader() {
  const adminSegments = useBreadcrumbs('/admin');

  return (
    <header className="bg-background/95 supports-[backdrop-filter]:bg-background/60 sticky top-0 z-20 flex h-16 shrink-0 items-center gap-2 border-b px-4 backdrop-blur">
      <div className="flex items-center gap-2">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mr-2 data-[orientation=vertical]:h-4"
        />
        <Breadcrumb>
          <BreadcrumbList>
            {adminSegments.length === 0 ? (
              <BreadcrumbItem>
                <BreadcrumbPage>Dashboard</BreadcrumbPage>
              </BreadcrumbItem>
            ) : (
              adminSegments.map((segment, index) => {
                const isLast = index === adminSegments.length - 1;
                const isFirst = index === 0;

                return (
                  <div key={segment.path} className="contents">
                    {index > 0 && <BreadcrumbSeparator />}
                    <BreadcrumbItem
                      className={
                        isFirst && adminSegments.length === 1
                          ? ''
                          : 'hidden md:block'
                      }
                    >
                      {isLast ? (
                        <BreadcrumbPage>{segment.label}</BreadcrumbPage>
                      ) : (
                        <BreadcrumbLink render={<Link to={segment.path} />}>
                          {segment.label}
                        </BreadcrumbLink>
                      )}
                    </BreadcrumbItem>
                  </div>
                );
              })
            )}
          </BreadcrumbList>
        </Breadcrumb>
      </div>

      <div className="relative ml-auto max-w-md flex-1">
        <Search className="text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2" />
        <Input placeholder="Search..." className="h-9 pl-10" />
      </div>

      <Button variant="ghost" size="icon" className="relative rounded-full">
        <Bell className="h-5 w-5" />
        <span className="bg-destructive absolute top-1 right-1 h-2 w-2 rounded-full"></span>
      </Button>
    </header>
  );
}
