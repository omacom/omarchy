// Shared by the worker and isolated script, never installed in the page world.
globalThis.ThemeSyncPolicy = (() => {
  const colorKeys = Object.freeze([
    'accent', 'background', 'dark_background', 'darker_background', 'lighter_background',
    'foreground', 'dark_foreground', 'light_foreground', 'bright_foreground', 'cursor',
    'selection', 'selection_background', 'selection_foreground', 'muted', 'red', 'green',
    'yellow', 'blue', 'magenta', 'cyan', 'orange', 'brown', 'bright_red', 'bright_green',
    'bright_yellow', 'bright_blue', 'bright_magenta', 'bright_cyan',
  ]);

  function origin(url) {
    try {
      const parsed = new URL(url);
      if (!['http:', 'https:'].includes(parsed.protocol) || parsed.username || parsed.password) return null;
      return parsed.origin;
    } catch {
      return null;
    }
  }

  function pattern(url) {
    const parsed = new URL(url);
    // Chromium host grants span ports. The separate exact-origin approval is
    // checked again for every response and broadcast, including localhost.
    return `${parsed.protocol}//${parsed.hostname}/*`;
  }

  function palette(message) {
    if (!message || message.type !== 'palette' || !['dark', 'light'].includes(message.mode) ||
        !message.colors || typeof message.colors !== 'object' || Array.isArray(message.colors)) return null;
    const colors = {};
    for (const key of colorKeys) {
      const value = message.colors[key];
      if (Object.hasOwn(message.colors, key) && typeof value === 'string' && /^#[0-9a-f]{6}$/i.test(value)) {
        colors[key] = value.toLowerCase();
      }
    }
    return { type: 'palette', mode: message.mode, colors };
  }

  return Object.freeze({ colorKeys, origin, pattern, palette });
})();
