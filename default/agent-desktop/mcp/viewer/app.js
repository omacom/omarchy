import { api } from '/api.js';
import { createTile, installVideo, KEYS } from '/stream.js';
import { createChat } from '/chat.js';

const $ = id => document.getElementById(id);
const ORDER = ['Waiting for you', 'Needs attention', 'Working', 'Ready', 'Unknown', 'Finished', 'Stopped', 'Reconnecting', 'Ended'];
const rank = status => { const i = ORDER.indexOf(status); return i < 0 ? ORDER.indexOf('Unknown') : i; };
const desktopKey = d => `${d.host}/${d.desktop}/${d.generation}`;
const groupKey = d => d.agentId ? `agent:${d.agentId}` : `session:${desktopKey(d)}`;
function hue(id) { let h = 0; for (const char of id) h = (Math.imul(h, 31) + char.charCodeAt(0)) | 0; return (h >>> 0) % 360; }
const setText = (el, value) => { if (el.textContent !== value) el.textContent = value; };
const narrow = matchMedia('(max-width: 1199px)');

const hosts = new Map(), desktops = new Map(), groups = new Map(), rows = new Map(), tiles = new Map();
let selected = null, loaded = false, refreshing = false, controlling = null, focusedTile = null;
const video = installVideo($('fullscreen-video'));
const chat = createChat({ root: $('chat') });

function ingest({ hosts: list, desktops: rows }) {
  const seen = new Set(rows.map(desktopKey));
  for (const host of list) {
    hosts.set(host.id, host.online);
    for (const [key, d] of desktops) {
      if (d.host !== host.id) continue;
      if (host.online && !seen.has(key)) desktops.delete(key);
      else if (!host.online) d.reconnecting = true;
    }
  }
  for (const d of rows) {
    const key = desktopKey(d), previous = desktops.get(key);
    if (previous) Object.assign(previous, d, { reconnecting: false });
    else desktops.set(key, { ...d, reconnecting: false });
  }
  for (const [key, d] of desktops) if (!hosts.has(d.host)) desktops.delete(key);
}

function buildGroups() {
  const next = new Map();
  for (const d of desktops.values()) {
    const key = groupKey(d);
    let g = next.get(key);
    if (!g) { g = { key, agentId: d.agentId || null, title: d.title || d.owner || 'Agent desktop', icon: '', desktops: [], chatAvailable: false, ended: false }; next.set(key, g); }
    g.desktops.push(d);
    if (d.chatAvailable) g.chatAvailable = true;
    if (d.icon && !g.icon) g.icon = d.icon;
  }
  for (const [agentId, binding] of chat.bindings()) {
    const key = `agent:${agentId}`;
    if (!next.has(key)) next.set(key, { key, agentId, title: binding.title || 'Agent', icon: binding.icon || '', desktops: [], chatAvailable: true, ended: true });
  }
  for (const g of next.values()) {
    g.desktops.sort((a, b) => a.host.localeCompare(b.host) || a.desktop - b.desktop);
    const live = g.desktops.filter(d => !d.reconnecting);
    g.status = g.ended ? 'Ended' : !live.length ? 'Reconnecting' : live.map(d => d.agentStatus || 'Unknown').sort((a, b) => rank(a) - rank(b))[0];
  }
  groups.clear();
  for (const g of [...next.values()].sort((a, b) => rank(a.status) - rank(b.status) || a.title.localeCompare(b.title) || a.key.localeCompare(b.key))) groups.set(g.key, g);
}

