import express from 'express';
import { startCatalog } from '../../app/catalog.mjs';
import { T3 } from '../../app/t3.mjs';

export function installAgentFleet(app, { host, peers, leases, peerAuth, localList, localInfo,
  catalog = startCatalog(), t3 = new T3(), request = fetch, discoveryTimeout = 1500 }) {
  const prefix = '/hypr-desktop/viewer';
  const machines = [{ id: host }, ...peers];
  const remote = async (id, path, body, timeout = 20000) => {
    const peer = peers.find(p => p.id === id);
    if (!peer) throw new Error('Unknown machine.');
    const response = await request(peer.url + prefix + path, {
      method: body ? 'POST' : 'GET', headers: { Authorization: `Bearer ${peer.token}`, 'Content-Type': 'application/json' },
      ...(body ? { body: JSON.stringify(body) } : {}), signal: AbortSignal.timeout(timeout), redirect: 'error'
    });
    if (!response.ok) throw new Error(`${id} is unavailable (${response.status}).`);
    return response.json();
  };
  const route = fn => async (req, res) => {
    try { res.json(await fn(req)); } catch (error) { res.status(503).json({ error: error.message }); }
  };
  const own = () => [...leases.byHandle.values()].filter(l => leases.live(l)).map(l => ({
    host, desktop: l.desktop, generation: l.generation || String(l.created),
    handle: l.handle, created: l.created, owner: l.owner
  }));
  const router = express.Router();
  app.use([prefix + '/agents', '/viewer/agents'], peerAuth, express.json({ limit: '256kb' }), router);
  router.get('/claims', route(() => own()));
  router.post('/resolve', route(req => catalog.read(req.body.leases)));
  let cached, refreshAt = 0, pending, resolving, identities = [];
  const present = data => ({ ...data, desktops: data.desktops.map(d => {
    const matches = identities.filter(m => m.host === d.host && m.desktop === d.desktop && m.generation === d.generation);
    const unique = new Map(matches.map(m => [m.agentId, m]));
    return unique.size === 1 ? { ...d, ...unique.values().next().value } : d;
  }) });
  async function fleet() {
    if (cached && Date.now() < refreshAt) return present(cached);
    pending ||= (async () => {
      const sources = await Promise.all(machines.map(async p => {
        try {
          const [status, claims] = p.id === host ? [await localList(), own()] :
            await Promise.all([remote(p.id, '/desktops', null, discoveryTimeout), remote(p.id, '/agents/claims', null, discoveryTimeout)]).then(([s, c]) => [s.desktops, c]);
          return { id: p.id, online: true, claims, desktops: status.filter(d => d.held).map(d => ({ ...d, host: p.id })) };
        } catch { return { id: p.id, online: false, claims: [], desktops: [] }; }
      }));
      const claims = sources.flatMap(s => s.claims);
      resolving ||= Promise.all(sources.filter(s => s.online).map(async p => {
        try {
          const matches = p.id === host ? await catalog.read(claims) : await remote(p.id, '/agents/resolve', { leases: claims });
          return matches.filter(m => m.threadId).map(m => ({ ...m, sourceHost: p.id, agentId: `${p.id}/${m.threadId}` }));
        } catch { return []; }
      })).then(results => { identities = results.flat(); }).finally(() => { resolving = null; });
      const desktops = sources.flatMap(s => s.desktops);
      cached = { hosts: sources.map(({ id, online }) => ({ id, online })), desktops };
      refreshAt = Date.now() + 1500;
      return present(cached);
    })().finally(() => { pending = null; });
    return pending;
  }
  router.get('/fleet', route(fleet));
  router.get('/connect/:host/:number', route(req => req.params.host === host ? localInfo(Number(req.params.number), req.query.generation) :
    remote(req.params.host, `/${encodeURIComponent(req.params.number)}/connect?generation=${encodeURIComponent(req.query.generation || '')}`)));
  router.get('/thread/:thread', route(req => t3.page(req.params.thread, req.query.before)));
  router.post('/thread/:thread', route(req => {
    const { text, commandId, messageId } = req.body;
    if (typeof text !== 'string' || ![commandId, messageId].every(id => typeof id === 'string' && /^[a-zA-Z0-9-]{1,100}$/.test(id))) throw new Error('Invalid message.');
    return t3.send(req.params.thread, text, commandId, messageId);
  }));
  const page = (source, thread, before) => source === host ? t3.page(thread, before) :
    remote(source, `/agents/thread/${encodeURIComponent(thread)}?${new URLSearchParams(before ? { before } : {})}`);
  const send = (source, thread, text, commandId, messageId) => source === host ? t3.send(thread, text, commandId, messageId) :
    remote(source, `/agents/thread/${encodeURIComponent(thread)}`, { text, commandId, messageId });
  router.get('/chat/:host/:thread', route(req => page(req.params.host, req.params.thread, req.query.before)));
  router.post('/chat/:host/:thread', route(req => send(req.params.host, req.params.thread, req.body.text, req.body.commandId, req.body.messageId)));
  return { read: fleet, page, send, close: async () => { catalog.close(); await t3.close(); } };
}
