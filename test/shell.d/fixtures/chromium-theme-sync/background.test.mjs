import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const extension = new URL('../../../../default/chromium/extensions/theme-sync/', import.meta.url);
const manifest = JSON.parse(readFileSync(new URL('manifest.json', extension), 'utf8'));
const source = readFileSync(new URL(manifest.background.service_worker, extension), 'utf8');
const palette = { type: 'palette', name: 'Tokyo Night', mode: 'dark', colors: { background: '#1a1b26', accent: '#7aa2f7' } };
const page = { origin: 'https://omarchy.org', url: 'https://omarchy.org/', frameId: 0 };
const flush = () => new Promise(setImmediate);

function event() {
  const listeners = [];
  return {
    addListener: (listener) => listeners.push(listener),
    emit: (...args) => listeners.map((listener) => listener(...args)),
  };
}

// Runs the worker against a fake chrome.* surface. The context deliberately has
// no fetch, URL, or btoa global: the read-only worker must not need any of them.
function worker({ stored = {}, tabs = [{ id: 1 }, { id: 2 }, {}] } = {}) {
  const storage = { ...stored };
  const timers = new Map();
  const ports = [];
  const posts = [];
  const sent = [];
  const messages = event();
  let timerId = 0;
  let connectError = null;
  const context = vm.createContext({
    setTimeout: (callback, delay) => {
      const id = ++timerId;
      timers.set(id, { callback, delay });
      return id;
    },
    clearTimeout: (id) => timers.delete(id),
    chrome: {
      runtime: {
        onMessage: messages,
        onStartup: event(),
        onInstalled: event(),
        connectNative: (name) => {
          if (connectError) throw connectError;
          const port = { name, onMessage: event(), onDisconnect: event(), postMessage: (message) => posts.push(message) };
          ports.push(port);
          return port;
        },
      },
      storage: {
        local: {
          get: async (key) => (key in storage ? { [key]: storage[key] } : {}),
          set: async (items) => { Object.assign(storage, items); },
        },
      },
      tabs: {
        query: (_query, callback) => callback(tabs),
        sendMessage: (tabId, message, callback) => {
          // A JSON round trip strips the vm realm's prototypes so strict deep equality can compare it.
          sent.push({ tabId, message: JSON.parse(JSON.stringify(message)) });
          if (callback) callback();
        },
      },
    },
  });
  vm.runInContext(source, context);
  return {
    ports, posts, sent, storage, timers,
    port: () => ports.at(-1),
    send(message, sender = page) {
      const replies = [];
      const claimed = messages.emit(message, sender, (reply) => replies.push(reply));
      return { claimed, replies };
    },
    fire() {
      assert.equal(timers.size, 1, 'exactly one pending timer');
      const [id, { callback, delay }] = [...timers.entries()][0];
      timers.delete(id);
      callback();
      return delay;
    },
    failConnect(error) { connectError = error; },
  };
}

test('opens one native port on load and fans each palette out to every tab', async () => {
  const w = worker();
  assert.equal(w.ports.length, 1);
  assert.equal(w.port().name, 'com.omarchy.theme');
  w.port().onMessage.emit(palette);
  await flush();
  assert.deepEqual(w.storage.palette, palette);
  assert.deepEqual(w.sent, [
    { tabId: 1, message: { type: 'palette', palette } },
    { tabId: 2, message: { type: 'palette', palette } },
  ]);
  assert.equal(w.posts.length, 0, 'the worker never writes to the port');
});

test('ignores port messages that are not a palette', async () => {
  const w = worker();
  for (const message of [null, undefined, {}, { type: 'theme-result', id: '1', ok: true }, { type: 'install-theme' }]) {
    w.port().onMessage.emit(message);
  }
  await flush();
  assert.equal(w.storage.palette, undefined);
  assert.equal(w.sent.length, 0);
});

test('reconnects with capped exponential backoff and resets after a healthy palette', () => {
  const w = worker();
  const delays = [];
  for (let i = 0; i < 8; i++) {
    w.port().onDisconnect.emit();
    delays.push(w.fire());
  }
  assert.deepEqual(delays, [1000, 2000, 4000, 8000, 16000, 32000, 60000, 60000]);
  assert.equal(w.ports.length, 9);
  w.port().onMessage.emit(palette);
  w.port().onDisconnect.emit();
  assert.equal(w.fire(), 1000);
});

test('a failing connectNative schedules a retry instead of throwing', () => {
  const w = worker();
  w.port().onDisconnect.emit();
  w.failConnect(new Error('no such native host'));
  assert.equal(w.fire(), 1000);
  assert.equal(w.ports.length, 1);
  assert.equal(w.timers.size, 1, 'a retry is pending');
  w.failConnect(null);
  assert.equal(w.fire(), 2000);
  assert.equal(w.ports.length, 2);
});

test('answers the content script from the cache and reopens a dead port', async () => {
  const w = worker({ stored: { palette } });
  w.port().onDisconnect.emit();
  assert.equal(w.ports.length, 1);
  const { claimed, replies } = w.send({ type: 'omarchy-get-palette' });
  assert.deepEqual(claimed, [true], 'the channel stays open for the async storage read');
  assert.equal(w.ports.length, 2, 'the request reopens the port without waiting for the retry timer');
  await flush();
  assert.deepEqual(replies, [palette]);

  const cold = worker();
  const request = cold.send({ type: 'omarchy-get-palette' });
  await flush();
  assert.deepEqual(request.replies, [null]);
});

test('theme write requests from any page are neither claimed, answered, nor forwarded', async () => {
  const w = worker({ stored: { palette } });
  for (const message of [
    { type: 'omarchy-can-set-theme' },
    { type: 'omarchy-set-theme', name: 'Tokyo Night' },
    { type: 'omarchy-install-theme', name: 'Review', colors: palette.colors },
  ]) {
    const { claimed, replies } = w.send(message);
    await flush();
    assert.ok(claimed.every((value) => !value), JSON.stringify(message));
    assert.deepEqual(replies, []);
  }
  assert.equal(w.posts.length, 0);
  assert.equal(w.timers.size, 0);
});

test('the manifest grants only native messaging and storage', () => {
  assert.deepEqual(manifest.permissions, ['nativeMessaging', 'storage']);
  assert.equal(Object.hasOwn(manifest, 'host_permissions'), false);
});
