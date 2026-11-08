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

// Remember the stream manifest each player on a tab's page fetches. yt-dlp can't
// find a video on many course and members-only sites, because the player lives
// in a cross-origin iframe that builds the manifest URL in script, but the
// browser still sees the request. Streams are kept per frame, so an ad or preview
// player elsewhere on the page never displaces the lesson's. Within one frame the
// first manifest of its current document wins, since it is the master playlist
// when there is one, which lets yt-dlp pick the best quality; a new document in
// that frame, like the next lesson loading into the same iframe, replaces it. The
// streams belong to the page they were seen on and are only ever used for it.
// Session storage outlives the service worker, which Chromium stops when idle.
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
    const { frameId } = details;
    const documentId = details.documentId || '';
    onTab(tabId, async () => {
      const tab = await chrome.tabs.get(tabId);
      let stored = (await chrome.storage.session.get(key))[key];
      if (!stored || !samePage(stored.page, tab.url)) stored = { page: tab.url, seen: 0, streams: {} };

      const current = stored.streams[frameId];
      if (current && current.document === documentId) return;

      // CDNs that sign their streams often check the Referer, and the player
      // frame's origin is what the site's own requests carry.
      const referer = details.initiator && details.initiator !== 'null' ? `${details.initiator}/` : '';
      // A frame keeps the place it first took, so the next lesson loading into
      // the main player still ranks ahead of an ad that loaded in the meantime.
      let seen = current && current.seen;
      if (!seen) {
        stored.seen += 1;
        seen = stored.seen;
      }
      stored.streams[frameId] = { url: details.url, referer, document: documentId, seen };
      await chrome.storage.session.set({ [key]: stored });
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

// How much each frame looks like the player the user is watching: a playing
// video beats one that has played, which beats one that hasn't, and a bigger
// video beats a smaller one. Runs inside every frame of the page.
function scorePlayback() {
  let best = 0;
  for (const video of document.querySelectorAll('video')) {
    const rect = video.getBoundingClientRect();
    const area = Math.min(Math.round(rect.width * rect.height), 1e7);
    const playing = !video.paused && !video.ended ? 1 : 0;
    const played = video.currentTime > 0 ? 1 : 0;
    best = Math.max(best, playing * 1e9 + played * 1e8 + area);
  }
  return best;
}

// Pick the stream of the frame that is playing; failing that, the first stream
// the page fetched, which is usually its main player.
async function chooseStream(tabId, streams) {
  const candidates = Object.entries(streams);
  if (candidates.length < 2) return candidates.length ? candidates[0][1] : null;

  const scores = new Map();
  try {
    const results = await chrome.scripting.executeScript({ target: { tabId, allFrames: true }, func: scorePlayback });
    for (const { frameId, documentId, result } of results) scores.set(String(frameId), { documentId, score: result || 0 });
  } catch (_) {
    // Frames we can't script just keep their place in fetch order.
  }

  const score = ([frameId, stream]) => {
    const frame = scores.get(frameId);
    return frame && (!frame.documentId || !stream.document || frame.documentId === stream.document) ? frame.score : 0;
  };
  candidates.sort((a, b) => score(b) - score(a) || a[1].seen - b[1].seen);
  return candidates[0][1];
}

function sendUrl(url, tab) {
  if (!url || !/^https?:/i.test(url)) return;

  const tabId = tab && tab.id;
  const key = streamKey(tabId);
  onTab(tabId, async () => {
    const stored = (await chrome.storage.session.get(key))[key];
    // Only a stream seen on this very page may stand in for it.
    const streams = stored && samePage(stored.page, url) ? stored.streams : {};
    const stream = (await chooseStream(tabId, streams)) || {};

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
