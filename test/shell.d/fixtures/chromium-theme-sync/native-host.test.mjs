import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, mkdir, readdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const fixture = fileURLToPath(new URL('./native-host-fixture.sh', import.meta.url));
const FRAME_LIMIT = 1024 * 1024;
const toml = 'background = "#112233"\nforeground = "#ddeeff"\naccent = "#445566"\n';
const colors = { background: '#112233', foreground: '#ddeeff', accent: '#445566' };

function frame(message, advertisedLength) {
  const body = Buffer.isBuffer(message) ? message : Buffer.from(JSON.stringify(message));
  const header = Buffer.alloc(4);
  header.writeUInt32LE(advertisedLength ?? body.length);
  return Buffer.concat([header, body]);
}

function parseFrames(buffer) {
  const messages = [];
  for (let offset = 0; offset < buffer.length;) {
    assert.ok(buffer.length - offset >= 4, 'complete response header');
    const length = buffer.readUInt32LE(offset);
    offset += 4;
    assert.ok(length > 0 && length <= 1024 * 1024, 'bounded response');
    assert.ok(buffer.length - offset >= length, 'complete response body');
    messages.push(JSON.parse(buffer.subarray(offset, offset + length).toString()));
    offset += length;
  }
  return messages;
}

async function sandbox(t) {
  const root = await mkdtemp(join(tmpdir(), 'omarchy-native-host-test-'));
  const home = join(root, 'home');
  const current = join(home, '.local/state/omarchy/current');
  const mockBin = join(root, 'bin');
  const env = {
    ...process.env, TEST_ROOT: root, HOME: home, PATH: `${mockBin}:${process.env.PATH}`,
    XDG_CONFIG_HOME: join(home, '.config'), XDG_STATE_HOME: join(home, '.local/state'),
    XDG_CACHE_HOME: join(home, '.cache'), XDG_RUNTIME_DIR: join(root, 'runtime'), TMPDIR: join(root, 'tmp'),
  };
  delete env.BASH_ENV;
  delete env.ENV;
  for (const path of [current, mockBin, env.XDG_RUNTIME_DIR, env.TMPDIR]) await mkdir(path, { recursive: true });
  // Canaries: the read-only host must never reach for the desktop theme commands.
  for (const command of ['omarchy-theme-set', 'omarchy-theme-list']) {
    await writeFile(join(mockBin, command), `#!/bin/bash\ntouch "$TEST_ROOT/invoked-${command}"\n`, { mode: 0o755 });
  }
  t.after(() => rm(root, { recursive: true, force: true }));

  async function run(input = Buffer.alloc(0)) {
    const child = spawn('/bin/bash', [fixture], { env, stdio: ['pipe', 'pipe', 'pipe'] });
    const stdout = [], stderr = [];
    child.stdout.on('data', chunk => stdout.push(chunk));
    child.stderr.on('data', chunk => stderr.push(chunk));
    child.stdin.on('error', () => {});
    const timer = setTimeout(() => child.kill('SIGKILL'), 30000);
    try {
      const finished = new Promise((resolve, reject) => {
        child.on('error', reject);
        child.on('close', (code, signal) => resolve({ code, signal }));
      });
      child.stdin.end(input);
      const exit = await finished;
      assert.equal(exit.signal, null, Buffer.concat(stderr).toString());
      assert.equal(exit.code, 0, Buffer.concat(stderr).toString());
      assert.deepEqual(await readdir(env.XDG_RUNTIME_DIR), [], 'the frame lock is removed on exit');
      return { messages: parseFrames(Buffer.concat(stdout)), stderr: Buffer.concat(stderr).toString() };
    } finally {
      clearTimeout(timer);
      child.kill('SIGKILL');
    }
  }
  async function theme(name, source) {
    await mkdir(join(current, 'theme'), { recursive: true });
    await writeFile(join(current, 'theme.name'), name);
    await writeFile(join(current, 'theme/colors.toml'), source);
  }
  async function untouched() {
    assert.deepEqual(await readdir(home), ['.local'], 'nothing is written under HOME');
    assert.deepEqual(await readdir(join(home, '.local/state/omarchy')), ['current'], 'no install state appears');
    assert.deepEqual((await readdir(root)).filter(name => name.startsWith('invoked-')), [], 'no theme command runs');
  }
  return { root, home, current, env, run, theme, untouched };
}

