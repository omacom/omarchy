import assert from 'node:assert/strict';
import test from 'node:test';
import { createServer } from 'node:http';
import { chromium } from 'playwright';
import { serve } from '../server.mjs';
import { T3 } from '../t3.mjs';

const thread = { id: 'original-thread', title: 'Build the map editor', runtimeMode: 'full-access', interactionMode: 'default', modelSelection: { provider: 'codex', model: 'gpt-5' } };
const message = (n, role) => ({ id: `${n}-${role}`, role, text: role === 'user' ? `Prompt ${n}` : `## Reply ${n}\n\n**Markdown** with a table.\n\n| Name | Value |\n|---|---|\n| Map | ${n} |\n\n\`\`\`js\nconst map = ${n};\n\`\`\`\n\n<img src=x onerror="window.INJECTED=true"><script>window.INJECTED=true</script>`, createdAt: String(n).padStart(8, '0') + (role === 'user' ? 'a' : 'b'), updatedAt: '2026-09-08T10:00:00Z', streaming: false });

async function fixture() {
  const requests = [], dispatched = [];
  let desks = [{ desktop: 1, generation: 'generation-one', owner: 'Test task', ready: false, held: true }];
  let dropReply = false;
  const upstream = createServer(async (req, res) => {
    if (req.url.startsWith('/hypr-desktop/viewer/desktops')) return res.end(JSON.stringify({ desktops: desks }));
    assert.equal(req.headers.authorization, 'Bearer test-t3-token');
    if (req.method === 'GET') {
      const query = new URL(req.url, 'http://localhost').searchParams;
      requests.push(Object.fromEntries(query));
      const end = query.has('beforeCursor') ? Number(query.get('beforeCursor')) : 5000;
      const start = Math.max(1, end - Number(query.get('turnLimit')) + 1);
      const messages = [];
      for (let n = start; n <= end; n++) messages.push(message(n, 'user'), message(n, 'assistant'));
      return res.end(JSON.stringify({ snapshotSequence: 10000, thread: { ...thread, messages }, page: { hasMore: start > 1, beforeCursor: start > 1 ? String(start - 1) : null } }));
    }
    let body = ''; for await (const chunk of req) body += chunk;
    dispatched.push(JSON.parse(body));
    if (dropReply) { dropReply = false; return res.destroy(); }
    res.end(JSON.stringify({ sequence: 10001 }));
  });
  await new Promise(resolve => upstream.listen(0, '127.0.0.1', resolve));
  const url = `http://127.0.0.1:${upstream.address().port}`;
  const t3 = new T3({ url, issue: async () => ({ token: 'test-t3-token', sessionId: 'only-this-client' }), revoke: async () => {} });
  const app = await serve({ desktopURL: url, token: 'test-desktop-token', host: 'fixture', t3,
    catalog: { read: async () => desks.map(d => ({ ...d, title: thread.title, threadId: thread.id })), close() {} } });
  return { ...app, requests, dispatched, replace(value) { desks = value; }, dropReply() { dropReply = true; }, async close() { await app.close(); await new Promise(resolve => upstream.close(resolve)); } };
}
const json = async (url, body) => {
  const r = await fetch(url, body ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) } : {});
  assert.equal(r.status, 200); return r.json();
};

test('chat binds to the original thread after the desktop number is reused; retries keep one command', async () => {
  const f = await fixture();
  try {
    const chat = await json(f.url + 'api/chats', { desktop: 1, generation: 'generation-one' });
    f.replace([{ desktop: 1, generation: 'replacement', owner: 'Another task', held: true, ready: false }]);
    const stale = await fetch(f.url + 'api/chats', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ desktop: 1, generation: 'generation-one' }) });
    assert.equal(stale.status, 503);
    const page = await json(f.url + `api/chats/${chat.id}`);
    assert.equal(page.thread.id, 'original-thread'); assert.equal(page.thread.messages.length, 2);
    const payload = { commandId: 'retry-one', messageId: 'message-one', text: 'Keep going' };
    f.dropReply();
    await fetch(f.url + `api/chats/${chat.id}/messages`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
    await new Promise(resolve => setTimeout(resolve, 20));
    await json(f.url + `api/chats/${chat.id}/messages`, payload);
    assert.deepEqual(f.dispatched[0], f.dispatched[1], 'a network retry must use exactly the same T3 command');
    assert.equal(f.dispatched[0].threadId, 'original-thread');
    assert.deepEqual(f.dispatched[0].modelSelection, thread.modelSelection);
    assert.equal((await fetch(new URL('/api/desktops', f.url))).status, 404);
    assert.equal((await fetch(f.url + 'api/desktops', { headers: { Origin: 'https://other.example' } })).status, 403);
  } finally { await f.close(); }
});

