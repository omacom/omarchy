import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const extension = new URL('../../../../default/chromium/extensions/theme-sync/', import.meta.url);
const manifest = JSON.parse(readFileSync(new URL('manifest.json', extension), 'utf8'));
const source = readFileSync(new URL(manifest.background.service_worker, extension), 'utf8');
const policySource = readFileSync(new URL('policy.js', extension), 'utf8');
const id = 'ppnnomfimbfcofidkfmghapellfbgklc';
const origin = 'https://approved.example';
const match = `${origin}/*`;
const palette = { type: 'palette', mode: 'dark', colors: { background: '#112233', accent: '#445566' } };
const sender = { id, url: `${origin}/page`, frameId: 0, documentId: 'document-1', tab: { id: 1, incognito: false } };
const plain = value => JSON.parse(JSON.stringify(value));
const flush = () => new Promise(setImmediate);

function event() {
  const listeners = [];
  return { addListener: listener => listeners.push(listener), emit: (...args) => listeners.map(listener => listener(...args)) };
}

async function worker({ approved = [], grants = [], stored = {}, tabs, alarms = new Map() } = {}) {
  const storage = { ...stored, approvedOrigins: [...approved] };
  const permissions = new Set(grants);
  const ports = [], sent = [], executions = [], registrations = [], posts = [], requests = [];
  const onMessage = event(), onAction = event(), onRemoved = event(), onAlarm = event(), onMenu = event(), onUpdated = event();
  const badges = new Map(), titles = new Map();
  const availableTabs = tabs || [
    { id: 1, url: `${origin}/page` }, { id: 2, url: 'https://unapproved.example/' },
    { id: 3, url: `${origin}/private`, incognito: true }, { id: 4 },
  ];
  let accessLevel, gesture = false, connectError = false, permissionAccepted = true;
  const context = vm.createContext({ URL,
    // Reconnection must not depend on an in-memory timer or network API.
    setTimeout: () => { throw new Error('worker-lifetime timers are not durable'); },
    chrome: {
      runtime: {
        id, onMessage, onStartup: event(), onInstalled: event(),
        connectNative: name => {
          if (connectError) throw new Error('native host unavailable');
          const port = { name, onMessage: event(), onDisconnect: event(), disconnected: false,
            postMessage: message => posts.push(message), disconnect() { this.disconnected = true; } };
          ports.push(port);
          return port;
        },
      },
      storage: { local: {
        get: async key => ({ [key]: storage[key] }),
        set: async items => { Object.assign(storage, plain(items)); },
        remove: async key => { delete storage[key]; },
        setAccessLevel: async value => { accessLevel = value.accessLevel; },
      } },
      permissions: {
        onRemoved,
        contains: async query => query.origins.every(origin => permissions.has(origin)),
        request: async query => {
          assert.ok(gesture, 'browser permission requested synchronously inside the toolbar gesture');
          requests.push(plain(query));
          if (permissionAccepted) query.origins.forEach(origin => permissions.add(origin));
          return permissionAccepted;
        },
        remove: async query => {
          query.origins.forEach(origin => permissions.delete(origin));
          onRemoved.emit(query);
          return true;
        },
      },
      tabs: {
        onUpdated,
        query: async () => availableTabs,
        sendMessage: async (tabId, message, target) => { sent.push(plain({ tabId, message, target })); },
      },
      scripting: {
        unregisterContentScripts: async () => { registrations.length = 0; },
        registerContentScripts: async scripts => { registrations.push(...plain(scripts)); },
        executeScript: async script => { executions.push(plain(script)); },
      },
      action: { onClicked: onAction,
        setBadgeText: async value => { badges.set(value.tabId, value.text); },
        setTitle: async value => { titles.set(value.tabId, value.title); } },
      contextMenus: { onClicked: onMenu, removeAll: async () => {}, create: () => {} },
      alarms: {
        onAlarm,
        create: async (name, configuration) => { alarms.set(name, plain(configuration)); },
        clear: async name => alarms.delete(name),
      },
    },
  });
  context.importScripts = file => { assert.equal(file, 'policy.js'); vm.runInContext(policySource, context); };
  vm.runInContext(source, context);
  async function idle() {
    await vm.runInContext('Promise.all([ready, changes])', context);
    await flush();
    await vm.runInContext('changes', context);
    await flush();
  }
  await idle();
  return {
    storage, permissions, ports, sent, executions, registrations, posts, requests, alarms, badges, titles,
    accessLevel: () => accessLevel,
    port: () => ports.at(-1), idle,
    async message(message, from = sender) {
      return new Promise(resolve => {
        const claimed = onMessage.emit(message, from, resolve);
        if (claimed.every(value => !value)) resolve(undefined);
      });
    },
    async click(tab = { id: 1, url: `${origin}/page` }) {
      gesture = true;
      onAction.emit(tab);
      gesture = false;
      await idle();
    },
    async revoke(pattern = match) { permissions.delete(pattern); onRemoved.emit({ origins: [pattern] }); await idle(); },
    async stopAll() { onMenu.emit({ menuItemId: 'omarchy-theme-sync-stop-all' }); await idle(); },
    async alarm() { onAlarm.emit({ name: 'omarchy-theme-sync-reconnect' }); await idle(); },
    async navigate(url) { onUpdated.emit(1, {status: 'loading'}, {id: 1, url}); await idle(); },
    failConnect(value = true) { connectError = value; },
    denyPermission() { permissionAccepted = false; },
  };
}

