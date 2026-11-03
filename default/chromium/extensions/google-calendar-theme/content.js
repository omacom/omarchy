(() => {
  // Google's class names are obfuscated and change often, so nothing here
  // targets them. Colors are remapped by what they are instead:
  //
  //  - Inline styles carry calendar and event colors. A color the user picked
  //    from the theme is kept, and one picked as another theme's accent takes
  //    this theme's. Any other saturated color is bucketed by hue into a theme
  //    slot (red, orange, ..., magenta), keeping Google's light and dark
  //    variants distinct by mixing toward the paper or the ink. Past events,
  //    which Google fades toward its paper, fade from whatever their calendar
  //    color became.
  //  - Stylesheet rules carry the interface. Neutrals are placed by their
  //    distance from Google's paper: its surfaces become shades of the theme
  //    background, and its text and borders run from there to the theme
  //    foreground. Google blue becomes the theme accent. The paper is white or
  //    near-black depending on Calendar's own appearance setting.

  // Google's paper in its light and dark appearance (Material 3's dark surface).
  const WHITE = { r: 255, g: 255, b: 255 };
  const DARK_PAPER = { r: 19, g: 19, b: 20 };
  // What Google fades past and tentative events toward in its dark appearance
  // (fills halfway, borders a quarter); in its light one, it is white.
  const DARK_FADE = { r: 35, g: 35, b: 36 };
  const COLOR_RE = /#[0-9a-f]{3,8}\b|rgba?\([^)]*\)|\b(?:white|black)\b/gi;
  const RGB_TRIPLE_RE = /^\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*$/;
  const INK_ATTR = 'data-omarchy-ink';
  const STYLE_ID = 'omarchy-google-calendar-theme';
  const SHEET_EVENT = 'omarchy-calendar-sheet-change'; // Sent by sheet-hook.js.

  let palette = null;
  let theme = null;
  let googleDark = false; // Which appearance Google is drawing; see checkAppearance.

  const inlineState = new WeakMap(); // Element -> Map(prop -> { orig, out })
  const ruleEntries = []; // { style, prop, orig, priority }
  const seenRules = new WeakSet();
  const sheetLengths = new WeakMap();

  // ---------------------------------------------------------------- colors

  function parseHex(hex) {
    let h = hex.slice(1);
    if (h.length === 3 || h.length === 4) h = [...h].map((c) => c + c).join('');
    if (h.length !== 6 && h.length !== 8) return null;
    const n = (i) => parseInt(h.slice(i, i + 2), 16);
    return { r: n(0), g: n(2), b: n(4), a: h.length === 8 ? n(6) / 255 : 1 };
  }

  function parseColor(text) {
    const value = text.trim().toLowerCase();
    if (value === 'white') return { r: 255, g: 255, b: 255, a: 1 };
    if (value === 'black') return { r: 0, g: 0, b: 0, a: 1 };
    if (value.startsWith('#')) return parseHex(value);

    const parts = value.replace(/^rgba?\(|\)$/g, '').split(/[\s,/]+/).filter(Boolean);
    if (parts.length < 3 || parts.slice(0, 3).some((p) => p.endsWith('%') || isNaN(p))) return null;
    let a = 1;
    if (parts[3] !== undefined) a = parts[3].endsWith('%') ? parseFloat(parts[3]) / 100 : parseFloat(parts[3]);
    return { r: +parts[0], g: +parts[1], b: +parts[2], a: isNaN(a) ? 1 : a };
  }

  function toHex({ r, g, b }) {
    return '#' + [r, g, b].map((v) => Math.round(v).toString(16).padStart(2, '0')).join('');
  }

  function format(color, alpha) {
    if (alpha >= 1) return toHex(color);
    const { r, g, b } = color;
    return `rgba(${Math.round(r)}, ${Math.round(g)}, ${Math.round(b)}, ${+alpha.toFixed(3)})`;
  }

  function mix(a, b, amount) {
    return {
      r: a.r + (b.r - a.r) * amount,
      g: a.g + (b.g - a.g) * amount,
      b: a.b + (b.b - a.b) * amount,
    };
  }

  function luminance({ r, g, b }) {
    const lin = (v) => ((v /= 255) <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4);
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
  }

  function contrast(a, b) {
    const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
    return (hi + 0.05) / (lo + 0.05);
  }

  const near = (a, b, tolerance = 2) =>
    Math.abs(a.r - b.r) <= tolerance && Math.abs(a.g - b.g) <= tolerance && Math.abs(a.b - b.b) <= tolerance;

  // Where c falls along the line from a (0) to b (1).
  function project(c, a, b) {
    const axis = ['r', 'g', 'b'];
    const span = axis.reduce((sum, k) => sum + (b[k] - a[k]) ** 2, 0);
    return span ? axis.reduce((sum, k) => sum + (c[k] - a[k]) * (b[k] - a[k]), 0) / span : 0;
  }

  function classify({ r, g, b }) {
    const max = Math.max(r, g, b) / 255;
    const min = Math.min(r, g, b) / 255;
    const chroma = max - min;
    const l = (max + min) / 2;
    if (chroma < 0.07) return { slot: 'neutral', l };

    const s = chroma / (1 - Math.abs(2 * l - 1));
    let h;
    if (max === r / 255) h = ((g - b) / 255 / chroma) % 6;
    else if (max === g / 255) h = (b - r) / 255 / chroma + 2;
    else h = (r - g) / 255 / chroma + 4;
    h = (h * 60 + 360) % 360;

    // Google draws its built-in colors in different shades in its dark
    // appearance, drifting a few degrees of hue (Tomato from 0 to 11, Peacock
    // from 200 to 205), so the red and cyan edges sit clear of both shades.
    let slot;
    if (h >= 345 || h < 12.5) slot = 'red';
    else if (h < 40) slot = s < 0.5 && l < 0.5 ? 'brown' : 'orange';
    else if (h < 70) slot = 'yellow';
    else if (h < 165) slot = 'green';
    else if (h < 210) slot = 'cyan';
    else if (h < 255) slot = 'blue';
    else slot = 'magenta';
    return { slot, l };
  }

  // -------------------------------------------------------------- the theme

  function buildTheme() {
    const c = palette.colors;
    const color = (...keys) => parseHex(keys.map((k) => c[k]).find(Boolean));
    const bg = color('background');
    const fg = color('foreground');
    const accent = color('accent', 'blue', 'foreground');
    // Only saturated colors count as a calendar color picked from a theme.
    // Google's picker can't produce a neutral, and a neutral would claim every
    // grey on the page as one of its fades, or pin white surfaces in place.
    const saturated = (hexes) =>
      [...new Set(hexes)].map(parseHex).filter((color) => color && classify(color).slot !== 'neutral');
    const own = saturated(
      Object.entries(c)
        .filter(([key]) => !/background|^bg$|_bg$|^color0$/.test(key))
        .map(([, hex]) => hex),
    );
    // A calendar color picked as another theme's accent was picked as an
    // accent, so it becomes this theme's; this theme's own colors stay put.
    const foreignAccents = saturated(palette.accents || []).filter((a) => !own.some((o) => near(a, o)));

    return {
      bg,
      fg,
      // Surfaces rise from the background toward the foreground's side.
      lift: luminance(bg) < luminance(fg) ? 1 : -1,
      accent,
      own,
      picks: [...own.map((o) => ({ from: o, to: o })), ...foreignAccents.map((a) => ({ from: a, to: accent }))],
      slots: {
        red: color('red', 'foreground'),
        orange: color('orange', 'red', 'foreground'),
        yellow: color('yellow', 'foreground'),
        brown: color('brown', 'orange', 'foreground'),
        green: color('green', 'foreground'),
        cyan: color('cyan', 'foreground'),
        blue: color('blue', 'foreground'),
        magenta: color('magenta', 'foreground'),
      },
    };
  }

  const DARK_PAPER_L = classify(DARK_PAPER).l;

  // How far a neutral sits from Google's paper (0) toward its ink (1).
  function inkDepth(l) {
    return googleDark ? Math.max(0, (l - DARK_PAPER_L) / (1 - DARK_PAPER_L)) : 1 - l;
  }

  // Google's surfaces (paper, containers, hover fills) lie within this depth;
  // its borders, icons and text lie beyond it.
  const SURFACE_DEPTH = 0.15;
  // The lightness the deepest surface rises from the theme background.
  const SURFACE_LIFT = 0.12;
  // Google's text (Material 3's on-surface, tone 10 on light paper and 90 on
  // dark) sits at this depth rather than at full ink, so it and anything past
  // it become the theme foreground itself, not a fade of it.
  const INK_DEPTH = 0.88;

  // A surface is the theme background made lighter (or darker, on a light
  // theme) by an equal shift on every channel, which keeps the background's
  // own hue and tint rather than taking on the foreground's. Google's surfaces
  // are only a few percent apart, so the curve spreads the first steps out,
  // keeping the sidebar and the calendar canvas apart on low-contrast themes.
  function surface(depth) {
    const shift = SURFACE_LIFT * 255 * theme.lift * Math.sqrt(Math.min(depth, SURFACE_DEPTH) / SURFACE_DEPTH);
    const channel = (v) => Math.min(255, Math.max(0, v + shift));
    return { r: channel(theme.bg.r), g: channel(theme.bg.g), b: channel(theme.bg.b) };
  }

  function mapNeutral(l) {
    const depth = inkDepth(l);
    if (depth <= SURFACE_DEPTH) return surface(depth);
    return mix(surface(SURFACE_DEPTH), theme.fg, Math.min(1, (depth - SURFACE_DEPTH) / (INK_DEPTH - SURFACE_DEPTH)));
  }

  // Keep each color's distance from the paper, so Flamingo stays lighter than
  // Tomato, a container stays a faint tint, and so on. Event colors are the
  // same in both of Google's appearances; the interface's dark tones aren't:
  // Material 3 puts containers near tone 30, primaries near 80 and the text on
  // containers near 90 there.
  function variant(base, l, dark) {
    if (dark) {
      if (l <= 0.4) return mix(base, theme.bg, 0.8);
      if (l < 0.6) return mix(base, theme.bg, 0.3);
      if (l >= 0.88) return mix(base, theme.fg, 0.25);
      return base;
    }
    if (l >= 0.85) return mix(base, theme.bg, 0.8);
    if (l >= 0.62) return mix(base, theme.bg, 0.3);
    if (l <= 0.33) return mix(base, theme.fg, 0.25);
    return base;
  }

  // How far Google faded base to get color, and how many levels color strays
  // from that, or null when color is no fade of it. Google fades past and
  // tentative events this way, in its own color space, so a fade lands a level
  // or so off a straight mix.
  function fade(color, base) {
    const target = googleDark ? DARK_FADE : WHITE;
    const t = project(color, base, target);
    if (t < 0.05 || t > 0.97) return null;
    const straight = mix(base, target, t);
    const error = Math.max(...['r', 'g', 'b'].map((k) => Math.abs(color[k] - straight[k])));
    return error <= 3 ? { t, error } : null;
  }

  const fadeOf = (color, base) => fade(color, base)?.t ?? null;

  // Calendar and event colors Google draws inline, learned as the page shows
  // them. A fade is only recognized as one by knowing its base, and a calendar
  // with nothing but past events this week shows its base only on its swatch.
  let bases = [];
  let reprocessQueued = false;

  function learnBase(color) {
    if (classify(color).slot === 'neutral') return;
    if (theme.picks.some(({ from }) => near(color, from) || fadeOf(color, from) !== null)) return;
    if (bases.some((base) => near(color, base) || fadeOf(color, base) !== null)) return;

    // A fade seen before its base was taken for one; the base replaces it.
    bases = bases.filter((base) => fadeOf(base, color) === null);
    bases.push(color);
    if (reprocessQueued) return;
    reprocessQueued = true;
    queueMicrotask(() => {
      reprocessQueued = false;
      processTree(document.documentElement);
      observer.takeRecords();
    });
  }

  function learnBases(value) {
    for (const token of value.match(COLOR_RE) || []) {
      const color = parseColor(token);
      if (color && color.a >= 0.5) learnBase(color);
    }
  }

  // A calendar color picked from a theme (see picks in buildTheme), or a fade
  // of one or of a learned base, which is re-tinted against the themed
  // background instead of Google's paper. A heavily faded color has so little
  // hue left that several bases can account for it, so the closest one wins.
  function matchPick(color) {
    const exact = theme.picks.find(({ from }) => near(color, from));
    if (exact) return exact.to === exact.from ? color : exact.to;

    let best = null;
    const consider = (from, to) => {
      const match = fade(color, from);
      if (match && (!best || match.error < best.error)) best = { ...match, from, to };
    };
    for (const { from, to } of theme.picks) consider(from, to);
    for (const base of bases) consider(base, null);
    if (!best) return null;
    return mix(best.to ?? mapByValue(best.from, 'inline'), theme.bg, best.t);
  }

  // ctx is 'inline' (calendar and event colors) or 'sheet' (the interface).
  function mapColor(color, ctx) {
    if (ctx === 'inline') {
      const picked = matchPick(color);
      if (picked) return picked;
    }
    return mapByValue(color, ctx);
  }

  function mapByValue(color, ctx) {
    const { slot, l } = classify(color);
    if (slot === 'neutral') return mapNeutral(l);

    const base = ctx === 'sheet' && (slot === 'blue' || slot === 'cyan') ? theme.accent : theme.slots[slot];
    return variant(base, l, ctx === 'sheet' && googleDark);
  }

  function remapValue(value, ctx, prop) {
    if (!value || value.includes('url(')) return value;

    // GM3 also exposes channels as bare "r, g, b" custom properties.
    if (prop.startsWith('--') && prop.endsWith('-rgb')) {
      const m = value.match(RGB_TRIPLE_RE);
      if (!m) return value;
      const out = mapColor({ r: +m[1], g: +m[2], b: +m[3] }, ctx);
      return [out.r, out.g, out.b].map(Math.round).join(',');
    }

    return value.replace(COLOR_RE, (token) => {
      if (prop.startsWith('--') && /^[a-z]/i.test(token)) return token;
      const color = parseColor(token);
      return color ? format(mapColor(color, ctx), color.a) : token;
    });
  }

  function isColorProp(prop) {
    return (
      prop.endsWith('color') ||
      prop === 'background-image' ||
      prop === 'fill' ||
      prop === 'stroke' ||
      prop.startsWith('--')
    );
  }

  // ---------------------------------------------------------- inline styles

  // A saturated background, or one picked from the theme, marks an event chip
  // or calendar swatch; neutral inline backgrounds are interface surfaces.
  function isChip(color) {
    const { slot, l } = classify(color);
    if (l >= 0.85) return false;
    return slot !== 'neutral' || theme.own.some((own) => near(color, own));
  }

  function processElement(el) {
    const style = el.style;
    if (!style) return;
    let state = inlineState.get(el);
    if (!style.length && !state) return;

    let chipBackground = null;

    for (let i = 0; i < style.length; i++) {
      const prop = style[i];
      if (!isColorProp(prop)) continue;

      const current = style.getPropertyValue(prop);
      const record = state?.get(prop);
      const orig = record && current === record.out ? record.orig : current;
      learnBases(orig);
      const out = remapValue(orig, 'inline', prop);

      if (out === orig && !record) continue;
      if (!state) inlineState.set(el, (state = new Map()));

      if (current !== out) style.setProperty(prop, out, style.getPropertyPriority(prop));
      // Read back: the browser normalizes what we wrote (hex -> rgb()).
      state.set(prop, { orig, out: style.getPropertyValue(prop) });

      if (prop === 'background-color') {
        const before = parseColor(orig);
        const after = parseColor(out);
        if (before && after && after.a >= 0.5 && isChip(before)) {
          chipBackground = mix(theme.bg, after, after.a);
        }
      }
    }

    // Event chips: pick whichever theme color reads best on the new background.
    if (chipBackground) {
      const useBg = contrast(chipBackground, theme.bg) >= contrast(chipBackground, theme.fg);
      el.setAttribute(INK_ATTR, useBg ? 'bg' : 'fg');
    } else if (el.hasAttribute(INK_ATTR)) {
      el.removeAttribute(INK_ATTR);
    }
  }

  function processTree(root) {
    if (root.nodeType !== Node.ELEMENT_NODE) return;
    if (root.hasAttribute('style') || inlineState.has(root)) processElement(root);
    for (const el of root.querySelectorAll('[style]')) processElement(el);
  }

  // ------------------------------------------------------------ stylesheets

  function applyRule(entry) {
    const out = remapValue(entry.orig, 'sheet', entry.prop);
    if (entry.style.getPropertyValue(entry.prop) !== out) {
      entry.style.setProperty(entry.prop, out, entry.priority);
    }
  }

  function collectRules(rules) {
    for (const rule of rules) {
      if (rule instanceof CSSKeyframesRule) continue;
      if (rule.cssRules) collectRules(rule.cssRules);
      if (!(rule instanceof CSSStyleRule) || seenRules.has(rule)) continue;
      seenRules.add(rule);

      const style = rule.style;
      for (let i = 0; i < style.length; i++) {
        const prop = style[i];
        if (!isColorProp(prop)) continue;
        const orig = style.getPropertyValue(prop);
        COLOR_RE.lastIndex = 0;
        if (!orig || !(COLOR_RE.test(orig) || RGB_TRIPLE_RE.test(orig))) continue;
        const entry = { style, prop, orig, priority: style.getPropertyPriority(prop) };
        ruleEntries.push(entry);
        applyRule(entry);
      }
    }
  }

  // An unchanged length means no new rules, unless insertRule replaced one that
  // was deleted, which is why a sheet sheet-hook.js reports is always rescanned.
  function scanSheet(sheet, force) {
    if (sheet.ownerNode?.id === STYLE_ID) return;
    let rules;
    try {
      rules = sheet.cssRules;
    } catch {
      return; // Cross-origin sheet without CORS.
    }
    if (!force && sheetLengths.get(sheet) === rules.length) return;
    sheetLengths.set(sheet, rules.length);
    collectRules(rules);
  }

  function scanSheets() {
    for (const sheet of document.styleSheets) scanSheet(sheet, false);
  }

  // Google adds rules in bursts, so changed sheets are rescanned once each,
  // after the script adding them finishes.
  const changedSheets = new Set();

  function scanChangedSheets() {
    for (const sheet of changedSheets) scanSheet(sheet, true);
    changedSheets.clear();
    checkAppearance();
  }

  // New rules can repaint <body>, so the appearance is checked after each scan.
  function rescanSheets() {
    scanSheets();
    checkAppearance();
  }

  function applyAllRules() {
    for (let i = ruleEntries.length - 1; i >= 0; i--) {
      const entry = ruleEntries[i];
      const owner = entry.style.parentRule?.parentStyleSheet?.ownerNode;
      if (owner && !owner.isConnected) {
        ruleEntries.splice(i, 1);
      } else {
        applyRule(entry);
      }
    }
  }

  // ---------------------------------------------------------- our own CSS

  function renderOwnStyle() {
    let el = document.getElementById(STYLE_ID);
    if (!el) {
      el = document.createElement('style');
      el.id = STYLE_ID;
      (document.head || document.documentElement).append(el);
    }
    const bg = toHex(theme.bg);
    const fg = toHex(theme.fg);
    el.textContent = `
      :root { color-scheme: ${palette.mode === 'light' ? 'light' : 'dark'}; }
      html { background-color: ${bg}; color: ${fg}; }
      [${INK_ATTR}="bg"], [${INK_ATTR}="bg"] * { color: ${bg} !important; }
      [${INK_ATTR}="fg"], [${INK_ATTR}="fg"] * { color: ${fg} !important; }
    `;
  }

  // ----------------------------------------------------- Google's appearance

  // Calendar switches between its light and dark appearance live, with a
  // class on <body> whose name is obfuscated like the rest, so the appearance
  // is read back from the page instead: whatever Google paints <body> with is
  // its paper, which must come out as the theme background. When it comes out
  // nearer the foreground, Google is drawing the other appearance.
  function checkAppearance() {
    if (!theme || !document.body) return;
    const paper = parseColor(getComputedStyle(document.body).backgroundColor);
    if (!paper || paper.a < 0.5) return;

    if (project(paper, theme.fg, theme.bg) >= 0.5) return;

    googleDark = !googleDark;
    bases = []; // Fades point at the other paper now; relearn them.
    applyAllRules();
    processTree(document.documentElement);
    observer.takeRecords();
  }

  let watchedBody = null;

  function watchBody() {
    if (!document.body || document.body === watchedBody) return;
    watchedBody = document.body;
    new MutationObserver(checkAppearance).observe(watchedBody, { attributes: true, attributeFilter: ['class'] });
  }

  // ------------------------------------------------------------- lifecycle

  function applyAll() {
    if (!palette?.colors?.background || !palette.colors.foreground) return;
    theme = buildTheme();

    renderOwnStyle();
    scanSheets();
    applyAllRules();
    if (document.documentElement) processTree(document.documentElement);
    observer.takeRecords();
    watchBody();
    checkAppearance();
  }

  const observer = new MutationObserver((records) => {
    if (!theme) return;
    let sheetsChanged = false;

    for (const record of records) {
      if (record.type === 'attributes') {
        processElement(record.target);
        continue;
      }
      if (record.target.nodeName === 'STYLE') sheetsChanged = true;
      for (const node of record.addedNodes) {
        if (node.nodeName === 'STYLE') sheetsChanged = true;
        else if (node.nodeName === 'LINK') node.addEventListener('load', rescanSheets, { once: true });
        processTree(node);
      }
    }

    if (sheetsChanged) rescanSheets();
    // Drop the records our own writes just produced.
    observer.takeRecords();
  });

  observer.observe(document, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: ['style'],
  });

  document.addEventListener(
    SHEET_EVENT,
    (event) => {
      const sheet = event.target.sheet;
      if (!theme || !sheet) return;
      if (changedSheets.size === 0) queueMicrotask(scanChangedSheets);
      changedSheets.add(sheet);
    },
    true,
  );
  document.addEventListener('DOMContentLoaded', applyAll);
  // Calendar's "Device default" appearance follows the system's preference.
  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', checkAppearance);

  chrome.storage.local.get('palette').then((data) => {
    palette = data.palette || null;
    applyAll();
  });

  chrome.storage.onChanged.addListener((changes, area) => {
    if (area !== 'local' || !changes.palette) return;
    palette = changes.palette.newValue || null;
    applyAll();
  });

  // Keeps the native host connected, and theme changes flowing, while open.
  function connect() {
    if (!chrome.runtime?.id) return; // The extension reloaded; this script is orphaned.
    const port = chrome.runtime.connect({ name: 'calendar' });
    port.onDisconnect.addListener(() => setTimeout(connect, 1000));
  }
  connect();
})();
