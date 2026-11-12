// The native host tries yt-dlp on the page URL first. For a site yt-dlp has no
// extractor for (or one behind a login), it falls back to a stream the page
// itself played, so the extension remembers the first HLS/DASH manifest (or,
// failing that, the first plain video file) each tab loads, together with the
// request headers the browser sent for it.

const MANIFEST_TYPES = [
  'application/vnd.apple.mpegurl',
  'application/x-mpegurl',
  'audio/mpegurl',
  'audio/x-mpegurl',
  'application/dash+xml',
];
const MANIFEST_PATH = /\.(m3u8|mpd)$/i;

// Only these reach the host; everything else the browser sent stays here.
const FORWARDED_HEADERS = ['cookie', 'authorization', 'referer', 'origin', 'user-agent'];

const WATCHED = { urls: ['<all_urls>'], types: ['media', 'xmlhttprequest', 'other'] };

// Request headers by requestId, held until the response says what it is.
const pendingHeaders = new Map();

// Storage writes are chained so two streams that start together can't both
// see an empty slot and overwrite each other.
let queue = Promise.resolve();

function serially(task) {
  queue = queue.then(task, task);
  return queue;
}

function tabKey(tabId) {
  return `tab:${tabId}`;
}

function forget(tabId) {
  return serially(() => chrome.storage.session.remove(tabKey(tabId)));
}

function header(headers, name) {
  const found = (headers || []).find((h) => h.name.toLowerCase() === name);
  return found ? found.value || '' : '';
}

function streamKind(details) {
  let path;
  try {
    const url = new URL(details.url);
    if (url.protocol !== 'http:' && url.protocol !== 'https:') return null;
    path = url.pathname;
  } catch {
    return null;
  }

  const contentType = header(details.responseHeaders, 'content-type').split(';')[0].trim().toLowerCase();

  if (MANIFEST_TYPES.includes(contentType) || MANIFEST_PATH.test(path)) return 'manifest';

  // A <video src> that answers with a whole video file. Media Source players
  // fetch segments over XHR instead, and a segment alone is not the video.
  if (details.type === 'media' && contentType.startsWith('video/')) return 'file';

  return null;
}

chrome.webRequest.onSendHeaders.addListener(
  (details) => {
    if (details.tabId < 0) return;

    const headers = {};
    for (const h of details.requestHeaders || []) {
      const name = h.name.toLowerCase();
      if (FORWARDED_HEADERS.includes(name) && h.value) headers[name] = h.value;
    }
    pendingHeaders.set(details.requestId, headers);
  },
  WATCHED,
  ['requestHeaders', 'extraHeaders'],
);

chrome.webRequest.onHeadersReceived.addListener(
  (details) => {
    const headers = pendingHeaders.get(details.requestId) || {};
    pendingHeaders.delete(details.requestId);
    if (details.tabId < 0 || details.statusCode >= 400) return;

    const kind = streamKind(details);
    if (!kind) return;

    const key = tabKey(details.tabId);
    serially(async () => {
      const seen = (await chrome.storage.session.get(key))[key] || {};
      // The first manifest is the master playlist; later ones are its variants.
      if (seen[kind]) return;
      seen[kind] = { url: details.url, headers };
      await chrome.storage.session.set({ [key]: seen });
    });
  },
  WATCHED,
  ['responseHeaders'],
);

chrome.webRequest.onErrorOccurred.addListener((details) => {
  pendingHeaders.delete(details.requestId);
}, WATCHED);

// A new page, or a single-page app moving to another video, starts over.
chrome.webNavigation.onCommitted.addListener((details) => {
  if (details.frameId === 0) forget(details.tabId);
});

chrome.webNavigation.onHistoryStateUpdated.addListener((details) => {
  if (details.frameId === 0) forget(details.tabId);
});

chrome.tabs.onRemoved.addListener((tabId) => {
  forget(tabId);
});

async function streamFor(tabId) {
  if (tabId === undefined) return null;
  await queue;
  const key = tabKey(tabId);
  const seen = (await chrome.storage.session.get(key))[key] || {};
  return seen.manifest || seen.file || null;
}

async function sendUrl(tab, url) {
  if (!url || !/^https?:/i.test(url)) return;

  const message = { url };
  const stream = await streamFor(tab.id).catch(() => null);
  if (stream) {
    message.stream = stream;
    if (tab.title) message.title = tab.title;
  }

  // The native messaging host runs yt-dlp and owns all the desktop
  // notifications, so we just hand off the URL and ignore the reply.
  chrome.runtime.sendNativeMessage('com.omarchy.ytdlp', message, () => {
    void chrome.runtime.lastError;
  });
}

function triggerDownload(tab) {
  if (!tab) return;

  // The activeTab permission exposes tab.url whenever the user invokes the
  // extension — both via the toolbar click and the keyboard shortcut.
  if (tab.url) {
    sendUrl(tab, tab.url);
    return;
  }

  // Fallback: read the URL straight from the page.
  if (tab.id === undefined) return;
  chrome.scripting
    .executeScript({ target: { tabId: tab.id }, func: () => location.href })
    .then((results) => sendUrl(tab, results && results[0] && results[0].result))
    .catch(() => {});
}

// Keyboard shortcut (Alt+Shift+D).
chrome.commands.onCommand.addListener((command) => {
  if (command === 'download-video') {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      triggerDownload(tabs[0]);
    });
  }
});

// Clicking the extension's toolbar icon.
chrome.action.onClicked.addListener((tab) => {
  triggerDownload(tab);
});