test('long Markdown history loads a recent page, older pages on demand, and keeps rendered messages bounded', async () => {
  const f = await fixture(); let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const chat = await json(f.url + 'api/chats', { desktop: 1, generation: 'generation-one' });
    const page = await browser.newPage({ viewport: { width: 768, height: 874 } });
    const errors = []; page.on('pageerror', e => errors.push(e.message));
    const start = Date.now();
    await page.goto(f.url + `chat.html?id=${chat.id}`);
    await page.getByRole('heading', { name: 'Reply 5000', exact: true }).waitFor();
    assert.ok(Date.now() - start < 3000, 'latest Markdown appears promptly in a 5,000-turn thread');
    assert.equal(f.requests[0].turnLimit, '1');
    assert.equal(await page.evaluate(() => Boolean(window.INJECTED)), false, 'Markdown cannot execute scripts');
    for (let i = 0; i < 12; i++) {
      const before = await page.locator('.message').count();
      await page.locator('#older:not(:disabled)').waitFor({ state: 'attached' });
      await page.locator('#history').evaluate(el => { el.scrollTop = 0; });
      await page.waitForFunction(n => document.querySelectorAll('.message').length > n, before);
    }
    assert.ok(await page.locator('.message').count() >= 190, 'older history remains reachable');
    const rendered = await page.locator('.markdown').evaluateAll(els => els.filter(e => e.childElementCount).length);
    assert.ok(rendered < 35, `only nearby messages render, saw ${rendered}`);
    for (const width of [402, 768, 1440]) {
      await page.setViewportSize({ width, height: 874 });
      assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), `chat fits ${width}`);
    }
    assert.deepEqual(errors, []);
  } finally { await browser?.close(); await f.close(); }
});

test('viewer adds and removes tiles without reloading; no sessions shows an empty-state message', async () => {
  const f = await fixture(); let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto(f.url); await page.locator('.tile').waitFor();
    f.replace(Array.from({ length: 10 }, (_, n) => ({ desktop: n + 1, generation: `new-${n}`, owner: `Task ${n}`, held: true, ready: false })));
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 8);
    for (const width of [402, 768, 1440]) {
      await page.setViewportSize({ width, height: 874 });
      await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
      assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth && document.getElementById('tiles').scrollHeight <= document.getElementById('tiles').clientHeight), `eight tiles fit ${width} without scrolling`);
      assert.equal(await page.locator('header').count(), 0);
    }
    await page.locator('#pager').click();
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 2);
    f.replace([]); await page.waitForFunction(() => document.querySelectorAll('.tile').length === 0);
    assert.equal(await page.locator('#empty').isVisible(), true);
    assert.equal(await page.locator('#empty p').innerText(), 'No active desktops');
    f.replace([{ desktop: 1, generation: 'back', owner: 'Returning agent', held: true, ready: false }]);
    await page.locator('.tile').waitFor();
    assert.equal(await page.locator('#empty').isVisible(), false);
  } finally { await browser?.close(); await f.close(); }
});

test('native fleet chat follows the source host and its focused view includes all matching desktops', async () => {
  const calls = [];
  const desks = [
    { host: 'desktop-a', desktop: 1, generation: 'one', title: 'Shared agent', threadId: 'thread', sourceHost: 'hub', agentId: 'hub/thread', ready: false },
    { host: 'desktop-b', desktop: 1, generation: 'two', title: 'Shared agent', threadId: 'thread', sourceHost: 'hub', agentId: 'hub/thread', ready: false },
    { host: 'hub', desktop: 1, generation: 'three', title: 'Shared agent', threadId: 'different', sourceHost: 'hub', agentId: 'hub/different', ready: false }
  ];
  const app = await serve({ fleet: true, desktopURL: 'https://fixture.example', token: 'server-only', catalog: { close() {} }, t3: { close: async () => {} },
    request: async (url, options) => {
      calls.push({ url, options });
      return Response.json(url.endsWith('/agents/fleet') ? { hosts: [], desktops: desks } : { thread: { id: 'thread', messages: [] }, page: {} });
    }
  });
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const a = await json(app.url + 'api/chats', { host: 'desktop-a', desktop: 1, generation: 'one' });
    const b = await json(app.url + 'api/chats', { host: 'desktop-b', desktop: 1, generation: 'two' });
    assert.equal(a.id, b.id, 'one agent receives one chat across desktop hosts');
    await json(app.url + `api/chats/${a.id}`);
    assert.equal(calls.at(-1).url, 'https://fixture.example/hypr-desktop/viewer/agents/chat/hub/thread?');
    const page = await browser.newPage(); await page.goto(app.url + '?' + new URLSearchParams({ agent: a.agentId }));
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 2);
    assert.equal(await page.locator('.tile').count(), 2, 'same title on another thread must not join the group');
    const colors = await page.locator('.tile').evaluateAll(tiles => tiles.map(tile => getComputedStyle(tile).borderColor));
    assert.equal(colors[0], colors[1], 'related desktops share a border color');
    assert.notEqual(colors[0], 'rgba(0, 0, 0, 0)');
    assert.deepEqual(await page.locator('.agent-status').allTextContents(), ['Offline', 'Offline']);
    assert.ok(await page.locator('.agent-status').evaluateAll(badges => badges.every(badge => badge.nextElementSibling.textContent === 'Chat')));
    assert.ok(!(await page.content()).includes('server-only'));
    desks.shift();
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 1);
    const stale = await fetch(app.url + 'api/chats', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ host: 'desktop-a', desktop: 1, generation: 'one' }) });
    assert.equal(stale.status, 503);
  } finally { await browser?.close(); await app.close(); }
});
