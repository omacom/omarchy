import assert from 'node:assert/strict';
import test from 'node:test';
import express from 'express';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

// Browser tests for the dashboard frontend. The backend is mocked at its HTTP
// contract (DASHBOARD-API.md) and noVNC at its import boundary, under the real CSP.
const viewer = fileURLToPath(new URL('../viewer/', import.meta.url));
const vendor = name => fileURLToPath(new URL(`../node_modules/${name}`, import.meta.url));
const CSP = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'self'; base-uri 'none'; form-action 'self'";
const FAKE_RFB = `export default class RFB extends EventTarget {
  constructor(target, url, options) {
    super(); this.url = url; this.options = options; this.viewOnly = true; this.keys = []; this.disconnected = false;
    const canvas = document.createElement('canvas'); canvas.width = 320; canvas.height = 180; canvas.tabIndex = -1; target.append(canvas);
    canvas.addEventListener('keydown', e => this.keys.push('dom:' + e.key));
    (window.__rfb ||= []).push(this);
    this.timer = setTimeout(() => this.dispatchEvent(new Event('connect')), 10);
  }
  sendKey(code) { this.keys.push(code); }
  disconnect() { clearTimeout(this.timer); this.disconnected = true; setTimeout(() => this.dispatchEvent(new Event('disconnect')), 0); }
}`;
const ICON = 'data:image/svg+xml;base64,' + Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8"><rect width="8" height="8" fill="#7cc"/></svg>').toString('base64');
const desk = (host, desktop, generation, extra = {}) => ({ host, desktop, generation, owner: 'Agent', held: true, ready: true, idleMs: 1000, title: 'Task', icon: '', agentStatus: 'Working', agentId: null, chatAvailable: false, ...extra });
const message = (n, role) => ({ id: `${n}-${role}`, role, text: role === 'user' ? `Prompt ${n}` : `## Reply ${n}\n\n**Markdown** with a table.\n\n| Name | Value |\n|---|---|\n| Map | ${n} |\n\n\`\`\`js\nconst map = ${n};\n\`\`\`\n\n<img src=x onerror="window.INJECTED=true"><script>window.INJECTED=true</script>`, createdAt: String(n).padStart(8, '0') + (role === 'user' ? 'a' : 'b'), updatedAt: '2026-09-08T10:00:00Z', streaming: false });

