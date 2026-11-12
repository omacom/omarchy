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

// Request headers by requestId, held until the request finishes. A redirect
// sends the request again under the same id, so its headers are replaced.
const pendingHeaders = new Map();

// Each navigation in a tab, including a single-page app moving to another
// video, starts a new generation. A request that began in an earlier one
// belongs to the previous video and must not fill the cleared slot.
const generations = new Map();

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
  generations.set(tabId, (generations.get(tabId) || 0) + 1);
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
    // A redirect keeps the generation its request started in: following it
    // after a navigation doesn't make the previous video's stream current.
    const earlier = pendingHeaders.get(details.requestId);
    const generation = earlier ? earlier.generation : generations.get(details.tabId) || 0;
    pendingHeaders.set(details.requestId, { headers, generation });
  },
  WATCHED,
  ['requestHeaders', 'extraHeaders'],
);

chrome.webRequest.onHeadersReceived.addListener(
  (details) => {
    // A redirect is followed by the response that matters, with its own headers.
    if (details.tabId < 0 || details.statusCode < 200 || details.statusCode >= 300) return;

    const pending = pendingHeaders.get(details.requestId);
    if (!pending || pending.generation !== (generations.get(details.tabId) || 0)) return;

    const kind = streamKind(details);
    if (!kind) return;

    const key = tabKey(details.tabId);
    serially(async () => {
      if (pending.generation !== (generations.get(details.tabId) || 0)) return;
      const seen = (await chrome.storage.session.get(key))[key] || {};
      // The first manifest is the master playlist; later ones are its variants.
      // The same one fetched again carries the player's renewed credentials.
      if (seen[kind] && seen[kind].url !== details.url) return;
      seen[kind] = { url: details.url, headers: pending.headers };
      await chrome.storage.session.set({ [key]: seen });
    });
  },
  WATCHED,
  ['responseHeaders'],
);

for (const event of [chrome.webRequest.onCompleted, chrome.webRequest.onErrorOccurred]) {
  event.addListener((details) => {
    pendingHeaders.delete(details.requestId);
  }, WATCHED);
}

// A new page, or a single-page app moving to another video, starts over.
chrome.webNavigation.onCommitted.addListener((details) => {
  if (details.frameId === 0) forget(details.tabId);
});

chrome.webNavigation.onHistoryStateUpdated.addListener((details) => {
  if (details.frameId === 0) forget(details.tabId);
});

chrome.tabs.onRemoved.addListener((tabId) => {
  forget(tabId);
  generations.delete(tabId);
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
