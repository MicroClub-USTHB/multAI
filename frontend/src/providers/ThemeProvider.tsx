import { ThemeProviderContext, type ThemeMode } from '@/hooks/useTheme';
import { useEffect, useState } from 'react';

type ThemeProviderProps = {
  children: React.ReactNode;
  defaultTheme?: ThemeMode;
  storageKey?: string;
};

function getInitialMode(): ThemeMode {
  if (typeof window === 'undefined') {
    return 'system';
  }

  const stored = window.localStorage.getItem('theme');
  if (stored === 'light' || stored === 'dark' || stored === 'system') {
    return stored;
  }

  return 'system';
}

function applyThemeMode(mode: ThemeMode) {
  if (typeof window === 'undefined') {
    return;
  }
  
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const resolved = mode === 'system' ? (prefersDark ? 'dark' : 'light') : mode;

  document.documentElement.classList.remove('light', 'dark');
  document.documentElement.classList.add(resolved);

  if (mode === 'system') {
    document.documentElement.removeAttribute('data-theme');
  } else {
    document.documentElement.setAttribute('data-theme', mode);
  }

  document.documentElement.style.colorScheme = resolved;
}

export function ThemeProvider({
  children,
  defaultTheme = 'system',
  storageKey = 'vite-ui-theme',
  ...props
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<ThemeMode>(defaultTheme);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const initialMode = getInitialMode();
    setTheme(initialMode);
    applyThemeMode(initialMode);
  }, []);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    if (theme !== 'system') {
      return;
    }

    const media = window.matchMedia('(prefers-color-scheme: dark)');
    const onChange = () => applyThemeMode('system');

    media.addEventListener('change', onChange);
    return () => {
      media.removeEventListener('change', onChange);
    };
  }, [theme]);

  function toggleTheme() {
    if (typeof window === 'undefined') return;
    
    const nextMode: ThemeMode = theme === 'light' ? 'dark' : 'light';
    setTheme(nextMode);
    applyThemeMode(nextMode);
    window.localStorage.setItem('theme', nextMode);
  }

  const value = {
    theme,
    setTheme: (theme: ThemeMode) => {
      if (typeof window !== 'undefined') {
        localStorage.setItem(storageKey, theme);
      }
      setTheme(theme);
    },
    toggleTheme,
  };

  return (
    <ThemeProviderContext.Provider {...props} value={value}>
      {children}
    </ThemeProviderContext.Provider>
  );
}
