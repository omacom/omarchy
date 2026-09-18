import express from 'express';
import { createHmac, timingSafeEqual } from 'node:crypto';

export function installDashboard(app, { fleet, token, originOK }) {
  const route = fn => async (req, res) => {
    try { res.json(await fn(req)); }
    catch (error) { res.status(error.status || 503).json({ error: error.message }); }
  };
  const fail = (message, status = 400) => { throw Object.assign(new Error(message), { status }); };
  const sign = value => createHmac('sha256', token).update('desktop-web-chat-v1:' + value).digest('base64url');
  const binding = desktop => {
    const value = Buffer.from(JSON.stringify([desktop.sourceHost, desktop.threadId])).toString('base64url');
    return value + '.' + sign(value);
  };
  const conversation = id => {
    if (typeof id !== 'string' || id.length > 2048) return fail('Unknown chat.', 404);
    const [value, supplied, extra] = id.split('.');
    const expected = Buffer.from(sign(value));
    if (extra || !supplied || Buffer.byteLength(supplied) !== expected.length || !timingSafeEqual(Buffer.from(supplied), expected)) return fail('Unknown chat.', 404);
    try {
      const [host, thread] = JSON.parse(Buffer.from(value, 'base64url').toString());
      if (typeof host !== 'string' || typeof thread !== 'string') return fail('Unknown chat.', 404);
      return { host, thread };
    } catch { return fail('Unknown chat.', 404); }
  };
  app.get('/api/desktops', route(async () => {
    const snapshot = await fleet.read();
    return { hosts: snapshot.hosts.map(({ id, online }) => ({ id, online })),
      desktops: snapshot.desktops.map(d => ({
        host: d.host, desktop: d.desktop, generation: d.generation,
        owner: d.owner, held: d.held, ready: d.ready, idleMs: d.idleMs,
        title: d.title || d.owner, icon: d.icon || '', agentStatus: d.agentStatus || 'Unknown',
        agentId: d.agentId || null, chatAvailable: Boolean(d.agentId && d.threadId && d.sourceHost)
      })) };
  }));
  const writes = (req, res, next) => {
    if (!originOK(req)) return res.sendStatus(403);
    if (!req.is('application/json')) return res.sendStatus(415);
    next();
  };
  app.post('/api/chats', writes, express.json({ limit: '128kb' }), route(async req => {
    const { host, desktop, generation } = req.body || {};
    const snapshot = await fleet.read();
    const match = snapshot.desktops.find(d => d.host === host && d.desktop === desktop && d.generation === generation);
    if (!match) return fail('This desktop has ended.', 404);
    if (!match.agentId || !match.threadId || !match.sourceHost) return fail('Chat is unavailable for this desktop.', 409);
    return { id: binding(match), title: match.title || match.owner, agentId: match.agentId };
  }));
  app.get('/api/chats/:id', route(req => {
    const { host, thread } = conversation(req.params.id);
    if (req.query.before !== undefined && (typeof req.query.before !== 'string' || req.query.before.length > 4096)) return fail('Invalid history cursor.');
    return fleet.page(host, thread, req.query.before);
  }));
  app.post('/api/chats/:id/messages', writes, express.json({ limit: '128kb' }), route(req => {
    const { host, thread } = conversation(req.params.id);
    const { text, commandId, messageId } = req.body || {};
    if (typeof text !== 'string' || !text.trim() || text.length > 100000 ||
        ![commandId, messageId].every(id => typeof id === 'string' && /^[a-zA-Z0-9-]{1,100}$/.test(id))) return fail('Invalid message.');
    return fleet.send(host, thread, text, commandId, messageId);
  }));
}
