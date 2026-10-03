// Isolated world. Writes the palette into the shared DOM, which is the only part
// of this extension that pages actually see.
//
// Inline custom properties on <html> are visible to page CSS and to page
// JavaScript through getComputedStyle, even though this script's own globals are
// not. That makes the DOM the contract and removes any need to hand the palette
// across the world boundary.

const VAR_PREFIX = '--omarchy-';
const CHANGE_EVENT = 'omarchythemechange';

let applied = null;

function apply(palette) {
  const root = document.documentElement;
  if (!root || !palette || !palette.colors) return;

  // Theme switches re-send the whole palette; a key that disappeared between
  // themes has to be removed or it would linger as a stale value.
  const next = new Set();
  for (const [key, value] of Object.entries(palette.colors)) {
    if (typeof value !== 'string') continue;
    const property = VAR_PREFIX + key.replace(/_/g, '-');
    next.add(property);
    root.style.setProperty(property, value);
  }

  if (applied) {
    for (const property of applied) {
      if (!next.has(property)) root.style.removeProperty(property);
    }
  }
  applied = next;

  // Descriptive only. Setting color-scheme here would restyle form controls and
  // scrollbars on every site, so the mode is advertised and left for pages to use.
  if (palette.mode) root.dataset.omarchyMode = palette.mode;
  if (palette.name) root.dataset.omarchyTheme = palette.name;

  // No detail: cloning an object across the isolated/main boundary is realm
  // -sensitive, and pages read the values straight off window.omarchy or CSS.
  document.dispatchEvent(new Event(CHANGE_EVENT));
}

// Two sources, whichever lands first. The cached read covers a cold service
// worker; the request wakes the worker so it re-opens the native port.
chrome.storage.local.get('palette').then(
  (stored) => { if (stored.palette && !applied) apply(stored.palette); },
  () => {}
);

chrome.runtime.sendMessage({ type: 'omarchy-get-palette' }, (palette) => {
  void chrome.runtime.lastError;
  if (palette) apply(palette);
});

chrome.runtime.onMessage.addListener((message) => {
  if (message && message.type === 'palette') apply(message.palette);
});
