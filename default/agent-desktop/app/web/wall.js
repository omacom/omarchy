import RFB from './novnc/core/rfb.js';
import { api, native } from './api.js';
const tiles = document.getElementById('tiles'), status = document.getElementById('status');
const empty = document.getElementById('empty');
const active = new Map(), attention = new Map();
let focused, refreshing = false, page = 0;
const group = new URLSearchParams(location.search).get('agent');
const overview = document.getElementById('overview');
overview.hidden = !group; overview.onclick = () => native({ type: 'overview' });
const pager = document.getElementById('pager');
pager.onclick = () => { page++; void refresh(); };
const key = d => `${d.host || "local"}/${d.desktop}/${d.generation}`;
function groupColor(id) {
  let hash = 0; for (const char of id) hash = (Math.imul(hash, 31) + char.charCodeAt(0)) | 0;
  return `hsl(${(hash >>> 0) % 360} 65% 65%)`;
}
function layout() {
  const count = focused ? 1 : active.size;
  if (!count) return;
  let best = { area: 0, columns: 1, rows: count };
  for (let columns = 1; columns <= count; columns++) {
    const rows = Math.ceil(count / columns);
    const width = tiles.clientWidth / columns, height = tiles.clientHeight / rows - 38;
    const area = Math.max(0, Math.min(width * 9 / 16, height)) ** 2;
    if (area > best.area) best = { area, columns, rows };
  }
  const last = count - best.columns * (best.rows - 1);
  const tracks = best.columns * last;
  tiles.style.gridTemplateColumns = `repeat(${tracks}, minmax(0, 1fr))`;
  tiles.style.gridTemplateRows = `repeat(${best.rows}, minmax(0, 1fr))`;
  let index = 0;
  for (const [id, tile] of active) {
    tile.root.hidden = Boolean(focused && focused !== id);
    if (tile.root.hidden) tile.stop();
    else {
      const inLastRow = index >= best.columns * (best.rows - 1);
      tile.root.style.gridColumn = `span ${tracks / (inLastRow ? last : best.columns)}`;
      tile.quality();
      index++;
    }
  }
}
function tile(d) {
  const root = document.createElement('article'); root.className = 'tile';
  root.innerHTML = '<div class="screen"></div><div class="tile-footer"><div class="identity"><img alt=""><span></span><small class="host"></small></div><button class="size">Enlarge</button><button class="control" disabled>Take control</button><span class="agent-status" role="status"></span><button class="chat">Chat</button></div>';
  const screen = root.querySelector('.screen'), identity = root.querySelector('.identity span'), icon = root.querySelector('img');
  const note = document.createElement('span'); note.className = 'stream-status'; screen.append(note);
  let rfb, attempt = 0, connecting = false, disposed = false, profile = 'preview', wantsControl = false;
  const control = root.querySelector('.control');
  const controlNote = document.createElement('button');
  controlNote.className = 'control-note'; controlNote.textContent = 'You’re controlling · Esc to watch'; controlNote.hidden = true; screen.append(controlNote);
  function inputState() {
    root.classList.toggle('controlling', wantsControl); controlNote.hidden = !wantsControl;
    control.textContent = wantsControl ? 'Lock input' : 'Take control';
    control.setAttribute('aria-pressed', String(wantsControl));
  }
  function watch() {
    wantsControl = false; if (rfb) rfb.viewOnly = true; inputState(); quality();
  }
  controlNote.onclick = watch;
  function stop(preserveControl = false) {
    if (!preserveControl) wantsControl = false;
    attempt++; connecting = false;
    const old = rfb; rfb = null; old?.disconnect();
    control.disabled = true; inputState();
  }
  async function connect() {
    if (rfb || connecting || disposed || root.hidden || document.hidden || !d.ready) return;
    connecting = true; const current = ++attempt; note.textContent = 'Connecting'; note.hidden = false;
    try {
      const info = await api(`api/desktops/${encodeURIComponent(d.host || "local")}/${d.desktop}/connect?generation=${encodeURIComponent(d.generation)}`);
      if (disposed || current !== attempt || document.hidden) return;
      const url = new URL(`stream/${encodeURIComponent(d.host || "local")}/${d.desktop}?generation=${encodeURIComponent(info.generation)}&profile=${profile}`, location.href); url.protocol = 'ws:';
      const canvas = document.createElement('div'); canvas.style.cssText = 'width:100%;height:100%'; screen.prepend(canvas);
      rfb = new RFB(canvas, url.href, { credentials: { password: info.password } });
      rfb.scaleViewport = true; rfb.resizeSession = false; rfb.viewOnly = !wantsControl; rfb.qualityLevel = profile === 'preview' ? 2 : 8; rfb.compressionLevel = profile === 'preview' ? 6 : 2; rfb.background = '#090b0d';
      rfb.addEventListener('connect', () => { if (current !== attempt) return; note.hidden = true; control.disabled = false; inputState(); });
      rfb.addEventListener('disconnect', () => { canvas.remove(); if (current !== attempt) return; wantsControl = false; stop(); note.hidden = false; note.textContent = 'Reconnecting'; });
    } catch (error) { if (current === attempt) note.textContent = error.message; }
    finally { if (current === attempt) connecting = false; }
  }
  control.onclick = () => {
    if (!rfb) return;
    wantsControl = rfb.viewOnly; rfb.viewOnly = !wantsControl;
    inputState();
    quality();
  };
  root.querySelector('.size').onclick = event => { focused = focused === key(d) ? null : key(d); event.target.textContent = focused ? 'Tile' : 'Enlarge'; layout(); };
  root.querySelector('.chat').onclick = async () => {
    try { const chat = await api('api/chats', { host: d.host, desktop: d.desktop, generation: d.generation }); native({ type: 'chat', ...chat }); }
    catch (error) { status.textContent = error.message; }
  };
  function update(value) {
    d = value; identity.textContent = d.title || d.owner; identity.title = d.title || d.owner;
    const badge = root.querySelector('.agent-status');
    badge.textContent = d.reconnecting ? 'Reconnecting' : !d.ready ? 'Offline' : d.agentStatus || 'Unknown';
    root.classList.toggle('attention', d.agentStatus === 'Waiting for you');
    root.querySelector('.host').textContent = d.host || 'local';
    badge.title = `${d.host || 'local'} · desktop ${d.desktop} · ${badge.textContent}`;
    root.style.setProperty('--agent-color', d.agentId ? groupColor(d.agentId) : 'transparent');
    icon.hidden = !d.icon; if (d.icon && icon.src !== d.icon) icon.src = d.icon;
    root.querySelector('.chat').disabled = !d.threadId;
    if (!d.ready) { stop(); note.hidden = false; note.textContent = d.reconnecting ? 'Reconnecting' : 'Desktop unavailable'; } else void connect();
  }
  function quality() {
    const next = wantsControl || focused === key(d) || screen.clientWidth >= 900 ? 'full' : 'preview';
    if (next !== profile) { profile = next; stop(true); void connect(); }
  }
  const resize = new ResizeObserver(quality); resize.observe(screen);
  tiles.append(root); update(d);
  return { root, update, stop, quality, watch, controlling: () => wantsControl, dispose() { disposed = true; resize.disconnect(); stop(); root.remove(); } };
}
async function refresh() {
  if (refreshing || (document.hidden && group)) return;
  refreshing = true;
  try {
    const data = await api('api/desktops'); status.textContent = data.warning || '';
    if (!group) {
      const waiting = new Map(data.desktops.filter(d => d.agentId && d.agentStatus === 'Waiting for you').map(d => [d.agentId, d]));
      for (const id of attention.keys()) if (!waiting.has(id)) attention.delete(id);
      for (const [id, d] of waiting) if (!attention.has(id)) {
        try { attention.set(id, await api('api/chats', { host: d.host, desktop: d.desktop, generation: d.generation })); } catch { /* Retry verified binding next refresh. */ }
      }
      native({ type: 'attention', chats: [...attention.values()] });
    }
    const all = data.desktops.filter(d => !group || d.agentId === group);
    empty.hidden = all.length > 0 || Boolean(data.warning);
    empty.querySelector('p').textContent = group ? 'No active desktops for this agent' : 'No active desktops';
    const pages = Math.ceil(all.length / 8); page = pages ? page % pages : 0;
    pager.hidden = pages <= 1; pager.textContent = `${page + 1}/${pages} · Next`;
    data.desktops = all.slice(page * 8, (page + 1) * 8);
    const ids = new Set(data.desktops.map(key));
    for (const [id, item] of active) if (!ids.has(id)) { item.dispose(); active.delete(id); if (focused === id) focused = null; }
    for (const d of data.desktops) { const id = key(d); if (active.has(id)) active.get(id).update(d); else active.set(id, tile(d)); }
    layout();
  } catch (error) { empty.hidden = true; status.textContent = error.message; }
  finally { refreshing = false; }
}
let escapeConsumed = false;
window.addEventListener('keydown', event => {
  if (event.key !== 'Escape' || ![...active.values()].some(tile => tile.controlling())) return;
  event.preventDefault(); event.stopImmediatePropagation(); escapeConsumed = true;
  for (const tile of active.values()) tile.watch();
}, true);
window.addEventListener('keyup', event => {
  if (event.key === 'Escape' && escapeConsumed) { event.preventDefault(); event.stopImmediatePropagation(); escapeConsumed = false; }
}, true);
new ResizeObserver(layout).observe(tiles);
document.addEventListener('visibilitychange', () => { if (document.hidden) for (const item of active.values()) item.stop(); else void refresh(); });
window.addEventListener('pagehide', () => { for (const item of active.values()) item.dispose(); });
void refresh(); setInterval(refresh, 2000);
