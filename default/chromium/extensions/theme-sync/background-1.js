// Owns the single native messaging port and fans the palette out to every tab.
//
// The host pushes unprompted whenever omarchy-theme-set swaps the theme, so this
// worker mostly sits on an open port. Chrome keeps a service worker alive while a
// native port is connected, which is what lets a push arrive at all -- an idle
// MV3 worker would otherwise be torn down after 30s and miss it.
//
// This worker never posts to the port. Pages read the palette through the
// content scripts, and nothing a page does reaches this worker or the host, so
// no origin check or request validation lives here.

const HOST_NAME = 'com.omarchy.theme';
const RETRY_MIN_MS = 1000;
const RETRY_MAX_MS = 60000;

let port = null;
let retryMs = RETRY_MIN_MS;
let retryTimer = null;

function cache(palette) {
  // storage.local, not session: a content script at document_start needs the
  // palette even on the very first page load after the worker was torn down,
  // and session storage would be empty on a cold browser start.
  chrome.storage.local.set({ palette }).catch(() => {});
}

function broadcast(palette) {
  chrome.tabs.query({}, (tabs) => {
    void chrome.runtime.lastError;
    for (const tab of tabs || []) {
      if (tab.id === undefined) continue;
      // Tabs without our content script (chrome://, the web store) reject the
      // message; that is expected, so swallow the error rather than logging per tab.
      chrome.tabs.sendMessage(tab.id, { type: 'palette', palette }, () => {
        void chrome.runtime.lastError;
      });
    }
  });
}

function scheduleReconnect() {
  if (retryTimer !== null) return;
  retryTimer = setTimeout(() => {
    retryTimer = null;
    connect();
  }, retryMs);
  // Back off so a missing or crash-looping host does not spawn a process per second.
  retryMs = Math.min(retryMs * 2, RETRY_MAX_MS);
}

function connect() {
  if (port) return;

  try {
    port = chrome.runtime.connectNative(HOST_NAME);
  } catch (error) {
    port = null;
    scheduleReconnect();
    return;
  }

  port.onMessage.addListener((message) => {
    if (!message || message.type !== 'palette') return;
    // A message proves the host is healthy, so the next disconnect starts its
    // backoff from scratch instead of inheriting a long delay.
    retryMs = RETRY_MIN_MS;
    cache(message);
    broadcast(message);
  });

  port.onDisconnect.addListener(() => {
    void chrome.runtime.lastError;
    port = null;
    scheduleReconnect();
  });
}

// A content script asking for the palette is also the signal that the worker was
// respawned, so use it to re-open the port that died with the previous instance.
chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (!message || message.type !== 'omarchy-get-palette') return false;

  connect();
  chrome.storage.local.get('palette').then(
    (stored) => sendResponse(stored.palette || null),
    () => sendResponse(null)
  );

  return true; // keep the channel open for the async storage read
});

chrome.runtime.onStartup.addListener(connect);
chrome.runtime.onInstalled.addListener(connect);
connect();
