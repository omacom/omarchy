const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

for (const f of ['color.js', 'theme.js', 'transform.js', 'net.js']) require(path.join(__dirname, '../../../default/chromium/extensions/omareader/src', f));
const C = globalThis.OmareaderColor;
const T = globalThis.OmareaderTheme;
const X = globalThis.OmareaderTransform;

// Run the cache's real lifecycle code with CSSOM-shaped sources. No DOM paint
// stubs are involved: these checks concern which fetched resources stay owned.
function remoteCacheHarness() {
  const fs = require('node:fs');
  const vm = require('node:vm');
  const source = fs.readFileSync(path.join(__dirname, '../../../default/chromium/extensions/omareader/src/content.js'), 'utf8');
  const names = ['readRules', 'splitImports', 'fetchRemote', 'pruneRemote'];
  const functions = names.map((name) => {
    const match = source.match(new RegExp(`  (?:async )?function ${name}\\([^]*?\\n  \\}`));
    assert.ok(match, `${name} is available for the cache lifecycle check`);
    return match[0];
  });
  class CSSImportRule {
    constructor(styleSheet) { this.styleSheet = styleSheet; this.href = styleSheet.href; }
  }
  class CSSLayerStatementRule {}
  class CSSStyleSheet {
    replaceSync(text) { this.text = text; this.cssRules = []; }
  }
  const doc = { styleSheets: [], adoptedStyleSheets: [] };
  const context = vm.createContext({
    doc, scopes: new Map([[doc, {}]]), remote: new Map(), remoteText: new WeakMap(),
    CSSImportRule, CSSLayerStatementRule, CSSStyleSheet, URL,
    isOurs: (sheet) => !!sheet.ours,
    running: true, remoteVersion: 0, scans: 0,
    scheduleScan() { context.scans++; },
    // Also let the old budget-only implementation run: small leaks must be freed too.
    remoteBytes: 0, REMOTE_BUDGET: 16 * 1024 * 1024, REMOTE_IDLE_MS: 60000,
    performance: { now: () => 0 },
    chrome: { runtime: {} },
  });
  vm.runInContext(functions.join('\n') + '\nObject.assign(globalThis, { fetchRemote, pruneRemote });', context);
  context.crossOrigin = (href) => ({ href, get cssRules() { throw new Error('SecurityError'); } });
  return context;
}

test('remote sheets are released when no live document, import or shadow root uses them', () => {
  const c = remoteCacheHarness();
  const main = c.crossOrigin('https://cdn.test/main.css');
  const shared = c.crossOrigin('https://cdn.test/shared.css');
  const pending = c.crossOrigin('https://cdn.test/pending.css');
  const shadow = { host: { isConnected: true }, styleSheets: [shared], adoptedStyleSheets: [] };
  c.scopes.set(shadow, {});
  c.doc.styleSheets = [main];
  c.doc.adoptedStyleSheets = [{ cssRules: [new c.CSSLayerStatementRule(), new c.CSSImportRule(pending)] }];
  c.remote.set(main.href, { state: 'done', imports: [{ url: shared.href }, { url: main.href }] });
  c.remote.set(shared.href, { state: 'done', imports: [] });
  c.remote.set(pending.href, { state: 'pending' });
  for (const state of ['done', 'pending', 'failed']) c.remote.set(`https://cdn.test/removed-${state}.css`, { state, imports: [] });
  c.pruneRemote();
  assert.deepEqual([...c.remote.keys()].sort(), [main.href, shared.href, pending.href].sort());
  c.doc.styleSheets = [];
  c.doc.adoptedStyleSheets = [];
  c.pruneRemote();
  assert.deepEqual([...c.remote.keys()], [shared.href], 'a shared sheet survives while a connected shadow root uses it');
  shadow.host.isConnected = false;
  c.pruneRemote();
  assert.equal(c.remote.size, 0, 'detached shadow roots do not keep fetched sheets alive');
});

