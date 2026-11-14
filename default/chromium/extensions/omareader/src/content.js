// Isolated-world orchestrator. Every page stylesheet gets an index-aligned override sheet
// (same selectors, palette-mapped colors) adopted after the sources; inline colors and
// anonymous @layer blocks are rewritten in place, presentational attributes get
// value-matched rules in the lowest layer. Everything follows palette and setting changes
// live and is screen-only.
(() => {
  'use strict';
  const C = globalThis.OmareaderColor;
  const T = globalThis.OmareaderTheme;
  const X = globalThis.OmareaderTransform;
  const doc = document;
  if (!(doc instanceof HTMLDocument)) return;

  const extAlive = () => {
    try {
      return !!(chrome.runtime && chrome.runtime.id);
    } catch {
      return false;
    }
  };
  // After an extension reload/update the previous instance may still sit in this world;
  // a live one wins, a dead one is retired so it cannot keep painting a stale palette.
  const prior = globalThis.__omareader;
  if (prior && prior.alive()) return;
  if (prior) {
    try {
      prior.stop();
    } catch {}
  }
  globalThis.__omareader = { alive: extAlive, stop: () => stop() };

  // The per-site switch follows the top-level site, so embedded frames go with their page.
  const site = (() => {
    try {
      const origins = location.ancestorOrigins;
      if (origins && origins.length) return new URL(origins[origins.length - 1]).hostname;
      return location.hostname;
    } catch {
      return '';
    }
  })();

  const youtube = ['youtube.com', 'www.youtube.com', 'm.youtube.com'].includes(location.hostname);
  const gmail = location.hostname === 'mail.google.com';
  // Excel for the web draws the grid (cells, fills, gridlines, text) on canvases inside
  // its *-excel.officeapps.live.com frame; excel.cloud.microsoft is the standalone app.
  const excel = location.hostname === 'excel.cloud.microsoft' ||
    (location.hostname.endsWith('.officeapps.live.com') && location.hostname.includes('excel'));
  const RAMP_ID = 'omareader-ramp';
  const YOUTUBE_CANVAS = 'html,body,ytd-app,#page-manager,ytd-watch-flexy,ytd-watch-grid,#full-bleed-container';

  const SVG_NS = 'http://www.w3.org/2000/svg';
  // A prefixed namespace is inert unless a selector uses it, and can precede the page's
  // own @namespace declarations. A @property marker would make those declarations invalid.
  const MARK = '@namespace omareader-sheet "urn:omareader:sheet";';
  const PLACEHOLDER = '@media not all{}';
  const PRES_SELECTOR =
    '[bgcolor],font[color],body[text],body[link],body[vlink],body[alink],[fill],[stroke],[stop-color],[flood-color]';
  const OBSERVED_ATTRS = ['style', 'bgcolor', 'color', 'text', 'link', 'vlink', 'alink', 'fill', 'stroke', 'stop-color',
    'flood-color', 'contenteditable', 'rel', 'href', 'media', 'disabled', 'class'];
  // These affect which background is visible even without a color declaration.
  const BACKGROUND_STATE = new Set(['all', 'color-scheme', 'display', 'visibility', 'content-visibility', 'opacity', 'position', 'z-index']);
  // Built-in elements that can host a shadow root (custom elements can too).
  const HOST_TAGS = 'article,aside,blockquote,body,div,footer,h1,h2,h3,h4,h5,h6,header,main,nav,p,section,span';
  const HOSTS = new Set(HOST_TAGS.split(','));
  // Typed copies of an element's inline custom properties live in a varsSheet rule matched
  // by this attribute (see placeVars). Inline declarations beat every normal author rule;
  // the rule gets an id-heavy specificity instead (an id no page uses), so it still beats
  // the mirrored page rules on the same element.
  const VARS_ATTR = 'data-omareader-vars';
  const VARS_SPEC = ':not(#--omareader)'.repeat(8);
  const dom = (() => {
    try {
      return chrome.dom;
    } catch {
      return undefined;
    }
  })();

  let settings = null;
  let active = null;
  let palette = null;
  let activeKey = '';
  let running = false;
  let printing = false;
  let mapper = null;
  let siteL = 1;
  let version = 0;
  let ctx = null;
  let baseEl = null;
  let rampEl = null;
  let presSheet = null;
  let propSheet = null;
  let varsSheet = null;
  let varsSeq = 0;
  let timer = 0;
  let remoteVersion = 0;
  let renderHadPending = false;
  let copying = null;

  const ours = new WeakSet();
  const scopes = new Map();
  const entries = new WeakMap();
  const remote = new Map();
  const remoteText = new WeakMap();
  const rawIndex = new WeakMap();
  const ordinals = new WeakMap();
  const inline = new WeakMap();
  const inlineSource = new WeakMap();
  const touched = new Set();
  const anonSlots = new WeakMap();
  const anonTouched = new Set();
  const presRules = new Map();
  const presSeen = new Set();
  const propRules = new Map();
  const varRules = new Map();

  const isMarked = (s) => {
    try {
      const r = s.cssRules[0];
      return (r instanceof CSSNamespaceRule && r.prefix === 'omareader-sheet' && r.namespaceURI === 'urn:omareader:sheet') ||
        (r instanceof CSSPropertyRule && r.name === '--omareader-sheet'); // Older extension instances.
    } catch {
      return false;
    }
  };
  const isOurs = (s) => ours.has(s) || isMarked(s);

  function newSheet(media = 'all') {
    const s = new CSSStyleSheet({ media });
    ours.add(s);
    return s;
  }

  // ---- rendering --------------------------------------------------------

  const canonSheet = new CSSStyleSheet();
  function canonSelector(sel) {
    try {
      canonSheet.replaceSync(`${sel}{}`);
      return canonSheet.cssRules[0] ? canonSheet.cssRules[0].selectorText : sel;
    } catch {
      return sel;
    }
  }

  // Source text lookup for the rare var() shorthands the CSSOM drops entirely.
  function rawDecls(rule) {
    const sheet = rule.parentStyleSheet;
    if (!sheet) return [];
    let index = rawIndex.get(sheet);
    if (index === undefined) {
      const owner = sheet.ownerNode;
      let text = remoteText.get(sheet);
      if (text === undefined && owner && owner.localName === 'style') text = owner.textContent;
      if (text === undefined && sheet.href && owner && owner.localName === 'link') {
        rawIndex.set(sheet, null);
        fetch(sheet.href, { credentials: 'same-origin', cache: 'force-cache' })
          .then((r) => (r.ok ? r.text() : ''))
          .then((t) => {
            rawIndex.set(sheet, buildRawIndex(t));
            entries.delete(sheet);
            // The first render may have cached a rule before its dropped var() shorthand
            // could be recovered. Invalidate those rule results when the source arrives.
            if (ctx) for (const rule of readRules(sheet) || []) forgetRule(rule);
            scheduleScan();
          })
          .catch(() => {});
        return [];
      }
      index = text === undefined ? null : buildRawIndex(text);
      rawIndex.set(sheet, index);
    }
    if (!index) return [];
    const hits = index.get(rule.selectorText);
    return (hits && hits[ordinalOf(rule, sheet)]) || [];
  }

  // Source rules per canonical selector, by occurrence (only those with a var() are kept).
  function buildRawIndex(text) {
    const index = new Map();
    const count = new Map();
    for (const { selector, decls } of X.scanRawDecls(text)) {
      const key = canonSelector(selector);
      const n = count.get(key) || 0;
      count.set(key, n + 1);
      if (!decls.some((d) => d.value.includes('var('))) continue;
      if (!index.has(key)) index.set(key, []);
      index.get(key)[n] = decls;
    }
    return index;
  }

  // Occurrence of a style rule among same-selector rules of its sheet, counted the way
  // scanRawDecls walks the source (into conditional/layer blocks, not into nested rules).
  const GROUPS = ['CSSMediaRule', 'CSSSupportsRule', 'CSSLayerBlockRule', 'CSSContainerRule', 'CSSScopeRule',
    'CSSStartingStyleRule'].map((n) => globalThis[n]).filter(Boolean);
  function ordinalOf(rule, sheet) {
    if (rule.parentRule instanceof CSSStyleRule) return -1;
    const rules = readRules(sheet);
    if (!rules) return -1;
    let o = ordinals.get(sheet);
    if (!o || o.length !== rules.length) {
      o = { length: rules.length, map: new WeakMap() };
      const count = new Map();
      const walk = (list) => {
        for (const r of list) {
          if (r instanceof CSSStyleRule) {
            const n = count.get(r.selectorText) || 0;
            count.set(r.selectorText, n + 1);
            o.map.set(r, n);
          } else if (GROUPS.some((G) => r instanceof G)) walk(r.cssRules);
        }
      };
      walk(rules);
      ordinals.set(sheet, o);
    }
    const n = o.map.get(rule);
    return n === undefined ? -1 : n;
  }

  function onProperty(rule) {
    const text = X.propertyRules(rule, ctx);
    if (text && propRules.get(rule.name) !== text) {
      propRules.set(rule.name, text);
      queueSheetWrite();
    }
  }

  function newCtx() {
    return {
      mapper,
      values: new Map(),
      rules: new WeakMap(),
      base: doc.baseURI,
      renderImport: renderImportText,
      rawDecls,
      onProperty,
      onAnonLayer,
    };
  }

  function readRules(sheet) {
    try {
      return sheet.cssRules;
    } catch {
      return null;
    }
  }

  function withBase(base, fn) {
    const prev = ctx.base;
    ctx.base = base;
    try {
      return fn();
    } finally {
      ctx.base = prev;
    }
  }

  function renderImportText(sheet, href) {
    const rules = readRules(sheet);
    if (rules === null) return renderRemote(sheet.href || href, new Set());
    if (!rules.length) renderHadPending = true;
    return withBase(sheet.href || doc.baseURI, () => X.renderRules(rules, ctx));
  }

  const renderTop = (rule) => X.renderRule(rule, ctx) || PLACEHOLDER;

  function forgetRule(rule) {
    ctx.rules.delete(rule);
    if (rule.cssRules) for (const r of rule.cssRules) forgetRule(r);
  }

  // Cross-origin sheets are unreadable through the CSSOM. The service worker fetches them
  // without credentials; they are parsed into a private sheet here.
  function renderRemote(href, seen) {
    if (!href || seen.has(href)) return '';
    seen.add(href);
    const entry = remote.get(href);
    if (!entry) {
      remote.set(href, { state: 'pending' });
      fetchRemote(href);
      renderHadPending = true;
      return '';
    }
    if (entry.state === 'pending') {
      renderHadPending = true;
      return '';
    }
    if (entry.state !== 'done') return '';
    let out = '';
    for (const imp of entry.imports) {
      let inner = renderRemote(imp.url, seen);
      if (!inner) continue;
      if (imp.layer !== null) {
        if (!imp.layer) continue;
        inner = `@layer ${imp.layer}{${inner}}`;
      }
      if (imp.supports) inner = `@supports (${imp.supports}){${inner}}`;
      out += `@media ${imp.media}{${inner}}`;
    }
    return out + withBase(entry.base, () => X.renderRules(entry.sheet.cssRules, ctx));
  }

  // Leading @import rules of a fetched sheet with their layer/supports/media conditions.
  function splitImports(text, base) {
    const src = text.replace(/\/\*[\s\S]*?\*\//g, '');
    const imports = [];
    const re = /\s*(?:@charset\s+"[^"]*"\s*;|@layer\s+[^{;]+;|@import\s+([^;]+);)/y;
    let i = 0;
    for (;;) {
      re.lastIndex = i;
      const m = re.exec(src);
      if (!m) break;
      i = re.lastIndex;
      if (!m[1]) continue;
      const u = /^(?:url\(\s*(['"]?)(.*?)\1\s*\)|(['"])(.*?)\3)\s*([\s\S]*)$/.exec(m[1].trim());
      if (!u) continue;
      let rest = u[5];
      let layer = null;
      let supports = '';
      const lm = /^layer(?:\(\s*([^)]*?)\s*\))?(?=\s|$)\s*/i.exec(rest);
      if (lm) {
        layer = lm[1] || '';
        rest = rest.slice(lm[0].length);
      }
      const sm = /^supports\(/i.exec(rest);
      if (sm) {
        let depth = 0;
        let j = 0;
        for (; j < rest.length; j++) {
          if (rest[j] === '(') depth++;
          else if (rest[j] === ')' && --depth === 0) break;
        }
        supports = rest.slice(sm[0].length, j).trim();
        rest = rest.slice(j + 1);
      }
      try {
        imports.push({ url: new URL(u[2] ?? u[4], base).href, layer, supports, media: rest.trim() || 'all' });
      } catch {}
    }
    return { imports, body: src.slice(i) };
  }

  async function fetchRemote(href) {
    try {
      const res = await chrome.runtime.sendMessage({ type: 'fetch-css', url: href });
      if (!res || !res.ok) throw new Error(res ? res.error : 'no response');
      const { imports, body } = splitImports(res.text, res.url || href);
      const sheet = new CSSStyleSheet();
      sheet.replaceSync(body);
      remoteText.set(sheet, body);
      remote.set(href, { state: 'done', sheet, imports, base: res.url || href });
    } catch {
      remote.set(href, { state: 'failed' });
    }
    remoteVersion++;
    scheduleScan();
  }

  // Override sheets apply on screen only: printing keeps the page's own colors.
  function screenMedia(list) {
    const items = list ? Array.from(list) : [];
    if (!items.length) return 'screen';
    const out = [];
    for (const raw of items) {
      const m = raw.trim();
      const lm = m.toLowerCase();
      if (/^(only\s+)?print\b/.test(lm) || lm === 'not all') continue;
      if (/^not\s+print\b/.test(lm)) out.push('screen');
      else if (/^(only\s+)?screen\b/.test(lm)) out.push(m);
      else if (/^(only\s+)?all\b/.test(lm)) out.push(m.replace(/^(only\s+)?all/i, 'screen'));
      else if (lm.startsWith('(')) out.push(`screen and ${m}`);
      else out.push(m);
    }
    return out.length ? out.join(', ') : 'not all';
  }

  function fullRender(src, entry) {
    const rules = readRules(src);
    renderHadPending = false;
    if (rules === null) {
      entry.sheet.replaceSync(MARK + renderRemote(src.href, new Set()));
      entry.rules = null;
      entry.aligned = false;
    } else {
      const list = Array.from(rules);
      const text = withBase(src.href || doc.baseURI, () => list.map(renderTop).join(''));
      entry.sheet.replaceSync(MARK + text);
      entry.rules = list;
      entry.aligned = entry.sheet.cssRules.length === list.length + 1;
    }
    entry.version = version;
    entry.pending = renderHadPending;
    entry.remoteVersion = remoteVersion;
  }

  // Patches the override by identity diff against the last mirrored rule list: CSS-in-JS
  // appends turn into single insertRule calls instead of a full re-render.
  function patch(src, entry, rules) {
    const list = Array.from(rules);
    const old = entry.rules;
    let pre = 0;
    while (pre < old.length && pre < list.length && old[pre] === list[pre]) pre++;
    let suf = 0;
    while (suf < old.length - pre && suf < list.length - pre && old[old.length - 1 - suf] === list[list.length - 1 - suf]) suf++;
    const del = old.length - pre - suf;
    const ins = list.length - pre - suf;
    if (!del && !ins) return;
    if (del + ins > Math.max(64, list.length / 2)) {
      fullRender(src, entry);
      return;
    }
    const sheet = entry.sheet;
    withBase(src.href || doc.baseURI, () => {
      for (let k = 0; k < del; k++) sheet.deleteRule(1 + pre);
      for (let k = 0; k < ins; k++) {
        try {
          sheet.insertRule(renderTop(list[pre + k]), 1 + pre + k);
        } catch {
          sheet.insertRule(PLACEHOLDER, 1 + pre + k);
        }
      }
    });
    entry.rules = list;
    if (sheet.cssRules.length !== list.length + 1) fullRender(src, entry);
  }

  function overrideFor(src, deep) {
    if (src.disabled) return null;
    let entry = entries.get(src);
    if (!entry) {
      entry = { sheet: newSheet(), version: -1, rules: null, aligned: false };
      entries.set(src, entry);
    }
    const media = screenMedia(src.media);
    if (entry.sheet.media.mediaText !== media) entry.sheet.media.mediaText = media;
    const rules = readRules(src);
    if (entry.version !== version || (rules === null) !== (entry.rules === null)) fullRender(src, entry);
    else if (entry.pending && entry.remoteVersion !== remoteVersion) fullRender(src, entry);
    else if (rules && entry.rules) {
      const old = entry.rules;
      const changed = deep || rules.length !== old.length || rules[0] !== old[0] || rules[rules.length - 1] !== old[old.length - 1];
      if (changed) {
        if (entry.aligned) patch(src, entry, rules);
        else fullRender(src, entry);
      }
    }
    return entry.sheet;
  }

  // Ops reported by the page hook. An in-place edit re-renders that top-level rule; inserts
  // and deletes are replayed on the override at the reported index, so CSS-in-JS appends
  // cost O(1) renders instead of a diff over the whole sheet.
  function applyEdits(list) {
    let full = false;
    const moves = new Map();
    for (const op of list) {
      if (!op || op.k === 'x') {
        full = true;
        continue;
      }
      const src = op.k === 'd' ? doc.styleSheets[op.s] : doc.adoptedStyleSheets[op.s];
      const entry = src && entries.get(src);
      if (!entry || entry.version !== version || !entry.rules) continue;
      if (op.t === 'i' || op.t === 'r') {
        if (!moves.has(src)) moves.set(src, []);
        moves.get(src).push(op);
        continue;
      }
      if (moves.has(src)) {
        // The index refers to a rule list the override has not caught up with yet.
        entry.version = -1;
        continue;
      }
      const rule = entry.rules[op.i];
      const rules = readRules(src);
      if (!entry.aligned || !rule || !rules || rules[op.i] !== rule) {
        entry.version = -1;
        continue;
      }
      forgetRule(rule);
      withBase(src.href || doc.baseURI, () => {
        entry.sheet.deleteRule(op.i + 1);
        try {
          entry.sheet.insertRule(renderTop(rule), op.i + 1);
        } catch {
          entry.sheet.insertRule(PLACEHOLDER, op.i + 1);
        }
      });
    }
    for (const [src, ops] of moves) {
      const entry = entries.get(src);
      if (entry.version !== version || replay(src, entry, ops)) continue;
      const rules = readRules(src);
      if (rules && entry.aligned) patch(src, entry, rules);
      else entry.version = -1;
    }
    if (full) scheduleFullInvalidate();
    scheduleScan();
  }

  // Applies reported inserts/deletes to the mirrored rule list, spot-checks the result
  // against the live sheet (neighbours of every change, both ends) and only then touches
  // the override. False means "use the identity diff".
  function replay(src, entry, ops) {
    const rules = readRules(src);
    if (!rules || !entry.aligned || ops.length > 64) return false;
    const next = entry.rules.slice();
    const marks = [];
    for (const op of ops) {
      const i = op.i;
      if (op.t === 'i') {
        if (!(i >= 0 && i <= next.length)) return false;
        next.splice(i, 0, null);
        for (const m of marks) if (m.at >= i) m.at++;
        marks.push({ at: i, fresh: true });
      } else {
        if (!(i >= 0 && i < next.length)) return false;
        next.splice(i, 1);
        for (let k = marks.length - 1; k >= 0; k--) if (marks[k].fresh && marks[k].at === i) marks.splice(k, 1);
        for (const m of marks) if (m.at > i) m.at--;
        marks.push({ at: i, fresh: false });
      }
    }
    if (next.length !== rules.length) return false;
    const same = (j) => j < 0 || j >= next.length || next[j] === null || next[j] === rules[j];
    if (!same(0) || !same(next.length - 1)) return false;
    for (const m of marks) if (!same(m.at - 1) || !same(m.at) || !same(m.at + 1)) return false;
    const sheet = entry.sheet;
    withBase(src.href || doc.baseURI, () => {
      for (const op of ops) {
        if (op.t === 'i') sheet.insertRule(PLACEHOLDER, 1 + op.i);
        else sheet.deleteRule(1 + op.i);
      }
      for (const m of marks) {
        if (!m.fresh) continue;
        next[m.at] = rules[m.at];
        sheet.deleteRule(1 + m.at);
        try {
          sheet.insertRule(renderTop(rules[m.at]), 1 + m.at);
        } catch {
          sheet.insertRule(PLACEHOLDER, 1 + m.at);
        }
      }
    });
    entry.rules = next;
    if (sheet.cssRules.length !== next.length + 1) fullRender(src, entry);
    return true;
  }

  let invalidateTimer = 0;
  function scheduleFullInvalidate() {
    if (invalidateTimer) return;
    invalidateTimer = setTimeout(() => {
      invalidateTimer = 0;
      if (!running) return;
      version++;
      ctx = newCtx();
      scanAll(true);
    }, 200);
  }

  let sheetWriteQueued = false;
  function queueSheetWrite() {
    if (sheetWriteQueued) return;
    sheetWriteQueued = true;
    queueMicrotask(() => {
      sheetWriteQueued = false;
      if (!running) return;
      // Shared with every shadow root as well as the document. Multiply-blended product
      // pictures otherwise disappear into a recolored black background.
      const media = mapper.mode === 'dark' ? 'img,picture,video,canvas{mix-blend-mode:normal !important;}' : '';
      presSheet.replaceSync(`${MARK}@layer omareader-base{${media}${siteCss()}${[...presRules].map(([sel, css]) => `${sel}{${css}}`).join('')}}`);
      propSheet.replaceSync(MARK + [...propRules.values()].join(''));
    });
  }

  // ---- scopes (the document and each shadow root, open or closed) -------

  class Scope {
    constructor(root) {
      this.root = root;
      this.shadow = root !== doc;
      this.observer = new MutationObserver((m) => onMutations(this, m));
      this.observe();
      if (this.shadow) {
        root.addEventListener('load', onLoad, true);
        // Seen from the document, an event from inside a closed root is retargeted to
        // its host; each root listens itself so nested hosts are found.
        root.addEventListener('omareader:shadow', onShadowEvent);
      }
    }

    observe() {
      this.observer.observe(this.root, { childList: true, subtree: true, attributes: true, attributeFilter: OBSERVED_ATTRS });
    }

    scan(deep = false) {
      const outs = this.shadow ? [presSheet] : [propSheet, presSheet];
      for (const src of this.root.styleSheets) {
        if (baseEl && src.ownerNode === baseEl) continue;
        const o = overrideFor(src, deep);
        if (o) outs.push(o);
      }
      const current = this.root.adoptedStyleSheets;
      const page = current.filter((s) => !isOurs(s));
      for (const src of page) {
        const o = overrideFor(src, deep);
        if (o) outs.push(o);
      }
      outs.push(varsSheet);
      const wanted = page.concat(outs);
      if (wanted.length !== current.length || wanted.some((s, i) => s !== current[i])) {
        this.root.adoptedStyleSheets = wanted;
      }
    }

    destroy() {
      this.observer.disconnect();
      if (this.shadow) {
        this.root.removeEventListener('load', onLoad, true);
        this.root.removeEventListener('omareader:shadow', onShadowEvent);
      }
      this.root.adoptedStyleSheets = this.root.adoptedStyleSheets.filter((s) => !isOurs(s));
    }
  }

  function addScope(root) {
    if (!running || scopes.has(root)) return;
    const scope = new Scope(root);
    scopes.set(root, scope);
    processTree(root);
    discoverShadows(root);
    scope.scan();
  }

  // Open roots are a property read; closed ones need chrome.dom, about 1.5 µs a call.
  function closedRoot(el) {
    try {
      return dom ? dom.openOrClosedShadowRoot(el) : null;
    } catch {
      return null;
    }
  }
  const shadowOf = (el) =>
    el.shadowRoot || ((el.localName.includes('-') || HOSTS.has(el.localName)) && closedRoot(el));

  // Walks ask custom elements right away. Built-in hosts get a closed root either from
  // attachShadow (announced by the hook) or declaratively; those are swept in idle time.
  function discoverShadows(node) {
    if (node.nodeType === 1) {
      const root = shadowOf(node);
      if (root) addScope(root);
    }
    if (!node.firstElementChild && !(node instanceof ShadowRoot)) return;
    const walker = doc.createTreeWalker(node, NodeFilter.SHOW_ELEMENT);
    for (let el = walker.nextNode(); el; el = walker.nextNode()) {
      const root = el.shadowRoot || (dom && el.localName.includes('-') ? closedRoot(el) : null);
      if (root) addScope(root);
    }
    if (dom) {
      sweepQueue.add(node);
      if (!sweepId) sweepId = requestIdleCallback(sweep, { timeout: 1000 });
    }
  }

  const sweepQueue = new Set();
  let sweepJob = null;
  let sweepId = 0;
  function sweep(deadline) {
    sweepId = 0;
    // A callback forced by the timeout reports no idle time; it still gets a short slice.
    const end = performance.now() + Math.max(4, deadline.timeRemaining());
    while (running) {
      if (!sweepJob) {
        const node = sweepQueue.values().next().value;
        if (!node) return;
        sweepQueue.delete(node);
        sweepJob = { list: node.querySelectorAll(HOST_TAGS), i: 0 };
      }
      const job = sweepJob;
      while (job.i < job.list.length) {
        const el = job.list[job.i++];
        if (!el.shadowRoot && el.isConnected) {
          const root = closedRoot(el);
          if (root) addScope(root);
        }
        if (!(job.i & 127) && performance.now() > end) {
          sweepId = requestIdleCallback(sweep, { timeout: 1000 });
          return;
        }
      }
      sweepJob = null;
    }
  }

  function stopSweep() {
    cancelIdleCallback(sweepId);
    sweepId = 0;
    sweepJob = null;
    sweepQueue.clear();
  }

  let scanQueued = false;
  let deepQueued = false;
  function scheduleScan(deep = false) {
    if (!running) return;
    if (deep === true) deepQueued = true;
    if (scanQueued) return;
    scanQueued = true;
    queueMicrotask(() => {
      scanQueued = false;
      const d = deepQueued;
      deepQueued = false;
      scanAll(d);
    });
  }

  function scanAll(deep = false) {
    if (!running) return;
    for (const [root, scope] of scopes) {
      if (root !== doc && !root.host.isConnected) {
        scope.destroy();
        scopes.delete(root);
        continue;
      }
      scope.scan(deep);
    }
  }

  const isStyleNode = (n) => n.localName === 'style' || (n.localName === 'link' && /\bstylesheet\b/i.test(n.rel));

  function onMutations(scope, mutations) {
    if (!running) return;
    let scan = false;
    let detect = false;
    // Apps set inline properties one by one: map each element once per batch.
    const styled = new Set();
    for (const m of mutations) {
      if (m.type === 'attributes') {
        const t = m.target;
        const a = m.attributeName;
        if (a === 'rel' || a === 'href' || a === 'media' || a === 'disabled') {
          if (t.localName === 'link' || t.localName === 'style') scan = detect = true;
        } else if (a === 'style') styled.add(t);
        else if (a === 'class') detect = true;
        else if (a === 'contenteditable') processTree(t);
        else collectPres(t);
        continue;
      }
      if (m.target === baseEl) continue;
      if (m.target.localName === 'style') scan = detect = true;
      for (const n of m.addedNodes) {
        if (n.nodeType !== 1 || n === baseEl) continue;
        detect = true;
        if (n === doc.documentElement) onNewRoot();
        else if (n === doc.body) onNewBody();
        if (isStyleNode(n) || (n.firstElementChild && n.querySelector('style,link[rel~="stylesheet" i]'))) scan = true;
        processTree(n);
        discoverShadows(n);
      }
      for (const n of m.removedNodes) {
        if (n === baseEl) {
          queueMicrotask(insertBase);
          continue;
        }
        if (n.nodeType === 1) {
          detect = true;
          if (isStyleNode(n) || (n.firstElementChild && n.querySelector('style,link'))) scan = true;
        }
      }
    }
    for (const t of styled) if (processInline(t)) detect = true;
    if (scan) scope.scan();
    if (detect) scheduleDetect();
  }

  function onLoad(e) {
    const t = e.target;
    if (!t || (t.localName !== 'link' && t.localName !== 'style')) return;
    // An @import inside the sheet may just have arrived: re-render it fully.
    if (t.sheet) entries.delete(t.sheet);
    scheduleScan();
    scheduleDetect();
  }

  // ---- in-place rewrites -------------------------------------------------

  // Rewrites the color declarations of one declaration block in place: an inline style or
  // a rule inside an anonymous layer. `slot` keeps {orig, mapped, prio} per property and
  // the typed custom properties written, so later calls only touch what changed. With
  // `ownVars` false the typed copies are returned for the caller to place instead.
  function mapStyle(style, slot, canvasBackground = null, ownVars = true) {
    const decls = [];
    const vars = new Map();
    let pending = false;
    for (let i = 0; i < style.length; i++) {
      const prop = style[i];
      if (prop.startsWith('--omareader-')) continue;
      const v = style.getPropertyValue(prop);
      if (prop.startsWith('--')) {
        const prio = style.getPropertyPriority(prop);
        for (const [k, tv] of X.typedVars(prop, v, ctx)) vars.set(k, [tv, prio]);
        continue;
      }
      if (!v) {
        pending = true;
        continue;
      }
      if (X.roleOf(prop)) decls.push([prop, v, style.getPropertyPriority(prop)]);
    }
    if (pending) {
      for (const sh of X.VAR_SHORTHANDS) {
        const v = style.getPropertyValue(sh);
        if (v && v.includes('var(')) decls.push([sh, v, style.getPropertyPriority(sh)]);
      }
    }
    const state = slot.state;
    const seen = new Set();
    for (const [prop, v, prio] of decls) {
      seen.add(prop);
      const rec = state.get(prop);
      if (rec && v === rec.mapped) continue;
      const mapped = canvasBackground && prop === 'background-color' ? canvasBackground : X.transformValue(v, X.roleOf(prop), ctx);
      if (mapped === v) {
        state.delete(prop);
        continue;
      }
      style.setProperty(prop, mapped, prio);
      state.set(prop, { orig: v, mapped: style.getPropertyValue(prop), prio });
    }
    for (const prop of [...state.keys()]) if (!seen.has(prop)) state.delete(prop);

    const stale = [];
    for (let i = 0; i < style.length; i++) {
      if (style[i].startsWith('--omareader-') && (!ownVars || !vars.has(style[i]))) stale.push(style[i]);
    }
    for (const k of stale) style.removeProperty(k);
    if (!ownVars) return vars;
    for (const [k, [v, prio]] of vars) {
      const prev = slot.vars.get(k);
      if (prev && prev[0] === v && prev[1] === prio &&
        (style.getPropertyValue(k) !== '' || Array.prototype.includes.call(style, k))) continue;
      style.setProperty(k, v, prio);
    }
    slot.vars = vars;
  }

  function unmapStyle(style, slot) {
    swapStyle(style, slot, false);
    if (!slot.vars.size) return;
    const own = [];
    for (let i = 0; i < style.length; i++) if (style[i].startsWith('--omareader-')) own.push(style[i]);
    for (const k of own) style.removeProperty(k);
  }

  // Originals back (or the mapped values again) without forgetting the mapping.
  function swapStyle(style, slot, mapped) {
    for (const [prop, rec] of slot.state) {
      const [from, to] = mapped ? [rec.orig, rec.mapped] : [rec.mapped, rec.orig];
      if (style.getPropertyValue(prop) === from) style.setProperty(prop, to, rec.prio);
    }
  }

  // ---- inline styles ----------------------------------------------------

  // Inline colors are rewritten in place so they keep inline precedence (losing to
  // !important rules, animations and :hover the way the originals do). Originals are
  // restored on disable, palette change, print and copy. Editable content is never touched.
  const editable = (el) =>
    doc.designMode === 'on' || el.isContentEditable || (el.parentElement && el.parentElement.isContentEditable);

  function processTree(node) {
    if (node.nodeType === 1) {
      processInline(node);
      collectPres(node);
    }
    if (node.querySelectorAll && (node.firstElementChild || node instanceof ShadowRoot || node === doc)) {
      for (const el of node.querySelectorAll('[style]')) processInline(el);
      for (const el of node.querySelectorAll(PRES_SELECTOR)) collectPres(el);
    }
  }

  function processInline(el) {
    if (!running || printing || el.nodeType !== 1 || el === baseEl) return false;
    if (copying) {
      copying.deferred.add(el);
      return false;
    }
    const style = el.style;
    if (!style) return false;
    if (editable(el)) {
      restoreInline(el);
      return false;
    }
    let slot = inline.get(el);
    // Compare the page's declarations, with our mapped values normalized back to their
    // originals. Our own writes and temporary detection/copy swaps must not request
    // another background check; real app updates (including removals) must do so.
    // Player progress bars and other animations update transform/width every frame.
    // Those cannot change the page's colors and must not trigger background sampling.
    const source = JSON.stringify(Array.from(style).filter((prop) =>
      !prop.startsWith('--omareader-') && (prop.startsWith('--') || X.roleOf(prop) || BACKGROUND_STATE.has(prop))).sort().map((prop) => {
      const value = style.getPropertyValue(prop);
      const rec = slot && slot.state.get(prop);
      return [prop, rec && value === rec.mapped ? rec.orig : value, style.getPropertyPriority(prop)];
    }));
    const changed = (inlineSource.get(el) || '[]') !== source;
    inlineSource.set(el, source);
    if (!style.length && !slot) return changed;
    ctx.base = doc.baseURI;
    const fresh = !slot;
    if (fresh) slot = { state: new Map(), vars: new Map(), rule: null, id: '', varsText: '' };
    // The variable switches canvas backgrounds to black in fullscreen, including
    // inline !important backgrounds, without rewriting styles during playback.
    const canvasBackground = youtube && el.matches(YOUTUBE_CANVAS)
      ? `var(--omareader-youtube-fullscreen-bg, ${mapper.swatch.bg})` : null;
    placeVars(el, slot, mapStyle(style, slot, canvasBackground, false));
    if (slot.state.size || slot.rule) {
      if (fresh) {
        inline.set(el, slot);
        touched.add(new WeakRef(el));
      }
    } else if (!fresh) inline.delete(el);
    return changed;
  }

  function restoreInline(el) {
    const slot = inline.get(el);
    if (!slot) return;
    inline.delete(el);
    dropVars(el, slot);
    unmapStyle(el.style, slot);
  }

  function restoreAllInline() {
    for (const ref of touched) {
      const el = ref.deref();
      if (el) restoreInline(el);
    }
    touched.clear();
    // Rules of collected elements.
    if (varsSheet && varRules.size) varsSheet.replaceSync(MARK);
    varRules.clear();
  }

  // ---- inline custom properties -----------------------------------------

  // Typed copies of inline custom properties go into one varsSheet rule per element, not
  // into the style attribute. Meta apps declare their whole theme (about 1000 variables)
  // inline on wrapper divs: four copies each, written one by one, made those attributes
  // 200 KB, and page observers that read every ancestor's style froze the tab.
  function placeVars(el, slot, vars) {
    let text = '';
    for (const [k, [v, prio]] of vars) text += `${k}:${v}${prio ? '!important' : ''};`;
    if (!text) {
      dropVars(el, slot);
      return;
    }
    if (!slot.rule) {
      slot.id = String(++varsSeq);
      const rules = varsSheet.cssRules;
      slot.rule = rules[varsSheet.insertRule(`[${VARS_ATTR}="${slot.id}"]${VARS_SPEC}{}`, rules.length)];
      slot.varsText = '';
      varRules.set(slot.rule, new WeakRef(el));
    }
    if (slot.varsText !== text) {
      slot.rule.style.cssText = text;
      slot.varsText = text;
    }
    if (el.getAttribute(VARS_ATTR) !== slot.id) el.setAttribute(VARS_ATTR, slot.id);
  }

  function forgetVars(el, slot) {
    varRules.delete(slot.rule);
    slot.rule = null;
    slot.varsText = '';
    if (el.getAttribute(VARS_ATTR) === slot.id) el.removeAttribute(VARS_ATTR);
  }

  function dropVars(el, slot) {
    if (!slot.rule) return;
    const i = Array.prototype.indexOf.call(varsSheet.cssRules, slot.rule);
    if (i >= 0) varsSheet.deleteRule(i);
    forgetVars(el, slot);
  }

  // Rules of elements that left the document. A reinserted element is mapped again.
  function sweepVars() {
    const dead = new Set();
    for (const [rule, ref] of varRules) {
      const el = ref.deref();
      if (el && el.isConnected) continue;
      dead.add(rule);
      const slot = el && inline.get(el);
      if (slot && slot.rule === rule) forgetVars(el, slot);
      else varRules.delete(rule);
    }
    if (!dead.size) return;
    const rules = varsSheet.cssRules;
    for (let i = rules.length - 1; i >= 0; i--) if (dead.has(rules[i])) varsSheet.deleteRule(i);
  }

  // ---- anonymous layers -------------------------------------------------

  // An anonymous @layer cannot be re-entered: a copy would become a new, later layer and
  // beat the page's later layers. Its colors are rewritten in the page's own CSSOM instead,
  // which keeps the exact cascade position (cross-origin sheets are read-only and stay
  // unthemed). Called while rendering the block (or an `@import … layer`).
  function onAnonLayer(rule) {
    if (printing || remoteText.has(rule.parentStyleSheet)) return;
    const rules = rule instanceof CSSImportRule ? rule.styleSheet && readRules(rule.styleSheet) : rule.cssRules;
    if (!rules) return;
    // url() stays as written: the rule keeps its own base URL.
    withBase(null, () => mapAnon(rules));
  }

  function mapAnon(rules) {
    for (const r of rules) {
      if (r.style) {
        let slot = anonSlots.get(r.style);
        const fresh = !slot;
        if (fresh) slot = { state: new Map(), vars: new Map() };
        mapStyle(r.style, slot);
        if (fresh && (slot.state.size || slot.vars.size)) {
          anonSlots.set(r.style, slot);
          anonTouched.add(new WeakRef(r.style));
        }
      }
      if (r instanceof CSSPropertyRule) onProperty(r);
      else if (r instanceof CSSImportRule) {
        const inner = r.styleSheet && readRules(r.styleSheet);
        if (inner) mapAnon(inner);
      }
      if (r.cssRules) mapAnon(r.cssRules);
    }
  }

  function swapAnon(mapped) {
    for (const ref of anonTouched) {
      const style = ref.deref();
      const slot = style && anonSlots.get(style);
      if (slot) swapStyle(style, slot, mapped);
    }
  }

  function restoreAllAnon() {
    for (const ref of anonTouched) {
      const style = ref.deref();
      const slot = style && anonSlots.get(style);
      if (!slot) continue;
      anonSlots.delete(style);
      unmapStyle(style, slot);
    }
    anonTouched.clear();
  }

  // ---- copy -------------------------------------------------------------

  // Copy and cut serialize computed colors into the clipboard HTML, own sheets included.
  // For the default action the page gets its own colors back (own sheets off, inline
  // originals around the selection, anonymous-layer originals); everything is re-applied
  // in the next animation frame, before anything is painted. (Drag data is serialized
  // before dragstart fires, so drags cannot be fixed this way.)
  const within = (anc, n) => {
    for (; n; n = n.parentNode || n.host) if (n === anc) return true;
    return false;
  };

  function onCopy() {
    if (!running || copying) return;
    const sel = getSelection();
    if (!sel || !sel.rangeCount || sel.isCollapsed) return;
    const anc = sel.getRangeAt(0).commonAncestorContainer;
    const sheets = ownSheets();
    for (const s of sheets) s.disabled = true;
    swapAnon(false);
    const restored = [];
    for (const ref of touched) {
      const el = ref.deref();
      if (!el) touched.delete(ref);
      else if (inline.has(el) && (within(anc, el) || within(el, anc))) {
        touched.delete(ref);
        restoreInline(el);
        restored.push(el);
      }
    }
    copying = { sheets, restored, deferred: new Set() };
    requestAnimationFrame(endCopy);
    setTimeout(endCopy, 250);
  }

  function endCopy() {
    const c = copying;
    if (!c) return;
    copying = null;
    for (const s of c.sheets) s.disabled = false;
    if (!running) return;
    swapAnon(true);
    for (const el of c.restored) processInline(el);
    for (const el of c.deferred) processInline(el);
  }

  // ---- presentational attributes ----------------------------------------

  const quote = (v) => `"${v.replace(/[\\"]/g, '\\$&').replace(/\n/g, '\\a ')}"`;

  function addPres(key, selector, css) {
    if (presSeen.has(key)) return;
    presSeen.add(key);
    presRules.set(selector, css);
    queueSheetWrite();
  }

  // bgcolor="#fff", <font color>, <body text/link>, SVG fill="#000": one rule per distinct
  // value in the lowest layer, so any page CSS (hover fills, highlight classes) still wins.
  function collectPres(el) {
    if (!running || el.nodeType !== 1) return;
    const map = (c, role) => C.format(mapper.map(c, role));
    const legacy = (attr, sel, prop, role) => {
      const v = el.getAttribute(attr);
      if (v === null) return;
      const c = C.parseLegacy(v);
      if (c) addPres(`${sel}|${attr}|${v}`, sel.replaceAll('$', `[${attr}=${quote(v)} i]`), `${prop}:${map(c, role)}`);
    };
    if (el.hasAttribute('bgcolor')) legacy('bgcolor', '$', 'background-color', 'bg');
    const name = el.localName;
    if (name === 'font') legacy('color', 'font$', 'color', 'text');
    if (name === 'body') {
      legacy('text', 'body$', 'color', 'text');
      legacy('link', 'body$ :link', 'color', 'text');
      legacy('vlink', 'body$ :visited', 'color', 'text');
      legacy('alink', 'body$ :link:active,body$ :visited:active', 'color', 'text');
    }
    if (el.namespaceURI === SVG_NS) {
      for (const attr of ['fill', 'stroke', 'stop-color', 'flood-color']) {
        const v = el.getAttribute(attr);
        const c = v && C.parse(v);
        if (c) addPres(`svg|${attr}|${v}`, `[${attr}=${quote(v)}]`, `${attr}:${map(c, 'text')}`);
      }
    }
  }

  // ---- base layer --------------------------------------------------------

  // Canvas pixels are out of reach of CSS colors, so the grid goes through one sRGB color
  // matrix: invert + hue-rotate(180deg) (light cells dark, hues kept), then black→bg and
  // white→fg. All three steps are affine, so they fold into out = fg − (fg−bg)·H·in.
  const HUE_180 = [[-0.574, 1.43, 0.144], [0.426, 0.43, 0.144], [0.426, 1.43, -0.856]];
  function placeRamp() {
    const bg = C.parse(mapper.swatch.bg);
    const fg = C.parse(mapper.swatch.fg);
    if (!bg || !fg) return;
    const values = ['r', 'g', 'b'].map((k, i) => {
      const d = (fg[k] - bg[k]) / 255;
      return [...HUE_180[i].map((h) => +(-d * h).toFixed(4)), 0, +(fg[k] / 255).toFixed(4)].join(' ');
    }).join(' ') + ' 0 0 0 1 0';
    if (!rampEl) {
      rampEl = doc.createElementNS(SVG_NS, 'svg');
      rampEl.setAttribute('data-omareader', 'ramp');
      rampEl.setAttribute('aria-hidden', 'true');
      rampEl.setAttribute('style', 'position:absolute;width:0;height:0;overflow:hidden');
      rampEl.innerHTML = `<filter id="${RAMP_ID}" color-interpolation-filters="sRGB"><feColorMatrix type="matrix"/></filter>`;
    }
    rampEl.querySelector('feColorMatrix').setAttribute('values', values);
    if (!rampEl.isConnected && doc.documentElement) doc.documentElement.appendChild(rampEl);
  }

  function siteCss() {
    if (excel) {
      placeRamp();
      return `canvas{filter:url(#${RAMP_ID}) !important;}`;
    }
    if (gmail) {
      const s = mapper.swatch;
      // Gmail has nested scroll containers and its own WebKit scrollbar rules.
      // Mapping a thumb's background as a surface makes it almost as dark as
      // the track. Cover both scrollbar APIs without changing their geometry.
      // Inbox rows need explicit text/surface pairs: Gmail's subdued text and
      // native theme colors can otherwise collapse onto the same palette step.
      return `*{scrollbar-color:${s.thumb} ${s.bg} !important;}` +
        `::-webkit-scrollbar-thumb{background-color:${s.thumb} !important;}` +
        `::-webkit-scrollbar-thumb:hover{background-color:${s.fg} !important;}` +
        `::-webkit-scrollbar-track{background-color:${s.bg} !important;}` +
        `.zA{background-color:${s.bg} !important;color:${s.fg} !important;}` +
        `.zA.zE{background-color:${s.button} !important;}` +
        `.zA:is(:hover,.x7){background-color:${s.field} !important;}` +
        `.zA :is(.yW,.y6,.y2,.xW,.zF,.bog,.bqe){color:${s.fg} !important;}` +
        `.a3s{color:${s.fg} !important;}`;
    }
    if (!youtube) return '';
    // Keep the watch-page canvas in the palette even when YouTube supplies its native
    // background on a different wrapper or swaps its color-token stylesheet. The first
    // layer's important declaration wins over important page rules; inline backgrounds
    // are mapped to the same swatch by processInline with the usual restoration tracking.
    // This lives in the screen-only adopted sheet, independently of page style-src CSP.
    // Ambient mode paints blurred video frames on canvases far around the player (over
    // the masthead too); hidden, the surround is the palette background.
    // Fullscreen's top-layer player and its video surfaces must keep letterboxing
    // black with every palette. CSS handles entry/exit and YouTube's player class.
    const fullscreen = ':fullscreen,.html5-video-player.ytp-fullscreen';
    const videoSurfaces = '#movie_player,.html5-video-container,video';
    return `${YOUTUBE_CANVAS}{background-color:var(--omareader-youtube-fullscreen-bg, ${mapper.swatch.bg}) !important;}` +
      `:is(${fullscreen}){--omareader-youtube-fullscreen-bg:#000 !important;background-color:#000 !important;}` +
      `:is(${fullscreen}) :is(${videoSurfaces}){background-color:#000 !important;}` +
      ':fullscreen::backdrop{background-color:#000 !important;}#cinematics{display:none !important;}';
  }

  // First node in the document: declares the lowest cascade layer. Its normal declarations
  // stand in for UA defaults. Screen only.
  function baseCss() {
    const s = mapper.swatch;
    return `@layer omareader-base{
:root{color-scheme:${mapper.mode} !important;background-color:${s.bg};color:${s.fg};scrollbar-color:${s.thumb} ${s.bg};accent-color:${s.accent}}
input:not([type=checkbox],[type=radio],[type=range],[type=color],[type=file],[type=image],[type=button],[type=submit],[type=reset]),textarea,select{background-color:${s.field};color:${s.fg};border-color:${s.border}}
button,input[type=button],input[type=submit],input[type=reset]{background-color:${s.button};color:${s.fg};border-color:${s.border}}
::placeholder{color:${s.muted};opacity:1}
a:link{color:${s.link}}
a:visited{color:${s.visited}}
mark{background-color:${s.mark};color:${s.fg}}
::selection{background-color:${s.selection} !important;color:${s.selectionText} !important}
}`;
  }

  function insertBase() {
    if (!running) return;
    const rootEl = doc.documentElement;
    if (!rootEl) return;
    if (!baseEl) {
      baseEl = doc.createElement('style');
      baseEl.setAttribute('data-omareader', 'base');
      baseEl.media = 'screen';
      baseEl.textContent = baseCss();
    }
    if (baseEl.parentNode !== rootEl || rootEl.firstChild !== baseEl) rootEl.insertBefore(baseEl, rootEl.firstChild);
  }

  // document.open()/write() replaced the whole tree.
  function onNewRoot() {
    insertBase();
    const scope = scopes.get(doc);
    if (scope) scope.observe();
    addListeners();
    onNewBody();
  }

  function onNewBody() {
    watchRootAttrs();
    scheduleDetect();
  }

  // ---- page background detection ----------------------------------------

  const opaqueBg = (el) => {
    const c = C.parse(getComputedStyle(el).backgroundColor);
    return c && c.a > 0.5 ? c : null;
  };

  // Find full-page surfaces under sample points, ignoring fixed/sticky overlays.
  function pageCandidates() {
    const surfaces = new Set();
    const vw = innerWidth, vh = innerHeight;
    if (vw && vh) {
      for (const [x, y] of [[0.5, 0.5], [0.5, 0.25], [0.5, 0.75]]) {
        let candidates = [];
        for (let el = doc.elementFromPoint(vw * x, vh * y); el && el !== doc.body && el !== doc.documentElement; el = el.parentElement) {
          const cs = getComputedStyle(el);
          if (cs.position === 'fixed' || cs.position === 'sticky' || parseFloat(cs.opacity) < 1) {
            candidates = [];
            continue;
          }
          candidates.push(el);
        }
        for (const el of candidates) {
          const r = el.getBoundingClientRect();
          if (r.width >= vw * 0.9 && r.height >= vh * 0.9) surfaces.add(el);
        }
      }
    }
    return [...surfaces];
  }

  // The innermost opaque full-page surface, then root/body, then the canvas default.
  function pageBackground(candidates) {
    for (const el of candidates) {
      const c = opaqueBg(el);
      if (c) return c;
    }
    const c = opaqueBg(doc.documentElement) || (doc.body && opaqueBg(doc.body));
    if (c) return c;
    const scheme = getComputedStyle(doc.documentElement).colorScheme || '';
    return /dark/.test(scheme) && !/light/.test(scheme) ? { r: 18, g: 18, b: 18, a: 1 } : { r: 255, g: 255, b: 255, a: 1 };
  }

  function ownSheets() {
    const own = [];
    if (baseEl && baseEl.sheet) own.push(baseEl.sheet);
    for (const scope of scopes.values()) for (const s of scope.root.adoptedStyleSheets) if (isOurs(s)) own.push(s);
    return own;
  }

  function detectSite() {
    if (!running || !doc.body) return;
    if (copying) {
      scheduleDetect();
      return;
    }
    // YouTube exposes its native color mode on <html dark>. Sampling its busy watch
    // page instead disables every theme sheet, forces full-page layout, and briefly
    // rewrites canvas inline colors under the player's own mutation observers. Player
    // progress/controls can request this several times a second. Read the native mode
    // directly; rootAttrObserver already follows changes to the dark attribute.
    if (youtube) {
      updateSiteBackground(C.parse(doc.documentElement.hasAttribute('dark') ? '#0f0f0f' : '#fff'));
      return;
    }
    const own = ownSheets();
    for (const s of own) s.disabled = true;
    const candidates = pageCandidates();
    const measured = new Set([...candidates, doc.documentElement, doc.body]);
    // Only full-page surfaces need their original inline colors for this measurement.
    // Restoring unrelated buttons can restart transitions or trigger page observers.
    const originals = [];
    for (const ref of touched) {
      const el = ref.deref();
      if (!el) touched.delete(ref);
      const slot = el && el.isConnected && measured.has(el) && inline.get(el);
      if (slot) {
        originals.push([el.style, slot]);
        swapStyle(el.style, slot, false);
      }
    }
    swapAnon(false);
    let col;
    try {
      col = pageBackground(candidates);
    } finally {
      swapAnon(true);
      for (const [style, slot] of originals) swapStyle(style, slot, true);
      for (const s of own) s.disabled = false;
    }
    updateSiteBackground(col);
  }

  function updateSiteBackground(col) {
    const L = Math.round(C.toOklab(col).L * 100) / 100;
    if ((L < 0.5) !== (siteL < 0.5) || Math.abs(L - siteL) >= 0.04) {
      siteL = L;
      rebuild();
    }
  }

  let detectTimer = 0;
  function scheduleDetect(delay = 200) {
    // Coalesce bursts without postponing detection indefinitely on a busy feed.
    if (detectTimer) return;
    detectTimer = setTimeout(() => {
      detectTimer = 0;
      detectSite();
    }, delay);
  }

  const rootAttrObserver = new MutationObserver(() => scheduleDetect());

  function watchRootAttrs() {
    rootAttrObserver.disconnect();
    if (!doc.documentElement) return;
    // Inline style changes are already tracked by the scope observer, which can tell
    // page writes apart from our mapped writes.
    const opts = { attributes: true, attributeFilter: ['class', 'data-theme', 'data-color-mode', 'theme', 'dark'] };
    rootAttrObserver.observe(doc.documentElement, opts);
    if (doc.body) rootAttrObserver.observe(doc.body, opts);
  }

  // ---- lifecycle ---------------------------------------------------------

  function rebuild() {
    restoreAllInline();
    restoreAllAnon();
    mapper = T.createMapper(palette, { siteL });
    version++;
    ctx = newCtx();
    presRules.clear();
    presSeen.clear();
    propRules.clear();
    if (baseEl) baseEl.textContent = baseCss();
    for (const scope of scopes.values()) {
      scope.scan();
      processTree(scope.root);
    }
    queueSheetWrite();
  }

  function onReady() {
    if (!running) return;
    insertBase();
    watchRootAttrs();
    processTree(doc);
    discoverShadows(doc);
    scanAll();
    detectSite();
  }

  const onCss = () => {
    scheduleScan(true);
    scheduleDetect();
  };
  const onEdit = (e) => {
    let list;
    try {
      list = JSON.parse(e.detail);
    } catch {
      return;
    }
    if (Array.isArray(list)) {
      applyEdits(list);
      scheduleDetect();
    }
  };
  const onNav = () => scheduleDetect(300);
  const onBeforePrint = () => {
    printing = true;
    restoreAllInline();
    swapAnon(false);
  };
  const onAfterPrint = () => {
    printing = false;
    swapAnon(true);
    for (const scope of scopes.values()) processTree(scope.root);
  };

  function addListeners() {
    doc.addEventListener('load', onLoad, true);
    doc.addEventListener('omareader:css', onCss);
    doc.addEventListener('omareader:edit', onEdit);
    doc.addEventListener('omareader:nav', onNav);
    doc.addEventListener('omareader:shadow', onShadowEvent);
    addEventListener('popstate', onNav);
    addEventListener('beforeprint', onBeforePrint);
    addEventListener('afterprint', onAfterPrint);
    addEventListener('copy', onCopy, true);
    addEventListener('cut', onCopy, true);
  }

  function removeListeners() {
    doc.removeEventListener('load', onLoad, true);
    doc.removeEventListener('omareader:css', onCss);
    doc.removeEventListener('omareader:edit', onEdit);
    doc.removeEventListener('omareader:nav', onNav);
    doc.removeEventListener('omareader:shadow', onShadowEvent);
    removeEventListener('popstate', onNav);
    removeEventListener('beforeprint', onBeforePrint);
    removeEventListener('afterprint', onAfterPrint);
    removeEventListener('copy', onCopy, true);
    removeEventListener('cut', onCopy, true);
  }

  function tick() {
    if (!extAlive()) {
      stop();
      return;
    }
    if (doc.documentElement && (!baseEl || !baseEl.isConnected)) onNewRoot();
    if (doc.visibilityState === 'visible') scanAll();
    sweepVars();
  }

  function start() {
    if (running) {
      rebuild();
      return;
    }
    running = true;
    for (const stale of doc.querySelectorAll('style[data-omareader],svg[data-omareader]')) stale.remove();
    mapper = T.createMapper(palette, { siteL });
    version++;
    ctx = newCtx();
    presSheet = newSheet('screen');
    presSheet.replaceSync(MARK);
    propSheet = newSheet();
    propSheet.replaceSync(MARK);
    varsSheet = newSheet('screen');
    varsSheet.replaceSync(MARK);
    insertBase();
    addScope(doc);
    queueSheetWrite();
    addListeners();
    if (doc.readyState === 'loading') doc.addEventListener('DOMContentLoaded', onReady, { once: true });
    else onReady();
    addEventListener('load', () => scheduleDetect(0), { once: true });
    watchRootAttrs();
    timer = setInterval(tick, 1000);
  }

  function stop() {
    if (!running) return;
    running = false;
    clearInterval(timer);
    clearTimeout(detectTimer);
    detectTimer = 0;
    rootAttrObserver.disconnect();
    removeListeners();
    stopSweep();
    endCopy();
    restoreAllInline();
    restoreAllAnon();
    for (const scope of scopes.values()) scope.destroy();
    scopes.clear();
    if (baseEl) baseEl.remove();
    baseEl = null;
    if (rampEl) rampEl.remove();
    rampEl = null;
    presRules.clear();
    presSeen.clear();
    propRules.clear();
  }

  // attachShadow or a root's adoptedStyleSheets changed. The innermost scope sees the
  // real host first (bubbling), so the document's retargeted copy is skipped.
  const shadowEvents = new WeakSet();
  function onShadowEvent(e) {
    if (shadowEvents.has(e)) return;
    shadowEvents.add(e);
    const hostEl = e.composedPath()[0];
    const root = hostEl && hostEl.nodeType === 1 && shadowOf(hostEl);
    if (!root) return;
    const scope = scopes.get(root);
    if (scope) scope.scan(true);
    else addScope(root);
  }

  // `active` carries the Omarchy palette; Dark is fixed, so each site can use either.
  const darkPalette = T.normalize(T.DARK);
  function evaluate() {
    const mode = T.siteModeOf(settings, site);
    const next = mode === 'dark' ? darkPalette : active && active.palette;
    if (mode === 'normal' || !next) {
      stop();
      return;
    }
    const key = JSON.stringify(next);
    if (!running || key !== activeKey) {
      activeKey = key;
      palette = next;
      start();
    }
  }

  try {
    chrome.storage.onChanged.addListener((changes, area) => {
      if (area !== 'local') return;
      if (!changes.settings && !changes.active) return;
      if (changes.settings) settings = changes.settings.newValue;
      if (changes.active) active = changes.active.newValue;
      evaluate();
    });

    chrome.storage.local.get(['settings', 'active']).then(async (r) => {
      settings = r.settings;
      active = r.active;
      if (!active) {
        try {
          const state = await chrome.runtime.sendMessage({ type: 'get-state' });
          settings = state.settings;
          active = state.active;
        } catch {}
      }
      evaluate();
    });
  } catch {}
})();
// OMAREADER-DIAG-BEGIN
(() => {
  if (!/^read\.amazon\./.test(location.hostname)) return;
  const dump = () => {
    const out = [];
    const vw = innerWidth, vh = innerHeight;
    const walk = (root, depth) => {
      for (const el of root.querySelectorAll('*')) {
        const r = el.getBoundingClientRect();
        if (r.width < 40 || r.height < 40) continue;
        const cs = getComputedStyle(el);
        const interesting = r.width * r.height > vw * vh * 0.15 || /^(IMG|CANVAS|SVG|IFRAME)$/i.test(el.tagName);
        if (interesting) out.push({
          tag: el.tagName, id: el.id, cls: String(el.className && el.className.baseVal !== undefined ? el.className.baseVal : el.className).slice(0, 80),
          box: [r.x, r.y, r.width, r.height].map(Math.round), z: cs.zIndex, pos: cs.position, op: cs.opacity, filt: cs.filter,
          blend: cs.mixBlendMode, bg: cs.backgroundColor, bgi: cs.backgroundImage.slice(0, 80), color: cs.color, vis: cs.visibility,
          mask: cs.maskImage, bdf: cs.backdropFilter, attrVars: (el.getAttribute('data-omareader-vars') || '').slice(0, 200),
          style: (el.getAttribute('style') || '').slice(0, 300), src: (el.currentSrc || el.src || '').slice(0, 60),
        });
        if (el.shadowRoot) walk(el.shadowRoot, depth + 1);
      }
    };
    walk(document, 0);
    const body = JSON.stringify({ h: location.pathname.slice(0, 30), top: self === top, n: out.length, out }).replace(/[^\x20-\x7e]/g, '?');
    try { top.document.title = (/^DIAG/.test(top.document.title) ? top.document.title : 'DIAG') + ' || ' + body; } catch {}
  };
  for (const t of [6000, 14000]) setTimeout(dump, t);
})();
// OMAREADER-DIAG-END
