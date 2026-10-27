// Only a browser-toolbar gesture can approve an origin. Websites have no read
// consent bridge, and no message is ever sent to the read-only native host.
importScripts('policy.js');

const HOST_NAME = 'com.omarchy.theme';
const SCRIPT_ID = 'omarchy-theme-sync';
const RETRY_ALARM = 'omarchy-theme-sync-reconnect';
const STOP_ALL = 'omarchy-theme-sync-stop-all';
const policy = ThemeSyncPolicy;
let approved = new Set();
let epoch = 0;
let port = null;
let palette = null;
let changes = Promise.resolve();

function serialize(change) {
  const next = changes.then(change);
  changes = next.catch(() => {});
  return next;
}

async function allowed(url, incognito = false) {
  const origin = policy.origin(url);
  return !incognito && approved.has(origin) &&
    await chrome.permissions.contains({ origins: [policy.pattern(origin)] });
}

async function updateAction(tab) {
  const version = epoch;
  const sharing = await allowed(tab.url, tab.incognito);
  if (version !== epoch) return;
  await Promise.all([
    chrome.action.setBadgeText({ tabId: tab.id, text: sharing && port && palette ? 'ON' : '' }),
    chrome.action.setTitle({ tabId: tab.id, title: sharing
      ? 'Stop sharing desktop colors with this site' : 'Share desktop colors with this site' }),
  ]);
}

async function clearPages() {
  const version = epoch;
  for (const tab of await chrome.tabs.query({})) {
    if (version !== epoch) return;
    if (tab.id === undefined) continue;
    chrome.tabs.sendMessage(tab.id, { type: 'omarchy-clear-palette' }, { frameId: 0 }).catch(() => {});
    chrome.action.setBadgeText({ tabId: tab.id, text: '' }).catch(() => {});
    chrome.action.setTitle({ tabId: tab.id, title: approved.has(policy.origin(tab.url)) && !tab.incognito
      ? 'Stop sharing desktop colors with this site' : 'Share desktop colors with this site' }).catch(() => {});
  }
}

async function broadcast() {
  const current = palette;
  const version = epoch;
  if (!current || !port) return;
  for (const tab of await chrome.tabs.query({})) {
    if (tab.id === undefined || !await allowed(tab.url, tab.incognito)) continue;
    if (version !== epoch || current !== palette || !port) return;
    chrome.tabs.sendMessage(tab.id, { type: 'omarchy-palette', palette: current }, { frameId: 0 }).catch(() => {});
    chrome.action.setBadgeText({ tabId: tab.id, text: 'ON' }).catch(() => {});
    chrome.action.setTitle({ tabId: tab.id, title: 'Stop sharing desktop colors with this site' }).catch(() => {});
  }
}

function retry() {
  if (!approved.size) return;
  // Alarms wake an idle MV3 worker; a 32/60-second setTimeout can disappear
  // when Chromium stops the worker after 30 seconds. Keep retrying until a
  // fresh native palette arrives, not merely until connectNative returns.
  chrome.alarms.create(RETRY_ALARM, { delayInMinutes: 0.5, periodInMinutes: 0.5 }).catch(() => {});
}

function connect() {
  if (port || !approved.size) return;
  let connection;
  try {
    connection = chrome.runtime.connectNative(HOST_NAME);
  } catch {
    retry();
    return;
  }
  port = connection;
  connection.onMessage.addListener(message => {
    if (port !== connection) return;
    const next = policy.palette(message);
    if (!next) return;
    epoch++;
    palette = next;
    chrome.alarms.clear(RETRY_ALARM).catch(() => {});
    broadcast().catch(() => {});
  });
  connection.onDisconnect.addListener(() => {
    void chrome.runtime.lastError;
    if (port !== connection) return;
    epoch++;
    port = null;
    palette = null;
    clearPages().catch(() => {});
    retry();
  });
}

async function configure() {
  epoch++;
  await clearPages();
  await chrome.scripting.unregisterContentScripts({ ids: [SCRIPT_ID] }).catch(() => {});
  if (approved.size) {
    await chrome.scripting.registerContentScripts([{
      id: SCRIPT_ID,
      matches: [...new Set([...approved].map(policy.pattern))],
      js: ['policy.js', 'content.js'],
      runAt: 'document_start', allFrames: false, persistAcrossSessions: true,
    }]);
    connect();
    // An approval also takes effect on already-open pages. Delivery still
    // checks the exact origin; a host match is not sufficient authorization.
    for (const tab of await chrome.tabs.query({})) {
      if (tab.id !== undefined && await allowed(tab.url, tab.incognito)) {
        await chrome.scripting.executeScript({ target: { tabId: tab.id, frameIds: [0] },
          files: ['policy.js', 'content.js'] }).catch(() => {});
      }
    }
    await broadcast();
  } else {
    const previous = port;
    port = null;
    palette = null;
    previous?.disconnect();
    await chrome.alarms.clear(RETRY_ALARM);
  }
}

