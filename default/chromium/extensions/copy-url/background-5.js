// Keep this filename versioned. Chromium caches service workers for extensions
// loaded via --load-extension, so a new URL forces registration of new code.

function sendToHost(message, callback = () => {}) {
  chrome.runtime.sendNativeMessage('com.omarchy.copy_url', message, (response) => {
    const failed = Boolean(chrome.runtime.lastError);
    callback(failed ? undefined : response);
  });
}

function copyUrl(url) {
  if (!url) return;

  // The native host owns both the Wayland clipboard and confirmation toast.
  sendToHost({ url });
}

async function openWebAppTargetInDefaultBrowser({ sourceTabId, tabId, url }) {
  if (!/^https?:\/\//i.test(url)) return;

  try {
    const sourceTab = await chrome.tabs.get(sourceTabId);
    const sourceWindow = await chrome.windows.get(sourceTab.windowId);
    if (sourceWindow.type !== 'app') return;

    // Chromium has already created the target by the time this event fires.
    // Keep it as a fallback unless the native host confirms the handoff.
    sendToHost({ action: 'open', url }, (response) => {
      if (response && response.opened) {
        chrome.tabs.remove(tabId).catch(() => {});
      }
    });
  } catch (_) {
    // The source or target can disappear while an asynchronous lookup is in
    // flight. In that case Chromium has already handled the navigation.
  }
}

chrome.commands.onCommand.addListener((command) => {
  if (command !== 'copy-url') return;

  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    copyUrl(tabs[0] && tabs[0].url);
  });
});

chrome.action.onClicked.addListener((tab) => {
  copyUrl(tab && tab.url);
});

chrome.webNavigation.onCreatedNavigationTarget.addListener(openWebAppTargetInDefaultBrowser);

if (typeof module !== 'undefined') {
  module.exports = { openWebAppTargetInDefaultBrowser };
}
