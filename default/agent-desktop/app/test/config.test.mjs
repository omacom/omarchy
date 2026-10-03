import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { viewerConfig } from '../server.mjs';

test('native viewer defaults to the installed local port without fleet configuration or T3', () => {
  const home = mkdtempSync(join(tmpdir(), 'viewer-config-'));
  try {
    const state = join(home, '.local/share/hypr-desktop');
    mkdirSync(state, { recursive: true });
    writeFileSync(join(state, 'local-url'), 'http://127.0.0.1:17873/mcp\n');
    writeFileSync(join(state, 'token'), 'fixture-token\n');
    assert.deepEqual(viewerConfig(home), { fleet: true, desktopURL: 'http://127.0.0.1:17873', token: 'fixture-token' });
    const config = join(home, '.config/agent-desktops');
    mkdirSync(config, { recursive: true });
    const set = url => writeFileSync(join(config, 'fleet.json'), JSON.stringify({ url, tokenFile: join(state, 'token') }));
    set('https://hub.example.com');
    assert.equal(viewerConfig(home).desktopURL, 'https://hub.example.com');
    set('http://hub.example.com');
    assert.throws(() => viewerConfig(home), /loopback/);
    set('https://secret@hub.example.com');
    assert.throws(() => viewerConfig(home), /credentials/);
    writeFileSync(join(config, 'fleet.json'), '{broken');
    assert.throws(() => viewerConfig(home), SyntaxError, 'invalid optional configuration must not silently fall back');
  } finally { rmSync(home, { recursive: true }); }
});
