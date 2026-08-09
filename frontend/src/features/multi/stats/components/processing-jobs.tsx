import { Star } from 'lucide-react';

import { Badge, Card, CardContent, CardHeader, CardTitle, Separator } from '@/shared/ui';

import type { ProcessingJob } from '../types';

import { useProcessingJobs } from '../hooks';

function formatJobName(job: ProcessingJob) {
  return `${job.eventId}/${job.photoId}`;
}

function formatJobTime(job: ProcessingJob) {
  const date = job.completedAt ?? job.startedAt;

  if (!date) {
    return '--:--';
  }

  return date.toLocaleTimeString([], {
    hour: 'numeric',
    minute: '2-digit',
  });
}

function getStatusLabel(status: ProcessingJob['status']) {
  if (status === 'completed') {
    return 'Processed';
  }

  if (status === 'queued') {
    return 'In queue';
  }

  if (status === 'processing') {
    return 'Processing';
  }

  return 'Failed';
}

function getStatusVariant(
  status: ProcessingJob['status']
): 'secondary' | 'destructive' | 'outline' {
  if (status === 'completed') {
    return 'secondary';
  }

  if (status === 'failed') {
    return 'destructive';
  }

  return 'outline';
}

function getStatusClassName(status: ProcessingJob['status']) {
  if (status === 'completed') {
    return 'border-transparent bg-emerald-500/20 text-emerald-400';
  }

  if (status === 'queued') {
    return 'border-transparent bg-red-500/20 text-red-400';
  }

  if (status === 'processing') {
    return 'border-transparent bg-amber-500/20 text-amber-300';
  }

  return '';
}

export function ProcessingJobs() {
  const { data, isLoading } = useProcessingJobs();

  if (isLoading) {
    return (
      <Card className='border-sidebar-border'>
        <CardHeader>
          <CardTitle className='text-lg font-semibold tracking-tight'>
            Recent processing jobs
          </CardTitle>
        </CardHeader>
        <CardContent className='space-y-3'>
          {Array.from({ length: 5 }).map((_, index) => (
            <div key={index} className='space-y-3'>
              <div className='h-5 w-full animate-pulse rounded bg-sidebar-accent/40' />
              {index < 4 ? <Separator className='bg-sidebar-border/60' /> : null}
            </div>
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className='border-sidebar-border'>
      <CardHeader>
        <CardTitle className='text-lg font-semibold tracking-tight'>
          Recent processing jobs
        </CardTitle>
      </CardHeader>
      <CardContent className='space-y-3'>
        {data.map((job, index) => (
          <div key={job.id} className='space-y-3'>
            <div className='flex items-center gap-3 text-sidebar-foreground'>
              <Star className='h-5 w-5 text-purple-300/90' />
              <p className='flex-1 truncate text-base font-medium leading-none'>
                {formatJobName(job)}
              </p>
              <Badge
                variant={getStatusVariant(job.status)}
                className={`h-7 rounded-md px-2.5 text-xs font-medium ${getStatusClassName(job.status)}`}
              >
                {getStatusLabel(job.status)}
              </Badge>
              <p className='min-w-18 text-right text-sm text-purple-200/70'>
                {formatJobTime(job)}
              </p>
            </div>
            {index < data.length - 1 ? (
              <Separator className='bg-sidebar-border/70' />
            ) : null}
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