test('late stylesheet fetches cannot restore removed entries or replace a newer fetch', async () => {
  const c = remoteCacheHarness();
  const href = 'https://cdn.test/slow.css';
  c.doc.styleSheets = [c.crossOrigin(href)];
  for (const fail of [false, true]) {
    let resolve, reject;
    c.chrome.runtime.sendMessage = () => new Promise((yes, no) => { resolve = yes; reject = no; });
    const pending = { state: 'pending' };
    c.remote.set(href, pending);
    const fetch = c.fetchRemote(href, pending);
    c.remote.delete(href);
    const replacement = { state: 'pending' };
    c.remote.set(href, replacement);
    if (fail) reject(new Error('old request failed'));
    else resolve({ ok: true, text: 'body{color:white}' });
    await fetch;
    assert.equal(c.remote.get(href), replacement, 'an obsolete response leaves the replacement request alone');
  }
  assert.equal(c.scans, 0, 'obsolete requests do not trigger renders');
  c.chrome.runtime.sendMessage = async () => ({ ok: true, text: 'body{color:white}' });
  const pending = c.remote.get(href);
  await c.fetchRemote(href, pending);
  assert.equal(c.remote.get(href).state, 'done', 'a current request still populates the cache');
  assert.equal(c.scans, 1);
});

// Every theme Omarchy ships, read by the native host itself so the tests see what the
// extension gets. An empty HOME keeps the user's own themes out.
function shippedThemes() {
  const { execFileSync } = require('node:child_process');
  const fs = require('node:fs');
  const os = require('node:os');
  const root = path.join(__dirname, '../../..');
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'omareader-test-'));
  try {
    const out = execFileSync(path.join(root, 'bin/omarchy-chromium-omareader-host'), ['--dump'], {
      env: { ...process.env, HOME: home, OMARCHY_PATH: root },
    });
    const themes = JSON.parse(out).themes;
    const dirs = fs.readdirSync(path.join(root, 'themes')).filter((d) => fs.existsSync(path.join(root, 'themes', d, 'colors.toml')));
    assert.deepEqual(Object.keys(themes).sort(), dirs.sort(), 'the host reads every shipped theme');
    return themes;
  } finally {
    fs.rmSync(home, { recursive: true, force: true });
  }
}

const LIFTOFF = {
  mode: 'dark', accent: '#F3B77B', selection: '#334D5D', muted: '#88979F', background: '#151E26',
  dark_background: '#10171E', darker_background: '#0B1117', lighter_background: '#253440',
  foreground: '#ECE5D8', dark_foreground: '#A2ACAE', red: '#EF8D80', yellow: '#EAD093', orange: '#F3B77B',
  green: '#A9C59A', cyan: '#8BC8D0', blue: '#7BBCE0', magenta: '#C3ABCC', bright_red: '#FFABA0',
};
const ANSI = {
  background: '#1a1b26', foreground: '#c0caf5', color0: '#15161e', color1: '#f7768e', color2: '#9ece6a',
  color3: '#e0af68', color4: '#7aa2f7', color5: '#bb9af7', color6: '#7dcfff', color7: '#a9b1d6',
  color9: '#ff7a93', color12: '#7da6ff',
};
const LATTE = {
  background: '#eff1f5', foreground: '#4c4f69', color1: '#d20f39', color2: '#40a02b', color3: '#df8e1d',
  color4: '#1e66f5', color5: '#8839ef', color6: '#179299', accent: '#1e66f5',
};

const hex = (c) => C.format(c);
const near = (a, b, tol = 3) => {
  const x = C.parse(a), y = C.parse(b);
  return Math.abs(x.r - y.r) <= tol && Math.abs(x.g - y.g) <= tol && Math.abs(x.b - y.b) <= tol;
};

test('scrollbar thumbs remain visible on dark and light tracks', () => {
  for (const raw of [LIFTOFF, ANSI, LATTE, T.DARK]) {
    const p = T.normalize(raw);
    const m = T.createMapper(p);
    assert.ok(C.contrast(C.parse(m.swatch.thumb), C.parse(p.bg)) >= 2.95,
      `${p.bg}: thumb ${m.swatch.thumb} needs 3:1 contrast`);
  }
});

