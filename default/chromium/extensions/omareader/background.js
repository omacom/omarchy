// Service worker: keeps the native-host connection to Omarchy, resolves the active palette
// into storage for the content scripts and fetches cross-origin CSS.
importScripts('src/color.js', 'src/theme.js', 'src/net.js');

async function setToolbarIcon() {
  try {
    await chrome.action.setIcon({ path: { 16: 'icons/omarchy-16.png', 32: 'icons/omarchy-32.png' } });
    await chrome.action.setTitle({ title: 'Omareader' });
  } catch (error) {
    console.warn('Omareader could not load its toolbar icon:', error);
  }
}

let port = null;

async function recompute() {
  const st = await chrome.storage.local.get(['settings', 'omarchy', 'active']);
  const settings = OmareaderTheme.normalizeSettings(st.settings);
  const current = st.omarchy;
  // Always the Omarchy palette, whatever the modes: Dark is a fixed palette that content
  // scripts and the popup build themselves, so sites can use different modes side by side.
  const active = {
    name: current ? current.name : 'fallback',
    follow: true,
    palette: OmareaderTheme.normalize(current && current.colors),
  };
  const writes = {};
  if (JSON.stringify(active) !== JSON.stringify(st.active)) writes.active = active;
  if (JSON.stringify(settings) !== JSON.stringify(st.settings)) writes.settings = settings;
  if (Object.keys(writes).length) await chrome.storage.local.set(writes);
  return { settings, active };
}

let chain = Promise.resolve();
function queueRecompute() {
  chain = chain.then(recompute, recompute);
  return chain;
}

function connect() {
  if (port) return;
  try {
    port = chrome.runtime.connectNative('com.omarchy.omareader');
  } catch (e) {
    port = null;
    chrome.storage.local.set({ host: { connected: false, error: String(e.message || e) } });
    return;
  }
  port.onMessage.addListener((msg) => {
    if (!msg || msg.type !== 'state') return;
    chrome.storage.local.set({ omarchy: msg.current, themes: msg.themes, host: { connected: true, error: null } });
  });
  port.onDisconnect.addListener(() => {
    const err = chrome.runtime.lastError && chrome.runtime.lastError.message;
    port = null;
    chrome.storage.local.set({ host: { connected: false, error: err || 'Native host exited' } });
  });
}

// Cross-origin stylesheet fetches for content scripts. A page decides which URLs end up
// here, so the request must not be more powerful than an anonymous fetch from anywhere:
// no cookies or auth, CSS only, no reaching into private networks from public pages.
const CSS_TIMEOUT_MS = 10000;
const CSS_MAX_BYTES = 5 * 1024 * 1024;
const cssCache = new Map();

const { isPrivateHost } = OmareaderNet;

function originHost(sender) {
  try {
    return new URL(sender.origin || sender.url).hostname;
  } catch {
    return '';
  }
}

async function fetchCssOnce(url, allowPrivate) {
  const target = new URL(url);
  if (!/^https?:$/.test(target.protocol)) return { ok: false, error: 'unsupported scheme' };
  if (!allowPrivate && isPrivateHost(target.hostname)) return { ok: false, error: 'private address' };
  const abort = new AbortController();
  const timer = setTimeout(() => abort.abort(), CSS_TIMEOUT_MS);
  try {
    // The hostname check above cannot see where a public name resolves (DNS rebinding,
    // names pointing at 127.0.0.1). targetAddressSpace makes Chrome refuse any connection,
    // redirect hop or cache hit whose actual peer address is not public.
    const space = allowPrivate ? {} : { targetAddressSpace: 'public' };
    const res = await fetch(target.href, { credentials: 'omit', cache: 'force-cache', redirect: 'follow', signal: abort.signal, ...space });
    if (!allowPrivate && isPrivateHost(new URL(res.url).hostname)) return { ok: false, error: 'redirected to private address' };
    if (!res.ok) return { ok: false, error: `HTTP ${res.status}` };
    const type = (res.headers.get('content-type') || '').toLowerCase();
    if (!type.startsWith('text/css')) return { ok: false, error: `not CSS (${type || 'no type'})` };
    if (Number(res.headers.get('content-length')) > CSS_MAX_BYTES) return { ok: false, error: 'too large' };
    const text = await res.text();
    if (text.length > CSS_MAX_BYTES) return { ok: false, error: 'too large' };
    return { ok: true, text, url: res.url };
  } catch (e) {
    return { ok: false, error: String(e) };
  } finally {
    clearTimeout(timer);
  }
}

