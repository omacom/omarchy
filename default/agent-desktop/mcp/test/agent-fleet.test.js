import test from 'node:test';
import assert from 'node:assert/strict';
import express from 'express';
import { installAgentFleet } from '../lib/agent-fleet.js';

test('fleet groups desktops by conversation source, protects private claims and routes chat to that source', async () => {
  const records = ['hub', 'desktop-a', 'desktop-b'].map((host, i) => ({ host, desktop: 1, generation: `g${i}`, handle: `private-${i}`, owner: host, created: 1 }));
  const runtimes = [], calls = [];
  try {
    for (const name of ['desktop-a', 'desktop-b', 'hub']) {
      const app = express(), row = records.find(r => r.host === name);
      if (name !== 'hub') app.use((req, res, next) => { req.url = req.url.replace(/^\/hypr-desktop(?=\/)/, ''); next(); });
      const auth = (req, res, next) => req.headers.authorization === `Bearer ${name}-secret` ? next() : res.sendStatus(401);
      const status = () => [{ desktop: 1, generation: row.generation, held: true, ready: true }];
      app.get(['/hypr-desktop/viewer/desktops', '/viewer/desktops'], auth, (req, res) => res.json({ desktops: status() }));
      const runtime = installAgentFleet(app, { host: name, peers: runtimes.map(r => ({ id: r.name, url: r.url, token: `${r.name}-secret` })),
        leases: { byHandle: new Map([[row.handle, row]]), live: () => true }, peerAuth: auth, localList: status, localInfo: async () => ({ generation: row.generation }),
        catalog: { read: async claims => name === 'desktop-b' ? claims.map(c => ({ host: c.host, desktop: c.desktop, generation: c.generation, threadId: 'same-agent', title: 'Fleet task' })) : [], close() {} },
        t3: { page: async (thread, before) => { calls.push({ host: name, thread, before }); return { thread: { id: thread }, page: {} }; },
          send: async (...args) => { calls.push({ host: name, args }); return { ok: true }; }, close: async () => {} }
      });
      const listener = app.listen(0, '127.0.0.1'); await new Promise(resolve => listener.once('listening', resolve));
      runtimes.push({ name, url: `http://127.0.0.1:${listener.address().port}`, listener, runtime });
    }
    const hub = runtimes.at(-1);
    const call = async (path, body) => {
      const response = await fetch(hub.url + '/hypr-desktop/viewer/agents' + path, { headers: { Authorization: 'Bearer hub-secret', 'Content-Type': 'application/json' }, ...(body ? { method: 'POST', body: JSON.stringify(body) } : {}) });
      assert.equal(response.status, 200); return response.json();
    };
    assert.equal((await fetch(hub.url + '/hypr-desktop/viewer/agents/claims')).status, 401);
    assert.equal((await fetch(hub.url + '/viewer/agents/claims')).status, 401);
    let fleet = await call('/fleet');
    for (let i = 0; i < 30 && fleet.desktops.some(d => !d.agentId); i++) {
      await new Promise(resolve => setTimeout(resolve, 10));
      fleet = await call('/fleet');
    }
    assert.equal(fleet.desktops.length, 3);
    assert.deepEqual(new Set(fleet.desktops.map(d => d.host)), new Set(['hub', 'desktop-a', 'desktop-b']));
    assert.deepEqual(new Set(fleet.desktops.map(d => d.agentId)), new Set(['desktop-b/same-agent']));
    assert.ok(!JSON.stringify(fleet).includes('private-'), 'ownership capabilities never reach the viewer');
    await call('/chat/desktop-b/same-agent?before=cursor');
    await call('/chat/desktop-b/same-agent', { text: 'Continue', commandId: 'command', messageId: 'message' });
    assert.deepEqual(calls, [{ host: 'desktop-b', thread: 'same-agent', before: 'cursor' }, { host: 'desktop-b', args: ['same-agent', 'Continue', 'command', 'message'] }]);
  } finally {
    for (const r of runtimes) { await r.runtime.close(); r.listener.closeAllConnections(); await new Promise(resolve => r.listener.close(resolve)); }
  }
});

test('offline hosts and a slow identity resolver do not block healthy desktop discovery', async () => {
  const app = express(), paths = [];
  const fleet = installAgentFleet(app, { host: 'healthy', peers: [{ id: 'asleep', url: 'https://asleep.example', token: 'private' }], discoveryTimeout: 40,
    peerAuth: (req, res, next) => next(), leases: { byHandle: new Map(), live: () => true },
    localList: async () => [{ desktop: 1, generation: 'live', held: true }], localInfo: async () => ({}),
    catalog: { read: () => new Promise(() => {}), close() {} }, t3: { close: async () => {} },
    request: (url, { signal }) => { paths.push(url); return new Promise((resolve, reject) => signal.addEventListener('abort', () => reject(signal.reason), { once: true })); }
  });
  const server = app.listen(0, '127.0.0.1'); await new Promise(resolve => server.once('listening', resolve));
  try {
    const start = Date.now();
    const response = await fetch(`http://127.0.0.1:${server.address().port}/hypr-desktop/viewer/agents/fleet`);
    const data = await response.json();
    assert.ok(Date.now() - start < 1000);
    assert.equal(data.desktops[0].host, 'healthy');
    assert.deepEqual(data.hosts, [{ id: 'healthy', online: true }, { id: 'asleep', online: false }]);
    assert.equal(paths.length, 2, 'an offline peer must not get a second identity request');
  } finally { await fleet.close(); server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
});
