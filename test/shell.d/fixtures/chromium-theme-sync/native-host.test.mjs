import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { mkdtemp, mkdir, readdir, readFile, rename, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../../../../', import.meta.url));
const host = join(root, 'bin/omarchy-browser-theme-host');
const LIMIT = 1024 * 1024;
const source = 'background = "#112233"\nforeground = "#ddeeff"\naccent = "#445566"\n';
const colors = { accent: '#445566', background: '#112233', foreground: '#ddeeff' };
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

function frame(message, advertised) {
  const body = Buffer.isBuffer(message) ? message : Buffer.from(JSON.stringify(message));
  const header = Buffer.alloc(4);
  header.writeUInt32LE(advertised ?? body.length);
  return Buffer.concat([header, body]);
}

async function sandbox(t, prefix = 'omarchy-native-') {
  const directory = await mkdtemp(join(tmpdir(), prefix));
  const home = join(directory, 'home');
  const state = join(home, '.local/state/omarchy/current');
  const runtime = join(directory, 'runtime');
  await mkdir(join(state, 'theme'), { recursive: true });
  await mkdir(runtime);
  const env = { ...process.env, HOME: home, XDG_RUNTIME_DIR: runtime, OMARCHY_PATH: root };
  delete env.BASH_ENV;
  delete env.ENV;
  t.after(() => rm(directory, { recursive: true, force: true }));

  async function theme(text = source) {
    await writeFile(join(state, 'theme/colors.toml'), text);
    await writeFile(join(state, 'theme.name'), 'Synthetic private name never exported');
  }

  function start() {
    // Exercise the actual executable and main loop, not a sourced fixture.
    const child = spawn(host, [], { env, stdio: ['pipe', 'pipe', 'pipe'] });
    const messages = [];
    let buffer = Buffer.alloc(0);
    let stderr = '';
    child.stderr.on('data', chunk => { stderr += chunk; });
    child.stdin.on('error', () => {});
    child.stdout.on('data', chunk => {
      buffer = Buffer.concat([buffer, chunk]);
      while (buffer.length >= 4) {
        const length = buffer.readUInt32LE();
        assert.ok(length > 0 && length <= LIMIT);
        if (buffer.length < length + 4) break;
        messages.push(JSON.parse(buffer.subarray(4, length + 4).toString()));
        buffer = buffer.subarray(length + 4);
      }
    });
    const finished = once(child, 'close');
    const timeout = setTimeout(() => child.kill('SIGKILL'), 10000);
    t.after(() => { clearTimeout(timeout); child.kill('SIGKILL'); });
    async function until(count) {
      for (let i = 0; i < 200 && messages.length < count; i++) await delay(10);
      assert.ok(messages.length >= count, `received ${count} frames: ${stderr}`);
      return messages.at(-1);
    }
    async function close(input = Buffer.alloc(0)) {
      child.stdin.end(input);
      const [code, signal] = await finished;
      clearTimeout(timeout);
      assert.equal(signal, null, stderr);
      assert.equal(code, 0, stderr);
      assert.equal(buffer.length, 0, 'every emitted frame is complete');
      return messages;
    }
    return { child, messages, until, close, finished };
  }
  return { directory, home, state, runtime, theme, start };
}

test('actual host pushes normalized colors and treats legacy write requests only as resync', async t => {
  const s = await sandbox(t);
  await s.theme(source);
  const host = s.start();
  const messages = await host.close(Buffer.concat([
    frame({}), frame({ type: 'set-theme', name: 'no' }), frame({ type: 'install-theme', colors }),
  ]));
  assert.deepEqual(messages, Array(4).fill({ type: 'palette', mode: 'dark', colors }));
  assert.equal(await readFile(join(s.state, 'theme.name'), 'utf8'), 'Synthetic private name never exported');
  assert.deepEqual(await readdir(s.runtime), [], 'no lock or temporary files');
});

test('only known top-level hex colors are exported; tables, identifiers, names and CSS URLs stay private', async t => {
  const s = await sandbox(t);
  await s.theme([
    'accent = "#ABCDEF"', 'background = "url(https://invalid.example/pixel)"',
    'mode = "private-mode"', 'client_0123456789abcdef = "#000000"',
    'profile = "synthetic-private"', 'red = "rgba(0,0,0,1)"',
    '[private]', 'api_token = "synthetic-secret"', 'foreground = "#112233"', '',
  ].join('\n'));
  assert.deepEqual((await s.start().close())[0], { type: 'palette', mode: 'dark', colors: { accent: '#abcdef' } });
});

test('mode follows explicit mode, theme_type, light.mode, background brightness and dark fallback', async t => {
  const s = await sandbox(t);
  for (const [text, marker, mode] of [
    ['mode="dark"\ntheme_type="light"\nbackground="#ffffff"', true, 'dark'],
    ['theme_type="light"\nbackground="#000000"', false, 'light'],
    ['background="#000000"', true, 'light'],
    ['background="#ffffff"', false, 'light'],
    ['color0="#ffffff"', false, 'light'],
    ['bg="#ffffff"', false, 'light'],
    ['background="#7f7f80"', false, 'dark'],
    ['background="#7f7f81"', false, 'light'],
    ['mode="invalid"\nbackground="invalid"', false, 'dark'],
  ]) {
    await s.theme(text);
    await rm(join(s.state, 'theme/light.mode'), { force: true });
    if (marker) await writeFile(join(s.state, 'theme/light.mode'), '');
    assert.equal((await s.start().close())[0].mode, mode, text);
  }
});

test('missing, oversized, malformed and non-UTF8 palettes fail closed', async t => {
  const s = await sandbox(t);
  for (const text of [null, 'x'.repeat(65537), 'background="unterminated', Buffer.from([255, 254])]) {
    await rm(join(s.state, 'theme/colors.toml'), { force: true });
    if (text !== null) await writeFile(join(s.state, 'theme/colors.toml'), text);
    assert.deepEqual((await s.start().close())[0], { type: 'palette', mode: 'dark', colors: {} });
  }
});

test('native framing refuses oversized, partial, NUL-containing and malformed frames', async t => {
  const s = await sandbox(t);
  await s.theme();
  const request = Buffer.from('{}');
  for (const input of [
    Buffer.from([1, 0, 0]), frame(Buffer.alloc(0), 0), frame(Buffer.alloc(0), LIMIT + 1),
    frame(Buffer.alloc(0), 0xffffffff), frame(request, 12), frame(Buffer.from('{}garbage')),
    frame(Buffer.from('{}{}')), frame(Buffer.from('{}\0')), frame(Buffer.from('[]')),
    frame(Buffer.from('"string"')), frame(Buffer.from([255])),
  ]) assert.equal((await s.start().close(input)).length, 1);
  const padded = Buffer.concat([request, Buffer.alloc(LIMIT - request.length, 32)]);
  assert.equal((await s.start().close(frame(padded))).length, 2);
});

test('live updates survive spaces, direct palette edits, light.mode edits and theme directory replacement', async t => {
  const s = await sandbox(t, 'omarchy host with spaces-');
  await s.theme();
  const host = s.start();
  await host.until(1);
  await writeFile(join(s.state, 'theme/colors.toml'), 'background="#ffffff"');
  assert.equal((await host.until(2)).mode, 'light');
  await writeFile(join(s.state, 'theme/colors.toml'), 'background="#000000"');
  assert.equal((await host.until(3)).mode, 'dark');
  await writeFile(join(s.state, 'theme/light.mode'), '');
  assert.equal((await host.until(4)).mode, 'light');
  await mkdir(join(s.state, 'next-theme'));
  await writeFile(join(s.state, 'next-theme/colors.toml'), 'accent="#123456"');
  await rm(join(s.state, 'theme'), { recursive: true });
  await rename(join(s.state, 'next-theme'), join(s.state, 'theme'));
  assert.deepEqual((await host.until(5)).colors, { accent: '#123456' });
  await host.close();
});

test('EOF and SIGTERM close the real event loop with no child watcher or lock file', async t => {
  const s = await sandbox(t);
  await s.theme();
  for (const terminate of [false, true]) {
    const host = s.start();
    await host.until(1);
    assert.equal((await readFile(`/proc/${host.child.pid}/task/${host.child.pid}/children`, 'utf8')).trim(), '');
    if (terminate) {
      host.child.stdin.write(Buffer.from([10, 0, 0, 0, 123]));
      host.child.kill('SIGTERM');
      assert.deepEqual(await host.finished, [0, null]);
    } else {
      await host.close();
    }
    assert.deepEqual(await readdir(s.runtime), []);
  }
});

test('the worker and native host keep the same fixed palette schema', async () => {
  const source = await readFile(new URL('../../../../default/chromium/extensions/theme-sync/policy.js', import.meta.url), 'utf8');
  const { default: vm } = await import('node:vm');
  const context = vm.createContext({ URL });
  vm.runInContext(source, context);
  const script = 'import runpy,json; print(json.dumps(runpy.run_path(__import__("sys").argv[1])["COLOR_KEYS"]))';
  const child = spawn('/usr/bin/python', ['-c', script, join(root, 'default/chromium/theme-sync-host.py')]);
  let output = '';
  child.stdout.on('data', chunk => { output += chunk; });
  assert.deepEqual(await once(child, 'close'), [0, null]);
  assert.deepEqual(JSON.parse(output), JSON.parse(JSON.stringify(context.ThemeSyncPolicy.colorKeys)));
});
