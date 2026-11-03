// Turn a raw Godot web export into a Cloudflare Workers static-assets release.
// Usage: node web/package.mjs <export-dir> <dist-dir>
// Files above the 25 MiB per-asset limit are split into content-hashed chunks under chunks/,
// and chunk-loader.js (injected before index.js) streams them back together in the browser.
import { createHash } from 'node:crypto';
import { execSync } from 'node:child_process';
import { copyFileSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const [src, dist] = process.argv.slice(2);
if (!src || !dist) throw new Error('usage: node web/package.mjs <export-dir> <dist-dir>');
const here = dirname(fileURLToPath(import.meta.url));
const CHUNK = 20 * 1024 * 1024;
const LIMIT = 25 * 1024 * 1024;
const TYPES = { 'index.wasm': 'application/wasm', 'index.pck': 'application/octet-stream' };

rmSync(dist, { recursive: true, force: true });
mkdirSync(join(dist, 'chunks'), { recursive: true });

const sha256 = buf => createHash('sha256').update(buf).digest('hex');
const manifest = {};
const files = {};
for (const name of readdirSync(src)) {
  const path = join(src, name);
  if (!statSync(path).isFile()) continue;
  const data = readFileSync(path);
  files[name] = sha256(data);
  if (name in TYPES) {
    const hash = files[name].slice(0, 12);
    const chunks = [];
    for (let off = 0, i = 1; off < data.length; off += CHUNK, i++) {
      const chunkName = `chunks/${name}.${hash}.${String(i).padStart(3, '0')}`;
      writeFileSync(join(dist, chunkName), data.subarray(off, off + CHUNK));
      chunks.push(chunkName);
    }
    manifest[name] = { size: data.length, type: TYPES[name], sha256: files[name], chunks };
  } else if (name === 'index.html') {
    continue; // rewritten below
  } else {
    if (data.length > LIMIT) throw new Error(`${name} is ${data.length} bytes, over the 25 MiB asset limit`);
    copyFileSync(path, join(dist, name));
  }
}

const loader = readFileSync(join(here, 'chunk-loader.js'), 'utf8')
  .replace('__CHUNK_MANIFEST__', JSON.stringify(Object.fromEntries(
    Object.entries(manifest).map(([k, v]) => [k, { size: v.size, type: v.type, chunks: v.chunks }]))));
writeFileSync(join(dist, 'chunk-loader.js'), loader);

let html = readFileSync(join(src, 'index.html'), 'utf8');
const tag = '<script src="index.js"></script>';
if (!html.includes(tag)) throw new Error('index.html: could not find the index.js script tag');
html = html.replace(tag, `<script src="chunk-loader.js"></script>\n\t\t${tag}`);
writeFileSync(join(dist, 'index.html'), html);

writeFileSync(join(dist, '_headers'), [
  '/chunks/*',
  '  Cache-Control: public, max-age=31536000, immutable',
  '  X-Content-Type-Options: nosniff',
  '/chunks/index.wasm.*',
  '  Content-Type: application/wasm',
  '/chunks/index.pck.*',
  '  Content-Type: application/octet-stream',
  '',
].join('\n'));

let commit = 'unknown';
try { commit = execSync('git rev-parse HEAD', { cwd: here }).toString().trim(); } catch {}
let dirty = false;
try { dirty = execSync('git status --porcelain --untracked-files=no', { cwd: here }).toString().trim() !== ''; } catch {}
writeFileSync(join(dist, 'release.json'), JSON.stringify({
  source_commit: commit, local_changes: dirty, built: new Date().toISOString(), files,
  chunked: Object.fromEntries(Object.entries(manifest).map(([k, v]) => [k, v.chunks.length])),
}, null, 2) + '\n');

for (const [name, info] of Object.entries(manifest)) console.log(`${name}: ${info.size} bytes -> ${info.chunks.length} chunks`);
console.log(`release written to ${dist}`);