test('pushes the palette on connect and repeats it for every resync request', async t => {
  const s = await sandbox(t);
  await s.theme('Tokyo Night\n', `mode = "light"\n${toml}`);
  const result = await s.run(Buffer.concat([frame({}), frame({ type: 'get-palette' })]));
  const expected = { type: 'palette', name: 'Tokyo Night', mode: 'light', colors };
  assert.deepEqual(result.messages, [expected, expected, expected]);
  assert.equal(result.stderr, '');
  await s.untouched();
});

test('reads only flat double-quoted lowercase keys and defaults the mode to dark', async t => {
  const s = await sandbox(t);
  await s.theme('Plain', [
    '# comment', 'background = "#112233"', 'foreground="#ddeeff" # trailing comment', "accent = '#445566'",
    '  bright_green = "#9ece6a"', 'number = 3', 'Upper = "#000000"', 'spaced key = "#000000"', '',
  ].join('\n'));
  const [message] = (await s.run()).messages;
  assert.deepEqual(message, {
    type: 'palette', name: 'Plain', mode: 'dark',
    colors: { background: '#112233', foreground: '#ddeeff', bright_green: '#9ece6a' },
  });
});

test('missing theme state yields an empty palette instead of an error', async t => {
  const s = await sandbox(t);
  const result = await s.run(frame({}));
  assert.deepEqual(result.messages, Array(2).fill({ type: 'palette', name: '', mode: 'dark', colors: {} }));
  assert.equal(result.stderr, '');
});

test('legacy theme write requests get nothing but the palette and change nothing', async t => {
  const s = await sandbox(t);
  await s.theme('Example', toml);
  const result = await s.run(Buffer.concat([
    frame({ type: 'set-theme', id: 'set', name: 'Example' }),
    frame({ type: 'install-theme', id: 'install', name: 'Review', colors }),
  ]));
  assert.equal(result.messages.length, 3);
  assert.ok(result.messages.every(message => message.type === 'palette'));
  assert.ok(result.messages.every(message => !('id' in message) && !('ok' in message)));
  await s.untouched();
});

test('native framing refuses oversized, partial, NUL-containing, and malformed JSON frames', async t => {
  const s = await sandbox(t);
  const request = Buffer.from(JSON.stringify({ type: 'get-palette' }));
  for (const input of [
    Buffer.from([1, 0, 0]), frame(Buffer.alloc(0), 0), frame(Buffer.alloc(0), FRAME_LIMIT + 1),
    frame(Buffer.alloc(0), 0xffffffff), frame(request, request.length + 10),
    frame(Buffer.concat([request, Buffer.from('garbage')])), frame(Buffer.concat([request, request])),
    frame(Buffer.concat([request, Buffer.from([0])])), frame(Buffer.from('[]')), frame(Buffer.from('"string"')),
    frame(Buffer.concat([request, Buffer.alloc(FRAME_LIMIT - request.length + 1, 0x20)])),
  ]) {
    const result = await s.run(input);
    assert.equal(result.messages.length, 1, 'only the connect push, then the port closes');
  }
  const padded = Buffer.concat([request, Buffer.alloc(FRAME_LIMIT - request.length, 0x20)]);
  assert.equal((await s.run(frame(padded))).messages.length, 2, 'a frame at exactly the cap is a resync');
});

test('palette output is bounded, uses stdin rather than a large argv, and supports resync', async t => {
  const s = await sandbox(t);
  // ASCII JSON escaping expands this below-cap source past Linux MAX_ARG_STRLEN.
  await s.theme('Tøkyø', `background = "${'\x01'.repeat(30000)}"\n`);
  const result = await s.run(Buffer.concat([frame({}), frame({ type: 'get-palette' })]));
  assert.equal(result.messages.length, 3);
  assert.ok(result.messages.every(message => message.colors.background.length === 30000 && message.name === 'Tøkyø'));
  await s.theme('n'.repeat(200000), 'x'.repeat(65537));
  const oversized = await s.run();
  assert.deepEqual(oversized.messages[0].colors, {});
  assert.equal(oversized.messages[0].name.length, 64);
  assert.equal(oversized.stderr, '');
});
