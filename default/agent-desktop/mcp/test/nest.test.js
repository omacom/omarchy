import assert from 'node:assert/strict';
import { test } from 'node:test';
import { createNest, keyArgs, nestEnv } from '../lib/nest.js';

test('key combos become wtype press/tap/release sequences', () => {
  assert.deepEqual(keyArgs('Return'), ['-k', 'Return']);
  assert.deepEqual(keyArgs('enter'), ['-k', 'Return']);
  assert.deepEqual(keyArgs('ctrl+l'), ['-M', 'ctrl', '-k', 'l', '-m', 'ctrl']);
  assert.deepEqual(keyArgs('ctrl+shift+t'), ['-M', 'ctrl', '-M', 'shift', '-k', 't', '-m', 'shift', '-m', 'ctrl']);
  assert.deepEqual(keyArgs('super+Return'), ['-M', 'logo', '-k', 'Return', '-m', 'logo']);
  assert.throws(() => keyArgs('hyper+x'), /unknown modifier/);
});

test('every nest command carries only that nest\'s names', () => {
  const e = nestEnv(3);
  assert.equal(e.WAYLAND_DISPLAY, 'wayland-agent-3');
  assert.equal(e.DISPLAY, ':93');
  assert.equal(e.HYPRLAND_INSTANCE_SIGNATURE, 'agent-3');
});

test('input on one desktop is serialised, cursor moves precede clicks', async () => {
  const log = [];
  const run = async (cmd, args) => { log.push([cmd, ...args].join(' ')); await new Promise(r => setTimeout(r, 5)); return { stdout: '', stderr: '' }; };
  const nest = createNest({ run, launcher: '/bin/true' });
  await Promise.all([nest.click(1, 10, 20), nest.type(1, 'ab'), nest.key(1, 'ctrl+c')]);
  assert.deepEqual(log, [
    'hyprctl repl hl.dispatch(hl.dsp.cursor.move({ x = 10, y = 20 }))',
    'wlrctl pointer click left',
    'wtype -- ab',
    'wtype -M ctrl -k c -m ctrl'
  ]);
});

test('browser launches have distinct profiles and stop with their desktop service', async () => {
  const calls = [];
  const nest = createNest({ run: async (cmd, args) => { calls.push([cmd, args]); return { stdout: '' }; } });
  await nest.open(1, ['brave', 'about:blank']);
  await nest.open(5, ['brave', 'about:blank']);
  for (const [index, n] of [1, 5].entries()) {
    const [cmd, args] = calls.filter(([cmd]) => cmd === 'systemd-run')[index];
    assert.equal(cmd, 'systemd-run');
    assert.ok(args.includes(`BindsTo=agent-desktop-${n}.service`));
    assert.ok(args.includes(`After=agent-desktop-${n}.service`));
    assert.ok(args.some(arg => arg.endsWith(`/profiles/${n}/brave`)));
    assert.ok(args.includes(`WAYLAND_DISPLAY=wayland-agent-${n}`));
  }
});