test('parses the CSS color syntaxes Chrome serializes', () => {
  assert.deepEqual(C.parse('#fff'), { r: 255, g: 255, b: 255, a: 1 });
  assert.deepEqual(C.parse('rgb(10, 20, 30)'), { r: 10, g: 20, b: 30, a: 1 });
  assert.deepEqual(C.parse('rgba(10, 20, 30, 0.5)'), { r: 10, g: 20, b: 30, a: 0.5 });
  assert.deepEqual(C.parse('rgb(10 20 30 / 50%)'), { r: 10, g: 20, b: 30, a: 0.5 });
  assert.equal(hex(C.parse('hsl(0 100% 50%)')), '#ff0000');
  assert.equal(hex(C.parse('hsl(120deg, 100%, 25%)')), '#008000');
  assert.equal(hex(C.parse('rebeccapurple')), '#663399');
  assert.ok(near(hex(C.parse('oklch(0.628 0.2577 29.23)')), '#ff0000'));
  assert.ok(near(hex(C.parse('oklab(1 0 0)')), '#ffffff'));
  assert.ok(near(hex(C.parse('lab(54.29 80.8 69.89)')), '#ff0000', 4));
  assert.ok(near(hex(C.parse('color(srgb 0 0.5 1)')), '#0080ff'));
  assert.equal(C.parse('rgb(var(--x))'), null);
  assert.equal(C.parse('notacolor'), null);
});

test('oklab round-trips', () => {
  for (const h of ['#000000', '#ffffff', '#7aa2f7', '#f7768e', '#151e26']) {
    assert.equal(hex(C.fromOklab(C.toOklab(C.parse(h)))), h);
  }
});

test('normalizes both colors.toml layouts', () => {
  const a = T.normalize(LIFTOFF);
  assert.equal(a.bg, '#151e26');
  assert.equal(a.blue, '#7bbce0');
  assert.equal(a.mode, 'dark');
  const b = T.normalize(ANSI);
  assert.equal(b.red, '#f7768e');
  assert.equal(b.bright_red, '#ff7a93');
  assert.equal(b.accent, '#7aa2f7');
  assert.equal(b.mode, 'dark');
  assert.equal(T.normalize(LATTE).mode, 'light');
  assert.equal(T.normalize(null).bg, '#1a1b26');
});

test('light pages: white surfaces become the palette background, black text the foreground', () => {
  const m = T.createMapper(T.normalize(LIFTOFF));
  assert.equal(hex(m.map(C.parse('#ffffff'), 'bg')), '#151e26');
  assert.equal(hex(m.map(C.parse('#000000'), 'text')), '#ece5d8');
  const panel = C.toOklab(m.map(C.parse('#f6f8fa'), 'bg')).L;
  assert.ok(panel > C.toOklab(C.parse('#151e26')).L, 'light grey panel sits slightly above bg');
  const secondary = C.contrast(m.map(C.parse('#666666'), 'text'), C.parse('#151e26'));
  assert.ok(secondary > 4.5, `secondary text stays readable (${secondary.toFixed(2)})`);
});

test('dark pages keep their layering direction', () => {
  const m = T.createMapper(T.normalize(LIFTOFF), { siteL: C.toOklab(C.parse('#0d1117')).L });
  assert.ok(near(hex(m.map(C.parse('#0d1117'), 'bg')), '#151e26', 2));
  const card = C.toOklab(m.map(C.parse('#161b22'), 'bg')).L;
  assert.ok(card > C.toOklab(C.parse('#151e26')).L);
  assert.equal(hex(m.map(C.parse('#ffffff'), 'text')), '#ece5d8');
});

test('saturated colors snap to the nearest palette hue', () => {
  const m = T.createMapper(T.normalize(LIFTOFF));
  assert.equal(hex(m.map(C.parse('#0969da'), 'text')), '#7bbce0'); // link blue -> palette blue
  assert.equal(hex(m.map(C.parse('#cf222e'), 'text')), '#ef8d80'); // error red -> palette red
  assert.equal(hex(m.map(C.parse('#1a7f37'), 'text')), '#a9c59a'); // success green -> palette green
  const btn = m.map(C.parse('#1f883d'), 'bg');
  const lab = C.toOklab(btn);
  assert.ok(Math.hypot(lab.a, lab.b) > 0.03, 'green button keeps a green tint');
  assert.ok(C.contrast(btn, C.parse('#ece5d8')) > 3, 'foreground text stays readable on it');
});

test('light Omarchy themes keep white pages light', () => {
  const m = T.createMapper(T.normalize(LATTE));
  assert.equal(hex(m.map(C.parse('#ffffff'), 'bg')), '#eff1f5');
  assert.equal(hex(m.map(C.parse('#000000'), 'text')), '#4c4f69');
  assert.equal(m.mode, 'light');
});

