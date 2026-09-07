// Explicit handles instead of sessions (MCP 2026-07-28, SEP-2567): claim mints a
// handle the model passes back on every call. A lease renews on use and expires
// idle, so a thread that stops using its desktop frees it with no session for
// the server to watch. Persisted so a server restart keeps the table.
import { randomBytes } from 'node:crypto';
import { mkdirSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';

export const IDLE_MS = 30 * 60 * 1000;

export class HandleError extends Error {}

export class Leases {
  constructor({ file = null, now = () => Date.now(), idleMs = IDLE_MS } = {}) {
    this.file = file;
    this.now = now;
    this.idleMs = idleMs;
    this.byHandle = new Map();
    this.frames = new Map();
    this.load();
  }

  load() {
    if (!this.file) return;
    try {
      for (const l of JSON.parse(readFileSync(this.file, 'utf8'))) this.byHandle.set(l.handle, l);
    } catch {
      // first run or unreadable file: start empty
    }
  }

  save() {
    if (!this.file) return;
    mkdirSync(dirname(this.file), { recursive: true });
    const tmp = `${this.file}.tmp`;
    writeFileSync(tmp, JSON.stringify([...this.byHandle.values()]));
    renameSync(tmp, this.file);
  }

  live(l) {
    return this.now() - l.lastUsed < this.idleMs;
  }

  status() {
    return [...this.byHandle.values()].map(l => ({
      desktop: l.desktop, held: this.live(l), owner: l.owner,
      idleMs: this.now() - l.lastUsed
    })).sort((a, b) => a.desktop - b.desktop);
  }

  claim(owner = 'unknown') {
    const occupied = new Set([...this.byHandle.values()].map(l => l.desktop));
    let d = 1;
    while (occupied.has(d)) d++;
    const lease = { handle: `d${d}-${randomBytes(4).toString('hex')}`, desktop: d, owner, created: this.now(), lastUsed: this.now() };
    this.byHandle.set(lease.handle, lease);
    this.save();
    return lease;
  }

  touch(handle) {
    const l = this.byHandle.get(handle);
    if (!l) throw new HandleError(`unknown handle ${handle}; claim a desktop first`);
    if (!this.live(l)) {
      throw new HandleError(`handle ${handle} expired after ${Math.round(this.idleMs / 60000)} min idle; claim again`);
    }
    l.lastUsed = this.now();
    this.save();
    return l;
  }

  release(handle) {
    const l = this.byHandle.get(handle);
    if (!l) throw new HandleError(`unknown handle ${handle}`);
    this.byHandle.delete(handle);
    this.frames.delete(l.desktop);
    this.save();
    return l;
  }

  // Coordinates are only meaningful against the frame the model last saw.
  newFrame(desktop) {
    const id = `f${desktop}-${randomBytes(3).toString('hex')}`;
    this.frames.set(desktop, id);
    return id;
  }

  checkFrame(desktop, frameId) {
    const current = this.frames.get(desktop);
    if (!current) throw new HandleError('no frame yet: call observe before sending coordinates');
    if (frameId !== current) throw new HandleError(`stale frame ${frameId} (current ${current}): observe again before clicking`);
  }
}
