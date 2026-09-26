import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { loadViewerPeers } from '../lib/viewer.js';

test('peer configuration requires named HTTPS hosts and private token files', () => {
  const dir = mkdtempSync(join(tmpdir(), 'viewer-peers-'));
  const file = join(dir, 'viewer-peers.json');
  try {
    assert.deepEqual(loadViewerPeers(file, 'hub'), []);
    writeFileSync(join(dir, 'desktop-a-token'), 'test-only-peer-token-with-32-characters');
    const row = { id: 'desktop-a', url: 'https://desktop-a.example.test', tokenFile: 'desktop-a-token' };
    writeFileSync(file, JSON.stringify([row]));
    assert.equal(loadViewerPeers(file, 'hub')[0].token, 'test-only-peer-token-with-32-characters');
    for (const bad of [{ ...row, id: 'hub' }, { ...row, url: 'http://desktop-a.example.test' }, { ...row, url: 'https://user:password@desktop-a.example.test' }, { ...row, url: 'https://desktop-a.example.test?token=bad' }]) {
      writeFileSync(file, JSON.stringify([bad])); assert.throws(() => loadViewerPeers(file, 'hub'));
    }
    writeFileSync(file, JSON.stringify([row, row])); assert.throws(() => loadViewerPeers(file, 'hub'));
    writeFileSync(file, '{broken'); assert.throws(() => loadViewerPeers(file, 'hub'));
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
