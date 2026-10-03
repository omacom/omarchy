// Used by both the content script and service worker. Cross-origin allowances
// are checked by the native host against the user's per-app configuration.
// Automatic redirects and form submissions are never intercepted.
const webappLinksPolicy = (() => {
  function external(destination, source, allowed = {}) {
    try {
      const target = new URL(destination);
      const origin = new URL(source);
      if (!['http:', 'https:'].includes(target.protocol) ||
          !['http:', 'https:'].includes(origin.protocol) || target.origin === origin.origin) return false;
      return !Object.entries(allowed).some(([app, origins]) => {
        const group = [app, ...origins];
        return group.includes(origin.origin) && group.includes(target.origin);
      });
    } catch {
      return false;
    }
  }

  return { external };
})();
