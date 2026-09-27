importScripts('policy.js');

function openDefault(url, source, done) {
  chrome.runtime.sendNativeMessage('com.omarchy.webapp_links', { url, source }, reply => {
    done(!chrome.runtime.lastError && reply?.opened === true);
  });
}

chrome.runtime.onMessage.addListener((message, sender, respond) => {
  if (sender.frameId !== 0 || !sender.tab) return;
  if (message?.action === 'policy') {
    chrome.runtime.sendNativeMessage('com.omarchy.webapp_links', { action: 'policy' }, reply => {
      respond(chrome.runtime.lastError ? null : reply);
    });
    return true;
  }
  const source = sender.url || sender.tab.url;
  if (!webappLinksPolicy.external(message?.url, source)) return;
  openDefault(message.url, source, respond);
  return true;
});

// A link with target=_blank or window.open creates a navigation target rather
// than following the same-tab click path. Leave the original target alone until
// xdg-open confirms success; if it fails, its normal navigation still proceeds.
chrome.webNavigation.onCreatedNavigationTarget.addListener(async details => {
  try {
    if (!['http:', 'https:'].includes(new URL(details.url).protocol)) return;
  } catch { return; }
  try {
    const frames = await chrome.scripting.executeScript({
      target: { tabId: details.sourceTabId, frameIds: [...new Set([0, details.sourceFrameId])] },
      func: () => ({ standalone: matchMedia('(display-mode: standalone)').matches, url: location.href })
    });
    const app = frames.find(frame => frame.frameId === 0)?.result;
    const source = frames.find(frame => frame.frameId === details.sourceFrameId)?.result;
    if (!app?.standalone || !source || !webappLinksPolicy.external(details.url, source.url)) return;
    openDefault(details.url, source.url, opened => {
      if (opened) chrome.tabs.remove(details.tabId).catch(() => {});
    });
  } catch {
    // A restricted/inaccessible opener is never reason to discard its popup.
  }
});
