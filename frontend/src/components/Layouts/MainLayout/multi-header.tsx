import { Link } from '@tanstack/react-router';
import { Bell } from 'lucide-react';

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
import { Separator } from '@/shared/ui';
import { SidebarTrigger } from '@/shared/ui';

export function MultiHeader() {
  const multiSegments = useBreadcrumbs('/multi');

  return (
    <header className="flex h-16 shrink-0 items-center gap-2 px-4">
      <div className="flex items-center gap-2">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mr-2 data-[orientation=vertical]:h-4"
        />
        <Breadcrumb>
          <BreadcrumbList>
            {multiSegments.length === 0 ? (
              <BreadcrumbItem>
                <BreadcrumbPage>Dashboard</BreadcrumbPage>
              </BreadcrumbItem>
            ) : (
              multiSegments.map((segment, index) => {
                const isLast = index === multiSegments.length - 1;
                const isFirst = index === 0;

                return (
                  <div key={segment.path} className="contents">
                    {index > 0 && <BreadcrumbSeparator />}
                    <BreadcrumbItem
                      className={
                        isFirst && multiSegments.length === 1
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

      <Button variant="ghost" size="icon" className="relative rounded-full">
        <Bell className="h-5 w-5" />
        <span className="bg-destructive absolute top-1 right-1 h-2 w-2 rounded-full"></span>
      </Button>
    </header>
  );
}
