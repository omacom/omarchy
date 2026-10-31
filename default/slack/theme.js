(colors => {
  const state = window.omarchySlackTheme ??= {};
  state.colors = colors;
  state.apply ??= () => {
    if (!state.runtime && window.rspackChunkGantryV2) {
      window.rspackChunkGantryV2.push([["omarchy-theme"], {}, runtime => { state.runtime = runtime; }]);
    }
    if (!state.runtime) return;
    const values = Object.values(state.runtime.c).flatMap(module => Object.values(module.exports || {}));
    const find = key => values.find(value => typeof value === "function" && (value.meta?.key === key || value.name === key));
    const stores = find("getStoreInstanceMap")?.();
    const client = find("tryGetClientStoreInstance")?.();
    const preference = find("createActionSetUserPref");
    const mode = find("createActionSetClientThemeInternal");
    if (!stores || !Object.keys(stores).length || !client || !preference || !mode) return;
    const { background, accent, green, red, mode: scheme } = state.colors;
    const color = hex => ({ palette: "gray", custom: hex });
    const theme = {
      primary: color(background), highlight1: color(accent),
      highlight2: color(green), important: color(red),
      brightness: scheme === "light" ? 1 : 6,
      sidebarInverted: false, useCustomHex: true
    };
    // These reducer actions stay local; the API setter would sync the account.
    for (const store of Object.values(stores)) {
      store.dispatch(preference({ pref: "ia_theme", value: theme }));
      store.dispatch(mode(scheme));
    }
    client.dispatch(mode(scheme));
    state.observer?.disconnect();
    return true;
  };
  if (!state.apply()) {
    state.observer ??= new MutationObserver(state.apply);
    state.observer.observe(document, { childList: true, subtree: true });
  }
})