function rowElement(g) {
  const li = document.createElement('li'); li.dataset.group = g.key;
  const button = document.createElement('button'); button.type = 'button'; button.className = 'row';
  button.innerHTML = '<img class="icon" alt=""><span class="name"></span><span class="where"></span><span class="status"></span>';
  button.onclick = () => select(g.key);
  li.append(button);
  return li;
}
function updateRow(li, g) {
  li.style.setProperty('--hue', g.agentId ? String(hue(g.agentId)) : '');
  li.classList.toggle('verified', Boolean(g.agentId));
  li.classList.toggle('attention', g.status === 'Waiting for you' || g.status === 'Needs attention');
  const icon = li.querySelector('.icon');
  icon.hidden = !g.icon; if (g.icon && icon.getAttribute('src') !== g.icon) icon.src = g.icon;
  setText(li.querySelector('.name'), g.title);
  setText(li.querySelector('.where'), g.desktops.map(d => `${d.host}/${d.desktop}`).join('  '));
  const status = li.querySelector('.status');
  setText(status, g.status); status.dataset.status = g.status;
  li.querySelector('.row').setAttribute('aria-current', selected === g.key ? 'true' : 'false');
}
function renderRail() {
  const list = $('agents'), ordered = [];
  for (const g of groups.values()) {
    let li = rows.get(g.key);
    if (!li) { li = rowElement(g); rows.set(g.key, li); }
    updateRow(li, g); ordered.push(li);
  }
  for (const [key, li] of rows) if (!groups.has(key)) { li.remove(); rows.delete(key); }
  const same = ordered.length === list.children.length && ordered.every((li, i) => list.children[i] === li);
  // Reordering would blur a row the user is about to activate; the next poll catches up.
  if (!same && !list.contains(document.activeElement)) list.replaceChildren(...ordered);
  else for (const li of ordered) if (!li.isConnected) list.append(li);
  const online = [...hosts.values()].some(Boolean);
  setText($('rail-state'), !loaded ? 'Finding desktops…' : groups.size ? '' : online ? 'No active desktops' : 'No machines reachable');
  $('rail-state').hidden = !$('rail-state').textContent;
}
function renderHosts() {
  const strip = $('hosts');
  const items = [...hosts].map(([id, online]) => {
    let li = strip.querySelector(`li[data-host="${CSS.escape(id)}"]`);
    if (!li) { li = document.createElement('li'); li.dataset.host = id; li.innerHTML = '<span class="dot"></span><span class="host"></span><span class="count"></span>'; li.querySelector('.host').textContent = id; }
    li.classList.toggle('offline', !online);
    const count = [...desktops.values()].filter(d => d.host === id && !d.reconnecting).length;
    setText(li.querySelector('.count'), count ? String(count) : '');
    li.title = `${id} · ${online ? 'online' : 'offline'}`;
    return li;
  });
  const same = items.length === strip.children.length && items.every((li, i) => strip.children[i] === li);
  if (!same) strip.replaceChildren(...items);
}

function setControlling(tile, wants, toggleKeyboard = false) {
  if (wants) {
    for (const other of tiles.values()) if (other !== tile) other.watch();
    if (controlling !== tile) { controlling = tile; $('typing').hidden = true; }
    else if (toggleKeyboard) { $('typing').hidden = !$('typing').hidden; if (!$('typing').hidden) $('keys').focus(); }
  } else if (controlling === tile) { controlling = null; $('typing').hidden = true; $('keys').value = ''; }
  document.body.classList.toggle('controlling', Boolean(controlling));
}
function layoutTiles() {
  const chatOnly = narrow.matches && document.body.classList.contains('tab-chat');
  if (focusedTile && !tiles.has(focusedTile.key)) focusedTile = null;
  const visible = [...tiles.values()].filter(tile => !chatOnly && (!focusedTile || focusedTile === tile));
  $('desktops').classList.toggle('single', visible.length === 1);
  for (const tile of tiles.values()) tile.layout({ shown: visible.includes(tile), sole: visible.length === 1, focused: focusedTile === tile });
}
const tileHooks = {
  video,
  onControl: setControlling,
  onFocus(tile) { focusedTile = focusedTile === tile ? null : tile; layoutTiles(); },
  onChat() { if (narrow.matches) setTab(true); chat.focus(); }
};
function renderStage() {
  const g = selected ? groups.get(selected) : null;
  const active = Boolean(selected && (g || loaded));
  document.body.classList.toggle('selected', active);
  $('work').hidden = !active;
  $('idle').hidden = active || !groups.size;
  if (!active) { for (const tile of tiles.values()) tile.dispose(); tiles.clear(); controlling = null; $('typing').hidden = true; chat.select(null); return; }
  const icon = $('stage-icon');
  icon.hidden = !g?.icon; if (g?.icon && icon.getAttribute('src') !== g.icon) icon.src = g.icon;
  setText($('stage-title'), g ? g.title : 'Ended');
  const status = $('stage-status'); setText(status, g ? g.status : ''); status.dataset.status = g?.status || '';
  $('stage-head').style.setProperty('--hue', g?.agentId ? String(hue(g.agentId)) : '0');
  $('stage-head').classList.toggle('verified', Boolean(g?.agentId));
  $('dismiss').hidden = !g?.ended;
  const want = new Map((g?.desktops || []).map(d => [desktopKey(d), d]));
  for (const [key, tile] of tiles) if (!want.has(key)) { tile.dispose(); tiles.delete(key); if (controlling === tile) setControlling(tile, false); }
  const ordered = [];
  for (const [key, d] of want) {
    let tile = tiles.get(key);
    if (!tile) { tile = createTile(d, tileHooks); tiles.set(key, tile); }
    ordered.push(tile.root);
  }
  const grid = $('desktops');
  const same = ordered.length === grid.children.length && ordered.every((el, i) => grid.children[i] === el);
  if (!same && !grid.contains(document.activeElement)) grid.replaceChildren(...ordered);
  else for (const el of ordered) if (!el.isConnected) grid.append(el);
  layoutTiles();
  for (const [key, d] of want) tiles.get(key).update(d);
  const empty = $('stage-empty');
  empty.hidden = tiles.size > 0;
  setText(empty, !g ? 'This desktop has ended' : g.ended ? 'Desktops closed · chat stays open' : 'No desktops');
  chat.select(g);
}

