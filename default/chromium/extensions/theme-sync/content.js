// A dynamic top-frame script, registered only for approved hosts. Host grants
// span ports, so the worker must approve this exact document's origin before
// anything is published. No page event or postMessage reaches the worker.
(() => {
  if (globalThis.__omarchyThemeSync) return;
  globalThis.__omarchyThemeSync = true;
  let updates = 0;
  let pending = null;
  let published = false;

  function removeColors() {
    const root = document.documentElement;
    if (!root) return;
    for (const property of [...root.style]) {
      if (property.startsWith('--omarchy-')) root.style.removeProperty(property);
    }
  }

  function clear() {
    pending = null;
    if (!published) return;
    published = false;
    const root = document.documentElement;
    if (!root) return;
    removeColors();
    delete root.dataset.omarchySharing;
    delete root.dataset.omarchyMode;
    delete root.dataset.omarchyTheme;
    document.dispatchEvent(new Event('omarchythemechange'));
  }

  function apply(message) {
    const palette = ThemeSyncPolicy.palette(message);
    if (!palette) { clear(); return; }
    if (!document.documentElement) { pending = palette; return; }
    removeColors();
    const root = document.documentElement;
    delete root.dataset.omarchyTheme;
    for (const [key, value] of Object.entries(palette.colors)) {
      root.style.setProperty('--omarchy-' + key.replace(/_/g, '-'), value);
    }
    root.dataset.omarchyMode = palette.mode;
    root.dataset.omarchySharing = 'true';
    published = true;
    // The main-world API is injected only after this authenticated delivery.
    chrome.runtime.sendMessage({ type: 'omarchy-enable-api' }, () => { void chrome.runtime.lastError; });
    document.dispatchEvent(new Event('omarchythemechange'));
  }

  document.addEventListener('DOMContentLoaded', () => {
    if (pending) apply(pending);
  }, { once: true });

  chrome.runtime.onMessage.addListener((message, sender) => {
    if (sender.id !== chrome.runtime.id || sender.tab) return;
    // Reauthorize broadcasts too: a palette notification queued before a
    // revocation cannot republish data after its clear message arrived.
    if (message?.type === 'omarchy-palette') request();
    if (message?.type === 'omarchy-clear-palette') { updates++; clear(); }
  });
  function request() {
    const requestedAt = ++updates;
    chrome.runtime.sendMessage({ type: 'omarchy-get-palette' }, palette => {
      void chrome.runtime.lastError;
      // A delayed reply must not overwrite a newer broadcast or revocation.
      if (updates === requestedAt) apply(palette);
    });
  }
  request();
})();