async function fixture() {
  const state = { hosts: [{ id: 'hub', online: true }, { id: 'desktop-a', online: true }, { id: 'desktop-b', online: true }], desktops: [], connects: [], chats: [], pages: [], dispatched: [], sent: [], failNext: false, failBefore: null, down: false, latest: 5000 };
  const app = express();
  app.use((req, res, next) => { res.set({ 'Cache-Control': 'no-store', 'Content-Security-Policy': CSP }); next(); });
  app.get('/novnc/core/rfb.js', (_req, res) => res.type('application/javascript').send(FAKE_RFB));
  app.get('/vendor/marked.js', (_req, res) => res.sendFile(vendor('marked/lib/marked.esm.js')));
  app.get('/vendor/purify.js', (_req, res) => res.sendFile(vendor('dompurify/dist/purify.es.mjs')));
  app.get('/api/desktops', (_req, res) => state.down ? res.status(503).json({ error: 'down' }) : res.json({ hosts: state.hosts, desktops: state.desktops }));
  app.get('/api/desktops/:host/:n/connect', (req, res) => { state.connects.push(`${req.params.host}/${req.params.n}/${req.query.generation}`); res.json({ generation: req.query.generation, password: 'vnc' }); });
  app.post('/api/chats', express.json(), (req, res) => {
    const d = state.desktops.find(d => d.host === req.body.host && d.desktop === req.body.desktop && d.generation === req.body.generation);
    if (!d) return res.status(404).json({ error: 'This desktop has ended.' });
    if (!d.chatAvailable) return res.status(409).json({ error: 'Chat is unavailable for this desktop.' });
    state.chats.push(req.body);
    res.json({ id: 'signed-' + d.agentId.replace(/\W/g, '_'), title: d.title, agentId: d.agentId });
  });
  app.get('/api/chats/:id', (req, res) => {
    state.pages.push({ id: req.params.id, before: req.query.before });
    if (req.query.before && req.query.before === state.failBefore) { state.failBefore = null; return res.status(503).json({ error: 'Chat history is briefly unavailable.' }); }
    const end = req.query.before ? Number(req.query.before) : state.latest, start = Math.max(1, end - (req.query.before ? 8 : 1) + 1);
    const messages = [];
    for (let n = start; n <= end; n++) messages.push(message(n, 'user'), message(n, 'assistant'));
    if (!req.query.before) for (const s of state.sent) messages.push({ id: s.messageId, role: 'user', text: s.text, createdAt: '99999999z' + s.messageId, updatedAt: 'z', streaming: false });
    res.json({ snapshotSequence: 10000 + state.sent.length, thread: { id: req.params.id, title: 'Thread ' + req.params.id, messages }, page: { hasMore: start > 1, beforeCursor: start > 1 ? String(start - 1) : null } });
  });
  app.post('/api/chats/:id/messages', express.json(), (req, res) => {
    state.dispatched.push({ id: req.params.id, ...req.body });
    if (state.failNext) { state.failNext = false; return res.status(503).json({ error: 'The message has not been confirmed.' }); }
    state.sent.push(req.body); res.json({ sequence: 10001 });
  });
  app.use(express.static(viewer));
  const server = app.listen(0, '127.0.0.1'); await new Promise(resolve => server.once('listening', resolve));
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const errors = []; page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) errors.push(m.text()); });
  return { state, page, errors, url: `http://127.0.0.1:${server.address().port}/`,
    rfbs: () => page.evaluate(() => (window.__rfb || []).map(r => ({ url: r.url, viewOnly: r.viewOnly, keys: r.keys, disconnected: r.disconnected }))),
    live: async host => (await page.evaluate(() => (window.__rfb || []).map(r => ({ url: r.url, viewOnly: r.viewOnly, keys: r.keys, disconnected: r.disconnected })))).filter(r => !r.disconnected && r.url.includes(`/view/${host}/`)),
    fits: async () => { for (const width of [402, 768, 1440]) { await page.setViewportSize({ width, height: 874 }); await page.evaluate(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)))); assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth), `no horizontal overflow at ${width}`); } },
    async close() { await browser.close(); server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); } };
}
const sharedAgent = () => [
  desk('desktop-a', 1, 'g1', { title: 'Build dashboard', icon: ICON, agentId: 'hub/thread-a', chatAvailable: true }),
  desk('desktop-b', 2, 'g2', { title: 'Build dashboard', icon: ICON, agentId: 'hub/thread-a', chatAvailable: true }),
  desk('desktop-a', 3, 'g3', { title: 'Build dashboard', agentStatus: 'Unknown' }),
  desk('desktop-b', 1, 'g4', { title: 'Fix login', agentStatus: 'Waiting for you', agentId: 'desktop-b/thread-b', chatAvailable: true })
];

