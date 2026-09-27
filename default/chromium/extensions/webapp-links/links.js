// Chromium --app windows advertise standalone display mode; normal browser
// tabs (including tabs opened by xdg-open in the same browser) do not.
let allowedOrigins = null;
if (matchMedia('(display-mode: standalone)').matches) {
  chrome.runtime.sendMessage({ action: 'policy' }, reply => {
    if (!chrome.runtime.lastError && reply?.origins) allowedOrigins = reply.origins;
  });
}

document.addEventListener('click', event => {
  if (!matchMedia('(display-mode: standalone)').matches || event.defaultPrevented || event.button !== 0 ||
      event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;

  const link = event.composedPath().find(node => node instanceof Element && node.matches('a[href], area[href]'));
  if (!link || link.hasAttribute('download') || (link.target && link.target !== '_self')) return;
  // No host/policy yet: leave the browser's original click handling intact.
  if (!allowedOrigins || !webappLinksPolicy.external(link.href, location.href, allowedOrigins)) return;

  event.preventDefault();
  event.stopImmediatePropagation();
  chrome.runtime.sendMessage({ url: link.href }, opened => {
    // If the extension/host/default browser is unavailable, the link still works.
    if (chrome.runtime.lastError || opened !== true) location.assign(link.href);
  });
}, true);
