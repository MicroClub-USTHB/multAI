// Minimal production server for the TanStack Start build (Node built-ins only).
//   dist/client  -> static files   (hashed /assets/* are cached for a year)
//   dist/server  -> SSR            (server.fetch(Request) -> Response)
//   /healthz     -> 200 "ok"       (container healthcheck, no render)
//   /api/*       -> API_PROXY_TARGET with the /api prefix stripped (optional, see README)
import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import http from 'node:http';
import https from 'node:https';
import { extname, join, normalize, resolve } from 'node:path';
import { Readable } from 'node:stream';
import { pathToFileURL } from 'node:url';

const root = resolve(process.env.APP_DIR ?? '.');
const clientDir = join(root, 'dist/client');
const port = Number(process.env.PORT ?? 3000);
const apiTarget = process.env.API_PROXY_TARGET ? new URL(process.env.API_PROXY_TARGET) : null;
const { default: app } = await import(pathToFileURL(join(root, 'dist/server/server.js')).href);

const types = {
  '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.html': 'text/html; charset=utf-8',
  '.json': 'application/json', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.ico': 'image/x-icon',
  '.webp': 'image/webp', '.woff': 'font/woff', '.woff2': 'font/woff2', '.txt': 'text/plain; charset=utf-8', '.map': 'application/json',
};
const hopByHop = new Set(['connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailer', 'transfer-encoding', 'upgrade']);
const first = (value) => String(value ?? '').split(',')[0].trim();

async function serveStatic(req, res, pathname) {
  const file = normalize(join(clientDir, decodeURIComponent(pathname)));
  if (!file.startsWith(clientDir + '/')) return false;
  const info = await stat(file).catch(() => null);
  if (!info?.isFile()) return false;
  res.writeHead(200, {
    'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    'Content-Length': info.size,
    'Cache-Control': pathname.startsWith('/assets/') ? 'public, max-age=31536000, immutable' : 'public, max-age=3600',
  });
  if (req.method === 'HEAD') res.end();
  else createReadStream(file).pipe(res);
  return true;
}

function proxyApi(req, res, pathname, search) {
  const headers = Object.fromEntries(Object.entries(req.headers).filter(([name]) => !hopByHop.has(name)));
  headers.host = apiTarget.host;
  headers['x-forwarded-for'] = [req.headers['x-forwarded-for'], req.socket.remoteAddress].filter(Boolean).join(', ');
  headers['x-forwarded-proto'] ??= 'http';
  headers['x-forwarded-host'] ??= req.headers.host;
  const client = apiTarget.protocol === 'https:' ? https : http;
  const upstream = client.request(
    { protocol: apiTarget.protocol, hostname: apiTarget.hostname, port: apiTarget.port, method: req.method, path: (pathname.slice(4) || '/') + search, headers },
    (response) => {
      const out = Object.fromEntries(Object.entries(response.headers).filter(([name]) => !hopByHop.has(name))); // set-cookie stays an array
      res.writeHead(response.statusCode ?? 502, out);
      response.pipe(res);
    },
  );
  upstream.on('error', (error) => {
    console.error('api proxy error:', error.message);
    if (!res.headersSent) res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Bad gateway');
  });
  res.on('close', () => upstream.destroy());
  req.pipe(upstream);
}

async function renderApp(req, res, url) {
  const headers = new Headers();
  for (const [name, value] of Object.entries(req.headers)) {
    if (hopByHop.has(name) || value === undefined) continue;
    headers.set(name, Array.isArray(value) ? value.join(name === 'cookie' ? '; ' : ', ') : value);
  }
  const hasBody = req.method !== 'GET' && req.method !== 'HEAD';
  const controller = new AbortController();
  res.on('close', () => controller.abort());
  const response = await app.fetch(
    new Request(url, { method: req.method, headers, signal: controller.signal, ...(hasBody ? { body: Readable.toWeb(req), duplex: 'half' } : {}) }),
  );
  const out = {};
  response.headers.forEach((value, name) => { if (name !== 'set-cookie' && !hopByHop.has(name)) out[name] = value; });
  const cookies = response.headers.getSetCookie();
  if (cookies.length) out['set-cookie'] = cookies;
  res.writeHead(response.status, out);
  if (!response.body || req.method === 'HEAD') res.end();
  else Readable.fromWeb(response.body).pipe(res);
}

const server = http.createServer(async (req, res) => {
  try {
    const host = first(req.headers['x-forwarded-host']) || req.headers.host || 'localhost';
    const url = new URL(req.url ?? '/', `${first(req.headers['x-forwarded-proto']) || 'http'}://${host}`);
    if (url.pathname === '/healthz') return void res.writeHead(200, { 'Content-Type': 'text/plain' }).end('ok');
    if (apiTarget && (url.pathname === '/api' || url.pathname.startsWith('/api/'))) return proxyApi(req, res, url.pathname, url.search);
    if ((req.method === 'GET' || req.method === 'HEAD') && (await serveStatic(req, res, url.pathname))) return;
    await renderApp(req, res, url);
  } catch (error) {
    console.error('request failed:', error);
    if (!res.headersSent) res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Internal Server Error');
  }
});

server.listen(port, '0.0.0.0', () => console.log(`listening on :${port}${apiTarget ? ` (api proxy -> ${apiTarget.origin})` : ''}`));

const shutdown = () => {
  server.close(() => process.exit(0));
  server.closeIdleConnections();
  setTimeout(() => process.exit(0), 10_000).unref();
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
