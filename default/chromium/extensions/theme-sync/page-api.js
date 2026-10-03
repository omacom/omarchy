// Main world. Exposes window.omarchy to page scripts.
//
// Every accessor reads the live DOM rather than caching a payload, so this is
// immune to the injection-order race between the isolated and main worlds: there
// is no first message to miss, only <html> to look at whenever the page asks.
//
// The API is read-only. A page can observe the palette, but it cannot set or
// install desktop themes through this extension.

(() => {
  const VAR_PREFIX = '--omarchy-';

  function colors() {
    const style = document.documentElement && document.documentElement.style;
    const out = {};
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

  Object.defineProperty(window, 'omarchy', {
    configurable: true,
    enumerable: false,
    value: Object.freeze({
      get theme() {
        return document.documentElement?.dataset.omarchyTheme || null;
      },
      get mode() {
        return document.documentElement?.dataset.omarchyMode || null;
      },
      colors,
      color(name) {
        return colors()[String(name).replace(/-/g, '_')] || null;
      },
      onChange(handler) {
        if (typeof handler !== 'function') return () => {};
        const listener = () => handler(Object.freeze(colors()));
        document.addEventListener('omarchythemechange', listener);
        return () => document.removeEventListener('omarchythemechange', listener);
      },
    }),
  });
})();
