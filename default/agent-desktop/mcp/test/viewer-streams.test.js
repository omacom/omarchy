import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtempSync, writeFileSync, readFileSync, existsSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createViewerStreams } from '../lib/viewer-streams.js';

test('Wayland viewers share one process; last disconnect removes its socket without stopping the desktop', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'stream-process-test-'));
  const command = join(dir, 'fake-wayvnc');
  writeFileSync(command, `#!${process.execPath}\nconst net = require('net'); const fs = require('fs'); const path = process.argv.at(-1).slice(5); fs.writeFileSync(path + '.args', JSON.stringify(process.argv)); net.createServer().listen(path); process.on('SIGTERM', () => process.exit(0));`, { mode: 0o755 });
  const streams = createViewerStreams({ nest: {}, wayland: true, command });
  try {
    const [one, two] = await Promise.all([streams.acquire(1, 'generation-a'), streams.acquire(1, 'generation-a')]);
    assert.equal(one.endpoint.path, two.endpoint.path);
    assert.ok(existsSync(one.endpoint.path));
    const preview = await streams.acquire(1, 'generation-a', 'preview');
    assert.notEqual(preview.endpoint.path, one.endpoint.path, 'preview quality cannot downgrade a full-quality viewer');
    const args = JSON.parse(readFileSync(preview.endpoint.path + '.args', 'utf8'));
    assert.equal(args[args.indexOf('-f') + 1], '5');
    const fullArgs = JSON.parse(readFileSync(one.endpoint.path + '.args', 'utf8'));
    assert.equal(fullArgs[fullArgs.indexOf('-f') + 1], '20');
    await preview.release(); assert.ok(existsSync(one.endpoint.path));
    const other = await streams.acquire(2, 'generation-b'); assert.notEqual(one.endpoint.path, other.endpoint.path);
    await one.release(); assert.ok(existsSync(two.endpoint.path));
    await two.release(); assert.equal(existsSync(two.endpoint.path), false); assert.ok(existsSync(other.endpoint.path));
    await two.release(); assert.ok(existsSync(other.endpoint.path), 'repeated close is harmless');
    await other.release(); assert.equal(existsSync(other.endpoint.path), false);
  } finally { await streams.close(); rmSync(dir, { recursive: true, force: true }); }
});

test('missing encoder fails without leaving a pending stream or temp directory', async () => {
  const streams = createViewerStreams({ nest: {}, wayland: true, command: '/no-such-viewer-test-executable' });
  await assert.rejects(streams.acquire(1, 'g'), /not installed/);
  await assert.rejects(streams.acquire(1, 'g'), /not installed/);
  await streams.close();
});
