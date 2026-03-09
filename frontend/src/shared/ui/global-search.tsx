import {
  Command,
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
  CommandShortcut,
} from '@/shared/ui/command';
import {
  ClipboardPasteIcon,
  CommandIcon,
  CopyIcon,
  FolderPlusIcon,
  HomeIcon,
  Megaphone,
  PlusIcon,
  ScissorsIcon,
  Search,
  SettingsIcon,
  TrashIcon,
  UsersRound,
} from 'lucide-react';
import { useSidebar } from './sidebar';
import { cn } from '../utils/helpers';

export function GlobalSearch({
  open,
  onOpenChange,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  return (
    <div className='flex flex-col gap-4'>
      <CommandDialog open={open} onOpenChange={onOpenChange}>
        <Command>
          <CommandInput placeholder='Type a command or search...' />
          <CommandList>
            <CommandEmpty>No results found.</CommandEmpty>
            <CommandGroup heading='Navigation'>
              <CommandItem>
                <HomeIcon />
                <span>Home</span>
                <CommandShortcut>⌘H</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <Megaphone />
                <span>Events</span>
                <CommandShortcut>⌘E</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <UsersRound />
                <span>Users</span>
                <CommandShortcut>⌘U</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <SettingsIcon />
                <span>Settings</span>
                <CommandShortcut>⌘S</CommandShortcut>
              </CommandItem>
            </CommandGroup>
            <CommandSeparator />
            <CommandGroup heading='Actions'>
              <CommandItem>
                <PlusIcon />
                <span>New Event</span>
                <CommandShortcut>⌘N</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <FolderPlusIcon />
                <span>New Folder</span>
                <CommandShortcut>⇧⌘N</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <CopyIcon />
                <span>Copy</span>
                <CommandShortcut>⌘C</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <ScissorsIcon />
                <span>Cut</span>
                <CommandShortcut>⌘X</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <ClipboardPasteIcon />
                <span>Paste</span>
                <CommandShortcut>⌘V</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <TrashIcon />
                <span>Delete</span>
                <CommandShortcut>⌫</CommandShortcut>
              </CommandItem>
            </CommandGroup>
          </CommandList>
        </Command>
      </CommandDialog>
    </div>
  );
}

interface SearchTriggerProps {
  onClick: () => void;
  className?: string;
}

export function SearchTrigger({ onClick, className }: SearchTriggerProps) {
  const { state } = useSidebar();
  const isCollapsed = state === 'collapsed';

  return (
    <button
      onClick={onClick}
      className={cn(
        'flex items-center gap-2 text-sm text-muted-foreground overflow-hidden',
        'bg-sidebar-accent/50 hover:bg-sidebar-accent rounded-md transition-all duration-200 ease-in-out',
        'border border-border/50 group cursor-pointer',
        // Conditional sizing with smooth transitions
        isCollapsed ? 'w-8 h-8 px-2' : 'w-full px-3 py-2 justify-start',
        className,
      )}
      title='Search (⌘K)'
    >
      <Search className='h-4 w-4 flex-shrink-0 -ml-0.5' />

      {/* Text content with smooth fade and slide animation */}
      <span
        className={cn(
          'flex-1 text-left whitespace-nowrap transition-all duration-200 ease-in-out',
          isCollapsed
            ? 'opacity-0 w-0 -translate-x-2'
            : 'opacity-100 w-auto translate-x-0',
        )}
      >
        Search...
      </span>

      {/* Keyboard shortcut with smooth fade animation */}
      <div
        className={cn(
          'flex items-center gap-1 transition-all duration-200 ease-in-out',
          isCollapsed
            ? 'opacity-0 w-0 -translate-x-2'
            : 'opacity-100 w-auto translate-x-0',
        )}
      >
        <kbd className='inline-flex h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium text-muted-foreground opacity-60 group-hover:opacity-100 transition-opacity'>
          <CommandIcon className='h-2.5 w-2.5' />K
        </kbd>
      </div>
    </button>
  );
}
