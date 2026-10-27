// Main world. Exposes window.omarchy to page scripts.
//
// Every accessor reads the live DOM rather than caching a payload, so this is
// immune to the injection-order race between the isolated and main worlds: there
// is no first message to miss, only <html> to look at whenever the page asks.
//
// The API is read-only. A page can observe the palette, but it cannot set or
// install desktop themes through this extension.

(() => {
  if (document.documentElement?.dataset.omarchySharing !== 'true' || Object.hasOwn(window, 'omarchy')) return;
  const VAR_PREFIX = '--omarchy-';

  function colors() {
    const style = document.documentElement && document.documentElement.style;
    const out = Object.create(null);
    if (!style) return out;

    // Inline custom properties enumerate through the style declaration's index,
    // which is how the main world reads what the isolated world wrote.
    for (let i = 0; i < style.length; i++) {
      const property = style[i];
      if (!property.startsWith(VAR_PREFIX)) continue;
      out[property.slice(VAR_PREFIX.length).replace(/-/g, '_')] =
        style.getPropertyValue(property).trim();
    }
    return out;
  }

  const api = Object.freeze({
    // Custom theme names are private. Retain the getter for compatibility.
    get theme() { return null; },
    get mode() {
      const mode = document.documentElement?.dataset.omarchyMode;
      return ['dark', 'light'].includes(mode) ? mode : null;
    },
    colors,
    color(name) {
      const key = String(name).replace(/-/g, '_');
      const snapshot = colors();
      return Object.hasOwn(snapshot, key) ? snapshot[key] : null;
    },
    onChange(handler) {
      if (typeof handler !== 'function') return () => {};
      const listener = () => handler(Object.freeze(colors()));
      document.addEventListener('omarchythemechange', listener);
      return () => document.removeEventListener('omarchythemechange', listener);
    },
  });
  Object.defineProperty(window, 'omarchy', {
    configurable: true,
    enumerable: false,
    value: api,
  });
  const revoke = () => {
    if (document.documentElement?.dataset.omarchySharing === 'true') return;
    if (window.omarchy === api) delete window.omarchy;
    document.removeEventListener('omarchythemechange', revoke);
  };
  document.addEventListener('omarchythemechange', revoke);
  // The authorized main-world injection can arrive after the isolated script's
  // first DOM update. Announce API availability as well as palette changes.
  document.dispatchEvent(new Event('omarchythemechange'));
})();