test('alpha is preserved and shadows stay dark', () => {
  const m = T.createMapper(T.normalize(LIFTOFF));
  const veil = m.map(C.parse('rgba(0,0,0,0.5)'), 'bg');
  assert.equal(veil.a, 0.5);
  const shadow = m.map(C.parse('rgba(255,255,255,0.8)'), 'shadow');
  assert.ok(C.toOklab(shadow).L < 0.25);
  const hover = m.map(C.parse('rgba(0,0,0,0.05)'), 'bg');
  assert.ok(C.toOklab(hover).L > 0.8, 'faint black hover tint on a light page lightens on dark');
});

function ctx(palette = LIFTOFF) {
  return { mapper: T.createMapper(T.normalize(palette)), values: new Map(), base: 'https://example.com/css/site.css' };
}

test('transformValue rewrites colors inside arbitrary values', () => {
  const c = ctx();
  assert.equal(X.transformValue('#fff', 'bg', c), '#151e26');
  assert.equal(X.transformValue('white', 'bg', c), '#151e26');
  assert.equal(X.transformValue('1px solid transparent', 'border', c), '1px solid transparent');
  assert.equal(X.transformValue('currentColor', 'text', c), 'currentColor');
  assert.match(X.transformValue('linear-gradient(to right, #fff 0%, rgb(240, 240, 240) 100%)', 'bg', c), /^linear-gradient\(to right, #[0-9a-f]{6} 0%, #[0-9a-f]{6} 100%\)$/);
  assert.equal(X.transformValue('0 1px 2px rgba(0, 0, 0, 0.2)', 'shadow', c).startsWith('0 1px 2px rgba('), true);
  assert.equal(X.transformValue('url(img/a.png) no-repeat', 'bg', c), 'url("https://example.com/css/img/a.png") no-repeat');
  assert.equal(X.transformValue('url("data:image/svg+xml;utf8,<svg fill=\'red\'/>")', 'bg', c), 'url("data:image/svg+xml;utf8,<svg fill=\'red\'/>")');
  assert.equal(X.transformValue('"white"', 'text', c), '"white"');
  assert.equal(X.transformValue('#abcdeg', 'text', c), '#abcdeg');
});

test('variables are renamed per role with the original as fallback', () => {
  const c = ctx();
  assert.equal(X.transformValue('var(--bg)', 'bg', c), 'var(--omareader-bg--bg, var(--bg))');
  assert.equal(X.transformValue('var(--fg, #000)', 'text', c), 'var(--omareader-text--fg, var(--fg, #ece5d8))');
  assert.equal(X.transformValue('hsl(var(--background))', 'bg', c), 'hsl(var(--omareader-bg--background, var(--background)))');
  assert.equal(
    X.transformValue('rgb(255 255 255 / var(--tw-bg-opacity))', 'bg', c),
    'rgb(21 30 38 / var(--omareader-bg--tw-bg-opacity, var(--tw-bg-opacity)))',
  );
  assert.equal(
    X.transformValue('rgba(255,255,255,var(--a))', 'bg', c),
    'rgb(21 30 38 / var(--omareader-bg--a, var(--a)))',
  );
  assert.match(X.transformValue('color-mix(in srgb, white 50%, var(--x))', 'bg', c), /^color-mix\(in srgb, #151e26 50%, var\(--omareader-bg--x, var\(--x\)\)\)$/);
});

test('picture samples average by alpha and report how much is opaque', () => {
  // two opaque white pixels, one transparent red, one half-transparent black
  const s = C.sampleStats(new Uint8ClampedArray([255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 128]), 40, 20);
  assert.equal(s.width, 40);
  assert.ok(Math.abs(s.cover - (2 + 128 / 255) / 4) < 1e-9);
  assert.ok(s.color.r > 200 && s.color.r === s.color.g && s.color.g === s.color.b, 'red pixel is invisible, black is half weight');
  assert.equal(C.sampleStats(new Uint8ClampedArray(8), 1, 1).color, null);
});

test('channel-triple fallbacks inside rgb()/hsl() map like the color they render', () => {
  const c = ctx();
  // Google Docs' disabled menu text: the -rgb variable is undefined, so 31,31,31 renders.
  const m = c.mapper.map(C.parse('rgb(31,31,31)'), 'text');
  assert.equal(
    X.transformValue('rgba(var(--on-rgb,31,31,31),.38)', 'text', c),
    `rgba(var(--omareader-text--on-rgb, var(--on-rgb,${[m.r, m.g, m.b].map(Math.round).join(',')})),.38)`,
  );
  assert.ok(C.toOklab(m).L > 0.8);
  const light = X.transformValue('rgb(var(--a, var(--b, 31 31 31)) / .5)', 'text', c).match(/var\(--b,(\d+) (\d+) (\d+)\)/);
  assert.ok(light && C.toOklab({ r: +light[1], g: +light[2], b: +light[3], a: 1 }).L > 0.8, 'nested chain fallback maps');
  assert.match(X.transformValue('hsl(var(--bg, 0 0% 100%))', 'bg', c), /var\(--bg,[\d.]+ [\d.]+% [\d.]+%\)\)\)$/);
  assert.ok(!/100%\)\)\)$/.test(X.transformValue('hsl(var(--bg, 0 0% 100%))', 'bg', c)), 'white hsl fallback darkens');
  // Bare numbers are HSL inside hsl(), so the mapped fallback must still read as HSL.
  const green = X.transformValue('hsl(var(--g, 120 100 50))', 'text', c).match(/var\(--g,([\d.]+) ([\d.]+)% ([\d.]+)%\)\)\)$/);
  assert.ok(green, 'numeric hsl fallback stays an hsl triple');
  const got = C.parse(`hsl(${green[1]} ${green[2]}% ${green[3]}%)`);
  const want = c.mapper.map(C.parse('hsl(120 100% 50%)'), 'text');
  assert.ok(['r', 'g', 'b'].every((k) => Math.abs(got[k] - want[k]) < 1.5), `${hex(got)} vs ${hex(want)}`);
  // Outside a channel position the same text is not a color.
  assert.equal(X.transformValue('var(--pad, 1 2 3)', 'text', c), 'var(--omareader-text--pad, var(--pad, 1 2 3))');
  assert.equal(X.transformValue('rgb(calc(var(--n, 1 2 3)) 0 0)', 'text', c).includes('var(--n, 1 2 3)'), true);
});

