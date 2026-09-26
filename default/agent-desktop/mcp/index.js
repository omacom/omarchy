#!/usr/bin/env node
// hypr-desktop MCP: Streamable HTTP on loopback, bearer token in front, one
// fresh McpServer per request; nothing binds beyond 127.0.0.1.
import { createMcpExpressApp, requireBearerAuth } from '@modelcontextprotocol/express';
import { toNodeHandler } from '@modelcontextprotocol/node';
import { createMcpHandler, OAuthError, OAuthErrorCode } from '@modelcontextprotocol/server';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { readFileSync } from 'node:fs';
import { homedir, hostname } from 'node:os';
import { join } from 'node:path';
import { Leases } from './lib/leases.js';
import { createNest } from './lib/nest.js';
import { createLifecycle } from './lib/lifecycle.js';
import { buildServer } from './lib/server.js';
import { installViewer, loadViewerPeers } from './lib/viewer.js';

const STATE = process.env.HYPR_DESKTOP_STATE || join(homedir(), '.local/share/hypr-desktop');
const PORT = Number(process.env.HYPR_DESKTOP_PORT || 7873);
const HOSTS = (process.env.HYPR_DESKTOP_HOSTS || '').split(',').map(s => s.trim()).filter(Boolean);
const token = readFileSync(join(STATE, 'token'), 'utf8').trim();
if (token.length < 32) throw new Error(`${join(STATE, 'token')} is too short; run omarchy install ai agent-desktop`);

const leases = new Leases({ file: join(STATE, 'leases.json') });
const nest = createNest();
const execFileP = promisify(execFile);
const notify = async (title, body) => {
  try {
    await execFileP('omarchy-notification-send', [title, body], { timeout: 5000 });
  } catch (error) {
    console.error('desktop notification failed:', error.message);
  }
};
const lifecycle = createLifecycle({ leases, nest, notify });
const reaper = setInterval(() => lifecycle.reap().catch(e => console.error('desktop cleanup failed:', e.message)), 60000);
reaper.unref();
const host = hostname().split('.')[0];
const handler = createMcpHandler(() => buildServer({ leases, nest, host, lifecycle }));

const auth = requireBearerAuth({
  verifier: {
    async verifyAccessToken(t) {
      if (t !== token) throw new OAuthError(OAuthErrorCode.InvalidToken, 'invalid token');
      // The verifier contract wants an expiry; a static local token never expires,
      // so each check is stamped an hour out.
      return { token: t, clientId: 'agent-desktop', scopes: ['mcp'], expiresAt: Math.floor(Date.now() / 1000) + 3600 };
    }
  },
  requiredScopes: ['mcp']
});
const app = createMcpExpressApp({ allowedHosts: ['localhost', '127.0.0.1', host, ...HOSTS], allowedOrigins: ['localhost', '127.0.0.1', host, ...HOSTS] });
const node = toNodeHandler(handler);
app.all(['/mcp', '/hypr-desktop/mcp'], auth, (req, res) => void node(req, res, req.body));
app.get('/healthz', (_req, res) => res.json({ ok: true, desktops: leases.status().length }));

const origins = (process.env.AGENT_DESKTOP_VIEWER_ORIGINS || '').split(',').filter(Boolean);
for (const value of origins) {
  const url = new URL(value);
  if (url.protocol !== 'https:' || url.origin !== value) throw new Error('Web viewer origins must be explicit HTTPS origins behind a trusted private gateway.');
}
const viewer = installViewer(app, { host, token, leases, nest, wayland: true, agents: true,
  web: origins.length > 0, peers: loadViewerPeers(join(STATE, 'viewer-peers.json'), host), origins });
const listener = app.listen(PORT, '127.0.0.1', () => console.error(`hypr-desktop: listening on 127.0.0.1:${PORT} (hosts: ${['localhost', host, ...HOSTS].join(', ')})`));
viewer(listener);
for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, async () => { await viewer.close(); await handler.close(); listener.close(); process.exit(0); });
}
