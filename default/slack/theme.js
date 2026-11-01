(colors => {
  const state = window.omarchySlackTheme ??= {};
  state.colors = colors;
  state.apply ??= () => {
    if (!state.runtime && window.rspackChunkGantryV2) {
      window.rspackChunkGantryV2.push([["omarchy-theme"], {}, runtime => { state.runtime = runtime; }]);
    }
    if (!state.runtime) return;
    if (!state.actions) {
      // A look walks every export of Slack's ~13,000 modules, about 20 ms, and
      // the observer calls this on each DOM change. Look at most once a second,
      // and give up after a minute on a Slack build whose actions have moved.
      const now = Date.now();
      if (state.lookedAt !== undefined && now - state.lookedAt < 1000) return;
      state.lookedAt = now;
      state.firstLook ??= now;
      const values = Object.values(state.runtime.c).flatMap(module => Object.values(module.exports || {}));
      const find = key => values.find(value => typeof value === "function" && (value.meta?.key === key || value.name === key));
      const actions = ["getStoreInstanceMap", "tryGetClientStoreInstance", "createActionSetUserPref", "createActionSetClientThemeInternal"].map(find);
      if (actions.includes(undefined)) {
        if (now - state.firstLook > 60000) state.observer?.disconnect();
        return;
      }
      state.actions = actions;
    }
    const [storeMap, clientStore, preference, mode] = state.actions;
    const stores = storeMap();
    const client = clientStore();
    if (!stores || !Object.keys(stores).length || !client) return;
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
