import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { startCatalog } from '../catalog.mjs';
import { T3 } from '../t3.mjs';

test('the persistent resolver recovers after a timed-out child', async () => {
  let launches = 0;
  const catalog = startCatalog({ timeout: 300, launch: () => spawn(process.execPath, ['-e', ++launches === 1 ? 'setInterval(() => {}, 1000)' :
    `require('node:readline').createInterface({ input: process.stdin }).on('line', () => process.stdout.write(JSON.stringify({ desktops: [{ desktop: 1 }] }) + '\\n'))`], { stdio: ['pipe', 'pipe', 'inherit'] }) });
  try {
    await assert.rejects(catalog.read(), /timed out/);
    assert.deepEqual(await catalog.read(), [{ desktop: 1 }]);
    assert.equal(launches, 2);
  } finally { catalog.close(); }
});

test('successful sends do not retain full prompts in the persistent service', async () => {
  const client = new T3();
  client.page = async () => ({ thread: { id: 'thread', modelSelection: {}, runtimeMode: 'full-access', interactionMode: 'default' } });
  client.call = async () => ({ sequence: 1 });
  for (let i = 0; i < 600; i++) await client.send('thread', 'private prompt', `command-${i}`, `message-${i}`);
  assert.equal(client.pending.size, 0);
  assert.equal(client.completed.size, 256);
  assert.ok(!JSON.stringify([...client.completed]).includes('private prompt'));
  await assert.rejects(client.send('thread', 'changed message', 'command-599', 'message-599'), /same message/);
});
