import contentCollections from '@content-collections/vite'
import tailwindcss from '@tailwindcss/vite'
import { devtools } from '@tanstack/devtools-vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'
import { defineConfig, loadEnv } from 'vite'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const apiProxyTarget = env.VITE_API_PROXY_TARGET
  const stripSecureFromAuthCookies = (cookie: string) =>
    cookie
      .replace(/;\s*Secure/gi, '')
      .replace(/SameSite=Strict/gi, 'SameSite=Lax')

  return {
    plugins: [
      devtools(),
      contentCollections(),
      tsconfigPaths({ projects: ['./tsconfig.json'] }),
      tailwindcss(),
      tanstackStart(),
      viteReact({
        babel: {
          plugins: ['babel-plugin-react-compiler'],
        },
      }),
    ],
    server: apiProxyTarget
      ? {
          proxy: {
            '/api': {
              target: apiProxyTarget,
              changeOrigin: true,
              secure: false,
              rewrite: (path) => path.replace(/^\/api/, ''),
              configure: (proxy) => {
                proxy.on('proxyRes', (proxyRes) => {
                  const setCookie = proxyRes.headers['set-cookie']

                  if (!setCookie) {
                    return
                  }

                  proxyRes.headers['set-cookie'] = Array.isArray(setCookie)
                    ? setCookie.map(stripSecureFromAuthCookies)
                    : [stripSecureFromAuthCookies(setCookie)]
                })
              },
            },
          },
        }
      : undefined,
    test: {
      environment: 'jsdom',
      setupFiles: ['./src/test/setup.ts'],
      clearMocks: true,
    },
  }
})