async function refresh() {
  if (refreshing || document.hidden) return;
  refreshing = true;
  try {
    const data = await api('/api/desktops');
    ingest(data); loaded = true;
    setText($('notice'), '');
    buildGroups(); renderHosts(); renderRail(); renderStage();
  } catch (error) {
    setText($('notice'), loaded ? 'Desktop service unreachable · retrying' : '');
    if (!loaded) { setText($('rail-state'), 'Desktop service unreachable. Check Tailscale.'); $('rail-state').hidden = false; }
  } finally { refreshing = false; }
}

function routeFor(key) {
  if (key.startsWith('agent:')) return `#/agent/${encodeURIComponent(key.slice(6))}`;
  const [host, n, generation] = key.slice(8).split('/');
  return `#/session/${encodeURIComponent(host)}/${n}/${encodeURIComponent(generation)}`;
}
function parseHash() {
  const agent = location.hash.match(/^#\/agent\/([^/]+)$/);
  if (agent) return `agent:${decodeURIComponent(agent[1])}`;
  const session = location.hash.match(/^#\/session\/([a-z][a-z0-9-]*)\/([1-9]\d*)\/([^/]+)$/);
  if (session) return `session:${session[1]}/${session[2]}/${decodeURIComponent(session[3])}`;
  return null;
}
function select(key) { location.hash = key ? routeFor(key) : '#/'; }
function applyRoute() {
  const key = parseHash();
  if (key === selected) return;
  if (controlling) setControlling(controlling, false);
  void video.leave();
  selected = key; focusedTile = null;
  setTab(false);
  renderRail(); renderStage();
}
function setTab(chatTab) {
  document.body.classList.toggle('tab-chat', chatTab);
  $('tab-desktops').setAttribute('aria-selected', String(!chatTab));
  $('tab-chat').setAttribute('aria-selected', String(chatTab));
  layoutTiles();
}
$('tab-desktops').onclick = () => setTab(false);
$('tab-chat').onclick = () => setTab(true);
$('back').onclick = () => select(null);
$('dismiss').onclick = () => { const g = groups.get(selected); if (g?.agentId) chat.forget(g.agentId); select(null); void refresh(); };
narrow.addEventListener('change', layoutTiles);

// Escape leaves human control and must never reach the remote desktop.
let escapeConsumed = false;
window.addEventListener('keydown', event => {
  if (event.key !== 'Escape' || !controlling) return;
  event.preventDefault(); event.stopImmediatePropagation(); escapeConsumed = true;
  controlling.watch();
}, true);
window.addEventListener('keyup', event => {
  if (event.key === 'Escape' && escapeConsumed) { event.preventDefault(); event.stopImmediatePropagation(); escapeConsumed = false; }
}, true);

const keys = $('keys');
function sendDraft() { controlling?.sendText(keys.value); keys.value = ''; }
function enter() { sendDraft(); controlling?.sendKey(KEYS.enter); }
keys.addEventListener('keydown', event => { if (event.key === 'Enter' && !event.isComposing) { event.preventDefault(); enter(); } });
$('send-keys').onclick = sendDraft;
$('enter').onclick = enter;
$('escape').onclick = () => controlling?.sendKey(KEYS.escape);
$('backspace').onclick = () => {
  if (!keys.value) return controlling?.sendKey(KEYS.backspace);
  const start = keys.selectionStart, end = keys.selectionEnd;
  const before = Array.from(keys.value.slice(0, start));
  if (start === end) before.pop();
  const prefix = before.join(''); keys.value = prefix + keys.value.slice(end);
  keys.setSelectionRange(prefix.length, prefix.length);
};
$('hide-keyboard').onclick = () => { keys.blur(); $('typing').hidden = true; };

window.addEventListener('hashchange', applyRoute);
// Streams close on pagehide so the page can enter the back-forward cache; a persisted pageshow reopens them.
window.addEventListener('pagehide', () => { for (const tile of tiles.values()) tile.stop(); video.stop(); });
window.addEventListener('pageshow', event => { if (event.persisted) { layoutTiles(); void refresh(); } });
document.addEventListener('visibilitychange', () => {
  if (document.hidden) { for (const tile of tiles.values()) tile.stop(); video.stop(); }
  else void refresh();
});
applyRoute(); void refresh();
setInterval(refresh, 4000);
