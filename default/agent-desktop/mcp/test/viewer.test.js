import assert from 'node:assert/strict';
import { test } from 'node:test';
import { createServer } from 'node:net';
import express from 'express';
import { WebSocket } from 'ws';
import { installViewer } from '../lib/viewer.js';
import { Leases } from '../lib/leases.js';

const token = 'test-only-peer-token-at-least-32-characters';
const wait = ms => new Promise(resolve => setTimeout(resolve, ms));
async function fixture(t) {
  const leases = new Leases();
  const lease = leases.claim('test task');
  let acquired = 0, released = 0;
  const tcp = createServer(socket => { socket.write('RFB 003.008\n'); socket.on('error', () => {}); socket.on('data', data => socket.write(data)); });
  tcp.listen(0, '127.0.0.1'); await new Promise(resolve => tcp.once('listening', resolve));
  const nest = { ready: async () => true, info: () => ({ password: 'vnc-only-password' }) };
  const streams = { async acquire(n, generation) {
    assert.equal(n, lease.desktop); assert.equal(generation, lease.generation); acquired++;
    return { endpoint: { host: '127.0.0.1', port: tcp.address().port }, release() { released++; } };
  }, async close() {} };
  const app = express(), origins = [];
  const attach = installViewer(app, { host: 'hub', leases, nest, token, origins, streams });
  const listener = app.listen(0, '127.0.0.1'); attach(listener);
  await new Promise(resolve => listener.once('listening', resolve));
  const base = `http://127.0.0.1:${listener.address().port}`; origins.push(base);
  const clients = [];
  t.after(async () => { clients.forEach(ws => ws.terminate()); await wait(20); listener.closeAllConnections(); await new Promise(resolve => listener.close(resolve)); await new Promise(resolve => tcp.close(resolve)); });
  const socket = (path, headers = { Origin: base }) => { const ws = new WebSocket(base.replace('http:', 'ws:') + path, { headers }); clients.push(ws); ws.on('error', () => {}); return ws; };
  const rejected = (path, headers) => new Promise((resolve, reject) => {
    const ws = socket(path, headers);
    ws.once('unexpected-response', (_req, res) => { resolve(res.statusCode); res.resume(); ws.terminate(); });
    ws.once('open', () => reject(new Error('unexpected admission')));
  });
  return { base, leases, lease, socket, rejected, counts: () => ({ acquired, released }) };
}

test('tailnet viewer needs no password; listing never starts streaming or leaks agent handles', async t => {
  const f = await fixture(t);
  const res = await fetch(f.base + '/api/desktops'); assert.equal(res.status, 200);
  const body = await res.json();
  assert.deepEqual(body.hosts, [{ id: 'hub', online: true }]);
  assert.equal(body.desktops[0].owner, 'test task');
  assert.equal(JSON.stringify(body).includes(f.lease.handle), false);
  assert.equal(JSON.stringify(body).includes(token), false);
  assert.deepEqual(f.counts(), { acquired: 0, released: 0 });
  assert.equal((await fetch(f.base + '/api/desktops', { headers: { Origin: 'https://evil.test' } })).status, 403);
  assert.equal((await fetch(f.base + '/hypr-desktop/viewer/desktops')).status, 401);
  assert.equal((await fetch(f.base + '/hypr-desktop/viewer/desktops', { headers: { Authorization: `Bearer ${token}` } })).status, 200);
  assert.equal((await fetch(f.base + '/viewer/desktops')).status, 401);
  assert.equal((await fetch(f.base + '/viewer/desktops', { headers: { Authorization: `Bearer ${token}` } })).status, 200);
  assert.equal((await fetch(f.base + '/favicon.svg')).status, 200);
  const html = await (await fetch(f.base + '/')).text(); assert.ok(!html.includes('id="login"'));
});

