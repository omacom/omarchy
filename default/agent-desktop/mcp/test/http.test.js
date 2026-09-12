import assert from 'node:assert/strict';
import { test } from 'node:test';
import { spawn } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { once } from 'node:events';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { createServer } from 'node:net';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { invokeDesktop } from '../client.js';

for (const web of [false, true]) test(`HTTP runtime is authenticated and web dashboard is ${web ? 'explicitly enabled' : 'disabled by default'}`, async () => {
  const socket = createServer();
  socket.listen(0, '127.0.0.1');
  await once(socket, 'listening');
  const port = socket.address().port;
  await new Promise(resolve => socket.close(resolve));
  const state = mkdtempSync(join(tmpdir(), 'desktop-http-'));
  const token = randomBytes(32).toString('hex');
  const url = `http://127.0.0.1:${port}/mcp`;
  writeFileSync(join(state, 'token'), token, { mode: 0o600 });
  writeFileSync(join(state, 'local-url'), url);
  const child = spawn(process.execPath, [new URL('../index.js', import.meta.url).pathname], {
    env: { ...process.env, HYPR_DESKTOP_STATE: state, HYPR_DESKTOP_PORT: String(port), PATH: '/usr/bin:/bin', HYPR_DESKTOP_HOSTS: 'desktops.example.com', AGENT_DESKTOP_VIEWER_ORIGINS: web ? 'https://desktops.example.com' : '' },
    stdio: ['ignore', 'ignore', 'pipe']
  });
  let logs = '';
  child.stderr.on('data', chunk => { logs += chunk; });
  try {
    let ready = false;
    for (let n = 0; n < 100; n++) {
      if (child.exitCode !== null) throw Error(logs);
      try {
        if ((await fetch(`http://127.0.0.1:${port}/healthz`)).ok) { ready = true; break; }
      } catch {}
      await new Promise(resolve => setTimeout(resolve, 25));
    }
    assert.ok(ready, logs);
    assert.equal((await fetch(url)).status, 401);
    assert.equal((await fetch(url, { headers: { Authorization: 'Bearer wrong' } })).status, 401);
    const result = await invokeDesktop('status', {}, { state });
    assert.equal(result.isError, undefined);
    assert.match(result.content[0].text, /no agent desktops/i);
    const base = `http://127.0.0.1:${port}`;
    const peer = base + '/hypr-desktop/viewer/agents/fleet';
    assert.equal((await fetch(peer)).status, 401);
    assert.deepEqual((await (await fetch(peer, { headers: { Authorization: `Bearer ${token}` } })).json()).desktops, []);
    const headers = { Host: 'desktops.example.com', Origin: 'https://desktops.example.com' };
    assert.equal((await fetch(base + '/api/desktops', { headers })).status, web ? 200 : 404);
    assert.equal((await fetch(base + '/api/desktops', { headers: { ...headers, Origin: 'https://evil.example' } })).status, 403);
    assert.equal(logs.includes(token), false);
  } finally {
    if (child.exitCode === null) {
      const exited = once(child, 'exit');
      child.kill('SIGTERM');
      await exited;
    }
    rmSync(state, { recursive: true });
  }
});
