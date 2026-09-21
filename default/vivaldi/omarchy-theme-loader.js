(() => {
  const OMARCHY_THEME = 'Omarchy';
  let cssSynced = '';
  let prefsSynced = '';
  let loggedError = false;

  const isOmarchyTheme = (theme) =>
    !!theme && String(theme.name || '').indexOf(OMARCHY_THEME) === 0;

  const newThemeId = () => {
    if (window.crypto && typeof window.crypto.randomUUID === 'function') {
      return window.crypto.randomUUID();
    }
    return 'omarchy-' + Date.now().toString(16);
  };

  const syncNativeTheme = async (
    bg, fg, accent, lighterBg, radius, dimBlurred, blur, contrast, alpha
  ) => {
    const prefs = window.vivaldi && window.vivaldi.prefs;
    if (!prefs || typeof prefs.get !== 'function' || typeof prefs.set !== 'function') {
      // The CSS already applied the colors live. Leave the prefs marker unset
      // so a later poll retries once the UI exposes prefs during startup.
      return false;
    }

    // Apply the fields Omarchy owns from the channel so updates land in the
    // running browser. Everything else the user set in Vivaldi's theme editor
    // is left alone.
    const appearance = {
      accentFromPage: false,
      colorBg: bg,
      colorFg: fg,
      colorAccentBg: lighterBg,
      colorHighlightBg: accent,
      colorWindowBg: bg,
      name: OMARCHY_THEME,
      preferSystemAccent: false,
      radius: radius,
      dimBlurred: dimBlurred,
      blur: blur,
      contrast: contrast
    };
    if (alpha !== null) appearance.alpha = alpha;
    const baseTheme = {
      engineVersion: 1,
      version: 1,
      url: '',
      accentOnWindow: true,
      accentSaturationLimit: 1,
      alpha: 0.92,
      backgroundImage: '',
      backgroundPosition: 'stretch',
      backgroundSource: '',
      colorPosition: 'tabbar',
      simpleScrollbar: true,
      transparencyTabBar: true,
      transparencyTabs: true
    };

    const stored = await prefs.get('vivaldi.themes.user');
    const list = (stored && stored.value) || [];
    let active = null;
    const themes = list.map(function (theme) {
      if (!active && isOmarchyTheme(theme)) {
        active = Object.assign({}, theme, appearance);
        return active;
      }
      return theme;
    });
    if (!active) {
      active = Object.assign({}, baseTheme, appearance, {
        id: newThemeId(),
        name: OMARCHY_THEME
      });
      themes.push(active);
    }
    // Point the schedule at the theme only after the theme write lands, or the
    // handler would re-derive from stale (or missing) Omarchy colors.
    await prefs.set({ path: 'vivaldi.themes.user', value: themes });
    await prefs.set({
      path: 'vivaldi.theme.schedule.o_s',
      value: { light: active.id, dark: active.id }
    });
    return true;
  };

  const applyThemeCss = (bg, fg, accent, lighterBg, radius) => {
    const style = document.getElementById('omarchy-theme');
    if (!style) return;
    const mix = (a, b, p) => `color-mix(in srgb, ${a}, ${b} ${p})`;
    // Corner rounding is rendered from CSS custom properties, so inject them
    // alongside the colors to update corners live. Mirrors Vivaldi's own
    // derivation from the theme radius; -1 is "Disabled" (no rounding), and
    // the derived lengths must never go negative or CSS drops them.
    const radiusPx = radius > -1 ? radius + 'px' : 0;
    const safeRadius = Math.max(0, radius);
    style.textContent = `
      #browser {
        --colorBg: ${bg} !important;
        --colorBgLight: ${bg} !important;
        --colorBgIntense: ${mix(bg, 'white', '7%')} !important;
        --colorFg: ${fg} !important;
        --colorAccentBg: ${lighterBg} !important;
        --colorAccentFg: ${fg} !important;
        --colorHighlightBg: ${accent} !important;
        --colorHighlightFg: ${fg} !important;
        --colorWindowBg: ${bg} !important;
        --colorTabBar: ${lighterBg} !important;
        --radius: ${radiusPx} !important;
        --radiusRounded: ${radius > -1 ? '2px' : 0} !important;
        --radiusRoundedLess: ${radius > 0 ? (radius - 1) + 'px' : 0} !important;
        --radiusHalf: ${Math.round(safeRadius / 2)}px !important;
        --radiusCap: ${Math.min(safeRadius, 8)}px !important;
        --radiusRound: ${radius > -1 ? '100px' : 0} !important;
        --radiusWindow: 6px !important;
      }`;
  };

  const refresh = async () => {
    try {
      const text = await (await fetch('style/omarchy.json', { cache: 'no-store' })).text();
      const data = JSON.parse(text);
      const colors = data && data.colors || {};
      const bg = colors.bg;
      const fg = colors.fg;
      const accent = colors.accent;
      const lighterBg = colors.lighterBg;
      if (!/^#[a-f\d]{6}$/i.test(bg || '') || !/^#[a-f\d]{6}$/i.test(fg || '') ||
          !/^#[a-f\d]{6}$/i.test(accent || '') || !/^#[a-f\d]{6}$/i.test(lighterBg || '')) return;
      loggedError = false;
      // -1 is Vivaldi's "Disabled" corner rounding (Hyprland rounding 0); a
      // radius of 0 would still round controls, so it must not be clamped away.
      const rawRadius = Number(data.radius);
      const radius = Math.max(-1, Math.min(14, Math.round(isFinite(rawRadius) ? rawRadius : -1)));
      const dimBlurred = data.dimBlurred === true;
      const blur = Math.max(0, Math.min(10, Math.round(Number(data.blur) || 0)));
      const contrast = Math.max(-10, Math.min(20, Math.round(Number(data.contrast) || 0)));
      // Vivaldi's theme alpha is its transparency setting. It comes from
      // Hyprland's window opacity; with none configured, leave it untouched so
      // the theme keeps the transparency chosen in Vivaldi.
      const hasAlpha = data.alpha !== null && data.alpha !== undefined && data.alpha !== '';
      const rawAlpha = hasAlpha ? Number(data.alpha) : NaN;
      const alpha = isFinite(rawAlpha) ? Math.max(0, Math.min(1, rawAlpha)) : null;
      if (text !== cssSynced) {
        applyThemeCss(bg, fg, accent, lighterBg, radius);
        cssSynced = text;
      }
      if (text !== prefsSynced) {
        syncNativeTheme(bg, fg, accent, lighterBg, radius, dimBlurred, blur, contrast, alpha)
          .then(function (ok) { if (ok) prefsSynced = text; })
          .catch(function () {});
      }
    } catch (e) {
      if (!loggedError) {
        loggedError = true;
        console.error(e);
      }
    }
  };

  refresh();
  setInterval(refresh, 2000);
})();
