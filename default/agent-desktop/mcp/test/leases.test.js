import assert from 'node:assert/strict';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { HandleError, Leases } from '../lib/leases.js';

const clock = () => { let t = 1_000_000; return { now: () => t, tick: ms => { t += ms; } }; };

test('claims hand out the lowest free desktop and renew on use', () => {
  const c = clock();
  const l = new Leases({ now: c.now, idleMs: 1000 });
  const a = l.claim('a');
  const b = l.claim('b');
  assert.equal(a.desktop, 1);
  assert.equal(b.desktop, 2);
  assert.match(a.handle, /^d1-[0-9a-f]{8}$/);
  c.tick(900);
  l.touch(a.handle);
  c.tick(900);
  assert.equal(l.touch(a.handle).desktop, 1, 'renewed lease is still live');
  assert.throws(() => l.touch(b.handle), HandleError, 'idle lease expired');
  assert.equal(l.claim('c').desktop, 3, 'expired desktop stays reserved until its processes stop');
  l.release(b.handle);
  assert.equal(l.claim('d').desktop, 2);
});

test('release frees the desktop and unknown handles are rejected', () => {
  const l = new Leases();
  const a = l.claim('a');
  l.release(a.handle);
  assert.throws(() => l.touch(a.handle), HandleError);
  assert.equal(l.claim('b').desktop, 1);
  assert.throws(() => l.release('d9-nope'), HandleError);
});

test('status reports only allocated desktops and their holders', () => {
  const l = new Leases();
  l.claim('x'); l.claim('y');
  assert.deepEqual(l.status().map(s => [s.desktop, s.held, s.owner]), [[1, true, 'x'], [2, true, 'y']]);
});

test('frames gate coordinates to the latest observe', () => {
  const l = new Leases();
  const a = l.claim('a');
  assert.throws(() => l.checkFrame(a.desktop, 'f1-old'), /observe before/);
  const f1 = l.newFrame(a.desktop);
  l.checkFrame(a.desktop, f1);
  const f2 = l.newFrame(a.desktop);
  assert.throws(() => l.checkFrame(a.desktop, f1), /stale frame/);
  l.checkFrame(a.desktop, f2);
});

test('leases survive a restart through the state file', () => {
  const file = join(mkdtempSync(join(tmpdir(), 'leases-')), 'leases.json');
  const a = new Leases({ file }).claim('a');
  const again = new Leases({ file });
  assert.equal(again.touch(a.handle).desktop, 1);
  assert.equal(again.claim('b').desktop, 2);
});

test('on-demand allocation starts empty and grows beyond four', () => {
   const leases = new Leases();
   assert.deepEqual(leases.status(), []);
   const desktops = Array.from({ length: 12 }, () => leases.claim('parallel task').desktop);
   assert.equal(new Set(desktops).size, 12);
   assert.equal(desktops.at(-1), 12);
 });
