import assert from 'node:assert/strict';
import test from 'node:test';
import { chromium } from 'playwright';
import { serve } from '../server.mjs';

test('fleet reconnect preserves tile identity and ordering; attention and Escape use the real UI', async () => {
  const a = { host: 'desktop-a', desktop: 1, generation: 'a', ready: true, title: 'Build editor', threadId: 'thread', agentId: 'hub/thread', sourceHost: 'hub', agentStatus: 'Waiting for you' };
  const b = { host: 'desktop-b', desktop: 1, generation: 'b', ready: true, title: 'Other task' };
  let rows = [a, b], online = true;
  const app = await serve({ fleet: true, desktopURL: 'https://fixture.example', token: 'private', t3: { close: async () => {} },
    request: async url => Response.json(url.endsWith('/agents/fleet') ? { hosts: [{ id: 'desktop-a', online }, { id: 'desktop-b', online: true }], desktops: rows } : { generation: 'a' }) });
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    await page.addInitScript(() => { window.notices = []; window.webkit = { messageHandlers: { native: { postMessage: text => window.notices.push(JSON.parse(text)) } } }; });
    // Replace only the VNC transport boundary. Layout, input controls, native
    // bridge, fleet reconciliation, and Chat binding use production code.
    await page.route('**/novnc/core/rfb.js', route => route.fulfill({ contentType: 'text/javascript', body: `export default class RFB extends EventTarget {
      constructor(canvas) { super(); window.rfbs ||= []; window.rfbs.push(this); canvas.closest('.tile').rfb=this; const target=document.createElement('canvas'); canvas.append(target); setTimeout(()=>this.dispatchEvent(new Event('connect')),10); }
      disconnect(){this.dispatchEvent(new Event('disconnect'));}
    }` }));
    await page.goto(app.url);
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 2 && window.notices.some(n => n.chats?.length === 1));
    assert.deepEqual(await page.locator('.host').allTextContents(), ['desktop-a', 'desktop-b']);
    assert.equal(await page.locator('.attention').count(), 1);
    await page.locator('.tile').first().evaluate(el => { window.originalTile = el; });
    await page.locator('.control').first().click();
    await page.locator('.control-note:visible').waitFor();
    assert.equal(await page.evaluate(() => document.querySelector('.tile').rfb.viewOnly), false);
    await page.locator('.control').nth(1).click();
    assert.equal(await page.locator('.control-note:visible').count(), 2);
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('.control-note:visible').count(), 0);
    assert.equal(await page.evaluate(() => document.querySelector('.tile').rfb.viewOnly), true);
    online = false; rows = [b];
    await page.waitForFunction(() => document.querySelector('.agent-status')?.textContent === 'Reconnecting');
    assert.equal(await page.locator('.tile').count(), 2);
    assert.equal(await page.evaluate(() => document.querySelector('.tile') === window.originalTile), true);
    assert.deepEqual(await page.locator('.host').allTextContents(), ['desktop-a', 'desktop-b']);
    assert.equal(await page.locator('.attention').count(), 1, 'network loss does not resolve pending input');
    online = true; rows = [b, { ...a, agentStatus: 'Working' }];
    await page.waitForFunction(() => document.querySelector('.agent-status')?.textContent === 'Working');
    assert.equal(await page.evaluate(() => document.querySelector('.tile') === window.originalTile), true);
    assert.deepEqual(await page.locator('.host').allTextContents(), ['desktop-a', 'desktop-b'], 'server reordering cannot reshuffle tiles');
    assert.equal(await page.locator('.attention').count(), 0);
    await page.waitForFunction(() => window.notices.at(-1)?.chats?.length === 0);
    rows = [b, { ...a, generation: 'new', threadId: null, agentId: null }];
    await page.waitForFunction(() => !window.originalTile.isConnected);
    rows = [b];
    await page.waitForFunction(() => document.querySelectorAll('.tile').length === 1);
    assert.deepEqual(await page.locator('.host').allTextContents(), ['desktop-b']);
  } finally { await browser?.close(); await app.close(); }
});