async function fetchCss(url, sender) {
  // Only our own content scripts running in a tab may ask.
  if (sender.id !== chrome.runtime.id || !sender.tab) return { ok: false, error: 'bad sender' };
  const allowPrivate = isPrivateHost(originHost(sender));
  const key = `${allowPrivate ? 'p' : 'o'}|${url}`;
  const hit = cssCache.get(key);
  if (hit) return hit;
  const res = await fetchCssOnce(url, allowPrivate).catch((e) => ({ ok: false, error: String(e) }));
  if (res.ok) {
    cssCache.set(key, res);
    if (cssCache.size > 100) cssCache.delete(cssCache.keys().next().value);
  }
  return res;
}

async function toggleSite(hostname) {
  if (!hostname) return;
  const { settings } = await chrome.storage.local.get('settings');
  await chrome.storage.local.set({ settings: OmareaderTheme.toggleSite(settings, hostname) });
}

async function injectIntoOpenTabs() {
  const tabs = await chrome.tabs.query({ url: ['http://*/*', 'https://*/*'] });
  for (const tab of tabs) {
    const target = { tabId: tab.id, allFrames: true };
    chrome.scripting.executeScript({ target, files: ['src/page-hook.js'], world: 'MAIN' }).catch(() => {});
    chrome.scripting
      .executeScript({ target, files: ['src/color.js', 'src/theme.js', 'src/transform.js', 'src/content.js'] })
      .catch(() => {});
  }
}

chrome.storage.onChanged.addListener((changes, area) => {
  if (area === 'local' && (changes.settings || changes.omarchy || changes.themes)) queueRecompute();
});

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg.type === 'get-state') {
    queueRecompute().then(sendResponse);
    return true;
  }
  if (msg.type === 'fetch-css') {
    fetchCss(String(msg.url), _sender).then(sendResponse);
    return true;
  }
  if (msg.type === 'reconnect') {
    if (port) port.disconnect();
    port = null;
    connect();
    sendResponse(true);
  }
  return false;
});

const GLOBAL_MODE_COMMANDS = { 'mode-normal': 'normal', 'mode-dark': 'dark', 'mode-omarchy': 'omarchy' };

chrome.commands.onCommand.addListener(async (command, tab) => {
  if (GLOBAL_MODE_COMMANDS[command]) {
    const { settings } = await chrome.storage.local.get('settings');
    await chrome.storage.local.set({
      settings: { ...OmareaderTheme.normalizeSettings(settings), mode: GLOBAL_MODE_COMMANDS[command] },
    });
    return;
  }
  if (command !== 'toggle-site') return;
  const t = tab || (await chrome.tabs.query({ active: true, currentWindow: true }))[0];
  try {
    await toggleSite(new URL(t.url).hostname);
  } catch {}
});

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'reconnect' && !port) connect();
});

chrome.runtime.onInstalled.addListener((details) => {
  setToolbarIcon();
  chrome.alarms.create('reconnect', { periodInMinutes: 1 });
  if (details.reason === 'install' || details.reason === 'update') injectIntoOpenTabs();
});

chrome.runtime.onStartup.addListener(() => chrome.alarms.create('reconnect', { periodInMinutes: 1 }));

// Replace an old runtime crescent immediately; native-host and palette work can follow.
setToolbarIcon();
connect();
queueRecompute();
