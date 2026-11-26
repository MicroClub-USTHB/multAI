// Writes <out>/package.json listing only the packages that dist/server imports at
// runtime (exact installed versions), so the runtime image skips build-only deps.
import { builtinModules } from 'node:module';
import { mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const [serverDir = 'dist/server', out = 'runtime'] = process.argv.slice(2);
const builtins = new Set(builtinModules);
const specifier = /(?:\bfrom\s*|\bimport\s*\(?\s*|\brequire\(\s*)["']([^"'\n]+)["']/g;

const walk = (dir) =>
  readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : path.endsWith('.js') || path.endsWith('.mjs') ? [path] : [];
  });

const packages = new Set();
for (const file of walk(serverDir)) {
  for (const [, spec] of readFileSync(file, 'utf8').matchAll(specifier)) {
    if (spec.startsWith('.') || spec.startsWith('/') || spec.startsWith('node:') || spec.startsWith('#')) continue;
    const parts = spec.split('/');
    const name = spec.startsWith('@') ? parts.slice(0, 2).join('/') : parts[0];
    if (!builtins.has(name)) packages.add(name);
  }
}

const installedPackage = (name) => {
  try {
    return JSON.parse(readFileSync(join('node_modules', name, 'package.json'), 'utf8'));
  } catch {
    return null; // Strings such as "react/jsx-runtime" in comments or data, not real packages.
  }
};

// Peer dependencies (react-dom for react-router, ...) are pinned to the installed version too,
// otherwise npm resolves them to the newest release and the peer ranges conflict.
for (const name of [...packages]) {
  const info = installedPackage(name);
  for (const peer of Object.keys(info?.peerDependencies ?? {})) {
    const optional = info.peerDependenciesMeta?.[peer]?.optional;
    if (!optional && !peer.startsWith('@types/') && peer !== 'typescript' && installedPackage(peer)) packages.add(peer);
  }
}

const dependencies = {};
for (const name of [...packages].sort()) {
  const installed = installedPackage(name);
  if (!installed || name.startsWith('@types/') || name === 'typescript') continue;
  // An npm alias (e.g. h3-v2 -> h3) must stay an alias, or npm fetches an unrelated package.
  dependencies[name] = installed.name === name ? installed.version : `npm:${installed.name}@${installed.version}`;
}

mkdirSync(out, { recursive: true });
writeFileSync(join(out, 'package.json'), JSON.stringify({ name: 'multai-front-runtime', private: true, type: 'module', dependencies }, null, 2));
console.log(`runtime deps (${Object.keys(dependencies).length}):`, Object.keys(dependencies).join(', '));
