// Omarchy palette normalization and the color mapper that projects page colors onto it.
(function (root) {
  'use strict';
  const C = root.OmareaderColor;
  const { clamp } = C;

  const HUES = ['red', 'orange', 'yellow', 'green', 'cyan', 'blue', 'magenta'];
  const ANSI = { red: 1, green: 2, yellow: 3, blue: 4, magenta: 5, cyan: 6 };

  // Tokyo Night, used only when the native host supplied nothing.
  const FALLBACK = {
    background: '#1a1b26', foreground: '#c0caf5', accent: '#7aa2f7',
    red: '#f7768e', orange: '#ff9e64', yellow: '#e0af68', green: '#9ece6a',
    cyan: '#7dcfff', blue: '#7aa2f7', magenta: '#bb9af7', muted: '#565f89',
  };

  // "Dark" mode: a neutral dark scheme that keeps each page's own hues (the blue/magenta/
  // yellow slots only seed the link, visited and mark swatches).
  const DARK = {
    background: '#000000', foreground: '#e8e6e3', muted: '#9e9a93', lighter_background: '#080808',
    dark_background: '#000000', darker_background: '#000000', accent: '#5ea1ff', blue: '#5ea1ff',
    magenta: '#c792ea', yellow: '#e5c07b', selection_background: '#264f78', mode: 'dark', hues: 'source',
  };

  const hexOf = (v) => {
    const c = typeof v === 'string' ? C.parse(v) : null;
    return c ? C.format({ ...c, a: 1 }) : null;
  };

  // Accepts both colors.toml layouts: named keys (Omarchy 3.3+ "red", "muted", ...)
  // and terminal slots (color0..color15). Returns flat hex strings.
  function normalize(raw) {
    raw = raw && typeof raw === 'object' ? raw : FALLBACK;
    const get = (...keys) => {
      for (const k of keys) {
        const v = hexOf(raw[k]);
        if (v) return v;
      }
      return null;
    };
    const p = {};
    p.bg = get('background', 'color0') || FALLBACK.background;
    p.fg = get('foreground', 'color7', 'color15') || FALLBACK.foreground;
    for (const h of HUES) {
      p[h] = get(h, ANSI[h] !== undefined ? `color${ANSI[h]}` : '_');
      p[`bright_${h}`] = get(`bright_${h}`, ANSI[h] !== undefined ? `color${ANSI[h] + 8}` : '_');
    }
    p.accent = get('accent', 'active_border_color', 'blue', 'color4') || FALLBACK.accent;
    p.muted = get('muted');
    p.lighter_background = get('lighter_background');
    p.dark_background = get('dark_background');
    p.darker_background = get('darker_background');
    p.dark_foreground = get('dark_foreground');
    p.selection_background = get('selection_background', 'selection');
    p.selection_foreground = get('selection_foreground');
    const bgL = C.toOklab(C.parse(p.bg)).L, fgL = C.toOklab(C.parse(p.fg)).L;
    p.mode = raw.mode === 'light' || raw.mode === 'dark' ? raw.mode : bgL > fgL ? 'light' : 'dark';
    if (raw.hues === 'source') p.hues = 'source';
    for (const k of Object.keys(p)) if (p[k] === null) delete p[k];
    return p;
  }

  const smoothstep = (e0, e1, x) => {
    const t = clamp((x - e0) / (e1 - e0), 0, 1);
    return t * t * (3 - 2 * t);
  };

  // siteL: OKLab lightness of the page's own background (1 = white, the default guess).
  function createMapper(palette, { siteL = 1 } = {}) {
    const P = {};
    for (const [k, v] of Object.entries(palette)) if (typeof v === 'string' && v[0] === '#') P[k] = C.parse(v);
    const bg = C.toOklab(P.bg), fg = C.toOklab(P.fg);
    const span = Math.abs(fg.L - bg.L) < 0.02 ? (palette.mode === 'light' ? -0.6 : 0.6) : fg.L - bg.L;
    const tOf = (lab) => (lab.L - bg.L) / span;

    // The neutral ramp runs from the background (t=0) to the foreground (t=1) through the
    // theme's own surface colors, so greys come out tinted the way the theme tints them.
    const anchors = [{ t: 0, lab: bg }, { t: 1, lab: fg }];
    for (const k of ['lighter_background', 'muted', 'dark_foreground']) {
      if (!P[k]) continue;
      const lab = C.toOklab(P[k]);
      const t = tOf(lab);
      if (t > 0.03 && t < 0.95) anchors.push({ t, lab });
    }
    let low = P.darker_background || P.dark_background;
    let lowLab = low && C.toOklab(low);
    let lowT = lowLab ? tOf(lowLab) : 0;
    if (!lowLab || lowT > -0.02 || lowT < -0.4) {
      lowLab = { L: bg.L - Math.sign(span) * 0.035, a: bg.a, b: bg.b };
      lowT = tOf(lowLab);
    }
    anchors.push({ t: lowT, lab: lowLab });
    anchors.sort((x, y) => x.t - y.t);
    const ramp = [anchors[0]];
    for (const a of anchors.slice(1)) {
      const last = ramp[ramp.length - 1];
      if (a.t - last.t < 0.02) {
        if (a.t === 0 || a.t === 1) ramp[ramp.length - 1] = a;
      } else ramp.push(a);
    }
    const tMin = ramp[0].t;

    function rampLab(t) {
      t = clamp(t, tMin, 1);
      for (let i = 0; i < ramp.length - 1; i++) {
        const x = ramp[i], y = ramp[i + 1];
        if (t <= y.t) return C.mixLab(x.lab, y.lab, (t - x.t) / (y.t - x.t));
      }
      return ramp[ramp.length - 1].lab;
    }

    const bgRgb = P.bg;
    const accents = [];
    const chromaOf = (rgb) => {
      const l = C.toOklab(rgb);
      return Math.hypot(l.a, l.b);
    };
    for (const h of HUES) {
      const bright = P[`bright_${h}`];
      // A grey base slot with a colored bright slot (solitude's red) uses the bright one.
      const base = P[h] && chromaOf(P[h]) >= 0.02 ? P[h] : bright && chromaOf(bright) >= 0.02 ? bright : P[h];
      if (!base) continue;
      const lab = C.toOklab(base);
      const chroma = Math.hypot(lab.a, lab.b);
      let text = base;
      if (bright && C.contrast(text, bgRgb) < 3.5 && C.contrast(bright, bgRgb) > C.contrast(text, bgRgb)) text = bright;
      accents.push({ name: h, lab, textLab: C.toOklab(text), chroma, hue: Math.atan2(lab.b, lab.a) });
    }
    const sourceHues = palette.hues === 'source';
    const usable = sourceHues ? [] : accents.filter((a) => a.chroma >= 0.02);

    // Palettes without a color near the source hue (monochrome themes, or ones missing a
    // slot) get one synthesized at the palette's typical accent lightness and chroma, so
    // errors, links and success colors stay distinguishable.
    const chromatic = usable;
    const mean = (xs, f, dflt) => (xs.length ? xs.reduce((s, x) => s + f(x), 0) / xs.length : dflt);
    // Monochrome themes have no colored slot to copy a lightness from; pick one that can
    // still carry color (pure white/black cannot).
    const synthL = mean(chromatic, (a) => a.lab.L, (bg.L + fg.L) / 2);
    const synthTextL = mean(chromatic, (a) => a.textLab.L, fg.L >= bg.L ? 0.8 : 0.48);
    const synthC = Math.max(0.06, mean(chromatic, (a) => a.chroma, 0.09));
    const synthCache = new Map();

    // In source-hue mode (Dark) every color keeps its own hue and, within limits, chroma.
    function nearest(h, srcChroma) {
      let best = null, bestD = Infinity;
      for (const a of usable) {
        let d = Math.abs(a.hue - h);
        if (d > Math.PI) d = 2 * Math.PI - d;
        if (d < bestD) { bestD = d; best = a; }
      }
      if (best && bestD <= 0.87) return best;
      const chroma = sourceHues ? clamp(srcChroma * 0.9, 0.04, 0.15) : synthC;
      const key = `${Math.round(h * 20)}|${Math.round(chroma * 100)}`;
      let syn = synthCache.get(key);
      if (!syn) {
        const a = Math.cos(h) * chroma, b = Math.sin(h) * chroma;
        syn = { name: 'synth', lab: { L: synthL, a, b }, textLab: { L: synthTextL, a, b }, chroma, hue: h };
        synthCache.set(key, syn);
      }
      return syn;
    }

    // Keeps a color's contrast class: text or borders that stood out on the original page
    // stand out on the palette background too, never beyond what the theme's own
    // foreground manages (and never below 3:1).
    const fgContrast = C.contrast(P.fg, bgRgb);
    const siteRgb = C.fromOklab({ L: siteL, a: 0, b: 0 });
    const towardFg = fg.L >= bg.L ? 1 : 0;
    function floorContrast(lab, target) {
      target = Math.min(target, Math.max(fgContrast, 3));
      if (C.contrast(C.fromOklab(lab), bgRgb) >= target) return lab;
      let lo = 0, hi = 1, best = null;
      for (let i = 0; i < 14; i++) {
        const k = (lo + hi) / 2;
        const cand = { L: lab.L + (towardFg - lab.L) * k, a: lab.a * (1 - k / 2), b: lab.b * (1 - k / 2) };
        if (C.contrast(C.fromOklab(cand), bgRgb) >= target) {
          hi = k;
          best = cand;
        } else lo = k;
      }
      return best || { L: towardFg, a: 0, b: 0 };
    }

    const shadowLab = palette.mode === 'light'
      ? { L: 0, a: 0, b: 0 }
      : { L: Math.max(0, Math.min(bg.L, lowLab.L) - 0.06), a: bg.a * 0.5, b: bg.b * 0.5 };

    const siteDark = siteL < 0.5;
    const cache = new Map();

    // How strongly a surface color reads as "colored": needs real saturation (so tinted
    // greys like #0d1117 or slate stay neutral) and grows with chroma (so pastels stay subtle).
    function tint(c, chroma) {
      const sat = C.rgbToHsl(c).s;
      return smoothstep(0.35, 0.7, sat) * smoothstep(0.005, 0.025, chroma) * Math.min(1, chroma / 0.1);
    }

    // Keeps the ramp's lightness, takes the palette color's hue and chroma.
    function withHue(base, acc, w) {
      return { L: base.L, a: base.a + (acc.a - base.a) * w, b: base.b + (acc.b - base.b) * w };
    }

    function map(c, role) {
      const key = `${role}${c.r | 0},${c.g | 0},${c.b | 0},${c.a}`;
      const hit = cache.get(key);
      if (hit) return hit;
      const lab = C.toOklab(c);
      const L = lab.L;
      const chroma = Math.hypot(lab.a, lab.b);
      const h = Math.atan2(lab.b, lab.a);
      // How far the color sits from the page background, toward the page's text.
      const d = siteDark ? L - siteL : siteL - L;
      let out;
      if (role === 'bg') {
        let t;
        if (c.a < 0.25 && chroma < 0.04) t = clamp(d, tMin, 1); // hover/overlay tints keep their direction
        // Small steps away from the page background are lifted so layered surfaces stay apart.
        else if (d <= 0) t = -0.1 * Math.pow(Math.min(1, -d / 0.1), 0.6);
        else if (d <= 0.5) t = 0.25 * Math.pow(d / 0.5, 0.6);
        else t = 0.25 - (d - 0.5) * 0.6; // dark bars on light pages stay dark
        out = rampLab(t);
        const w = tint(c, chroma);
        if (w) out = withHue(out, nearest(h, chroma).lab, w);
      } else if (role === 'text') {
        const pivot = siteDark ? 0.3 : 0.75;
        const x = L <= pivot
          ? (pivot - L) / (pivot - (siteDark ? 0.05 : 0.32))
          : (L - pivot) / ((siteDark ? 0.92 : 0.97) - pivot);
        out = rampLab(0.5 + 0.5 * clamp(x, 0, 1));
        if (chroma > 0.03) out = C.mixLab(out, nearest(h, chroma).textLab, smoothstep(0.03, 0.1, chroma));
        if (c.a >= 0.5) out = floorContrast(out, Math.min(4.5, C.contrast({ ...c, a: 1 }, siteRgb)));
      } else if (role === 'border') {
        out = rampLab(d <= 0 ? 0.06 : Math.min(0.7, 0.08 + 0.55 * Math.pow(d, 0.8)));
        const w = tint(c, chroma);
        if (w) out = withHue(C.mixLab(out, nearest(h, chroma).lab, 0.25 * w), nearest(h, chroma).lab, w);
        if (c.a >= 0.5 && C.contrast({ ...c, a: 1 }, siteRgb) >= 3) out = floorContrast(out, 3);
      } else {
        const w = tint(c, chroma);
        out = w ? C.mixLab(shadowLab, nearest(h, chroma).lab, 0.6 * w) : shadowLab;
      }
      const res = C.fromOklab(out, c.a);
      if (cache.size > 20000) cache.clear();
      cache.set(key, res);
      return res;
    }

    const at = (t) => C.format(C.fromOklab(rampLab(t)));
    const accentText = (name) => {
      const a = accents.find((x) => x.name === name);
      return C.format(C.fromOklab(a ? a.textLab : C.toOklab(P.accent)));
    };

    const swatch = {
      bg: palette.bg,
      fg: palette.fg,
      field: at(0.06),
      button: at(0.12),
      // A scrollbar thumb is a control, not a background surface. Dark palette
      // surface shades disappear against the track (especially Tokyo Night).
      thumb: C.format(C.fromOklab(floorContrast(rampLab(0.55), 3))),
      border: at(0.25),
      muted: at(0.55),
      link: accentText('blue'),
      visited: accentText('magenta'),
      accent: palette.accent,
      mark: C.format(C.fromOklab(C.mixLab(bg, C.toOklab(P.yellow || P.accent), 0.4))),
      selection: palette.selection_background || C.format(C.fromOklab(C.mixLab(bg, C.toOklab(P.accent), 0.35))),
      selectionText: palette.selection_foreground || palette.fg,
    };

    return { map, ramp: at, swatch, mode: palette.mode, siteL, siteDark };
  }

  // Settings carry mode: 'normal' (pages untouched) | 'dark' | 'omarchy', the default for
  // every site, and sites: {host: mode} overrides. Older settings had enabled: true/false
  // and a disabledSites list.
  const MODES = ['normal', 'dark', 'omarchy'];
  function modeOf(settings) {
    const s = settings || {};
    if (MODES.includes(s.mode)) return s.mode;
    return s.enabled === true ? 'omarchy' : 'normal';
  }

  // www.example.com and example.com share one override; other subdomains have their own.
  const siteKey = (hostname) => String(hostname || '').toLowerCase().replace(/^www\./, '');

  function siteModeOf(settings, hostname) {
    const s = settings || {};
    const own = s.sites && s.sites[siteKey(hostname)];
    if (MODES.includes(own)) return own;
    if (Array.isArray(s.disabledSites) && s.disabledSites.includes(hostname)) return 'normal';
    return modeOf(s);
  }

  function normalizeSettings(stored) {
    const s = stored || {};
    const sites = {};
    for (const h of Array.isArray(s.disabledSites) ? s.disabledSites : []) if (siteKey(h)) sites[siteKey(h)] = 'normal';
    for (const [h, m] of Object.entries(s.sites || {})) if (siteKey(h) && MODES.includes(m)) sites[siteKey(h)] = m;
    return { mode: modeOf(s), sites: Object.fromEntries(Object.entries(sites).sort(([a], [b]) => (a < b ? -1 : 1))) };
  }

  // Sets (or with 'default', clears) a site's override.
  function withSiteMode(settings, hostname, mode) {
    const s = normalizeSettings(settings);
    const key = siteKey(hostname);
    if (!key) return s;
    if (MODES.includes(mode)) s.sites[key] = mode;
    else delete s.sites[key];
    return normalizeSettings(s);
  }

  // The keyboard shortcut: a themed site goes to Normal, a Normal one back to its default
  // (or to Follow Omarchy when the default is Normal).
  function toggleSite(settings, hostname) {
    const s = normalizeSettings(settings);
    if (siteModeOf(s, hostname) !== 'normal') return withSiteMode(s, hostname, s.mode === 'normal' ? 'default' : 'normal');
    return withSiteMode(s, hostname, s.mode === 'normal' ? 'omarchy' : 'default');
  }

  root.OmareaderTheme = {
    normalize, createMapper, modeOf, siteKey, siteModeOf, normalizeSettings, withSiteMode, toggleSite,
    MODES, FALLBACK, DARK, HUES,
  };
})(globalThis);
