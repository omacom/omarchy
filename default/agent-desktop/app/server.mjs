import express from 'express';
import { createServer } from 'node:http';
import { randomBytes, randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { homedir, hostname } from 'node:os';
import { fileURLToPath } from 'node:url';
import { resolve, isAbsolute } from 'node:path';
import { WebSocket, WebSocketServer, createWebSocketStream } from 'ws';
import { T3 } from './t3.mjs';

const HERE = fileURLToPath(new URL('.', import.meta.url));
export { startCatalog } from './catalog.mjs';
import { startCatalog } from './catalog.mjs';

export async function serve({ catalog, t3 = new T3(),
  desktopURL = 'http://127.0.0.1:7873', token = readFileSync(homedir() + '/.local/share/hypr-desktop/token', 'utf8').trim(),
  host = hostname(), request = fetch, fleet = false } = {}) {
  catalog ||= fleet ? { close() {} } : startCatalog();
  const app = express(), router = express.Router(), server = createServer(app);
  const secret = randomBytes(32).toString('hex'), base = `/${secret}/`;
  const chats = new Map();
  let origin, current = [], refreshing, metadataWarning = '';
  const known = new Map();
  const desktop = async (path, body) => {
    const response = await request(desktopURL + '/hypr-desktop/viewer' + path, {
      method: body ? 'POST' : 'GET', ...(body ? { body: JSON.stringify(body) } : {}),
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' }, signal: AbortSignal.timeout(25000), redirect: 'error' });
    if (!response.ok) throw new Error(`Desktop service unavailable (${response.status}).`);
    return response.json();
  };
  async function refresh() {
    if (fleet) {
      refreshing ||= desktop('/agents/fleet').then(data => {
        const offline = new Set(data.hosts.filter(h => !h.online).map(h => h.id));
        const incoming = new Map(data.desktops.map(d => [`${d.host}/${d.desktop}/${d.generation}`, d]));
        for (const [id, previous] of known) {
          if (incoming.has(id)) known.set(id, incoming.get(id));
          else if (offline.has(previous.host)) known.set(id, { ...previous, ready: false, reconnecting: true });
          else known.delete(id);
        }
        for (const [id, d] of incoming) if (!known.has(id)) known.set(id, d);
        current = [...known.values()]; metadataWarning = data.hosts.filter(h => !h.online).map(h => `${h.id} offline`).join(' · ');
        return current;
      }).finally(() => { refreshing = null; });
      return refreshing;
    }
    refreshing ||= Promise.all([desktop('/desktops'), catalog.read().then(value => {
      metadataWarning = ''; return value;
    }, error => { metadataWarning = `Session names unavailable: ${error.message}`; return []; })]).then(([status, labels]) => {
      current = status.desktops.filter(d => d.held).map(d => ({ ...d,
        ...labels.find(l => l.desktop === d.desktop && l.generation === d.generation) })).map(d => ({ ...d, host, agentId: d.threadId ? `${host}/${d.threadId}` : null }));
      return current;
    }).finally(() => { refreshing = null; });
    return refreshing;
  }
  const route = fn => async (req, res) => {
    try { res.json(await fn(req)); } catch (error) { res.status(error.status || 503).json({ error: error.message }); }
  };
  app.use((req, res, next) => {
    if (req.headers.host !== new URL(origin).host || (req.headers.origin && req.headers.origin !== origin)) return res.sendStatus(403);
    res.set({ 'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff',
      'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'none'" });
    next();
  });
  app.use(base, router);
  router.use(express.json({ limit: '128kb' }));
  router.get('/api/desktops', route(async () => { const desktops = await refresh(); return { host, desktops, warning: metadataWarning }; }));
  router.get('/api/desktops/:host/:number/connect', route(req => desktop(fleet ? `/agents/connect/${encodeURIComponent(req.params.host)}/${encodeURIComponent(req.params.number)}?generation=${encodeURIComponent(req.query.generation || '')}` : `/${encodeURIComponent(req.params.number)}/connect?generation=${encodeURIComponent(req.query.generation || '')}`)));
  router.get('/api/desktops/:number/connect', route(req => desktop(`/${encodeURIComponent(req.params.number)}/connect?generation=${encodeURIComponent(req.query.generation || '')}`)));
  router.post('/api/chats', route(async req => {
    await refresh();
    const d = current.find(d => d.desktop === req.body.desktop && d.generation === req.body.generation && (!fleet || d.host === req.body.host));
    if (!d?.threadId) throw new Error('This desktop has no verified local T3 thread.');
    let entry = [...chats.entries()].find(([, value]) => value.agentId === d.agentId);
    if (!entry) { entry = [randomUUID(), { threadId: d.threadId, title: d.title, sourceHost: d.sourceHost, agentId: d.agentId }]; chats.set(...entry); }
    return { id: entry[0], title: entry[1].title, agentId: entry[1].agentId };
  }));
  const chat = req => {
    const result = chats.get(req.params.id);
    if (!result) throw Object.assign(new Error('Unknown chat.'), { status: 404 });
    return result;
  };
  router.get('/api/chats/:id', route(req => fleet ? desktop(`/agents/chat/${encodeURIComponent(chat(req).sourceHost)}/${encodeURIComponent(chat(req).threadId)}?${new URLSearchParams(req.query)}`) : t3.page(chat(req).threadId, req.query.before)));
  router.post('/api/chats/:id/messages', route(req => {
    if (![req.body.commandId, req.body.messageId].every(id => typeof id === 'string' && /^[a-zA-Z0-9-]{1,100}$/.test(id)) || typeof req.body.text !== 'string') throw new Error('Invalid message.');
    return fleet ? desktop(`/agents/chat/${encodeURIComponent(chat(req).sourceHost)}/${encodeURIComponent(chat(req).threadId)}`, req.body) : t3.send(chat(req).threadId, req.body.text, req.body.commandId, req.body.messageId);
  }));
  router.use('/novnc', express.static(HERE + 'node_modules/@novnc/novnc', { index: false }));
  router.get('/vendor/marked.js', (req, res) => res.sendFile(HERE + 'node_modules/marked/lib/marked.esm.js'));
  router.get('/vendor/purify.js', (req, res) => res.sendFile(HERE + 'node_modules/dompurify/dist/purify.es.mjs'));
  router.get('/font.woff2', (req, res) => res.sendFile(resolve(HERE, '../mcp/viewer/plex-sans.woff2')));
  router.use(express.static(HERE + 'web'));
  const streams = new WebSocketServer({ noServer: true, maxPayload: 1024 * 1024, perMessageDeflate: false });
  server.on('upgrade', (req, socket, head) => {
    const url = new URL(req.url, origin);
    const match = url.pathname.startsWith(base) && url.pathname.slice(base.length).match(/^stream\/([a-zA-Z0-9.-]+)\/([1-9]\d*)$/);
    if (!match || req.headers.origin !== origin || req.headers.host !== new URL(origin).host) return socket.destroy();
    const upstreamURL = new URL(desktopURL + (fleet ? `/hypr-desktop/viewer/agents/stream/${match[1]}/${match[2]}` : `/hypr-desktop/viewer/stream/${match[2]}`));
    upstreamURL.protocol = upstreamURL.protocol === 'https:' ? 'wss:' : 'ws:'; upstreamURL.search = new URLSearchParams({ generation: url.searchParams.get('generation') || '', profile: url.searchParams.get('profile') === 'preview' ? 'preview' : 'full' }).toString();
    streams.handleUpgrade(req, socket, head, downstream => {
      const upstream = new WebSocket(upstreamURL, { headers: { Authorization: `Bearer ${token}` }, handshakeTimeout: 8000, perMessageDeflate: false });
      const a = createWebSocketStream(downstream), b = createWebSocketStream(upstream);
      const close = () => { downstream.terminate(); upstream.terminate(); a.destroy(); b.destroy(); };
      for (const item of [downstream, upstream, a, b]) item.on('error', close);
      downstream.on('close', close); upstream.on('close', close); a.pipe(b).pipe(a);
    });
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  origin = `http://127.0.0.1:${server.address().port}`;
  return { url: origin + base, async close() {
    for (const ws of streams.clients) ws.terminate();
    catalog.close(); await t3.close();
    server.closeAllConnections(); await new Promise(resolve => server.close(resolve));
  } };
}

export function viewerConfig(home = homedir()) {
  let config;
  try { config = JSON.parse(readFileSync(home + '/.config/agent-desktops/fleet.json', 'utf8')); }
  catch (error) {
    if (error.code !== 'ENOENT') throw error;
    const state = home + '/.local/share/hypr-desktop';
    config = { url: readFileSync(state + '/local-url', 'utf8').trim().replace(/\/mcp$/, ''), tokenFile: state + '/token' };
  }
  const endpoint = new URL(config.url);
  const local = endpoint.protocol === 'http:' && ['127.0.0.1', 'localhost'].includes(endpoint.hostname);
  if ((!local && endpoint.protocol !== 'https:') || endpoint.username || endpoint.password || endpoint.search || endpoint.hash) throw new Error('Viewer requires local loopback HTTP or HTTPS without URL credentials.');
  if (typeof config.tokenFile !== 'string' || !isAbsolute(config.tokenFile)) throw new Error('Viewer tokenFile must be an absolute path.');
  return { fleet: true, desktopURL: config.url.replace(/\/$/, ''), token: readFileSync(config.tokenFile, 'utf8').trim() };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const runtime = await serve(viewerConfig());
  process.stdout.write(JSON.stringify({ url: runtime.url }) + '\n');
  let closing = false;
  const close = async () => { if (closing) return; closing = true; try { await runtime.close(); } finally { process.exit(); } };
  process.stdin.resume(); process.stdin.on('end', close); process.on('SIGTERM', close); process.on('SIGINT', close);
}
