// NOTE: this file is intentionally version-numbered (background-2.js). Chromium
// caches the service worker for a command-line --load-extension and does NOT
// re-register it when the script changes in place, so an updated worker never
// takes effect on existing installs. Changing the filename is a new script URL,
// which forces a fresh registration. If you change this worker's code, rename it
// (background-3.js, ...) and update manifest.json's background.service_worker.

// yt-dlp downloads as a guest, so an age-restricted, members-only or private
// video fails with "Sign in to confirm your age". Read the cookies the page
// itself sends and hand them to the host, which passes them to yt-dlp as the
// Netscape cookie file documented in its FAQ — the same export the cookie
// extensions yt-dlp recommends would make by hand, scoped to this page's URL
// rather than the whole browser.
function collectCookies(url) {
  return new Promise((resolve) => {
    try {
      chrome.cookies.getAll({ url }, (cookies) => {
        void chrome.runtime.lastError;
        resolve(
          (cookies || []).map((cookie) => ({
            domain: cookie.domain,
            hostOnly: cookie.hostOnly,
            path: cookie.path,
            secure: cookie.secure,
            httpOnly: cookie.httpOnly,
            expirationDate: cookie.expirationDate,
            name: cookie.name,
            value: cookie.value,
          }))
        );
      });
    } catch {
      resolve([]);
    }
  });
}

function sendUrl(url) {
  if (!url || !/^https?:/i.test(url)) return;

  // The native messaging host runs yt-dlp and owns all the desktop
  // notifications, so we just hand off the URL and cookies and ignore the reply.
  collectCookies(url).then((cookies) => {
    chrome.runtime.sendNativeMessage('com.omarchy.ytdlp', { url, cookies }, () => {
      void chrome.runtime.lastError;
    });
  });
}

function triggerDownload(tab) {
  if (!tab) return;

  // The activeTab permission exposes tab.url whenever the user invokes the
  // extension — both via the toolbar click and the keyboard shortcut.
  if (tab.url) {
    sendUrl(tab.url);
    return;
  }

  // Fallback: read the URL straight from the page.
  if (tab.id === undefined) return;
  chrome.scripting
    .executeScript({ target: { tabId: tab.id }, func: () => location.href })
    .then((results) => sendUrl(results && results[0] && results[0].result))
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
