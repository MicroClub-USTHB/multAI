import { Moon, Sun } from 'lucide-react';

import { useTheme } from '@/hooks/use-theme';
import { Button } from '@/shared/ui/button';

export function ThemeToggle() {
  const { toggleTheme } = useTheme();

  return (
    <Button onClick={toggleTheme} variant="ghost" size="icon">
      <Sun className="h-[1.2rem] w-[1.2rem] scale-100 rotate-0 transition-all dark:scale-0 dark:-rotate-90" />
      <Moon className="absolute h-[1.2rem] w-[1.2rem] scale-0 rotate-90 transition-all dark:scale-100 dark:rotate-0" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  );
}
