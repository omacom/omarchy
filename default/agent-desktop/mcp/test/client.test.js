import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtempSync, writeFileSync, readFileSync, statSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { createMcpHandler } from '@modelcontextprotocol/server';
import { Leases } from '../lib/leases.js';
import { createLifecycle } from '../lib/lifecycle.js';
import { buildServer } from '../lib/server.js';
import { invokeDesktop, saveImages } from '../client.js';

test('fallback uses configured authentication and preserves ownership across calls', async () => {
  const state = mkdtempSync(join(tmpdir(), 'desktop-client-test-'));
  const token = 'test-token-never-used-outside-this-test';
  writeFileSync(join(state, 'url'), 'https://remote.invalid/mcp');
  writeFileSync(join(state, 'local-url'), 'http://test.local/mcp');
  writeFileSync(join(state, 'token'), token);
  const leases = new Leases();
  const running = new Set();
  const nest = { ready: n => running.has(n), start: async n => running.add(n), stop: async n => running.delete(n), windows: async () => [] };
  const lifecycle = createLifecycle({ leases, nest });
  const handler = createMcpHandler(() => buildServer({ leases, nest, lifecycle, host: 'test' }));
  const fetch = (url, init) => {
    const request = new Request(url, init);
    assert.equal(request.url, 'http://test.local/mcp');
    assert.equal(request.headers.get('authorization'), `Bearer ${token}`);
    return handler.fetch(request);
  };
  const call = (name, args = {}) => invokeDesktop(name, args, { state, fetch });
  try {
    const { structuredContent: { handle } } = await call('claim', { owner: 'fallback test' });
    assert.equal(running.size, 1);
    assert.equal((await call('windows', { handle })).isError, undefined);
    assert.equal((await call('release', { handle })).isError, undefined);
    assert.equal(running.size, 0);
    assert.equal((await call('windows', { handle })).isError, true);
  } finally {
    await handler.close();
    rmSync(state, { recursive: true });
  }
});

test('fallback saves screenshots privately while retaining the frame needed for clicks', () => {
  const image = Buffer.from('test screenshot bytes');
  const result = saveImages({ content: [{ type: 'image', mimeType: 'image/png', data: image.toString('base64') }], structuredContent: { frame_id: 'f1-example' } });
  const path = result.content[0].text.match(/Screenshot saved to (.+)\. Open/)[1];
  try {
    assert.deepEqual(readFileSync(path), image);
    assert.equal(statSync(path).mode & 0o777, 0o600);
    assert.equal(statSync(dirname(path)).mode & 0o777, 0o700);
    assert.equal(result.structuredContent.frame_id, 'f1-example');
    assert.equal(JSON.stringify(result).includes(image.toString('base64')), false);
  } finally { rmSync(dirname(path), { recursive: true }); }
});
