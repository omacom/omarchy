// The native host stays connected only while a Calendar tab is open. It sends
// the palette on connect and again whenever the Omarchy theme changes, and the
// open native port also keeps this service worker alive. Pages pick the
// palette up from storage, so a new tab paints with it straight away.
const RETRY_MIN = 1000;
const RETRY_MAX = 60000;

const calendarPorts = new Set();
let nativePort = null;
let retryTimer = null;
let retryDelay = RETRY_MIN;

function connectNative() {
  if (nativePort || calendarPorts.size === 0) return;

  nativePort = chrome.runtime.connectNative('com.omarchy.theme');
  nativePort.onMessage.addListener((message) => {
    if (message?.type !== 'palette') return;
    retryDelay = RETRY_MIN;
    const { theme, mode, colors, accents } = message;
    chrome.storage.local.set({ palette: { theme, mode, colors, accents } });
  });
  nativePort.onDisconnect.addListener(() => {
    void chrome.runtime.lastError; // Read, or Chromium logs it as unchecked.
    nativePort = null;
    if (calendarPorts.size === 0) return;

    // We only disconnect on our own side when the last tab closes, so this is
    // a missing, crashed or failing host: retry, backing off while it keeps
    // failing. A host installed after the fact is picked up this way too.
    clearTimeout(retryTimer);
    retryTimer = setTimeout(connectNative, retryDelay);
    retryDelay = Math.min(retryDelay * 2, RETRY_MAX);
  });
}

chrome.runtime.onConnect.addListener((port) => {
  if (port.name !== 'calendar') return;

  calendarPorts.add(port);
  port.onDisconnect.addListener(() => {
    calendarPorts.delete(port);
    if (calendarPorts.size > 0) return;
    clearTimeout(retryTimer);
    nativePort?.disconnect();
    nativePort = null;
  });
  connectNative();
});
