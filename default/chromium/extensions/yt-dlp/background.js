// HLS and DASH manifests, the streams a site's own player fetches.
const STREAM_PATTERN = /\.(?:m3u8|mpd)(?:[?#]|$)/i;

function streamKey(tabId) {
  return `stream:${tabId}`;
}

// Remember the first stream manifest each tab fetches since it last navigated.
// yt-dlp can't find a video on many course and members-only sites, because the
// player lives in a cross-origin iframe that builds the manifest URL in script,
// but the browser still sees the request. The first manifest is the master
// playlist when there is one, which lets yt-dlp pick the best quality. Session
// storage outlives the service worker, which Chromium stops when it goes idle.
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    if (details.tabId < 0) return;

    if (details.type === 'main_frame') {
      chrome.storage.session.remove(streamKey(details.tabId));
      return;
    }

    if (!STREAM_PATTERN.test(details.url)) return;

    const key = streamKey(details.tabId);
    chrome.storage.session.get(key).then((stored) => {
      if (stored[key]) return;
      // CDNs that sign their streams often check the Referer, and the player
      // frame's origin is what the site's own requests carry.
      const referer = details.initiator && details.initiator !== 'null' ? `${details.initiator}/` : '';
      chrome.storage.session.set({ [key]: { url: details.url, referer } });
    });
  },
  { urls: ['http://*/*', 'https://*/*'], types: ['main_frame', 'sub_frame', 'xmlhttprequest', 'media', 'other'] }
);

chrome.tabs.onRemoved.addListener((tabId) => {
  chrome.storage.session.remove(streamKey(tabId));
});

function sendUrl(url, tab) {
  if (!url || !/^https?:/i.test(url)) return;

  const key = streamKey(tab && tab.id);
  chrome.storage.session.get(key).then((stored) => {
    const stream = stored[key] || {};

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