test('first install is private: no content scripts, native process, or historical palette delivery', async () => {
  const w = await worker({ stored: { palette: { ...palette, name: 'private old name' } } });
  assert.equal(w.ports.length, 0);
  assert.equal(w.registrations.length, 0);
  assert.equal(w.storage.palette, undefined);
  assert.equal(w.accessLevel(), 'TRUSTED_CONTEXTS');
  assert.equal(await w.message({ type: 'omarchy-get-palette' }), null);
  assert.equal(await w.message({ type: 'omarchy-approve-origin', origin }), undefined);
  assert.deepEqual(w.storage.approvedOrigins, []);
  assert.ok(w.sent.every(({ message }) => message.type === 'omarchy-clear-palette'));
});

test('only an accepted browser-toolbar gesture authorizes the exact origin', async () => {
  const w = await worker();
  await w.click();
  assert.deepEqual(w.storage.approvedOrigins, [origin]);
  assert.equal(w.ports.length, 1);
  assert.deepEqual(w.registrations[0], { id: 'omarchy-theme-sync', matches: [match], js: ['policy.js', 'content.js'],
    runAt: 'document_start', allFrames: false, persistAcrossSessions: true });
  assert.ok(w.executions.every(script => script.target.tabId === 1 && script.target.frameIds[0] === 0));
  const denied = await worker();
  denied.denyPermission();
  await denied.click();
  assert.deepEqual(denied.storage.approvedOrigins, []);
  assert.equal(denied.ports.length, 0);
});

test('a host grant alone, different port, iframe, forged sender or private tab gets no palette or API', async () => {
  const w = await worker({ approved: [origin], grants: [match] });
  w.port().onMessage.emit({ ...palette, name: 'private', colors: { ...palette.colors, api_token: 'synthetic', client_id: '#ffffff' } });
  await w.idle();
  const reads = w.sent.filter(({ message }) => message.type === 'omarchy-palette');
  assert.deepEqual(reads.map(value => value.tabId), [1]);
  assert.deepEqual(reads[0].message.palette, palette);
  assert.deepEqual(reads[0].target, { frameId: 0 });
  assert.equal(w.storage.palette, undefined, 'a fresh palette never goes to disk');
  assert.deepEqual(plain(await w.message({ type: 'omarchy-get-palette' })), palette);
  w.executions.length = 0;
  for (const from of [
    { ...sender, frameId: 1 }, { ...sender, url: 'https://unapproved.example/' },
    { ...sender, url: 'https://approved.example:8443/' }, { ...sender, id: 'another-extension' },
    { ...sender, documentId: undefined }, { ...sender, tab: { id: 1, incognito: true } },
  ]) {
    assert.equal(await w.message({ type: 'omarchy-get-palette' }, from), null);
    assert.equal(await w.message({ type: 'omarchy-enable-api' }, from), null);
  }
  assert.deepEqual(w.executions, []);
  const permissionOnly = await worker({ grants: [match] });
  assert.equal(await permissionOnly.message({ type: 'omarchy-get-palette' }), null);
});

test('main-world injection is bound to the approved document, not a later navigation', async () => {
  const w = await worker({ approved: [origin], grants: [match] });
  w.port().onMessage.emit(palette);
  await w.idle();
  w.executions.length = 0;
  assert.equal(await w.message({ type: 'omarchy-enable-api' }), true);
  assert.deepEqual(w.executions, [{ target: { tabId: 1, documentIds: ['document-1'] }, world: 'MAIN', files: ['page-api.js'] }]);
});

