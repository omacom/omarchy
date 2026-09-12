import DOMPurify from './vendor/purify.js';
import { api, native } from './api.js';
const $ = id => document.getElementById(id), history = $('history'), container = $('messages');
$('overview').onclick = () => native({ type: 'overview' });
const id = new URLSearchParams(location.search).get('id');
const endpoint = `api/chats/${encodeURIComponent(id)}`;
const messages = new Map(), nodes = new Map(), visible = new Set(), cache = new Map();
const worker = new Worker('markdown-worker.js', { type: 'module' });
let cursor, hasMore = false, polling = false, loading = false, initial = true, sequence = -1, rendered = 0, pendingSend;
const requests = new Map();
worker.onmessage = ({ data }) => { requests.get(data.id)?.(data); requests.delete(data.id); };
function parse(text) { return new Promise(resolve => { const request = ++rendered; requests.set(request, resolve); worker.postMessage({ id: request, text }); }); }
const nearBottom = () => history.scrollHeight - history.scrollTop - history.clientHeight < 120;
function anchor() {
  const top = history.getBoundingClientRect().top;
  const el = [...container.children].find(el => el.getBoundingClientRect().bottom > top);
  return el ? { el, offset: el.getBoundingClientRect().top - top } : null;
}
function restore(point) { if (point?.el.isConnected) history.scrollTop += point.el.getBoundingClientRect().top - history.getBoundingClientRect().top - point.offset; }
async function render(messageId) {
  const node = nodes.get(messageId), message = messages.get(messageId);
  if (!node || !visible.has(messageId)) return;
  const revision = `${message.updatedAt}/${message.text}`;
  if (node.revision === revision) return;
  node.revision = revision;
  let html = cache.get(messageId);
  if (!html || html.revision !== revision) {
    const parsed = await parse(message.text);
    html = { revision, html: DOMPurify.sanitize(parsed.html || parsed.error, {
      USE_PROFILES: { html: true }, FORBID_TAGS: ['form', 'input', 'button', 'textarea', 'iframe', 'style'],
      FORBID_ATTR: ['style', 'id', 'name'], ALLOW_DATA_ATTR: false
    }) };
    if (!message.streaming) {
      cache.delete(messageId); cache.set(messageId, html);
      while (cache.size > 80 || [...cache.values()].reduce((bytes, item) => bytes + item.html.length * 2, 0) > 16 * 1024 * 1024) cache.delete(cache.keys().next().value);
    }
  }
  if (node.revision !== revision || !visible.has(messageId)) return;
  const bottom = nearBottom(), point = anchor();
  node.body.innerHTML = html.html;
  for (const img of node.body.querySelectorAll('img')) { img.loading = 'lazy'; img.addEventListener('load', () => { node.height = node.root.offsetHeight; }, { once: true }); }
  node.body.style.height = ''; node.root.classList.remove('placeholder');
  node.height = node.root.offsetHeight;
  if (bottom) history.scrollTop = history.scrollHeight; else restore(point);
}
const observer = new IntersectionObserver(entries => {
  for (const entry of entries) {
    const messageId = entry.target.dataset.message;
    const node = nodes.get(messageId);
    if (entry.isIntersecting) { visible.add(messageId); void render(messageId); }
    else if (node) {
      visible.delete(messageId); node.height = node.root.offsetHeight;
      node.body.replaceChildren(); node.body.style.height = `${Math.max(24, node.height - 28)}px`;
      node.root.classList.add('placeholder'); node.revision = null;
    }
  }
}, { root: history, rootMargin: '600px' });
function merge(page) {
  for (const message of page.thread.messages) {
    const previous = messages.get(message.id);
    if (previous && previous.updatedAt > message.updatedAt) continue;
    messages.set(message.id, message);
    if (!nodes.has(message.id)) {
      const root = document.createElement('article'); root.className = 'message'; root.dataset.message = message.id;
      const role = document.createElement('div'); role.className = 'role'; role.textContent = message.role === 'user' ? 'You' : message.role;
      const body = document.createElement('div'); body.className = 'markdown'; body.style.height = '100px';
      root.append(role, body); nodes.set(message.id, { root, body }); observer.observe(root);
    }
  }
  const ordered = [...messages.values()].sort((a, b) => a.createdAt.localeCompare(b.createdAt) || a.id.localeCompare(b.id));
  let previous = null;
  for (const message of ordered) {
    const root = nodes.get(message.id).root;
    const next = previous ? previous.nextSibling : container.firstChild;
    if (root !== next) container.insertBefore(root, next);
    previous = root;
    if (visible.has(message.id)) void render(message.id);
  }
}
async function older() {
  if (loading || !hasMore || !cursor) return;
  loading = true; $('older').disabled = true;
  const point = anchor();
  try {
    const page = await api(`${endpoint}?before=${encodeURIComponent(cursor)}`);
    merge(page); cursor = page.page.beforeCursor; hasMore = page.page.hasMore;
    $('older').hidden = !hasMore; restore(point);
  } catch (error) { $('status').textContent = error.message; }
  finally { loading = false; $('older').disabled = false; }
}
async function refresh() {
  if (polling || document.hidden) return;
  polling = true;
  try {
    const page = await api(endpoint);
    if (page.snapshotSequence < sequence) return;
    const bottom = nearBottom(), point = anchor();
    if (!initial && page.thread.messages.length && !page.thread.messages.some(m => messages.has(m.id))) {
      let gap = page;
      while (gap.page.hasMore && !gap.thread.messages.some(m => messages.has(m.id))) {
        gap = await api(`${endpoint}?before=${encodeURIComponent(gap.page.beforeCursor)}`);
        const overlap = gap.thread.messages.some(m => messages.has(m.id));
        merge(gap); if (overlap) break;
      }
    }
    merge(page); sequence = page.snapshotSequence;
    if (pendingSend && page.thread.messages.some(message => message.id === pendingSend.messageId)) {
      if ($('draft').value === pendingSend.text) $('draft').value = '';
      pendingSend = null; $('send-error').textContent = '';
    }
    if (initial) { cursor = page.page.beforeCursor; hasMore = page.page.hasMore; $('older').hidden = !hasMore; initial = false; }
    $('heading').textContent = page.thread.title; document.title = `Chat · ${page.thread.title}`;
    $('status').textContent = page.thread.latestTurn?.state === 'running' ? 'Agent working' : '';
    if (bottom) history.scrollTop = history.scrollHeight; else restore(point);
    $('jump').hidden = nearBottom();
  } catch (error) { $('status').textContent = error.message; }
  finally { polling = false; }
}
$('older').onclick = older;
new IntersectionObserver(entries => {
  if (entries.some(entry => entry.isIntersecting) && !initial) void older();
}, { root: history, rootMargin: '80px' }).observe($('older'));
history.addEventListener('scroll', () => { $('jump').hidden = nearBottom(); if (history.scrollTop < 80) void older(); }, { passive: true });
$('jump').onclick = () => { history.scrollTop = history.scrollHeight; };
$('composer').onsubmit = async event => {
  event.preventDefault(); if ($('send').disabled || !$('draft').value.trim()) return;
  const text = $('draft').value;
  if (pendingSend && pendingSend.text !== text) { $('send-error').textContent = 'Retry the unconfirmed message unchanged before sending another.'; return; }
  pendingSend ||= { text, commandId: crypto.randomUUID(), messageId: crypto.randomUUID() };
  const submission = pendingSend;
  $('send').disabled = true; $('send-error').textContent = '';
  try {
    await api(`${endpoint}/messages`, submission);
    if ($('draft').value === text) $('draft').value = '';
    pendingSend = null; await refresh(); history.scrollTop = history.scrollHeight;
  } catch (error) { if (pendingSend === submission) $('send-error').textContent = `${error.message} Retry Send to check the same submission.`; }
  finally { $('send').disabled = false; }
};
$('draft').addEventListener('keydown', event => { if (event.key === 'Enter' && (event.ctrlKey || event.metaKey)) { event.preventDefault(); $('composer').requestSubmit(); } });
container.addEventListener('click', event => {
  const link = event.target.closest('a'); if (!link) return;
  event.preventDefault();
  try { const url = new URL(link.getAttribute('href')); if (['http:', 'https:'].includes(url.protocol)) native({ type: 'link', url: url.href }); } catch { /* Relative file paths stay text. */ }
});
document.addEventListener('visibilitychange', () => { if (!document.hidden) void refresh(); });
window.addEventListener('pagehide', () => worker.terminate());
void refresh(); setInterval(refresh, 1000);
