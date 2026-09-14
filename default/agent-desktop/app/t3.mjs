import { execFile } from 'node:child_process';
import { homedir } from 'node:os';
import { dirname } from 'node:path';
import { createHash } from 'node:crypto';
import { promisify } from 'node:util';

const exec = promisify(execFile);
const cliOptions = () => ({ timeout: 15000, env: { ...process.env, PATH: `${dirname(process.execPath)}:${homedir()}/.npm-global/bin:${process.env.PATH || ''}` } });

export function turnCommand(thread, text, commandId, messageId) {
  if (!text.trim() || text.length > 100000) throw new Error('Enter a message of at most 100,000 characters.');
  return { type: 'thread.turn.start', commandId, threadId: thread.id,
    message: { messageId, role: 'user', text, attachments: [] },
    modelSelection: thread.modelSelection, runtimeMode: thread.runtimeMode,
    interactionMode: thread.interactionMode, createdAt: new Date().toISOString() };
}

export class T3 {
  constructor({ url = 'http://127.0.0.1:3773', issue = async () => {
    const { stdout } = await exec('t3', ['auth', 'session', 'issue', '--ttl', '8h', '--label', 'Agent Desktops', '--json'], cliOptions());
    return JSON.parse(stdout);
  }, revoke = id => exec('t3', ['auth', 'session', 'revoke', id], cliOptions()), request = fetch } = {}) {
    this.url = url; this.issue = issue; this.revoke = revoke; this.request = request; this.pending = new Map(); this.completed = new Map();
  }
  async call(path, body, retry = true) {
    this.auth ||= this.issue().catch(error => { this.auth = null; throw error; });
    const auth = await this.auth;
    const response = await this.request(this.url + path, {
      method: body ? 'POST' : 'GET', headers: { Authorization: `Bearer ${auth.token}`, 'Content-Type': 'application/json' },
      ...(body ? { body: JSON.stringify(body) } : {}), redirect: 'error', signal: AbortSignal.timeout(15000)
    });
    if (response.status === 401 && retry) {
      if (this.auth && await this.auth === auth) {
        this.auth = null;
        await this.revoke(auth.sessionId).catch(() => {});
      }
      return this.call(path, body, false);
    }
    if (!response.ok) throw new Error(`T3 request failed (${response.status}). ${response.status === 401 ? 'Reopen Agent Desktops to sign in again.' : 'The message has not been confirmed.'}`);
    return response.json();
  }
  async page(thread, cursor) {
    const query = new URLSearchParams({ turnLimit: cursor ? '8' : '1' });
    if (cursor) query.set('beforeCursor', cursor);
    const result = await this.call(`/api/orchestration/threads/${encodeURIComponent(thread)}?${query}`);
    if (!result.page || result.thread?.id !== thread) throw new Error('This T3 version does not provide safe paginated thread history.');
    return result;
  }
  async send(threadId, text, commandId, messageId) {
    const fingerprint = createHash('sha256').update(JSON.stringify([threadId, text, messageId])).digest('hex');
    const completed = this.completed.get(commandId);
    if (completed) {
      if (completed.fingerprint !== fingerprint) throw new Error('A retry must keep the same message and thread.');
      return completed.result;
    }
    let pending = this.pending.get(commandId);
    if (!pending) {
      if (this.pending.size >= 128) throw new Error('Too many unconfirmed messages. Retry an outstanding submission first.');
      pending = this.page(threadId).then(({ thread }) => turnCommand(thread, text, commandId, messageId));
      this.pending.set(commandId, pending);
      pending.catch(() => { if (this.pending.get(commandId) === pending) this.pending.delete(commandId); });
    }
    const command = await pending;
    if (command.threadId !== threadId || command.message.text !== text || command.message.messageId !== messageId) throw new Error('A retry must keep the same message and thread.');
    const result = await this.call('/api/orchestration/dispatch', command);
    this.pending.delete(commandId);
    this.completed.set(commandId, { fingerprint, result });
    if (this.completed.size > 256) this.completed.delete(this.completed.keys().next().value);
    // T3 persists command receipts by ID and thread, so an older evicted
    // successful retry still cannot start another turn.
    return result;
  }
  async close() {
    if (this.auth) { const auth = await this.auth; await this.revoke(auth.sessionId); }
  }
}
