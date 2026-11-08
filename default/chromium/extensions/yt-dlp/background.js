// HLS and DASH manifests, the streams a site's own player fetches.
const STREAM_PATTERN = /\.(?:m3u8|mpd)(?:[?#]|$)/i;

function streamKey(tabId) {
  return `stream:${tabId}`;
}

// A fragment change stays on the same video; anything else is another page.
function samePage(a, b) {
  return Boolean(a && b) && a.split('#')[0] === b.split('#')[0];
}

// Storage calls are asynchronous, so two events for one tab could otherwise land
// out of order: a late request from the old page saving its stream after the
// navigation cleared it. Each tab's updates run one after another in event order.
const tabQueues = new Map();

function onTab(tabId, task) {
  const run = (tabQueues.get(tabId) || Promise.resolve()).then(task).catch(() => {});
  tabQueues.set(tabId, run);
  run.then(() => {
    if (tabQueues.get(tabId) === run) tabQueues.delete(tabId);
  });
  return run;
}

function forgetStream(tabId) {
  return onTab(tabId, () => chrome.storage.session.remove(streamKey(tabId)));
}

// Remember the stream manifest each tab's player fetches. yt-dlp can't find a
// video on many course and members-only sites, because the player lives in a
// cross-origin iframe that builds the manifest URL in script, but the browser
// still sees the request. Within one player document the first manifest wins,
// since it is the master playlist when there is one, which lets yt-dlp pick the
// best quality; a new player document, like the next lesson's iframe, replaces
// it. Each stream records the page it was seen on, and is only ever used for
// that page. Session storage outlives the service worker, which Chromium stops
// when it goes idle.
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    const { tabId } = details;
    if (tabId < 0) return;

    if (details.type === 'main_frame') {
      forgetStream(tabId);
      return;
    }

    if (!STREAM_PATTERN.test(details.url)) return;

    const key = streamKey(tabId);
    const player = details.documentId || `frame:${details.frameId}`;
    onTab(tabId, async () => {
      const stored = (await chrome.storage.session.get(key))[key];
      if (stored && stored.player === player) return;

      const tab = await chrome.tabs.get(tabId);
      // CDNs that sign their streams often check the Referer, and the player
      // frame's origin is what the site's own requests carry.
      const referer = details.initiator && details.initiator !== 'null' ? `${details.initiator}/` : '';
      await chrome.storage.session.set({ [key]: { url: details.url, referer, player, page: tab.url } });
    });
  },
  { urls: ['http://*/*', 'https://*/*'], types: ['main_frame', 'sub_frame', 'xmlhttprequest', 'media', 'other'] }
);

// A course that switches lessons through the History API never loads a new top
// page, so a URL change is what retires the previous lesson's stream.
chrome.tabs.onUpdated.addListener((tabId, changeInfo) => {
  if (!changeInfo.url) return;

  const key = streamKey(tabId);
  onTab(tabId, async () => {
    const stored = (await chrome.storage.session.get(key))[key];
    if (stored && !samePage(stored.page, changeInfo.url)) await chrome.storage.session.remove(key);
  });
});

chrome.tabs.onRemoved.addListener((tabId) => {
  forgetStream(tabId);
});

function sendUrl(url, tab) {
  if (!url || !/^https?:/i.test(url)) return;

  const tabId = tab && tab.id;
  const key = streamKey(tabId);
  onTab(tabId, async () => {
    const stored = (await chrome.storage.session.get(key))[key];
    // Only a stream seen on this very page may stand in for it.
    const stream = stored && samePage(stored.page, url) ? stored : {};

    // The native messaging host runs yt-dlp and owns all the desktop
    // notifications, so we just hand off the URLs and ignore the reply. It
    // falls back to the stream only when yt-dlp can't handle the page itself.
    const message = { url, stream: stream.url, referer: stream.referer, title: tab && tab.title };
    chrome.runtime.sendNativeMessage('com.omarchy.ytdlp', message, () => {
      void chrome.runtime.lastError;
    });
  });
}

function triggerDownload(tab) {
  if (!tab) return;

  // The activeTab permission exposes tab.url whenever the user invokes the
  // extension — both via the toolbar click and the keyboard shortcut.
  if (tab.url) {
    sendUrl(tab.url, tab);
    return;
  }

  // Fallback: read the URL straight from the page.
  if (tab.id === undefined) return;
  chrome.scripting
    .executeScript({ target: { tabId: tab.id }, func: () => location.href })
    .then((results) => sendUrl(results && results[0] && results[0].result, tab))
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
