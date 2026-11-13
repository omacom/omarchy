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
  // MAX_OPS drops the list ops and falls back to a rescan.
  const MAX_OPS = 256;
  let ops = [];
  let overflow = false;
  const seen = new Set();
  const flushOps = later(() => {
    const list = overflow ? ops.filter((op) => op.t === 'e' || op.k === 'x') : ops;
    ops = [];
    overflow = false;
    seen.clear();
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
    const loc = locate(sheet);
    const op = loc ? { k: loc.k, s: loc.s, t: 'e', i: indexOf.call(sheet.cssRules, top) } : { k: 'x' };
    const key = `${op.k}|${op.s}|${op.i}`;
    if (seen.has(key)) return;
    seen.add(key);
    ops.push(op);
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
    ops.push({ k: loc.k, s: loc.s, t, i });
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
  for (const prop of COLOR_PROPS) {
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
  wrapSetter(Document.prototype, 'adoptedStyleSheets', notify);
  wrapSetter(window.ShadowRoot && ShadowRoot.prototype, 'adoptedStyleSheets', (root) => announceShadow(root.host));

  // SPA navigations can swap the page background without touching <html>/<body>.
  wrap(History.prototype, 'pushState', notifyNav);
  wrap(History.prototype, 'replaceState', notifyNav);
})();
