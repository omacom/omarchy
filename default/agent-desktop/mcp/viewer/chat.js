import DOMPurify from '/vendor/purify.js';
import { api } from '/api.js';

const STORAGE = 'desktop-chat-bindings';
const CACHE_ITEMS = 80, CACHE_BYTES = 16 * 1024 * 1024, GAP_PAGES = 64;

export function createChat({ root }) {
  const q = sel => root.querySelector(sel);
  const history = q('#history'), older = q('#older'), draft = q('#draft'), send = q('#send'), form = q('#composer');
  const error = q('#send-error'), state = q('#chat-state'), jump = q('#jump');
  // The Markdown worker is created on demand and dropped on pagehide, so a bfcache restore rebuilds it
  // and re-issues whatever parses were in flight instead of leaving messages blank.
  const requests = new Map(); let requestId = 0, worker = null;
  function ensureWorker() {
    if (worker) return worker;
    worker = new Worker('/markdown-worker.js', { type: 'module' });
    worker.onmessage = ({ data }) => { const pending = requests.get(data.id); requests.delete(data.id); pending?.resolve(data); };
    for (const [id, pending] of requests) worker.postMessage({ id, text: pending.text });
    return worker;
  }
  const parse = text => new Promise(resolve => { const w = ensureWorker(), id = ++requestId; requests.set(id, { text, resolve }); w.postMessage({ id, text }); });
  const sanitize = html => DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true }, FORBID_TAGS: ['form', 'input', 'button', 'textarea', 'iframe', 'style'],
    FORBID_ATTR: ['style', 'id', 'name'], ALLOW_DATA_ATTR: false
  });
  let bindings = new Map();
  try { bindings = new Map(JSON.parse(sessionStorage.getItem(STORAGE) || '[]')); } catch { bindings = new Map(); }
  const persist = () => { try { sessionStorage.setItem(STORAGE, JSON.stringify([...bindings])); } catch { /* Session storage is optional. */ } };
  const chats = new Map();
  let current = null, group = null;

  const nearBottom = () => history.scrollHeight - history.scrollTop - history.clientHeight < 120;
  function anchor(s) {
    const top = history.getBoundingClientRect().top;
    const el = [...s.container.children].find(child => child.getBoundingClientRect().bottom > top);
    return el ? { el, offset: el.getBoundingClientRect().top - top } : null;
  }
  function restore(point) { if (point?.el.isConnected) history.scrollTop += point.el.getBoundingClientRect().top - history.getBoundingClientRect().top - point.offset; }
  const attached = s => current === s && s.container.isConnected;

  function chatState(agentId, title) {
    let s = chats.get(agentId);
    if (s) return s;
    const container = document.createElement('div'); container.className = 'messages';
    s = { agentId, id: bindings.get(agentId)?.id || null, title, container, messages: new Map(), nodes: new Map(), visible: new Set(), cache: new Map(),
      cursor: null, hasMore: false, initial: true, sequence: -1, draft: '', pendingSend: null, scrollTop: 0, atBottom: true, error: '', status: '', loading: false, polling: false, binding: null };
    s.observer = new IntersectionObserver(entries => {
      for (const entry of entries) {
        const messageId = entry.target.dataset.message, node = s.nodes.get(messageId);
        if (!node) continue;
        if (entry.isIntersecting) { s.visible.add(messageId); void render(s, messageId); }
        else {
          s.visible.delete(messageId);
          if (node.root.isConnected) node.height = node.root.offsetHeight;
          node.body.replaceChildren(); node.body.style.height = `${Math.max(24, (node.height || 100) - 28)}px`;
          node.root.classList.add('placeholder'); node.revision = null;
        }
      }
    }, { root: history, rootMargin: '600px' });
    chats.set(agentId, s);
    return s;
  }

  async function render(s, messageId) {
    const node = s.nodes.get(messageId), message = s.messages.get(messageId);
    if (!node || !s.visible.has(messageId)) return;
    const revision = `${message.updatedAt}/${message.text}`;
    if (node.revision === revision) return;
    node.revision = revision;
    let html = s.cache.get(messageId);
    if (!html || html.revision !== revision) {
      const parsed = await parse(message.text);
      html = { revision, html: sanitize(parsed.html || parsed.error) };
      if (!message.streaming) {
        s.cache.delete(messageId); s.cache.set(messageId, html);
        let bytes = 0; for (const item of s.cache.values()) bytes += item.html.length * 2;
        while (s.cache.size > CACHE_ITEMS || bytes > CACHE_BYTES) { const oldest = s.cache.keys().next().value; bytes -= s.cache.get(oldest).html.length * 2; s.cache.delete(oldest); }
      }
    }
    if (node.revision !== revision || !s.visible.has(messageId)) return;
    const bottom = attached(s) && nearBottom(), point = attached(s) ? anchor(s) : null;
    node.body.innerHTML = html.html;
    for (const link of node.body.querySelectorAll('a[href]')) { link.target = '_blank'; link.rel = 'noopener'; }
    for (const img of node.body.querySelectorAll('img')) { img.loading = 'lazy'; img.addEventListener('load', () => { node.height = node.root.offsetHeight; }, { once: true }); }
    node.body.style.height = ''; node.root.classList.remove('placeholder');
    node.height = node.root.offsetHeight;
    if (!attached(s)) return;
    if (bottom) history.scrollTop = history.scrollHeight; else restore(point);
  }

  function merge(s, page) {
    for (const message of page.thread.messages) {
      const previous = s.messages.get(message.id);
      if (previous && previous.updatedAt > message.updatedAt) continue;
      s.messages.set(message.id, message);
      if (!s.nodes.has(message.id)) {
        const node = document.createElement('article'); node.className = 'message'; node.dataset.message = message.id;
        node.classList.add(message.role === 'user' ? 'from-user' : 'from-agent');
        const role = document.createElement('div'); role.className = 'role'; role.textContent = message.role === 'user' ? 'You' : message.role;
        const body = document.createElement('div'); body.className = 'markdown'; body.style.height = '100px';
        node.append(role, body); s.nodes.set(message.id, { root: node, body }); s.observer.observe(node);
      }
    }
    const ordered = [...s.messages.values()].sort((a, b) => a.createdAt.localeCompare(b.createdAt) || a.id.localeCompare(b.id));
    let previous = null;
    for (const message of ordered) {
      const node = s.nodes.get(message.id).root;
      const next = previous ? previous.nextSibling : s.container.firstChild;
      if (node !== next) s.container.insertBefore(node, next);
      previous = node;
      if (s.visible.has(message.id)) void render(s, message.id);
    }
  }

  function drop(s, ids) {
    for (const id of ids) {
      const node = s.nodes.get(id);
      if (node) { s.observer.unobserve(node.root); node.root.remove(); }
      s.nodes.delete(id); s.messages.delete(id); s.visible.delete(id); s.cache.delete(id);
    }
  }

  const endpoint = s => `/api/chats/${encodeURIComponent(s.id)}`;
  function setStatus(s, text) { s.status = text; if (current === s) state.textContent = text; }
  function setError(s, text) { s.error = text; if (current === s) error.textContent = text; }

  async function loadOlder(s) {
    if (s.loading || !s.hasMore || !s.cursor || !s.id) return;
    s.loading = true; if (current === s) older.disabled = true;
    const point = attached(s) ? anchor(s) : null;
    try {
      const page = await api(`${endpoint(s)}?before=${encodeURIComponent(s.cursor)}`);
      merge(s, page); s.cursor = page.page.beforeCursor; s.hasMore = Boolean(page.page.hasMore);
      if (current === s) { older.hidden = !s.hasMore; restore(point); }
    } catch (e) { setStatus(s, e.message); }
    finally { s.loading = false; if (current === s) older.disabled = false; }
  }

  async function refresh(s) {
    if (!s?.id || s.polling || document.hidden) return;
    s.polling = true;
    try {
      const page = await api(endpoint(s));
      if (page.snapshotSequence < s.sequence) return;
      const bottom = attached(s) && nearBottom(), point = attached(s) ? anchor(s) : null;
      if (!s.initial && page.thread.messages.length && !page.thread.messages.some(m => s.messages.has(m.id))) {
        // Walk older pages until one overlaps the history known before this poll. Pages are staged and merged only
        // once the whole walk succeeds: a page merged before a later request fails would count as known on the retry
        // and stop the walk early, permanently hiding the rest of the gap.
        const known = new Set(s.messages.keys()), staged = [];
        let gap = page;
        while (gap.page.hasMore && gap.page.beforeCursor && !gap.thread.messages.some(m => known.has(m.id))) {
          if (staged.length >= GAP_PAGES) { drop(s, known); s.cursor = gap.page.beforeCursor; s.hasMore = Boolean(gap.page.hasMore); break; }
          gap = await api(`${endpoint(s)}?before=${encodeURIComponent(gap.page.beforeCursor)}`);
          staged.push(gap);
        }
        for (const fetched of staged) merge(s, fetched);
      }
      merge(s, page); s.sequence = page.snapshotSequence ?? s.sequence;
      if (s.pendingSend && page.thread.messages.some(m => m.id === s.pendingSend.messageId)) {
        if (s.draft === s.pendingSend.text) { s.draft = ''; if (current === s) draft.value = ''; }
        s.pendingSend = null; setError(s, '');
      }
      if (s.initial) { s.cursor = page.page.beforeCursor; s.hasMore = Boolean(page.page.hasMore); s.initial = false; if (current === s) older.hidden = !s.hasMore; }
      if (page.thread.title) s.title = page.thread.title;
      setStatus(s, page.thread.latestTurn?.state === 'running' ? 'Agent working' : '');
      if (attached(s)) { if (bottom) history.scrollTop = history.scrollHeight; else restore(point); jump.hidden = nearBottom(); }
    } catch (e) { setStatus(s, e.message); }
    finally { s.polling = false; }
  }

  function bind(s, g) {
    if (s.id || s.binding) return s.binding;
    const source = g.desktops.find(d => d.chatAvailable && !d.reconnecting) || g.desktops.find(d => d.chatAvailable);
    if (!source) return null;
    setStatus(s, 'Opening chat');
    s.binding = api('/api/chats', { host: source.host, desktop: source.desktop, generation: source.generation })
      .then(chat => { s.id = chat.id; bindings.set(s.agentId, { id: chat.id, title: chat.title || g.title, icon: g.icon || '' }); persist(); setStatus(s, ''); if (current === s) apply(); return refresh(s); })
      .catch(e => { setStatus(s, e.message); })
      .finally(() => { s.binding = null; });
    return s.binding;
  }

  function apply() {
    const s = current, available = Boolean(s?.id || (s && group?.chatAvailable));
    root.classList.toggle('unavailable', !available);
    draft.disabled = send.disabled = !available;
    state.textContent = !group ? '' : !s ? 'Unverified session' : !available ? 'Chat unavailable' : s.status;
    error.textContent = s?.error || '';
    older.hidden = !s?.hasMore; older.disabled = Boolean(s?.loading);
    jump.hidden = !s || nearBottom();
  }

  function select(g) {
    const same = Boolean(g && group && g.key === group.key);
    if (current) { current.draft = draft.value; current.scrollTop = history.scrollTop; current.atBottom = nearBottom(); }
    group = g;
    const next = g?.agentId ? chatState(g.agentId, g.title) : null;
    if (same && next === current) { if (next && !next.id) void bind(next, g); else apply(); return; }
    if (next !== current) {
      current = next;
      history.replaceChildren(older, ...(next ? [next.container] : []));
      draft.value = next?.draft || '';
      if (next) history.scrollTop = next.atBottom ? history.scrollHeight : next.scrollTop;
    }
    apply();
    if (!next) return;
    if (!next.id) void bind(next, g); else void refresh(next);
  }

  older.onclick = () => current && loadOlder(current);
  new IntersectionObserver(entries => { if (entries.some(entry => entry.isIntersecting) && current && !current.initial) void loadOlder(current); }, { root: history, rootMargin: '80px' }).observe(older);
  history.addEventListener('scroll', () => { jump.hidden = nearBottom(); if (history.scrollTop < 80 && current) void loadOlder(current); }, { passive: true });
  jump.onclick = () => { history.scrollTop = history.scrollHeight; };
  draft.addEventListener('input', () => { if (current) current.draft = draft.value; });
  draft.addEventListener('keydown', event => { if (event.key === 'Enter' && (event.ctrlKey || event.metaKey)) { event.preventDefault(); form.requestSubmit(); } });
  form.onsubmit = async event => {
    event.preventDefault();
    const s = current;
    if (!s?.id || send.disabled || !draft.value.trim()) return;
    const text = draft.value;
    if (text.length > 100000) return setError(s, 'Message is over 100,000 characters.');
    if (s.pendingSend && s.pendingSend.text !== text) return setError(s, 'Retry the unconfirmed message unchanged before sending another.');
    s.pendingSend ||= { text, commandId: crypto.randomUUID(), messageId: crypto.randomUUID() };
    const submission = s.pendingSend;
    send.disabled = true; setError(s, '');
    try {
      await api(`${endpoint(s)}/messages`, submission);
      if (current === s && draft.value === text) draft.value = '';
      if (s.draft === text) s.draft = '';
      s.pendingSend = null;
      await refresh(s);
      if (attached(s)) history.scrollTop = history.scrollHeight;
    } catch (e) { if (s.pendingSend === submission) setError(s, `${e.message} Retry Send to check the same submission.`); }
    finally { if (current === s) send.disabled = false; }
  };
  document.addEventListener('visibilitychange', () => { if (!document.hidden && current) void refresh(current); });
  setInterval(() => { if (current?.id && !document.hidden) void refresh(current); }, 2000);
  window.addEventListener('pagehide', () => { worker?.terminate(); worker = null; });
  window.addEventListener('pageshow', event => {
    if (!event.persisted) return;
    if (requests.size) ensureWorker();
    if (current) void refresh(current);
  });

  return {
    select,
    focus() { (draft.disabled ? history : draft).focus(); },
    bindings: () => bindings,
    forget(agentId) {
      bindings.delete(agentId); persist();
      const s = chats.get(agentId);
      if (s) { s.observer.disconnect(); chats.delete(agentId); if (current === s) { current = null; history.replaceChildren(older); draft.value = ''; apply(); } }
    }
  };
}