async function save() {
  await chrome.storage.local.set({ approvedOrigins: [...approved].sort() });
  await configure();
}

const ready = (async () => {
  // Content scripts cannot read or mutate approval state. Discard all old
  // persistent palettes: a cold worker never exposes historical theme data.
  await chrome.storage.local.setAccessLevel({ accessLevel: 'TRUSTED_CONTEXTS' });
  await chrome.storage.local.remove('palette');
  const stored = await chrome.storage.local.get('approvedOrigins');
  for (const origin of Array.isArray(stored.approvedOrigins) ? stored.approvedOrigins : []) {
    if (typeof origin === 'string' && policy.origin(origin) === origin &&
        await chrome.permissions.contains({ origins: [policy.pattern(origin)] })) approved.add(origin);
  }
  await configure();
})();
// Fail closed if browser storage or dynamic registration is unavailable.
ready.catch(() => {});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (!message || !['omarchy-get-palette', 'omarchy-enable-api'].includes(message.type)) return false;
  (async () => {
    await ready;
    await changes;
    const version = epoch;
    if (sender.id !== chrome.runtime.id || sender.frameId !== 0 ||
        typeof sender.documentId !== 'string' || typeof sender.tab?.id !== 'number' ||
        !await allowed(sender.url, sender.tab.incognito) || version !== epoch) return null;
    if (message.type === 'omarchy-get-palette') {
      updateAction({ id: sender.tab.id, url: sender.url, incognito: sender.tab.incognito }).catch(() => {});
      return port ? palette : null;
    }
    if (!port || !palette) return null;
    // documentIds prevents an asynchronous authorization for one document
    // from injecting the API into a different document after navigation.
    await chrome.scripting.executeScript({ target: { tabId: sender.tab.id, documentIds: [sender.documentId] },
      world: 'MAIN', files: ['page-api.js'] });
    return true;
  })().then(sendResponse, () => sendResponse(null));
  return true;
});

function toggleSharing(tab) {
  const origin = policy.origin(tab.url);
  if (!origin || tab.incognito) return;
  // Request in the gesture's original task, before any await. A page cannot
  // manufacture this browser event or answer the browser's permission prompt.
  const permission = chrome.permissions.request({ origins: [policy.pattern(origin)] });
  return serialize(async () => {
    await ready;
    if (!await permission) return;
    if (approved.has(origin)) {
      approved.delete(origin);
    } else {
      approved.add(origin);
    }
    await save();
    // Revoking one port-specific origin must not remove the browser grant
    // still needed by another explicitly approved origin on the same host.
    if (![...approved].some(site => policy.pattern(site) === policy.pattern(origin))) {
      await chrome.permissions.remove({ origins: [policy.pattern(origin)] });
    }
    await chrome.action.setTitle({ tabId: tab.id, title: approved.has(origin)
      ? 'Stop sharing desktop colors with this site' : 'Share desktop colors with this site' });
  }).catch(() => {
    chrome.action.setBadgeText({ tabId: tab.id, text: '!' }).catch(() => {});
    chrome.action.setTitle({ tabId: tab.id, title: 'Theme Sync could not update sharing. Click to try again.' }).catch(() => {});
  });
}
chrome.action.onClicked.addListener(toggleSharing);

chrome.contextMenus.onClicked.addListener(info => {
  if (info.menuItemId !== STOP_ALL) return;
  serialize(async () => {
    await ready;
    const origins = [...new Set([...approved].map(policy.pattern))];
    approved.clear();
    await save();
    if (origins.length) await chrome.permissions.remove({ origins });
  }).catch(() => {});
});

chrome.permissions.onRemoved.addListener(() => {
  serialize(async () => {
    await ready;
    for (const origin of approved) {
      if (!await chrome.permissions.contains({ origins: [policy.pattern(origin)] })) approved.delete(origin);
    }
    await save();
  }).catch(() => {});
});

chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === RETRY_ALARM) ready.then(connect).catch(() => {});
});
chrome.runtime.onStartup.addListener(() => ready.then(connect).catch(() => {}));
chrome.tabs.onUpdated.addListener((_tabId, change, tab) => {
  if (change.url || change.status === 'loading') ready.then(() => updateAction(tab)).catch(() => {});
});
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.removeAll().then(() => chrome.contextMenus.create({
    id: STOP_ALL, title: 'Stop sharing on all sites', contexts: ['action'],
  })).catch(() => {});
});