test('typed custom properties cover full colors, rgb triples and hsl triples', () => {
  const c = ctx();
  const plain = Object.fromEntries(X.typedVars('--surface', '#ffffff', c));
  assert.equal(plain['--omareader-bg--surface'], '#151e26');
  assert.equal(plain['--omareader-text--surface'], '#ece5d8');
  const rgb = Object.fromEntries(X.typedVars('--bs-body-bg-rgb', '255, 255, 255', c));
  assert.equal(rgb['--omareader-bg--bs-body-bg-rgb'], '21, 30, 38');
  const hsl = Object.fromEntries(X.typedVars('--background', '0 0% 100%', c));
  assert.match(hsl['--omareader-bg--background'], /^[\d.]+ [\d.]+% [\d.]+%$/);
  assert.equal(hex(C.parse(`hsl(${hsl['--omareader-bg--background']})`)), '#151e26');
  assert.equal(Object.fromEntries(X.typedVars('--radius', '4px', c))['--omareader-bg--radius'], '4px');
  const alias = Object.fromEntries(X.typedVars('--link', 'var(--blue)', c));
  assert.equal(alias['--omareader-text--link'], 'var(--omareader-text--blue, var(--blue))');
});

test('roles', () => {
  assert.equal(X.roleOf('background-color'), 'bg');
  assert.equal(X.roleOf('border-top-color'), 'border');
  assert.equal(X.roleOf('border-inline-start-color'), 'border');
  assert.equal(X.roleOf('outline-color'), 'border');
  assert.equal(X.roleOf('fill'), 'text');
  assert.equal(X.roleOf('box-shadow'), 'shadow');
  assert.equal(X.roleOf('border-radius'), null);
  assert.equal(X.roleOf('width'), null);
});

test('every installed Omarchy theme yields a readable mapping', () => {
  for (const [name, raw] of Object.entries(shippedThemes())) {
    const p = T.normalize(raw);
    const m = T.createMapper(p);
    const bg = m.map(C.parse('#ffffff'), 'bg');
    const fg = m.map(C.parse('#24292f'), 'text');
    const link = m.map(C.parse('#0969da'), 'text');
    assert.ok(C.contrast(bg, fg) > 3, `${name}: body text contrast ${C.contrast(bg, fg).toFixed(2)}`);
    assert.ok(C.contrast(bg, link) > 1.8, `${name}: link contrast ${C.contrast(bg, link).toFixed(2)}`);
  }
});