test('revoking one port does not revoke another explicitly approved origin on the same host', async () => {
  const first = 'https://approved.example:8443';
  const second = 'https://approved.example:9443';
  const w = await worker({ approved: [first, second], grants: [match], tabs: [
    {id: 1, url: `${first}/`}, {id: 2, url: `${second}/`},
  ] });
  w.port().onMessage.emit(palette);
  await w.idle();
  await w.click({id: 1, url: `${first}/`});
  assert.deepEqual(w.storage.approvedOrigins, [second]);
  assert.equal(w.permissions.has(match), true);
  assert.equal(w.port().disconnected, false);
  assert.equal(await w.message({type: 'omarchy-get-palette'}, {...sender, url: `${first}/`}), null);
  assert.deepEqual(plain(await w.message({type: 'omarchy-get-palette'}, {...sender, url: `${second}/`})), palette);
});

test('the toolbar reflects approval on new documents and clears its badge on navigation away', async () => {
  const w = await worker({ approved: [origin], grants: [match] });
  w.port().onMessage.emit(palette);
  await w.idle();
  await w.message({type: 'omarchy-get-palette'});
  await w.idle();
  assert.equal(w.badges.get(1), 'ON');
  assert.equal(w.titles.get(1), 'Stop sharing desktop colors with this site');
  await w.navigate('https://unapproved.example/');
  assert.equal(w.badges.get(1), '');
  assert.equal(w.titles.get(1), 'Share desktop colors with this site');
});

test('revocation clears pages, approval state, scripts, native port and reconnect alarms', async () => {
  for (const revoke of ['click', 'revoke', 'stopAll']) {
    const w = await worker({ approved: [origin], grants: [match] });
    const port = w.port();
    port.onMessage.emit(palette);
    await w.idle();
    w.sent.length = 0;
    await w[revoke]();
    assert.deepEqual(w.storage.approvedOrigins, [], revoke);
    assert.equal(w.registrations.length, 0);
    assert.equal(port.disconnected, true);
    assert.equal(w.alarms.size, 0);
    assert.equal(await w.message({ type: 'omarchy-get-palette' }), null);
    assert.ok(w.sent.length > 0 && w.sent.every(({message}) => message.type === 'omarchy-clear-palette'));
  }
});

test('reconnect uses a worker-independent alarm; disconnect immediately invalidates the palette', async () => {
  const w = await worker({ approved: [origin], grants: [match] });
  w.port().onMessage.emit(palette);
  await w.idle();
  w.port().onDisconnect.emit();
  await w.idle();
  assert.equal(await w.message({ type: 'omarchy-get-palette' }), null);
  assert.deepEqual([...w.alarms.values()], [{ delayInMinutes: 0.5, periodInMinutes: 0.5 }]);
  w.failConnect();
  await w.alarm();
  assert.equal(w.alarms.size, 1);
  // The browser-owned alarm survives discarding this vm/worker entirely.
  const restarted = await worker({ approved: [origin], grants: [match], alarms: w.alarms });
  assert.equal(restarted.alarms.size, 1, 'connection alone does not prove healthy readback');
  restarted.port().onMessage.emit(palette);
  await restarted.idle();
  assert.equal(restarted.alarms.size, 0);
  assert.deepEqual(plain(await restarted.message({ type: 'omarchy-get-palette' })), palette);
  assert.equal(restarted.posts.length, 0, 'never sends native messages');
});

test('neither native failures nor invalid messages publish arbitrary or stale data', async () => {
  const w = await worker({ approved: [origin], grants: [match] });
  w.sent.length = 0;
  for (const message of [null, {}, { ...palette, mode: 'private-mode' }, { type: 'install-theme' }]) w.port().onMessage.emit(message);
  await w.idle();
  assert.equal(w.sent.length, 0);
  for (const type of ['omarchy-set-theme', 'omarchy-install-theme', 'omarchy-can-set-theme']) {
    assert.equal(await w.message({ type }), undefined);
  }
  assert.equal(w.posts.length, 0);
});

test('file, browser-internal and incognito toolbar clicks cannot approve sharing', async () => {
  const w = await worker();
  for (const tab of [{ url: 'file:///tmp/site.html' }, { url: 'chrome://extensions/' },
    { url: `${origin}/`, incognito: true }, { url: 'https://user:pass@approved.example/' }]) await w.click({ id: 1, ...tab });
  assert.deepEqual(w.requests, []);
  assert.deepEqual(w.storage.approvedOrigins, []);
});

test('manifest has no automatic all-site scripts or required host grants', () => {
  assert.equal(manifest.content_scripts, undefined);
  assert.equal(manifest.host_permissions, undefined);
  assert.deepEqual(manifest.optional_host_permissions, ['http://*/*', 'https://*/*']);
  assert.deepEqual(manifest.permissions, ['nativeMessaging', 'storage', 'scripting', 'activeTab', 'alarms', 'contextMenus']);
  assert.equal(manifest.background.service_worker, 'background-2.js');
});
