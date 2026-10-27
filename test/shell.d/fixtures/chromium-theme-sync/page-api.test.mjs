import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const extension = new URL('../../../../default/chromium/extensions/theme-sync/', import.meta.url);
const scripts = Object.fromEntries(['policy.js', 'content.js', 'page-api.js'].map(name =>
  [name, readFileSync(new URL(name, extension), 'utf8')]));
const id = 'ppnnomfimbfcofidkfmghapellfbgklc';
const palette = { type: 'palette', mode: 'dark', name: 'private name', colors: {
  background: '#1a1b26', bright_green: '#9ece6a', broken: '#123456', api_token: 'synthetic-secret', accent: 'url(https://invalid.example/pixel)',
} };
const plain = value => JSON.parse(JSON.stringify(value));

function styleDeclaration() {
  const values = new Map();
  const style = {
    get length() { return values.size; },
    setProperty(name, value) { values.set(name, value); index(); },
    removeProperty(name) { values.delete(name); index(); },
    getPropertyValue(name) { return values.get(name) ?? ''; },
    [Symbol.iterator]() { return values.keys(); },
  };
  function index() {
    for (const key of Object.keys(style)) if (/^\d+$/.test(key)) delete style[key];
    [...values.keys()].forEach((name, i) => { style[i] = name; });
  }
  return style;
}

function page({ noRoot = false, existingApi } = {}) {
  const document = new EventTarget();
  const root = { style: styleDeclaration(), dataset: {} };
  document.documentElement = noRoot ? null : root;
  const window = existingApi ? { omarchy: existingApi } : {};
  const requests = [], pending = [], listeners = [];
  const globals = { Event, CustomEvent, document, URL };
  const main = vm.createContext({ ...globals, window });
  const isolated = vm.createContext({ ...globals, chrome: {
    runtime: {
      id,
      onMessage: { addListener: listener => listeners.push(listener) },
      sendMessage: (message, callback) => {
        requests.push(plain(message));
        if (message.type === 'omarchy-get-palette') pending.push(callback);
        if (message.type === 'omarchy-enable-api') {
          vm.runInContext(scripts['page-api.js'], main);
          callback(true);
        }
      },
    },
  } });
  vm.runInContext(scripts['policy.js'], isolated);
  vm.runInContext(scripts['content.js'], isolated);
  return {
    window, document, root, requests, pending, main,
    get api() { return window.omarchy; },
    reply(value = palette, index = 0) { pending.splice(index, 1)[0](value); },
    broadcast(sender = { id }) { listeners.forEach(listener => listener({ type: 'omarchy-palette', palette }, sender)); },
    clear() { listeners.forEach(listener => listener({ type: 'omarchy-clear-palette' }, { id })); },
    injectAgain() { vm.runInContext(scripts['policy.js'], isolated); vm.runInContext(scripts['content.js'], isolated); },
  };
}

test('unapproved documents receive no API, attributes, colors or page-to-worker bridge', () => {
  const p = page();
  p.root.style.setProperty('--omarchy-background', '#123456');
  p.reply(null);
  assert.equal(p.api, undefined);
  assert.deepEqual(p.root.dataset, {});
  assert.equal(p.root.style.getPropertyValue('--omarchy-background'), '#123456', 'does not erase a site-owned fallback');
  vm.runInContext(scripts['page-api.js'], p.main);
  assert.equal(p.api, undefined, 'main-world script itself also refuses an unapproved DOM');
  for (const type of ['__omarchy_request', 'omarchy-get-palette']) {
    p.document.dispatchEvent(new CustomEvent(type, { detail: JSON.stringify({ kind: 'install', name: 'unsafe' }) }));
  }
  assert.deepEqual(p.requests, [{ type: 'omarchy-get-palette' }]);
});