test('legacy HTML color parsing', () => {
  assert.equal(hex(C.parseLegacy('FFFFCC')), '#ffffcc');
  assert.equal(hex(C.parseLegacy('#fff')), '#ffffff');
  assert.equal(hex(C.parseLegacy('chucknorris')), '#c00000');
  assert.equal(hex(C.parseLegacy('red')), '#ff0000');
  assert.equal(C.parseLegacy('transparent'), null);
  assert.equal(C.parseLegacy(''), null);
});

test('ring shadows map as borders, soft shadows stay dark', () => {
  const c = ctx();
  const ring = C.parse(X.transformValue('0 0 0 3px #0969da', 'shadow', c).match(/#[0-9a-f]{6}/)[0]);
  assert.ok(C.contrast(ring, C.parse('#151e26')) >= 2.9, 'focus ring keeps 3:1');
  const soft = X.transformValue('0 1px 3px rgba(0, 0, 0, 0.2)', 'shadow', c);
  assert.ok(C.toOklab(C.parse(soft.match(/rgba\([^)]*\)/)[0])).L < 0.25);
  assert.match(X.transformValue('0 1px 2px #000, 0 0 0 1px #d0d7de', 'shadow', c), /^0 1px 2px #[0-9a-f]{6},\s?0 0 0 1px #[0-9a-f]{6}$/);
});

test('keyword redeclarations produce typed copies', () => {
  const c = ctx();
  assert.deepEqual(Object.fromEntries(X.typedVars('--btnbg', 'transparent', c)), {
    '--omareader-bg--btnbg': 'transparent', '--omareader-text--btnbg': 'transparent',
    '--omareader-border--btnbg': 'transparent', '--omareader-shadow--btnbg': 'transparent',
  });
});

test('@property typed copies mirror inheritance and map initial values', () => {
  const c = ctx();
  const css = X.propertyRules({ name: '--pc', syntax: '<color>', inherits: false, initialValue: '#ffffff' }, c);
  assert.match(css, /@property --omareader-text--pc\{syntax:"<color>";inherits:false;initial-value:#ece5d8;\}/);
  assert.equal(X.propertyRules({ name: '--w', syntax: '<length>', inherits: true, initialValue: '1px' }, c), '');
});

test('raw declaration scan recovers var() shorthands', () => {
  const r = X.scanRawDecls('/* x */ .hero { background: var(--h) url("a;b.png") no-repeat; background-size: 10px } @media (x) { .a { border: var(--w) solid var(--c) !important } }');
  assert.equal(r[0].selector, '.hero');
  assert.deepEqual(r[0].decls[0], { prop: 'background', value: 'var(--h) url("a;b.png") no-repeat', important: false });
  assert.deepEqual(r[1].decls[0], { prop: 'border', value: 'var(--w) solid var(--c)', important: true });
});

test('text keeps its contrast class on every installed theme', () => {
  for (const [name, raw] of Object.entries(shippedThemes())) {
    const p = T.normalize(raw);
    const m = T.createMapper(p);
    const bg = C.parse(p.bg);
    const cap = Math.min(4.5, Math.max(3, C.contrast(C.parse(p.fg), bg))) - 0.05;
    for (const src of ['#24292f', '#9a6700', '#d1242f', '#0969da', '#1a7f37']) {
      const got = C.contrast(m.map(C.parse(src), 'text'), bg);
      assert.ok(got >= cap, `${name}: ${src} -> ${got.toFixed(2)} < ${cap.toFixed(2)}`);
    }
    const err = C.toOklab(m.map(C.parse('#d1242f'), 'text'));
    const link = C.toOklab(m.map(C.parse('#0969da'), 'text'));
    assert.ok(Math.hypot(err.L - link.L, err.a - link.a, err.b - link.b) > 0.03, `${name}: error and link collapse`);
  }
});

test('private-network classification covers canonical bypass forms', () => {
  const N = globalThis.OmareaderNet;
  const host = (u) => new URL(u).hostname;
  for (const u of [
    'http://localhost/', 'http://127.0.0.1/', 'http://2130706433/', 'http://0x7f.1/', 'http://127.0.0.1./',
    'http://0.0.0.0/', 'http://10.1.2.3/', 'http://192.168.0.1/', 'http://172.20.0.1/', 'http://169.254.169.254/',
    'http://100.64.0.1/', 'http://[::1]/', 'http://[::]/', 'http://[::ffff:127.0.0.1]/', 'http://[::ffff:7f00:1]/',
    'http://[::ffff:a9fe:a9fe]/', 'http://[::ffff:c0a8:1]/', 'http://[::127.0.0.1]/', 'http://[64:ff9b::7f00:1]/',
    'http://[2002:7f00:1::]/', 'http://[fd00::1]/', 'http://[fe80::1]/', 'http://printer.local./',
    'http://nas.lan/', 'http://intranet/', 'http://router.home.arpa/',
  ]) assert.ok(N.isPrivateHost(host(u)), `${u} (${host(u)}) should be private`);
  for (const u of ['https://cdn.jsdelivr.net/x.css', 'http://8.8.8.8/', 'http://[2606:4700::1111]/', 'https://example.com./a'])
    assert.ok(!N.isPrivateHost(host(u)), `${u} should be public`);
  // Only a sender whose own host is private may reach private hosts; a sandboxed frame's
  // opaque origin must not unlock them.
  assert.ok(N.isPrivateOrigin('http://192.168.1.1'));
  for (const o of ['null', '', 'data:text/html,x', 'file:///tmp/x.html', 'https://example.com'])
    assert.ok(!N.isPrivateOrigin(o), `${o || '(empty)'} should not count as a private origin`);
});

test('per-site modes override the default', () => {
  // A fresh install, or stored settings it cannot read, leaves pages alone.
  assert.deepEqual(T.normalizeSettings(undefined), { mode: 'normal', sites: {} });
  const s = T.normalizeSettings({ mode: 'normal', theme: 'old', sites: { 'www.x.com': 'normal', 'YouTube.com': 'dark', 'a.com': 'bogus' } });
  assert.deepEqual(s, { mode: 'normal', sites: { 'x.com': 'normal', 'youtube.com': 'dark' } });
  assert.equal(T.siteModeOf(s, 'www.youtube.com'), 'dark');
  assert.equal(T.siteModeOf(s, 'm.youtube.com'), 'normal');
  assert.equal(T.siteModeOf({ mode: 'dark' }, ''), 'dark');
  const om = T.withSiteMode(s, 'github.com', 'omarchy');
  assert.equal(T.siteModeOf(om, 'github.com'), 'omarchy');
  assert.equal(T.siteModeOf(T.withSiteMode(om, 'github.com', 'default'), 'github.com'), 'normal');
  // Shortcut: themed → Normal → back to the default (Follow Omarchy when the default is Normal).
  const dark = { mode: 'dark', sites: {} };
  const off = T.toggleSite(dark, 'a.com');
  assert.equal(T.siteModeOf(off, 'a.com'), 'normal');
  assert.deepEqual(T.toggleSite(off, 'a.com').sites, {});
  assert.equal(T.siteModeOf(T.toggleSite(s, 'b.com'), 'b.com'), 'omarchy');
  assert.equal(T.siteModeOf(T.toggleSite(s, 'youtube.com'), 'youtube.com'), 'normal');
  assert.deepEqual(T.toggleSite(s, 'youtube.com').sites, { 'x.com': 'normal' });
});

test('Dark mode is neutral and keeps each page color\'s own hue', () => {
  const p = T.normalize(T.DARK);
  assert.equal(p.hues, 'source');
  const m = T.createMapper(p);
  assert.equal(hex(m.map(C.parse('#ffffff'), 'bg')), '#000000');
  assert.equal(hex(m.map(C.parse('#000000'), 'text')), '#e8e6e3');
  const deg = (c) => ((Math.atan2(C.toOklab(c).b, C.toOklab(c).a) * 180) / Math.PI + 360) % 360;
  for (const src of ['#0969da', '#cf222e', '#1a7f37', '#8250df', '#bf8700', '#e16f24']) {
    const out = m.map(C.parse(src), 'text');
    let d = Math.abs(deg(out) - deg(C.parse(src)));
    d = Math.min(d, 360 - d);
    assert.ok(d < 15, `${src} hue drifted ${d.toFixed(1)}°`);
    assert.ok(C.contrast(out, C.parse('#000000')) >= 4.4, `${src} readable`);
  }
});
