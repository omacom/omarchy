// Rewrites CSS values and CSSOM rules so every color goes through the mapper.
(function (root) {
  'use strict';
  const C = root.OmareaderColor;

  const ROLES = ['bg', 'text', 'border', 'shadow'];
  const TEXT_PROPS = new Set([
    'color', '-webkit-text-fill-color', '-webkit-text-stroke-color', 'caret-color', 'text-decoration-color',
    'text-emphasis-color', 'fill', 'stroke', 'stop-color', 'flood-color', 'lighting-color', 'accent-color',
  ]);
  // Mirror only the properties we recolor when `all` resets a rule. Re-emitting `all`
  // itself would also reset layout properties supplied by later, unmirrored rules.
  const RESET_PROPS = [
    ...TEXT_PROPS, 'background-color', 'background-image', 'box-shadow', 'text-shadow', 'scrollbar-color',
    'outline-color', 'column-rule-color',
    ...['top', 'right', 'bottom', 'left', 'block-start', 'block-end', 'inline-start', 'inline-end']
      .map((side) => `border-${side}-color`),
  ];
  // Shorthands whose longhands go blank ("pending substitution") when they contain var().
  const VAR_SHORTHANDS = [
    'background', 'border', 'border-top', 'border-right', 'border-bottom', 'border-left', 'border-color',
    'border-block', 'border-inline', 'border-block-start', 'border-block-end', 'border-inline-start',
    'border-inline-end', 'border-block-color', 'border-inline-color', 'outline', 'text-decoration',
    'column-rule', 'text-emphasis', '-webkit-text-stroke',
  ];
  const COLOR_FNS = new Set(['rgb', 'rgba', 'hsl', 'hsla', 'hwb', 'lab', 'lch', 'oklab', 'oklch', 'color']);
  const VAR_KEYWORDS = new Set(['transparent', 'currentcolor', 'inherit', 'initial', 'unset', 'revert', 'revert-layer', 'none']);
  const KEEP = new Set(['transparent', 'currentcolor', 'inherit', 'initial', 'unset', 'revert', 'revert-layer', 'none']);

  function roleOf(prop) {
    if (prop === 'background-color' || prop === 'background-image' || prop === 'background') return 'bg';
    if (TEXT_PROPS.has(prop)) return 'text';
    if (prop === 'box-shadow' || prop === 'text-shadow') return 'shadow';
    if (prop === 'scrollbar-color') return 'scrollbar';
    if (/^(border|outline|column-rule)/.test(prop) && (prop.endsWith('color') || VAR_SHORTHANDS.includes(prop))) return 'border';
    if (prop === 'text-decoration' || prop === 'text-emphasis' || prop === '-webkit-text-stroke') return 'text';
    return null;
  }

  const isIdentStart = (ch) => /[a-zA-Z_\u0080-\uffff]/.test(ch);
  const isIdentChar = (ch) => /[\w\-\u0080-\uffff]/.test(ch);

  function matchParen(v, open) {
    let depth = 0;
    for (let i = open; i < v.length; i++) {
      const ch = v[i];
      if (ch === '"' || ch === "'") {
        i++;
        while (i < v.length && v[i] !== ch) i += v[i] === '\\' ? 2 : 1;
      } else if (ch === '(') depth++;
      else if (ch === ')' && --depth === 0) return i;
    }
    return v.length;
  }

  function splitTopLevelComma(v) {
    let depth = 0;
    for (let i = 0; i < v.length; i++) {
      const ch = v[i];
      if (ch === '(') depth++;
      else if (ch === ')') depth--;
      else if (ch === ',' && depth === 0) return [v.slice(0, i), v.slice(i + 1)];
    }
    return [v, undefined];
  }

  const typedName = (role, name) => `--omareader-${role}--${name.slice(2)}`;

  function absolutize(inner, base) {
    const raw = inner.trim();
    const q = raw[0] === '"' || raw[0] === "'" ? raw[0] : '';
    const url = q ? raw.slice(1, -1) : raw;
    if (!base || !url || url[0] === '#' || /^(data|blob|https?|chrome-extension):/i.test(url)) return `url(${inner})`;
    try {
      return `url("${new URL(url, base).href.replace(/"/g, '%22')}")`;
    } catch {
      return `url(${inner})`;
    }
  }

  function mapColor(c, role, ctx) {
    return C.format(ctx.mapper.map(c, role));
  }

  // rgb(255 255 255 / var(--tw-bg-opacity)): literal channels, dynamic alpha.
  function legacyWithVarAlpha(fn, inner, role, ctx) {
    if (!/^(rgba?|hsla?)$/.test(fn)) return null;
    let parts, alpha;
    const slash = inner.indexOf('/');
    if (slash >= 0) {
      parts = inner.slice(0, slash).trim().split(/[\s,]+/);
      alpha = inner.slice(slash + 1);
    } else {
      const commas = [];
      let rest = inner;
      for (let k = 0; k < 3; k++) {
        const [head, tail] = splitTopLevelComma(rest);
        if (tail === undefined) return null;
        commas.push(head.trim());
        rest = tail;
      }
      parts = commas;
      alpha = rest;
    }
    if (parts.length !== 3 || parts.some((p) => p.includes('('))) return null;
    const c = C.parse(`${fn.replace('a', '')}(${parts.join(' ')})`);
    if (!c) return null;
    const m = ctx.mapper.map(c, role);
    return `rgb(${Math.round(m.r)} ${Math.round(m.g)} ${Math.round(m.b)} / ${transformValue(alpha.trim(), role, ctx)})`;
  }

  function transformFn(name, inner, role, ctx) {
    const fn = name.toLowerCase();
    if (fn === 'url') return absolutize(inner, ctx.base);
    if (fn === 'var') {
      const [first, fallback] = splitTopLevelComma(inner);
      const varName = first.trim();
      if (!varName.startsWith('--') || varName.startsWith('--omareader-')) return `${name}(${inner})`;
      const fb = fallback === undefined ? '' : `,${transformValue(fallback, role, ctx)}`;
      // The original variable is the fallback: it covers non-color variables (widths in a
      // border shorthand) and variables defined somewhere this extension could not read.
      return `var(${typedName(role, varName)}, var(${varName}${fb}))`;
    }
    if (COLOR_FNS.has(fn)) {
      const c = C.parse(`${fn}(${inner})`);
      if (c) return mapColor(c, role, ctx);
      if (inner.includes('var(') && !/\bfrom\b/.test(inner)) {
        const lit = legacyWithVarAlpha(fn, inner, role, ctx);
        if (lit) return lit;
      }
    }
    return `${name}(${transformValue(inner, role, ctx)})`;
  }

  const ZERO_LEN = /^[-+]?0*\.?0+([a-z]+)?$/i;
  const LENGTHISH = /^([-+]?[\d.]|calc\(|min\(|max\(|clamp\()/i;

  // Splits on top-level whitespace, keeping function arguments together.
  function topLevelTokens(v) {
    const out = [];
    let depth = 0, cur = '';
    for (const ch of v) {
      if (ch === '(') depth++;
      else if (ch === ')') depth--;
      if (/\s/.test(ch) && depth === 0) {
        if (cur) out.push(cur);
        cur = '';
      } else cur += ch;
    }
    if (cur) out.push(cur);
    return out;
  }

  // "0 0 0 3px blue" (no blur, real spread) is a ring or a border drawn with box-shadow,
  // not a soft shadow, so it maps like a border.
  function shadowItemRole(item) {
    const lengths = topLevelTokens(item).filter((t) => LENGTHISH.test(t));
    return lengths.length >= 4 && ZERO_LEN.test(lengths[2]) && !ZERO_LEN.test(lengths[3]) ? 'border' : 'shadow';
  }

  function splitTopLevelCommas(v) {
    const out = [];
    let rest = v;
    for (;;) {
      const [head, tail] = splitTopLevelComma(rest);
      out.push(head);
      if (tail === undefined) return out;
      rest = tail;
    }
  }

  function transformValue(v, role, ctx) {
    if (role === 'shadow' && !ctx.inShadowItem) {
      ctx.inShadowItem = true;
      try {
        return splitTopLevelCommas(v)
          .map((item) => transformValue(item, shadowItemRole(item), ctx))
          .join(',');
      } finally {
        ctx.inShadowItem = false;
      }
    }
    if (role === 'scrollbar') {
      const parts = v.trim().split(/\s+(?![^(]*\))/);
      if (parts.length === 2) return `${transformValue(parts[0], 'border', ctx)} ${transformValue(parts[1], 'bg', ctx)}`;
      role = 'border';
    }
    // url() output depends on the sheet's base URL, so those values are not cached.
    const cacheKey = ctx.values && !v.includes('url(') ? role + '\u0000' + v : null;
    const hit = cacheKey ? ctx.values.get(cacheKey) : undefined;
    if (hit !== undefined) return hit;
    let out = '';
    let i = 0;
    const n = v.length;
    while (i < n) {
      const ch = v[i];
      if (ch === '"' || ch === "'") {
        let j = i + 1;
        while (j < n && v[j] !== ch) j += v[j] === '\\' ? 2 : 1;
        out += v.slice(i, j + 1);
        i = j + 1;
        continue;
      }
      if (ch === '#') {
        let j = i + 1;
        while (j < n && /[0-9a-fA-F]/.test(v[j])) j++;
        const len = j - i - 1;
        if ((len === 3 || len === 4 || len === 6 || len === 8) && !(j < n && isIdentChar(v[j]))) {
          out += mapColor(C.hexToRgb(v.slice(i + 1, j)), role, ctx);
          i = j;
          continue;
        }
        out += ch;
        i++;
        continue;
      }
      if (isIdentStart(ch) || (ch === '-' && i + 1 < n && (isIdentStart(v[i + 1]) || v[i + 1] === '-'))) {
        let j = i + 1;
        while (j < n && isIdentChar(v[j])) j++;
        const word = v.slice(i, j);
        if (v[j] === '(') {
          const end = matchParen(v, j);
          out += transformFn(word, v.slice(j + 1, end), role, ctx);
          i = end + 1;
          continue;
        }
        const lw = word.toLowerCase();
        const named = !KEEP.has(lw) && C.NAMED.get(lw);
        out += named ? mapColor({ ...named }, role, ctx) : word;
        i = j;
        continue;
      }
      if (/[\d.]/.test(ch)) {
        let j = i + 1;
        while (j < n && (isIdentChar(v[j]) || v[j] === '.' || v[j] === '%')) j++;
        out += v.slice(i, j);
        i = j;
        continue;
      }
      out += ch;
      i++;
    }
    if (cacheKey) {
      if (ctx.values.size > 50000) ctx.values.clear();
      ctx.values.set(cacheKey, out);
    }
    return out;
  }

  // "255, 255, 255" (rgb channels) or "222.2 84% 4.9%" (hsl channels) as used by
  // Bootstrap's --bs-*-rgb and shadcn/Tailwind's hsl(var(--background)).
  const TRIPLE_RE = /^(-?[\d.]+)(deg)?(\s*,\s*|\s+)([\d.]+%?)(\s*,\s*|\s+)([\d.]+%?)$/;

  function parseTriple(v) {
    const m = TRIPLE_RE.exec(v);
    if (!m) return null;
    const [, a, deg, sep, b, , c] = m;
    if (b.endsWith('%') && c.endsWith('%')) {
      const color = C.parse(`hsl(${a} ${b} ${c})`);
      return color && { kind: 'hsl', color, sep, deg: deg || '' };
    }
    if (b.endsWith('%') || c.endsWith('%') || deg) return null;
    const nums = [a, b, c].map(Number);
    if (nums.some((x) => !(x >= 0 && x <= 255))) return null;
    return { kind: 'rgb', color: { r: nums[0], g: nums[1], b: nums[2], a: 1 }, sep };
  }

  const r1 = (x) => Math.round(x * 10) / 10;

  function formatTriple(t, c) {
    if (t.kind === 'rgb') return [c.r, c.g, c.b].map(Math.round).join(t.sep);
    const hsl = C.rgbToHsl(c);
    return `${r1(hsl.h)}${t.deg}${t.sep}${r1(hsl.s * 100)}%${t.sep}${r1(hsl.l * 100)}%`;
  }

  // [name, value] pairs for --omareader-<role>--name, one per role. Non-colors pass through
  // so redeclarations cannot inherit an ancestor's mapped color.
  function typedVars(name, value, ctx) {
    const raw = value.trim();
    // An empty custom property is a valid redeclaration, not an absent one. Whitespace
    // keeps setProperty() from treating the mapped copy as a request to remove it.
    if (!raw) return ROLES.map((role) => [typedName(role, name), ' ']);
    if (raw.length > 4000) return ROLES.map((role) => [typedName(role, name), `var(${name})`]);
    const triple = parseTriple(raw);
    if (triple) return ROLES.map((role) => [typedName(role, name), formatTriple(triple, ctx.mapper.map(triple.color, role))]);
    // A keyword redeclaration (.ghost { --btn: transparent }) must also shadow the
    // ancestor's typed copies, or the ancestor's mapped color leaks through.
    if (VAR_KEYWORDS.has(raw.toLowerCase())) return ROLES.map((role) => [typedName(role, name), raw]);
    const first = transformValue(raw, ROLES[0], ctx);
    // Non-color values must shadow inherited mapped copies too. They also remain useful
    // unchanged when var() supplies a width or opacity in a color-bearing declaration.
    return ROLES.map((role, i) => [typedName(role, name), i === 0 ? first : transformValue(raw, role, ctx)]);
  }

  function typedVarDecls(name, value, ctx, important) {
    const prio = important ? '!important' : '';
    let out = '';
    for (const [k, v] of typedVars(name, value, ctx)) out += `${k}:${v}${prio};`;
    return out;
  }

  // Every color declaration is re-emitted, even unchanged keywords, so the override sheets
  // cascade among themselves exactly like their sources.
  function coveredBy(shorthands, longhand) {
    return shorthands.some((sh) => {
      const family = sh.split('-')[0] === 'border' ? 'border' : sh.split('-')[0];
      return longhand === sh || longhand.startsWith(`${family}-`) || longhand.startsWith(`${sh}-`);
    });
  }

  // The longhands a shorthand resets, as the browser expands them.
  const longhandSets = new Map();
  function longhandsOf(sh) {
    let set = longhandSets.get(sh);
    if (!set) {
      set = new Set();
      try {
        const sheet = new root.CSSStyleSheet();
        sheet.replaceSync(`a{${sh}:initial}`);
        const style = sheet.cssRules[0].style;
        for (let i = 0; i < style.length; i++) set.add(style[i]);
      } catch {}
      longhandSets.set(sh, set);
    }
    return set;
  }

  function renderDecls(style, ctx, all = false, rule = null) {
    let out = '';
    const pending = [];
    for (let i = 0; i < style.length; i++) {
      if (!style.getPropertyValue(style[i])) pending.push(style[i]);
    }
    if (pending.length) {
      const found = [];
      for (const sh of VAR_SHORTHANDS) {
        const v = style.getPropertyValue(sh);
        if (v && v.includes('var(')) {
          found.push(sh);
          out += `${sh}:${transformValue(v, roleOf(sh), ctx)}${style.getPropertyPriority(sh) ? '!important' : ''};`;
        }
      }
      const emitted = found.slice();
      // background: var(--x) url(a.png); background-size: 10px  -> the CSSOM keeps no text
      // for the shorthand at all, so it is recovered from the sheet's source text.
      if (rule && ctx.rawDecls && pending.some((lh) => roleOf(lh) && !coveredBy(found, lh))) {
        for (const d of ctx.rawDecls(rule)) {
          if (!VAR_SHORTHANDS.includes(d.prop) || found.includes(d.prop) || !d.value.includes('var(')) continue;
          emitted.push(d.prop);
          out += `${d.prop}:${transformValue(d.value, roleOf(d.prop), ctx)}${d.important ? '!important' : ''};`;
        }
      }
      // A re-emitted shorthand resets all its longhands; the rule's own explicit ones
      // (background-size after background) follow it again. Colored ones come below.
      if (emitted.length) {
        const reset = emitted.map(longhandsOf);
        for (let i = 0; i < style.length; i++) {
          const lh = style[i];
          const v = style.getPropertyValue(lh);
          if (!v || roleOf(lh) || !reset.some((set) => set.has(lh))) continue;
          out += `${lh}:${v}${style.getPropertyPriority(lh) ? '!important' : ''};`;
        }
      }
    }
    for (let i = 0; i < style.length; i++) {
      const prop = style[i];
      const v = style.getPropertyValue(prop);
      if (!v && !prop.startsWith('--')) continue;
      const important = style.getPropertyPriority(prop) === 'important';
      if (prop === 'all' && !all) {
        for (const p of RESET_PROPS) out += `${p}:${v}${important ? '!important' : ''};`;
        continue;
      }
      if (prop.startsWith('--')) {
        if (prop.startsWith('--omareader-')) continue;
        if (all) out += `${prop}:${v}${important ? '!important' : ''};`;
        out += typedVarDecls(prop, v, ctx, important);
        continue;
      }
      const role = roleOf(prop);
      if (!role) {
        if (all) out += `${prop}:${v}${important ? '!important' : ''};`;
        continue;
      }
      out += `${prop}:${transformValue(v, role, ctx)}${important ? '!important' : ''};`;
    }
    return out;
  }

  function prelude(rule) {
    const text = rule.cssText;
    const brace = text.indexOf('{');
    return brace > 0 ? text.slice(0, brace).trim() : null;
  }

  // Each source rule renders to at most one top-level rule, so an override sheet can be
  // kept index-aligned with its source and patched rule by rule.
  function renderRule(rule, ctx) {
    const cached = ctx.rules.get(rule);
    if (cached !== undefined) return cached;
    const W = root;
    let out = '';
    let cacheable = true;
    if (W.CSSStyleRule && rule instanceof W.CSSStyleRule) {
      const decls = renderDecls(rule.style, ctx, false, rule);
      const nested = rule.cssRules && rule.cssRules.length ? renderRules(rule.cssRules, ctx) : '';
      if (nested) cacheable = false;
      if (decls || nested) out = `${rule.selectorText}{${decls}${nested}}`;
    } else if (W.CSSNestedDeclarations && rule instanceof W.CSSNestedDeclarations) {
      out = renderDecls(rule.style, ctx);
    } else if (W.CSSImportRule && rule instanceof W.CSSImportRule) {
      cacheable = false;
      const layer = rule.layerName;
      let inner = '';
      // `@import … layer` is an anonymous layer: see CSSLayerBlockRule below.
      if (layer === '') {
        if (ctx.onAnonLayer) ctx.onAnonLayer(rule);
      } else if (rule.styleSheet) inner = ctx.renderImport(rule.styleSheet, rule.href);
      if (inner) {
        if (layer) inner = `@layer ${layer}{${inner}}`;
        const supports = rule.supportsText;
        if (inner && supports) inner = `@supports (${supports}){${inner}}`;
        const media = (rule.media && rule.media.mediaText) || 'all';
        if (inner) out = `@media ${media}{${inner}}`;
      }
    } else if (W.CSSKeyframesRule && rule instanceof W.CSSKeyframesRule) {
      // Always mirrored, colored or not: a later same-name @keyframes must keep winning.
      let body = '';
      for (const kf of rule.cssRules) body += `${kf.keyText}{${renderDecls(kf.style, ctx, true)}}`;
      out = `@keyframes ${CSS.escape(rule.name)}{${body}}`;
    } else if (W.CSSPropertyRule && rule instanceof W.CSSPropertyRule) {
      if (ctx.onProperty) ctx.onProperty(rule);
    } else if (W.CSSMediaRule && rule instanceof W.CSSMediaRule) {
      cacheable = false;
      const inner = renderRules(rule.cssRules, ctx);
      if (inner) out = `@media ${rule.media.mediaText}{${inner}}`;
    } else if (W.CSSSupportsRule && rule instanceof W.CSSSupportsRule) {
      cacheable = false;
      const inner = renderRules(rule.cssRules, ctx);
      if (inner) out = `@supports ${rule.conditionText}{${inner}}`;
    } else if (W.CSSLayerBlockRule && rule instanceof W.CSSLayerBlockRule) {
      // Anonymous layers cannot be re-entered (a copy would become a new, later layer),
      // so the owner rewrites them in place.
      cacheable = false;
      if (!rule.name) {
        if (ctx.onAnonLayer) ctx.onAnonLayer(rule);
      } else {
        const inner = renderRules(rule.cssRules, ctx);
        if (inner) out = `@layer ${rule.name}{${inner}}`;
      }
    } else if (W.CSSNamespaceRule && rule instanceof W.CSSNamespaceRule) {
      out = rule.cssText;
    } else if (rule.cssRules && W.CSSGroupingRule && rule instanceof W.CSSGroupingRule) {
      // @container, @scope, @starting-style, @document ...
      cacheable = false;
      const inner = renderRules(rule.cssRules, ctx);
      const head = inner && prelude(rule);
      if (head) out = `${head}{${inner}}`;
    }
    if (cacheable) ctx.rules.set(rule, out);
    return out;
  }

  // Typed copies of a registered custom property get the same inheritance and a mapped
  // initial value (inherits:false must not let a parent's copy leak into children).
  function propertyRules(rule, ctx) {
    const syntax = (rule.syntax || '*').trim();
    const universal = syntax === '*' || syntax === '"*"' || syntax === "'*'";
    if (!universal && !syntax.includes('<color>')) return '';
    const init = rule.initialValue;
    let out = '';
    for (const role of ROLES) {
      let value = null;
      if (init !== null && init !== undefined && init !== '') {
        const tv = typedVars(rule.name, init, ctx).find(([k]) => k === typedName(role, rule.name));
        value = tv ? tv[1] : init;
      }
      if (!universal && value === null) continue;
      out += `@property ${typedName(role, rule.name)}{syntax:${universal ? "'*'" : JSON.stringify(syntax)};inherits:${rule.inherits ? 'true' : 'false'};${value !== null ? `initial-value:${value};` : ''}}`;
    }
    return out;
  }

  // Minimal source-text scan: selector -> declarations, used only to recover var()
  // shorthands the CSSOM drops. Nested rules inside style rules are skipped.
  function scanRawDecls(text) {
    const res = [];
    const src = text.replace(/\/\*[\s\S]*?\*\//g, '');
    let i = 0;
    function block(end) {
      while (i < end) {
        const open = findTop(src, i, end, '{', ';');
        if (open < 0) return;
        const head = src.slice(i, open).trim();
        if (src[open] === ';') { i = open + 1; continue; }
        const close = matchBrace(src, open);
        if (head.startsWith('@')) {
          if (/^@(media|supports|layer|container|scope|document|-moz-document|starting-style)\b/i.test(head)) {
            i = open + 1;
            block(close);
          }
        } else if (head) {
          const body = src.slice(open + 1, close);
          const decls = [];
          for (const part of splitDecls(body)) {
            const colon = part.indexOf(':');
            if (colon < 0) continue;
            let value = part.slice(colon + 1).trim();
            const important = /!\s*important\s*$/i.test(value);
            if (important) value = value.replace(/!\s*important\s*$/i, '').trim();
            decls.push({ prop: part.slice(0, colon).trim().toLowerCase(), value, important });
          }
          res.push({ selector: head, decls });
        }
        i = close + 1;
      }
    }
    block(src.length);
    return res;
  }

  function findTop(src, from, end, a, b) {
    let depth = 0;
    for (let j = from; j < end; j++) {
      const ch = src[j];
      if (ch === '"' || ch === "'") {
        j++;
        while (j < end && src[j] !== ch) j += src[j] === '\\' ? 2 : 1;
      } else if (ch === '(') depth++;
      else if (ch === ')') depth--;
      else if (depth === 0 && (ch === a || ch === b)) return j;
    }
    return -1;
  }

  function matchBrace(src, open) {
    let depth = 0;
    for (let j = open; j < src.length; j++) {
      const ch = src[j];
      if (ch === '"' || ch === "'") {
        j++;
        while (j < src.length && src[j] !== ch) j += src[j] === '\\' ? 2 : 1;
      } else if (ch === '{') depth++;
      else if (ch === '}' && --depth === 0) return j;
    }
    return src.length;
  }

  function splitDecls(body) {
    const parts = [];
    let depth = 0, brace = 0, cur = '';
    for (let j = 0; j < body.length; j++) {
      const ch = body[j];
      if (ch === '"' || ch === "'") {
        let k = j + 1;
        while (k < body.length && body[k] !== ch) k += body[k] === '\\' ? 2 : 1;
        cur += body.slice(j, k + 1);
        j = k;
        continue;
      }
      if (ch === '(') depth++;
      else if (ch === ')') depth--;
      else if (ch === '{') brace++;
      else if (ch === '}') { brace--; if (!brace) cur = ''; continue; }
      if (ch === ';' && depth === 0 && brace === 0) {
        parts.push(cur);
        cur = '';
      } else if (!brace) cur += ch;
    }
    if (cur.trim()) parts.push(cur);
    return parts;
  }

  function renderRules(rules, ctx) {
    let out = '';
    for (let i = 0; i < rules.length; i++) out += renderRule(rules[i], ctx);
    return out;
  }

  root.OmareaderTransform = {
    ROLES,
    VAR_SHORTHANDS,
    roleOf,
    transformValue,
    typedName,
    typedVars,
    typedVarDecls,
    parseTriple,
    renderDecls,
    renderRule,
    renderRules,
    propertyRules,
    scanRawDecls,
  };
})(globalThis);