test('stream opens only on Watch; closing it leaves desktop ownership intact', async t => {
  const f = await fixture(t);
  const path = `/view/hub/1?generation=${f.lease.generation}`;
  const info = await (await fetch(f.base + `/api/desktops/hub/1/connect?generation=${f.lease.generation}`)).json();
  assert.equal(info.password, 'vnc-only-password'); assert.equal(f.counts().acquired, 0);
  assert.equal(await f.rejected(path, { Origin: 'https://evil.test' }), 403);
  assert.equal(await f.rejected(path, {}), 403);
  const ws = f.socket(path);
  const message = await new Promise(resolve => ws.once('message', resolve)); assert.match(message.toString(), /^RFB/);
  assert.equal(f.counts().acquired, 1);
  ws.close(); await new Promise(resolve => ws.once('close', resolve)); await wait(20);
  assert.equal(f.counts().released, 1); assert.equal(f.leases.status().length, 1);
});

test('stale links and active streams cannot follow a reused desktop number', async t => {
  const f = await fixture(t);
  const path = `/view/hub/1?generation=${f.lease.generation}`;
  const ws = f.socket(path); await new Promise(resolve => ws.once('message', resolve));
  f.leases.release(f.lease.handle); f.leases.claim('replacement');
  await new Promise(resolve => ws.once('close', resolve));
  assert.equal(await f.rejected(path, { Origin: f.base }), 404);
  assert.equal((await fetch(f.base + `/api/desktops/hub/1/connect?generation=${f.lease.generation}`)).status, 404);
  assert.equal(f.counts().released, 1);
});

test('peer streams require agent authentication even though the web UI is passwordless', async t => {
  const f = await fixture(t), path = `/hypr-desktop/viewer/stream/1?generation=${f.lease.generation}`;
  assert.equal(await f.rejected(path, {}), 403);
  assert.equal(await f.rejected(path, { Authorization: 'Bearer wrong' }), 403);
  const ws = f.socket(path.replace('/hypr-desktop', ''), { Authorization: `Bearer ${token}` });
  assert.match((await new Promise(resolve => ws.once('message', resolve))).toString(), /^RFB/);
});

test('fleet discovery and relay distinguish hosts, keep tokens server-side, and stop remote streams on close', async t => {
  const f = await fixture(t);
  const app = express(), leases = new Leases(), origins = [];
  const attach = installViewer(app, { host: 'hub', leases, nest: {}, origins, token,
    peers: [{ id: 'desktop-a', url: f.base, token }, { id: 'desktop-b', url: 'http://127.0.0.1:1', token }] });
  const server = app.listen(0, '127.0.0.1'); attach(server);
  await new Promise(resolve => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}`; origins.push(base);
  t.after(async () => { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); });
  const result = await (await fetch(base + '/api/desktops')).json();
  assert.deepEqual(result.hosts, [{ id: 'hub', online: true }, { id: 'desktop-a', online: true }, { id: 'desktop-b', online: false }]);
  assert.equal(result.desktops[0].host, 'desktop-a'); assert.equal(result.desktops[0].desktop, 1);
  assert.ok(!JSON.stringify(result).includes(token)); assert.equal(f.counts().acquired, 0);
  const info = await (await fetch(base + `/api/desktops/desktop-a/1/connect?generation=${f.lease.generation}`)).json();
  assert.equal(info.password, 'vnc-only-password');
  const ws = new WebSocket(base.replace('http:', 'ws:') + `/view/desktop-a/1?generation=${f.lease.generation}`, { headers: { Origin: base } });
  ws.on('error', () => {}); t.after(() => ws.terminate());
  assert.match((await new Promise(resolve => ws.once('message', resolve))).toString(), /^RFB/);
  const echoed = new Promise(resolve => ws.once('message', resolve)); ws.send(Buffer.from('relay bytes'));
  assert.equal((await echoed).toString(), 'relay bytes');
  assert.equal(f.counts().acquired, 1);
  ws.close(); await new Promise(resolve => ws.once('close', resolve)); await wait(50);
  assert.equal(f.counts().released, 1); assert.equal(f.leases.status().length, 1);
});
