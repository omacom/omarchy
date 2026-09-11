import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import { installDashboard } from '../lib/dashboard.js';

async function fixture(t) {
  let rows = [{ host: 'desktop-a', desktop: 1, generation: 'original', held: true, ready: true,
    owner: 'Agent', title: 'Build dashboard', icon: '', agentStatus: 'Working',
    agentId: 'desktop-b/thread-one', sourceHost: 'desktop-b', threadId: 'thread-one', handle: 'private-handle' }];
  const calls = [];
  const app = express(); let base;
  installDashboard(app, { token: 'private-server-token', originOK: req => req.headers.origin === base,
    fleet: { read: async () => ({ hosts: [{ id: 'desktop-a', online: true }], desktops: rows }),
      page: async (...args) => { calls.push(['page', ...args]); return { thread: { id: args[1], messages: [] }, page: { hasMore: false } }; },
      send: async (...args) => { calls.push(['send', ...args]); return { accepted: true }; } } });
  const server = app.listen(0, '127.0.0.1'); await new Promise(resolve => server.once('listening', resolve));
  base = `http://127.0.0.1:${server.address().port}`;
  t.after(async () => { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); });
  const post = (path, body, origin = base) => fetch(base + path, { method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  return { base, post, calls, replace: value => { rows = value; }, desktop: { host: 'desktop-a', desktop: 1, generation: 'original' } };
}

test('dashboard provides names and ownership groups without private handles or tokens', async t => {
  const f = await fixture(t);
  const response = await fetch(f.base + '/api/desktops'); const data = await response.json();
  assert.equal(data.desktops[0].title, 'Build dashboard');
  assert.equal(data.desktops[0].agentId, 'desktop-b/thread-one');
  assert.equal(data.desktops[0].chatAvailable, true);
  assert.ok(!JSON.stringify(data).includes('private-'));
  assert.ok(!Object.hasOwn(data.desktops[0], 'threadId'));
  assert.deepEqual(f.calls, []);
});

test('web chat stays on the original thread after a desktop closes or its slot is reused', async t => {
  const f = await fixture(t);
  const response = await f.post('/api/chats', f.desktop); assert.equal(response.status, 200);
  const chat = await response.json();
  f.replace([{ ...f.desktop, generation: 'replacement', sourceHost: 'hub', threadId: 'different', agentId: 'hub/different' }]);
  assert.equal((await f.post('/api/chats', f.desktop)).status, 404);
  const page = await fetch(f.base + '/api/chats/' + chat.id + '?before=older-cursor'); assert.equal(page.status, 200);
  const body = { text: 'Continue', commandId: 'same-command', messageId: 'same-message' };
  assert.equal((await f.post('/api/chats/' + chat.id + '/messages', body)).status, 200);
  assert.equal((await f.post('/api/chats/' + chat.id + '/messages', body)).status, 200);
  assert.deepEqual(f.calls, [['page', 'desktop-b', 'thread-one', 'older-cursor'],
    ['send', 'desktop-b', 'thread-one', 'Continue', 'same-command', 'same-message'],
    ['send', 'desktop-b', 'thread-one', 'Continue', 'same-command', 'same-message']]);
});

test('chat refuses forged identities, unsupported ownership, cross-origin writes and invalid messages', async t => {
  const f = await fixture(t);
  assert.equal((await f.post('/api/chats', f.desktop, 'https://evil.test')).status, 403);
  assert.equal((await fetch(f.base + '/api/chats', { method: 'POST' })).status, 403);
  const chat = await (await f.post('/api/chats', f.desktop)).json();
  const forged = Buffer.from(JSON.stringify(['desktop-b', 'unrelated-thread'])).toString('base64url') + '.' + chat.id.split('.')[1];
  assert.equal((await fetch(f.base + '/api/chats/' + forged)).status, 404);
  assert.equal((await f.post('/api/chats/' + chat.id + '/messages', { text: 'Continue' })).status, 400);
  assert.equal((await f.post('/api/chats/' + chat.id + '/messages', { text: 'Continue', commandId: 'c', messageId: 'm' }, 'https://evil.test')).status, 403);
  f.replace([{ ...f.desktop, ready: true }]);
  assert.equal((await f.post('/api/chats', f.desktop)).status, 409);
  assert.deepEqual(f.calls, []);
});
