import { spawn } from 'node:child_process';
import { mkdtemp, rm, access } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { nestEnv } from './nest.js';

// One encoder per desktop, shared by viewers and stopped with the last viewer.
export function createViewerStreams({ nest, wayland, command = 'wayvnc', spawnProcess = spawn }) {
  const entries = new Map();
  async function start(n, profile) {
    if (!wayland) return { endpoint: { host: '127.0.0.1', port: nest.info(n).port }, close: async () => {} };
    const dir = await mkdtemp(join(tmpdir(), 'agent-viewer-'));
    const path = join(dir, 'vnc');
    const child = spawnProcess(command, ['-C', '/dev/null', '-o', 'agent-main', '-r', '-f', profile === 'preview' ? '5' : '20', '-R', '-S', join(dir, 'control'), `unix:${path}`],
      { env: nestEnv(n), stdio: ['ignore', 'ignore', 'pipe'] });
    let failure, exited = false, stderr = '';
    child.stderr?.on('data', data => { stderr = (stderr + data).slice(-2000); });
    child.on('error', error => { failure = error; });
    const stopped = new Promise(resolve => child.once('close', () => { exited = true; resolve(); }));
    const close = async () => {
      if (!exited) {
        child.kill('SIGTERM');
        const force = setTimeout(() => { if (!exited) child.kill('SIGKILL'); }, 2000);
        await stopped; clearTimeout(force);
      }
      await rm(dir, { recursive: true, force: true });
    };
    try {
      for (let i = 0; i < 100; i++) {
        if (failure || exited) throw new Error(failure?.code === 'ENOENT' ? 'WayVNC is not installed on this machine.' : `Desktop stream failed to start: ${stderr || failure?.message || 'process exited'}`);
        try { await access(path); return { endpoint: { path }, close }; } catch { /* Waiting for WayVNC to bind its private socket. */ }
        await new Promise(resolve => setTimeout(resolve, 50));
      }
      throw new Error('Desktop stream startup timed out.');
    } catch (error) { await close(); throw error; }
  }
  return {
    async acquire(n, generation, profile = 'full') {
      profile = profile === 'preview' ? 'preview' : 'full';
      const key = `${n}:${generation}:${profile}`;
      let entry = entries.get(key);
      if (!entry) { entry = { refs: 0, ready: start(n, profile) }; entries.set(key, entry); }
      entry.refs++;
      let resource;
      try { resource = await entry.ready; }
      catch (error) { if (entries.get(key) === entry) entries.delete(key); throw error; }
      let released = false;
      return { endpoint: resource.endpoint, async release() {
        if (released) return;
        released = true;
        if (--entry.refs === 0) { if (entries.get(key) === entry) entries.delete(key); await resource.close(); }
      } };
    },
    async close() {
      const all = [...entries.values()]; entries.clear();
      await Promise.allSettled(all.map(async entry => (await entry.ready).close()));
    }
  };
}