test('authorized delivery exports only fixed validated colors and mode, never a theme name', () => {
  const p = page();
  p.root.dataset.omarchyTheme = 'stale private name';
  p.reply();
  assert.equal(p.api.theme, null);
  assert.equal(p.api.mode, 'dark');
  assert.equal(p.root.dataset.omarchyTheme, undefined);
  assert.equal(p.root.dataset.omarchySharing, 'true');
  assert.deepEqual(plain(p.api.colors()), { background: '#1a1b26', bright_green: '#9ece6a' });
  assert.equal(p.api.color('bright-green'), '#9ece6a');
  for (const key of ['api_token', 'broken', 'accent', 'missing', '__proto__', 'toString', 'constructor']) {
    assert.equal(p.api.color(key), null, key);
  }
  assert.ok(Object.isFrozen(p.api));
  assert.equal(Object.getPrototypeOf(p.api.colors()), null);
});

test('theme changes preserve the API, remove vanished colors and notify frozen snapshots once', () => {
  const p = page();
  p.reply();
  const api = p.api;
  const seen = [];
  const stop = api.onChange(value => seen.push(value));
  p.broadcast();
  p.reply({ type: 'palette', mode: 'light', colors: { accent: '#abcdef' } });
  assert.equal(p.api, api);
  assert.equal(p.api.mode, 'light');
  assert.deepEqual(plain(p.api.colors()), { accent: '#abcdef' });
  assert.equal(seen.length, 1);
  assert.ok(Object.isFrozen(seen[0]));
  stop();
  p.broadcast();
  p.reply(palette);
  assert.equal(seen.length, 1);
});

test('revocation removes API, attributes and colors and prevents delayed reads from republishing', () => {
  const p = page();
  p.reply();
  p.broadcast();
  p.clear();
  p.reply(palette);
  assert.equal(p.api, undefined);
  assert.equal(p.root.style.length, 0);
  assert.deepEqual(p.root.dataset, {});
  // An old broadcast does not itself authorize anything: it must ask again.
  p.broadcast();
  assert.equal(p.api, undefined);
  p.reply(null);
  assert.equal(p.api, undefined);
});

test('out-of-order snapshots cannot overwrite a newer palette', () => {
  const p = page();
  p.broadcast();
  p.reply({ type: 'palette', mode: 'light', colors: { accent: '#abcdef' } }, 1);
  p.reply(palette);
  assert.deepEqual(plain(p.api.colors()), { accent: '#abcdef' });
});

test('a document_start delivery waits for the root and a revocation cancels that pending update', () => {
  const p = page({ noRoot: true });
  p.reply();
  assert.equal(p.api, undefined);
  p.document.documentElement = p.root;
  p.document.dispatchEvent(new Event('DOMContentLoaded'));
  assert.equal(p.api.mode, 'dark');
  const revoked = page({ noRoot: true });
  revoked.reply();
  revoked.clear();
  revoked.document.documentElement = revoked.root;
  revoked.document.dispatchEvent(new Event('DOMContentLoaded'));
  assert.equal(revoked.api, undefined);
});

test('forged messages are ignored and repeated injection does not duplicate listeners', () => {
  const p = page();
  p.broadcast({ id: 'another-extension' });
  p.broadcast({ id, tab: { id: 123 } });
  assert.equal(p.pending.length, 1);
  p.injectAgain();
  assert.equal(p.pending.length, 1);
  p.reply();
  p.broadcast();
  assert.equal(p.pending.length, 1);
});

test('the API has no theme write methods and does not replace a site-owned window.omarchy', () => {
  const p = page();
  p.reply();
  assert.deepEqual(Object.keys(p.api).sort(), ['color', 'colors', 'mode', 'onChange', 'theme']);
  for (const method of ['setTheme', 'installTheme', 'canSetTheme']) assert.equal(p.api[method], undefined);
  const own = { site: true };
  const existing = page({ existingApi: own });
  existing.reply();
  existing.clear();
  assert.equal(existing.api, own);
});