test('fleet dashboard: empty state, verified grouping, focus-safe polling, offline retention, widths', async () => {
  const f = await fixture();
  try {
    await f.page.goto(f.url);
    await f.page.getByText('No active desktops', { exact: true }).waitFor();
    assert.equal(await f.page.locator('#notice').innerText(), '');
    await f.fits();
    f.state.desktops = sharedAgent();
    await f.page.waitForFunction(() => document.querySelectorAll('#agents li').length === 3);
    const names = await f.page.locator('#agents .name').allInnerTexts();
    assert.deepEqual(names, ['Fix login', 'Build dashboard', 'Build dashboard'], 'attention first; title never groups');
    const rows = f.page.locator('#agents li');
    assert.equal(await rows.nth(1).locator('.where').innerText(), 'desktop-a/1  desktop-b/2');
    assert.equal(await rows.nth(1).locator('.icon').getAttribute('src'), ICON);
    assert.equal(await rows.nth(2).locator('.where').innerText(), 'desktop-a/3');
    assert.deepEqual(await f.page.locator('#hosts li .count').allInnerTexts(), ['', '2', '2']);
    assert.deepEqual(await f.rfbs(), [], 'discovery never opens a stream');
    await rows.nth(1).locator('.row').click();
    await f.page.waitForFunction(() => document.querySelectorAll('.tile:not([hidden])').length === 2);
    assert.equal(await f.page.locator('#stage-title').innerText(), 'Build dashboard');
    assert.deepEqual(await f.page.locator('.tile .where').allInnerTexts(), ['desktop-a · 1', 'desktop-b · 2']);
    assert.deepEqual(await f.page.locator('.tile .title').allInnerTexts(), ['Build dashboard', 'Build dashboard'], 'each screen carries its session title');
    assert.deepEqual(await f.page.locator('.tile .icon').evaluateAll(els => els.map(e => e.getAttribute('src'))), [ICON, ICON], 'each screen carries its project favicon');
    assert.ok(await f.page.locator('.tile .title').evaluateAll(els => els.every(e => e.compareDocumentPosition(e.closest('.tile').querySelector('.screen')) & Node.DOCUMENT_POSITION_PRECEDING)), 'title sits below the screen');
    await f.page.waitForFunction(() => (window.__rfb || []).length === 2);
    assert.ok((await f.rfbs()).every(r => r.url.includes('profile=') && r.viewOnly));
    await f.page.waitForFunction(() => document.querySelectorAll('.tile .control:not(:disabled)').length === 2);
    await f.page.locator('#draft:not(:disabled)').waitFor();
    assert.equal(f.state.chats.length, 1, 'one binding per agent');
    await f.page.locator('.tile .chat').first().click();
    assert.equal(await f.page.evaluate(() => document.activeElement?.id), 'draft', 'Chat focuses the built-in panel');
    const before = (await f.rfbs()).length;
    await f.page.waitForTimeout(4500);
    assert.equal((await f.rfbs()).length, before, 'unchanged polls do not reconnect streams');
    await f.fits();
    await f.page.setViewportSize({ width: 402, height: 874 });
    assert.equal(await f.page.locator('#rail').isVisible(), false, 'phone shows the selected agent alone');
    await f.page.locator('.tile .chat').first().click();
    await f.page.locator('#chat').waitFor({ state: 'visible' });
    assert.equal(await f.page.locator('#tab-chat').getAttribute('aria-selected'), 'true', 'Chat on a phone switches to the chat tab');
    assert.equal(await f.page.evaluate(() => document.activeElement?.id), 'draft');
    assert.ok((await f.rfbs()).every(r => r.disconnected), 'chat tab on a phone stops the streams');
    await f.page.locator('#tab-desktops').click();
    await f.page.waitForFunction(() => (window.__rfb || []).filter(r => !r.disconnected).length === 2);
    await f.page.locator('#back').click();
    await f.page.locator('#rail').waitFor({ state: 'visible' });
    assert.ok((await f.rfbs()).every(r => r.disconnected), 'closing the view disconnects');
    await f.page.setViewportSize({ width: 1440, height: 900 });
    await f.page.locator('#agents li').nth(1).locator('.row').focus();
    f.state.desktops[3].agentStatus = 'Working';
    await f.page.waitForFunction(() => document.querySelector('#agents li:nth-child(2) .status').textContent === 'Working');
    assert.equal(await f.page.evaluate(() => document.activeElement?.closest('li')?.dataset.group), 'agent:hub/thread-a', 'polling keeps the focused row');
    await f.page.locator('#agents li').nth(1).locator('.row').click();
    await f.page.waitForFunction(() => (window.__rfb || []).filter(r => !r.disconnected).length === 2);
    f.state.hosts[2].online = false; f.state.desktops = f.state.desktops.filter(d => d.host !== 'desktop-b');
    await f.page.waitForFunction(() => document.querySelector('#hosts li:nth-child(3)').classList.contains('offline'));
    assert.deepEqual(await f.page.locator('.tile .where').allInnerTexts(), ['desktop-a · 1', 'desktop-b · 2'], 'offline host keeps known tiles');
    assert.equal(await f.page.locator('.tile').nth(1).locator('.status').innerText(), 'Reconnecting');
    f.state.hosts[2].online = true;
    await f.page.waitForFunction(() => document.querySelectorAll('.tile').length === 1, null, { timeout: 10000 });
    await f.page.locator('#agents li').filter({ hasText: 'desktop-a/3' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('chat-state').textContent === 'Unverified session');
    assert.equal(await f.page.locator('#draft').isDisabled(), true);
    assert.equal(await f.page.locator('.tile .chat').isDisabled(), true, 'unverified screens cannot open chat');
    assert.equal(f.state.chats.length, 1, 'unverified sessions never request a binding');
    f.state.desktops = [];
    await f.page.waitForFunction(() => document.querySelectorAll('#agents li').length === 1);
    assert.equal(await f.page.locator('#agents .status').innerText(), 'Ended');
    await f.page.locator('#agents .row').click();
    await f.page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    assert.equal(await f.page.locator('#dismiss').isVisible(), true);
    assert.ok(f.state.pages.every(p => p.id === 'signed-hub_thread_a'), 'the ended agent keeps its original signed chat');
    await f.fits();
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('chat: safe Markdown, bounded long history, drafts and retries survive switching agents', async () => {
  const f = await fixture();
  try {
    f.state.desktops = sharedAgent();
    await f.page.goto(f.url + '#/agent/' + encodeURIComponent('hub/thread-a'));
    const start = Date.now();
    await f.page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    assert.ok(Date.now() - start < 4000, 'the latest turn renders promptly in a 5,000-turn thread');
    assert.equal(f.state.pages[0].before, undefined, 'first fetch is the recent turn only');
    assert.equal(await f.page.evaluate(() => Boolean(window.INJECTED)), false, 'Markdown cannot execute scripts');
    assert.equal(await f.page.locator('.markdown script').count(), 0);
    for (let i = 0; i < 12; i++) {
      const count = await f.page.locator('.message').count();
      await f.page.locator('#older:not(:disabled)').waitFor({ state: 'attached' });
      await f.page.locator('#history').evaluate(el => { el.scrollTop = 0; });
      await f.page.waitForFunction(n => document.querySelectorAll('.message').length > n, count);
    }
    assert.ok(await f.page.locator('.message').count() >= 190, 'older history stays reachable on demand');
    const rendered = await f.page.locator('.markdown').evaluateAll(els => els.filter(e => e.childElementCount).length);
    assert.ok(rendered < 35, `only nearby messages hold rendered Markdown, saw ${rendered}`);
    const scrollTop = await f.page.locator('#history').evaluate(el => el.scrollTop);
    await f.page.locator('#draft').fill('keep this draft');
    await f.page.locator('#agents li').filter({ hasText: 'Fix login' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('stage-title').textContent === 'Fix login');
    assert.equal(await f.page.locator('#draft').inputValue(), '');
    await f.page.locator('#agents li').filter({ hasText: 'desktop-a/1' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('draft').value === 'keep this draft');
    assert.ok(Math.abs(await f.page.locator('#history').evaluate(el => el.scrollTop) - scrollTop) < 40, 'reading position survives switching agents');
    assert.equal(f.state.chats.length, 2, 'bindings are cached per agent');
    f.state.failNext = true;
    await f.page.locator('#send').click();
    await f.page.locator('#send-error').filter({ hasText: 'Retry' }).waitFor();
    assert.equal(await f.page.locator('#draft').inputValue(), 'keep this draft', 'a failed send keeps the draft');
    await f.page.locator('#send:not(:disabled)').click();
    await f.page.waitForFunction(() => document.getElementById('draft').value === '');
    assert.equal(f.state.dispatched.length, 2);
    assert.deepEqual(f.state.dispatched[0], f.state.dispatched[1], 'a retry keeps text and both IDs');
    assert.match(f.state.dispatched[0].commandId, /^[0-9a-f-]{36}$/);
    await f.page.locator('.message.from-user').filter({ hasText: 'keep this draft' }).waitFor();
    assert.equal(await f.page.locator('#send-error').innerText(), '');
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('chat: returning to an agent fills a multi-page gap in order and stays at the bottom', async () => {
  const f = await fixture();
  try {
    f.state.desktops = sharedAgent();
    await f.page.goto(f.url + '#/agent/' + encodeURIComponent('hub/thread-a'));
    await f.page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    await f.page.locator('#agents li').filter({ hasText: 'Fix login' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('stage-title').textContent === 'Fix login');
    f.state.latest = 5030; f.state.pages = [];
    await f.page.locator('#agents li').filter({ hasText: 'desktop-a/1' }).locator('.row').click();
    await f.page.locator('.message[data-message="5030-assistant"]').waitFor({ state: 'attached' });
    await f.page.locator('.message[data-message="5001-user"]').waitFor({ state: 'attached' });
    const ids = await f.page.locator('.message').evaluateAll(els => els.map(e => e.dataset.message));
    for (let n = 5000; n <= 5030; n++) assert.ok(ids.includes(`${n}-user`) && ids.includes(`${n}-assistant`), `turn ${n} is present`);
    const turns = ids.map(id => Number(id.split('-')[0]));
    assert.deepEqual(turns, [...turns].sort((a, b) => a - b), 'history stays chronological');
    const walked = f.state.pages.filter(p => p.id === 'signed-hub_thread_a' && Number(p.before) > 5000).map(p => p.before);
    assert.deepEqual(walked, ['5029', '5021', '5013', '5005'], 'older pages are walked until one overlaps the known history');
    assert.equal(await f.page.locator('#jump').isVisible(), false, 'the view stays at the latest turn');
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('chat: a failed request mid-walk stages nothing, and the retry recovers every missing turn in order', async () => {
  const f = await fixture();
  try {
    f.state.desktops = sharedAgent();
    await f.page.goto(f.url + '#/agent/' + encodeURIComponent('hub/thread-a'));
    await f.page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    await f.page.locator('#agents li').filter({ hasText: 'Fix login' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('stage-title').textContent === 'Fix login');
    f.state.latest = 5030; f.state.pages = []; f.state.failBefore = '5021';
    await f.page.locator('#agents li').filter({ hasText: 'desktop-a/1' }).locator('.row').click();
    await f.page.waitForFunction(() => document.getElementById('chat-state').textContent === 'Chat history is briefly unavailable.');
    assert.equal(f.state.failBefore, null, 'the second older page failed once');
    assert.deepEqual(await f.page.locator('.message').evaluateAll(els => els.map(e => e.dataset.message).filter(id => Number(id.split('-')[0]) > 5000)), [], 'a failed walk merges none of its pages');
    await f.page.locator('.message[data-message="5001-user"]').waitFor({ state: 'attached', timeout: 10000 });
    await f.page.locator('.message[data-message="5030-assistant"]').waitFor({ state: 'attached' });
    const ids = await f.page.locator('.message').evaluateAll(els => els.map(e => e.dataset.message));
    for (let n = 5000; n <= 5030; n++) assert.ok(ids.includes(`${n}-user`) && ids.includes(`${n}-assistant`), `turn ${n} is present`);
    const turns = ids.map(id => Number(id.split('-')[0]));
    assert.deepEqual(turns, [...turns].sort((a, b) => a - b), 'history stays chronological');
    const walked = f.state.pages.filter(p => p.id === 'signed-hub_thread_a' && Number(p.before) > 5000).map(p => p.before);
    assert.deepEqual(walked, ['5029', '5021', '5029', '5021', '5013', '5005'], 'the retry restarts the walk from the original boundary');
    await f.page.waitForFunction(() => document.getElementById('chat-state').textContent === '');
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('bfcache: a persisted pagehide suspends streams and Markdown, pageshow resumes both without a reload', async () => {
  const f = await fixture();
  try {
    f.state.desktops = sharedAgent();
    await f.page.goto(f.url + '#/agent/' + encodeURIComponent('hub/thread-a'));
    await f.page.waitForFunction(() => (window.__rfb || []).filter(r => !r.disconnected).length === 2);
    await f.page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    await f.page.evaluate(() => window.dispatchEvent(new PageTransitionEvent('pagehide', { persisted: true })));
    assert.ok((await f.rfbs()).every(r => r.disconnected), 'pagehide closes the streams');
    assert.equal(await f.page.locator('.tile').count(), 2, 'tiles are kept for resumption');
    await f.page.evaluate(() => window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true })));
    await f.page.waitForFunction(() => (window.__rfb || []).filter(r => !r.disconnected).length === 2);
    assert.ok((await f.rfbs()).filter(r => !r.disconnected).every(r => r.viewOnly), 'resumed streams start in watch mode');
    f.state.latest = 5001;
    await f.page.getByRole('heading', { name: 'Reply 5001', exact: true }).waitFor();
    assert.equal(await f.page.locator('.message[data-message="5001-assistant"] table').count(), 1, 'Markdown renders after the worker is rebuilt');
    assert.equal(await f.page.evaluate(() => Boolean(window.INJECTED)), false);
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('control: explicit Take control, Escape returns to watching without reaching the desktop, one controller at a time', async () => {
  const f = await fixture();
  try {
    f.state.desktops = sharedAgent();
    await f.page.goto(f.url + '#/agent/' + encodeURIComponent('hub/thread-a'));
    await f.page.waitForFunction(() => document.querySelectorAll('.tile .control:not(:disabled)').length === 2);
    const first = f.page.locator('.tile').nth(0), second = f.page.locator('.tile').nth(1);
    await first.locator('.control').click();
    assert.equal(await first.locator('.control').getAttribute('aria-pressed'), 'true');
    assert.equal(await first.locator('.controlling-note').isVisible(), true);
    await f.page.waitForFunction(() => (window.__rfb || []).some(r => !r.disconnected && r.url.includes('/view/desktop-a/') && r.url.includes('profile=full') && !r.viewOnly));
    await first.locator('.keyboard').click();
    await f.page.locator('#keys').fill('hi');
    await f.page.keyboard.press('Enter');
    assert.deepEqual((await f.live('desktop-a'))[0].keys, [104, 105, 0xff0d], 'phone typing reaches the controlled desktop');
    await f.page.locator('canvas').first().focus();
    await f.page.keyboard.press('Escape');
    await f.page.waitForFunction(() => document.querySelector('.tile .control').getAttribute('aria-pressed') === 'false');
    const after = await f.rfbs();
    assert.ok(after.every(r => r.viewOnly || r.disconnected), 'watch mode after Escape');
    assert.ok(after.every(r => !r.keys.includes(0xff1b) && !r.keys.includes('dom:Escape')), 'Escape is consumed, not forwarded');
    assert.equal(await f.page.locator('#typing').isVisible(), false);
    await second.locator('.control').click();
    await first.locator('.control').click();
    assert.equal(await second.locator('.control').getAttribute('aria-pressed'), 'false', 'only one tile controls at a time');
    assert.equal(await first.locator('.control').getAttribute('aria-pressed'), 'true');
    await f.page.evaluate(() => { Object.defineProperty(document, 'hidden', { value: true, configurable: true }); document.dispatchEvent(new Event('visibilitychange')); });
    assert.ok((await f.rfbs()).every(r => r.disconnected), 'a hidden page disconnects streams');
    assert.equal(await f.page.locator('.tile').count(), 2, 'tiles stay; agents keep running');
    await f.page.evaluate(() => { Object.defineProperty(document, 'hidden', { value: false, configurable: true }); document.dispatchEvent(new Event('visibilitychange')); });
    await f.page.waitForFunction(() => (window.__rfb || []).filter(r => !r.disconnected).length === 2);
    assert.ok((await f.rfbs()).filter(r => !r.disconnected).every(r => r.viewOnly), 'reconnects always start in watch mode');
    assert.ok(f.state.connects.every(c => c === 'desktop-a/1/g1' || c === 'desktop-b/2/g2'), 'reconnects use the exact generation');
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});

test('service outage shows one line, then recovers into the list without a reload', async () => {
  const f = await fixture();
  try {
    f.state.down = true;
    await f.page.goto(f.url);
    await f.page.getByText('Desktop service unreachable. Check Tailscale.').waitFor();
    assert.equal(await f.page.locator('#agents li').count(), 0);
    f.state.down = false; f.state.desktops = sharedAgent();
    await f.page.waitForFunction(() => document.querySelectorAll('#agents li').length === 3, null, { timeout: 10000 });
    assert.equal(await f.page.locator('#rail-state').isVisible(), false);
    f.state.down = true;
    await f.page.locator('#notice').filter({ hasText: 'retrying' }).waitFor({ timeout: 10000 });
    assert.equal(await f.page.locator('#agents li').count(), 3, 'known rows survive a failed poll');
    assert.deepEqual(f.errors, []);
  } finally { await f.close(); }
});
