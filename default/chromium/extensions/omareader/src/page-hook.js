// Main-world hook. CSS-in-JS libraries (emotion, styled-components, JSS) change styles
// through the CSSOM, which no MutationObserver sees; this tells the isolated content
// script what changed. Events carry only indices, never page objects.
(() => {
  'use strict';
  const MARK = Symbol.for('omareader.hooked');
  if (CSSStyleSheet.prototype[MARK]) return;
  Object.defineProperty(CSSStyleSheet.prototype, MARK, { value: true });

  const indexOf = Array.prototype.indexOf;
  const later = (fn) => {
    let queued = false;
    return () => {
      if (queued) return;
      queued = true;
      queueMicrotask(() => {
        queued = false;
        fn();
      });
    };
  };

  const notify = later(() => document.dispatchEvent(new Event('omareader:css')));
  const notifyNav = later(() => document.dispatchEvent(new Event('omareader:nav')));

  // Ops are reported in order as {k: 'd'|'a'|'x', s: sheet index, t, i: top-level rule
  // index}: t 'e' is an in-place edit, 'i'/'r' a top-level insert/delete. A burst beyond
  // MAX_OPS drops the list ops and falls back to a rescan. Until the flush an op holds its
  // sheet, not an index: a sheet inserted before it in the same task would shift the index.
  const MAX_OPS = 256;
  let ops = [];
  let overflow = false;
  const seen = new Map(); // sheet → top-level indices with an edit queued
  let unlocated = false;
  const flushOps = later(() => {
    const list = [];
    for (const op of ops) {
      if (!op.sheet) {
        list.push({ k: 'x' });
        continue;
      }
      if (overflow && op.t !== 'e') continue;
      // A sheet removed since needs no edit: the scan sees it go.
      const loc = locate(op.sheet);
      if (loc) list.push({ k: loc.k, s: loc.s, t: op.t, i: op.i });
    }
    ops = [];
    overflow = false;
    seen.clear();
    unlocated = false;
    if (list.length) document.dispatchEvent(new CustomEvent('omareader:edit', { detail: JSON.stringify(list) }));
  });

  const located = new WeakMap();
  function locate(sheet) {
    const last = located.get(sheet);
    if (last && (last.k === 'd' ? document.styleSheets[last.s] : document.adoptedStyleSheets[last.s]) === sheet) return last;
    let k = 'd';
    let s = indexOf.call(document.styleSheets, sheet);
    if (s < 0) {
      k = 'a';
      s = document.adoptedStyleSheets.indexOf(sheet);
    }
    if (s < 0) return null;
    const loc = { k, s };
    located.set(sheet, loc);
    return loc;
  }

  function edited(rule) {
    let top = rule;
    while (top && top.parentRule) top = top.parentRule;
    const sheet = top && top.parentStyleSheet;
    if (!sheet) return;
    if (!locate(sheet)) {
      if (unlocated) return;
      unlocated = true;
      ops.push({ k: 'x' });
    } else {
      const i = indexOf.call(sheet.cssRules, top);
      let queued = seen.get(sheet);
      if (!queued) seen.set(sheet, (queued = new Set()));
      if (queued.has(i)) return;
      queued.add(i);
      ops.push({ sheet, t: 'e', i });
    }
    flushOps();
  }

  function listOp(sheet, t, i) {
    const loc = locate(sheet);
    if (!loc || ops.length >= MAX_OPS) {
      if (loc) overflow = true;
      notify();
      return;
    }
    // Edit indices recorded before this op no longer line up with later ones.
    seen.clear();
    ops.push({ sheet, t, i });
    flushOps();
  }

  const wrap = (proto, name, after) => {
    const orig = proto && proto[name];
    if (typeof orig !== 'function') return;
    Object.defineProperty(proto, name, {
      configurable: true,
      writable: true,
      value: {
        [name](...args) {
          const result = orig.apply(this, args);
          after(this, result, args);
          return result;
        },
      }[name],
    });
  };
  const wrapSetter = (proto, name, after) => {
    const desc = proto && Object.getOwnPropertyDescriptor(proto, name);
    if (!desc || !desc.set) return;
    Object.defineProperty(proto, name, {
      configurable: true,
      enumerable: desc.enumerable,
      get: desc.get,
      set(value) {
        desc.set.call(this, value);
        after(this);
      },
    });
  };

  wrap(CSSStyleSheet.prototype, 'insertRule', (sheet, index) => listOp(sheet, 'i', index));
  wrap(CSSStyleSheet.prototype, 'deleteRule', (sheet, _, args) => listOp(sheet, 'r', args[0] >>> 0));
  for (const name of ['addRule', 'removeRule', 'replaceSync']) wrap(CSSStyleSheet.prototype, name, notify);
  wrap(CSSStyleSheet.prototype, 'replace', (_, promise) => promise.then(notify, () => {}));

  // Switching a sheet off or changing media through the CSSOM touches no attribute.
  wrapSetter(StyleSheet.prototype, 'disabled', notify);
  wrapSetter(window.HTMLStyleElement && HTMLStyleElement.prototype, 'disabled', notify);
  // A media list does not know its owner, so the page's reads record it: a rule whose
  // conditions changed is re-rendered, while a sheet's media needs only a rescan.
  const mediaOwners = new WeakMap();
  const mediaChanged = (owner) => (window.CSSRule && owner instanceof CSSRule ? edited(owner) : notify());
  for (const proto of [StyleSheet.prototype, window.CSSMediaRule && CSSMediaRule.prototype, window.CSSImportRule && CSSImportRule.prototype]) {
    const desc = proto && Object.getOwnPropertyDescriptor(proto, 'media');
    if (!desc || !desc.get) continue;
    Object.defineProperty(proto, 'media', {
      configurable: true,
      enumerable: desc.enumerable,
      get() {
        const list = desc.get.call(this);
        if (list) mediaOwners.set(list, this);
        return list;
      },
      // `rule.media = '…'` forwards to mediaText.
      set: desc.set && function (value) {
        desc.set.call(this, value);
        mediaChanged(this);
      },
    });
  }
  const listChanged = (list) => mediaChanged(mediaOwners.get(list));
  wrapSetter(window.MediaList && MediaList.prototype, 'mediaText', listChanged);
  for (const name of ['appendMedium', 'deleteMedium']) wrap(window.MediaList && MediaList.prototype, name, listChanged);

  // In-place edits of existing rules (inline element styles have no parentRule and are
  // left alone; the isolated script sees those through attribute mutations).
  const decl = CSSStyleDeclaration.prototype;
  const setProperty = decl.setProperty;
  const getPropertyValue = decl.getPropertyValue;
  const parentRule = Object.getOwnPropertyDescriptor(decl, 'parentRule').get;
  const ruleEdit = (style) => {
    const rule = parentRule.call(style);
    if (rule) edited(rule);
  };
  wrap(decl, 'setProperty', ruleEdit);
  wrap(decl, 'removeProperty', ruleEdit);
  wrapSetter(decl, 'cssText', ruleEdit);

  // Named setters (rule.style.color = …): Chrome serves them from a named-property
  // handler that only runs when the prototype chain has no such property, so accessors
  // defined here take over with the same semantics (setProperty without priority).
  const SIDES = ['', '-top', '-right', '-bottom', '-left', '-block', '-inline', '-block-start', '-block-end', '-inline-start', '-inline-end'];
  const COLOR_PROPS = [
    'all', 'color', 'background', 'background-color', 'background-image', 'box-shadow', 'text-shadow', 'caret-color',
    'accent-color', 'fill', 'stroke', 'stop-color', 'flood-color', 'lighting-color', 'scrollbar-color',
    'text-decoration', 'text-decoration-color', 'text-emphasis', 'text-emphasis-color', '-webkit-text-fill-color',
    '-webkit-text-stroke', '-webkit-text-stroke-color', 'outline', 'outline-color', 'column-rule', 'column-rule-color',
    ...SIDES.flatMap((side) => [`border${side}`, `border${side}-color`]),
  ];
  // A mirrored var() shorthand also carries the geometry it resets (background-size,
  // border widths), so the longhands of these shorthands report as well.
  const watchedProps = new Set(COLOR_PROPS);
  for (const prop of COLOR_PROPS) {
    if (prop === 'all') continue;
    const probe = document.createElementNS('http://www.w3.org/1999/xhtml', 'div').style;
    setProperty.call(probe, prop, 'initial');
    for (let i = 0; i < probe.length; i++) watchedProps.add(probe[i]);
  }
  for (const prop of watchedProps) {
    if (!CSS.supports(prop, 'inherit')) continue;
    const camel = prop.replace(/^-webkit-/, 'webkit-').replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    const names = [prop, camel];
    if (prop.startsWith('-webkit-')) names.push(`W${camel.slice(1)}`);
    for (const name of new Set(names)) {
      if (name in decl) continue;
      Object.defineProperty(decl, name, {
        configurable: true,
        get() {
          return getPropertyValue.call(this, prop);
        },
        set(value) {
          setProperty.call(this, prop, value);
          const rule = parentRule.call(this);
          if (rule) edited(rule);
        },
      });
    }
  }

  wrapSetter(window.CSSStyleRule && CSSStyleRule.prototype, 'selectorText', edited);
  for (const name of ['insertRule', 'deleteRule']) wrap(window.CSSGroupingRule && CSSGroupingRule.prototype, name, edited);
  for (const name of ['appendRule', 'deleteRule']) wrap(window.CSSKeyframesRule && CSSKeyframesRule.prototype, name, edited);

  // Open and closed roots alike: the event goes to the host, which the page already
  // has; the root itself is never exposed (the isolated side reaches it via chrome.dom).
  const announceShadow = (host) => {
    queueMicrotask(() => host.dispatchEvent(new Event('omareader:shadow', { bubbles: true, composed: true })));
  };
  wrap(Element.prototype, 'attachShadow', announceShadow);

  // adoptedStyleSheets is an observable array: push() and splice() change it without
  // going through the setter. Each list the page reads gets array methods of its own
  // that report the change as the setter does.
  const LIST_EDITS = ['push', 'pop', 'shift', 'unshift', 'splice', 'fill', 'copyWithin', 'reverse', 'sort'];
  const watchedLists = new WeakSet();
  function watchList(list, report, owner) {
    if (!list || watchedLists.has(list)) return;
    watchedLists.add(list);
    for (const name of LIST_EDITS) {
      const edit = Array.prototype[name];
      try {
        Object.defineProperty(list, name, {
          configurable: true,
          writable: true,
          value: {
            [name](...args) {
              const result = edit.apply(this, args);
              report(owner);
              return result;
            },
          }[name],
        });
      } catch {}
    }
  }
  const watchAdopted = (proto, report) => {
    const desc = proto && Object.getOwnPropertyDescriptor(proto, 'adoptedStyleSheets');
    if (!desc || !desc.get || !desc.set) return;
    Object.defineProperty(proto, 'adoptedStyleSheets', {
      configurable: true,
      enumerable: desc.enumerable,
      get() {
        const list = desc.get.call(this);
        watchList(list, report, this);
        return list;
      },
      set(value) {
        desc.set.call(this, value);
        report(this);
      },
    });
  };
  watchAdopted(Document.prototype, notify);
  watchAdopted(window.ShadowRoot && ShadowRoot.prototype, (root) => announceShadow(root.host));

  // SPA navigations can swap the page background without touching <html>/<body>.
  wrap(History.prototype, 'pushState', notifyNav);
  wrap(History.prototype, 'replaceState', notifyNav);
})();
