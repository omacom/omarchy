import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const extension = new URL('../../../../default/chromium/extensions/theme-sync/', import.meta.url);
const manifest = JSON.parse(readFileSync(new URL('manifest.json', extension), 'utf8'));
const scripts = Object.fromEntries(['content.js', 'page-api.js'].map((name) =>
  [name, readFileSync(new URL(name, extension), 'utf8')]));
const palette = {
  type: 'palette', name: 'Tokyo Night', mode: 'dark',
  colors: { background: '#1a1b26', bright_green: '#9ece6a', broken: 7 },
};
const flush = () => new Promise(setImmediate);
// Objects built inside a vm context carry that realm's prototypes, which strict
// deep equality rejects. A JSON round trip makes them comparable to literals.
const plain = (value) => JSON.parse(JSON.stringify(value));

// Enough of CSSStyleDeclaration for both worlds: the isolated script sets and
// removes custom properties, and the main-world API enumerates them by index.
function styleDeclaration() {
  const values = new Map();
  const style = {
    get length() { return values.size; },
    setProperty(name, value) { values.set(name, value); index(); },
    removeProperty(name) { values.delete(name); index(); },
    getPropertyValue(name) { return values.get(name) ?? ''; },
  };
  function index() {
    for (const key of Object.keys(style)) if (/^\d+$/.test(key)) delete style[key];
    [...values.keys()].forEach((name, i) => { style[i] = name; });
  }
  return style;
}

function page({ stored = null } = {}) {
  const document = new EventTarget();
  document.documentElement = { style: styleDeclaration(), dataset: {} };
  const window = {};
  const runtimeMessages = [];
  const listeners = [];
  const globals = { Event, CustomEvent, document };
  vm.runInNewContext(scripts['content.js'], {
    ...globals,
    chrome: {
      storage: { local: { get: async () => (stored ? { palette: stored } : {}) } },
      runtime: {
        onMessage: { addListener: (listener) => listeners.push(listener) },
        sendMessage: (message, callback) => {
          runtimeMessages.push(plain(message));
          callback(null);
        },
      },
    },
  });
  vm.runInNewContext(scripts['page-api.js'], { ...globals, window });
  return {
    api: window.omarchy, document, runtimeMessages,
    root: document.documentElement,
    push: (message) => listeners.forEach((listener) => listener(message)),
  };
}

test('a palette becomes custom properties, data attributes, an event, and window.omarchy reads', () => {
  const p = page();
  const seen = [];
  const stop = p.api.onChange((colors) => seen.push(colors));
  assert.equal(p.api.theme, null);
  assert.equal(p.api.mode, null);
  assert.deepEqual(plain(p.api.colors()), {});

  p.push({ type: 'palette', palette });
  assert.equal(p.root.style.getPropertyValue('--omarchy-background'), '#1a1b26');
  assert.equal(p.root.style.getPropertyValue('--omarchy-bright-green'), '#9ece6a');
  assert.equal(p.root.style.getPropertyValue('--omarchy-broken'), '', 'non-string values are skipped');
  assert.equal(p.root.dataset.omarchyTheme, 'Tokyo Night');
  assert.equal(p.root.dataset.omarchyMode, 'dark');
  assert.equal(p.api.theme, 'Tokyo Night');
  assert.equal(p.api.mode, 'dark');
  assert.deepEqual(plain(p.api.colors()), { background: '#1a1b26', bright_green: '#9ece6a' });
  assert.equal(p.api.color('bright-green'), '#9ece6a');
  assert.equal(p.api.color('bright_green'), '#9ece6a');
  assert.equal(p.api.color('missing'), null);
  assert.equal(seen.length, 1);
  assert.ok(Object.isFrozen(seen[0]));
  assert.deepEqual(seen[0], p.api.colors());

  stop();
  p.push({ type: 'palette', palette });
  assert.equal(seen.length, 1, 'unsubscribed handlers stop firing');
});

test('a theme switch clears properties the new palette no longer has', () => {
  const p = page();
  p.push({ type: 'palette', palette });
  p.push({ type: 'palette', palette: { ...palette, name: 'Rose Pine', mode: 'light', colors: { accent: '#ebbcba' } } });
  assert.deepEqual(plain(p.api.colors()), { accent: '#ebbcba' });
  assert.equal(p.root.style.getPropertyValue('--omarchy-background'), '');
  assert.equal(p.api.theme, 'Rose Pine');
  assert.equal(p.api.mode, 'light');
});

test('a cached palette applies on a cold start before the worker answers', async () => {
  const p = page({ stored: palette });
  await flush();
  assert.equal(p.api.theme, 'Tokyo Night');
  assert.equal(p.api.color('background'), '#1a1b26');
  assert.deepEqual(p.runtimeMessages, [{ type: 'omarchy-get-palette' }]);
});

test('messages without colors and unrelated messages leave the page untouched', () => {
  const p = page();
  for (const message of [null, {}, { type: 'palette' }, { type: 'palette', palette: { name: 'x' } }, { type: 'theme-result', ok: true }]) {
    p.push(message);
  }
  assert.deepEqual(plain(p.api.colors()), {});
  assert.deepEqual(p.root.dataset, {});
});

test('window.omarchy is a frozen read-only surface with no theme write path', () => {
  const p = page();
  assert.ok(Object.isFrozen(p.api));
  assert.deepEqual(Object.keys(p.api).sort(), ['color', 'colors', 'mode', 'onChange', 'theme']);
  for (const method of ['canSetTheme', 'setTheme', 'installTheme']) assert.equal(p.api[method], undefined);

  // The standalone write bridge listened for this event. Nothing may answer it now.
  let responses = 0;
  p.document.addEventListener('__omarchy_response', () => responses++);
  for (const request of [
    { id: 'raw', kind: 'can-set' },
    { id: 'raw', kind: 'set', name: 'Tokyo Night' },
    { id: 'raw', kind: 'install', name: 'Unsafe', colors: palette.colors },
  ]) {
    p.document.dispatchEvent(new CustomEvent('__omarchy_request', { detail: JSON.stringify(request) }));
  }
  assert.equal(responses, 0);
  assert.deepEqual(p.runtimeMessages, [{ type: 'omarchy-get-palette' }], 'the content script only ever asks for the palette');
});

test('the manifest injects both worlds at document_start on every frame', () => {
  const [isolated, main] = manifest.content_scripts;
  assert.deepEqual(isolated, { matches: ['<all_urls>'], js: ['content.js'], run_at: 'document_start', all_frames: true });
  assert.deepEqual(main, { matches: ['<all_urls>'], js: ['page-api.js'], run_at: 'document_start', all_frames: true, world: 'MAIN' });
});
