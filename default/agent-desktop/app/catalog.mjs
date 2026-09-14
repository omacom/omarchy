import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { fileURLToPath } from 'node:url';
const HERE = fileURLToPath(new URL('.', import.meta.url));

export function startCatalog({ launch = () => spawn('python3', [HERE + 'catalog.py'], { stdio: ['pipe', 'pipe', 'inherit'] }), timeout = 60000 } = {}) {
  let child, waiting, closed = false, chain = Promise.resolve();
  function start() {
    const process = launch(); child = process;
    const fail = error => {
      if (child !== process) return;
      child = null; const pending = waiting; waiting = null; pending?.reject(error);
    };
    createInterface({ input: process.stdout }).on('line', line => {
      if (child !== process) return;
      const pending = waiting; waiting = null;
      try { const value = JSON.parse(line); value.error ? pending?.reject(new Error(value.error)) : pending?.resolve(value.desktops); }
      catch (error) { pending?.reject(error); }
    });
    process.on('error', fail); process.stdin.on('error', fail);
    process.on('exit', () => fail(new Error('Session lookup stopped. Retrying on the next refresh.')));
  }
  return { read(leases) {
    const next = chain.then(() => new Promise((resolve, reject) => {
      if (closed) return reject(new Error('Session lookup is closed.'));
      if (!child) start();
      const process = child;
      const timer = setTimeout(() => {
        if (child === process) { child = null; waiting = null; process.kill(); }
        reject(new Error('Session lookup timed out. Retrying on the next refresh.'));
      }, timeout);
      waiting = { resolve: value => { clearTimeout(timer); resolve(value); }, reject: error => { clearTimeout(timer); reject(error); } };
      process.stdin.write(JSON.stringify({ leases }) + '\n');
    }));
    chain = next.catch(() => {}); return next;
  }, close() { closed = true; child?.stdin.end(); } };
}
