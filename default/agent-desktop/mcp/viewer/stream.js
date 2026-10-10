import RFB from '/novnc/core/rfb.js';
import { api } from '/api.js';

// One shared <video> for native fullscreen playback of whichever tile asked for it.
export function installVideo(video) {
  let stream, owner;
  function stop() {
    stream?.getTracks().forEach(track => track.stop()); stream = null; owner = null;
    video.pause(); video.srcObject = null; video.hidden = true;
  }
  video.addEventListener('webkitendfullscreen', () => { video.hidden = true; });
  document.addEventListener('fullscreenchange', () => { if (!document.fullscreenElement) video.hidden = true; });
  return {
    prepare(canvas, tile) {
      if (owner === tile && stream) return Promise.resolve(true);
      stop();
      if (!canvas?.captureStream) return Promise.resolve(false);
      return new Promise(resolve => {
        try {
          stream = canvas.captureStream(15); owner = tile; video.srcObject = stream;
          video.addEventListener('loadeddata', () => resolve(owner === tile), { once: true });
          void video.play().catch(() => {});
        } catch { stop(); resolve(false); }
      });
    },
    async enter(tile) {
      if (owner !== tile || !stream) throw new Error('Unavailable');
      video.hidden = false;
      // Apple's native video player is distinct from fullscreening the page.
      if (video.webkitEnterFullscreen) video.webkitEnterFullscreen();
      else if (video.requestFullscreen) await video.requestFullscreen();
      else throw new Error('Unsupported');
      await video.play();
    },
    async leave() {
      if (document.fullscreenElement) await document.exitFullscreen().catch(() => {});
      if (video.webkitDisplayingFullscreen) video.webkitExitFullscreen();
      video.hidden = true;
    },
    release(tile) { if (owner === tile) stop(); },
    stop
  };
}

const KEYS = { enter: 0xff0d, escape: 0xff1b, backspace: 0xff08 };
export const keysym = char => { const cp = char.codePointAt(0); return cp > 255 ? 0x01000000 + cp : cp; };

export function createTile(initial, { onControl, onFocus, onChat, video }) {
  let d = initial;
  const root = document.createElement('article'); root.className = 'tile';
  root.innerHTML = '<div class="screen"><span class="note" role="status"></span><button class="controlling-note" type="button" hidden>Controlling · Esc to watch</button></div>'
    + '<div class="tile-bar"><img class="icon" alt="" hidden><span class="title"></span><button class="chat" type="button" disabled>Chat</button>'
    + '<span class="where"></span><span class="status"></span><span class="actions">'
    + '<button class="control" type="button" disabled aria-pressed="false">Take control</button>'
    + '<button class="keyboard" type="button" hidden>Keyboard</button>'
    + '<button class="fullscreen" type="button" disabled>Fullscreen</button>'
    + '<button class="enlarge" type="button" aria-pressed="false">Enlarge</button>'
    + '<details class="more"><summary aria-label="More">⋯</summary><div class="menu"><button class="fit" type="button">Actual size</button><button class="reconnect" type="button">Reconnect</button></div></details>'
    + '</span></div>';
  const q = sel => root.querySelector(sel);
  const screen = q('.screen'), note = q('.note'), controlNote = q('.controlling-note');
  const icon = q('.icon'), title = q('.title'), chat = q('.chat');
  const control = q('.control'), keyboard = q('.keyboard'), fullscreen = q('.fullscreen'), enlarge = q('.enlarge'), fit = q('.fit'), reconnect = q('.reconnect'), more = q('.more');
  let rfb, holder, attempt = 0, connecting = false, disposed = false, profile = 'preview', wantsControl = false, fitted = true, shown = true, sole = false, focused = false;
  const tile = {};
  const key = `${d.host}/${d.desktop}/${d.generation}`;
  function inputState() {
    root.classList.toggle('controlling', wantsControl); controlNote.hidden = !wantsControl;
    control.textContent = wantsControl ? 'Watch' : 'Take control';
    control.setAttribute('aria-pressed', String(wantsControl));
    keyboard.hidden = !wantsControl;
  }
  function watch() {
    if (!wantsControl) return;
    wantsControl = false; if (rfb) rfb.viewOnly = true;
    inputState(); onControl(tile, false); quality();
  }
  function stop(preserveControl = false) {
    if (!preserveControl && wantsControl) { wantsControl = false; onControl(tile, false); }
    attempt++; connecting = false;
    const old = rfb; rfb = null; old?.disconnect();
    holder?.remove(); holder = null;
    video.release(tile); fullscreen.disabled = true;
    control.disabled = true; inputState();
  }
  function status(text) { note.hidden = !text; note.textContent = text || ''; }
  async function connect() {
    if (rfb || connecting || disposed || !shown || document.hidden || !d.ready || d.reconnecting) return;
    connecting = true; const current = ++attempt; status('Connecting');
    try {
      const info = await api(`/api/desktops/${encodeURIComponent(d.host)}/${d.desktop}/connect?generation=${encodeURIComponent(d.generation)}`);
      if (disposed || current !== attempt || document.hidden) return;
      const url = new URL(`/view/${encodeURIComponent(d.host)}/${d.desktop}`, location.href);
      url.searchParams.set('generation', info.generation); url.searchParams.set('profile', profile);
      url.protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
      holder = document.createElement('div'); holder.className = 'canvas'; screen.prepend(holder);
      const connection = new RFB(holder, url.href, { credentials: { password: info.password } });
      rfb = connection;
      connection.scaleViewport = fitted; connection.clipViewport = !fitted; connection.dragViewport = !fitted;
      connection.resizeSession = false; connection.viewOnly = !wantsControl; connection.background = '#0b0d0c';
      connection.qualityLevel = profile === 'preview' ? 2 : 8; connection.compressionLevel = profile === 'preview' ? 6 : 2;
      connection.addEventListener('connect', () => {
        if (rfb !== connection) return;
        status(''); control.disabled = false; inputState();
        if (sole) void prepareVideo();
      });
      connection.addEventListener('disconnect', () => {
        if (rfb !== connection) return;
        stop(); status('Disconnected · reconnecting');
      });
      connection.addEventListener('securityfailure', () => { if (rfb === connection) status('Stream refused'); });
    } catch (error) { if (current === attempt) status(error.message); }
    finally { if (current === attempt) connecting = false; }
  }
  async function prepareVideo() {
    const canvas = holder?.querySelector('canvas');
    if (!canvas) return;
    fullscreen.disabled = !(await video.prepare(canvas, tile)) || !rfb;
  }
  function quality() {
    const next = wantsControl || focused || sole || screen.clientWidth >= 900 ? 'full' : 'preview';
    if (next !== profile) { profile = next; stop(true); void connect(); }
  }
  control.onclick = () => {
    if (!rfb) return;
    wantsControl = !wantsControl; rfb.viewOnly = !wantsControl;
    inputState(); onControl(tile, wantsControl); quality();
  };
  controlNote.onclick = watch;
  keyboard.onclick = () => onControl(tile, wantsControl, true);
  fit.onclick = () => {
    fitted = !fitted; more.open = false;
    fit.textContent = fitted ? 'Actual size' : 'Fit to screen';
    if (rfb) { rfb.scaleViewport = fitted; rfb.clipViewport = !fitted; rfb.dragViewport = !fitted; }
  };
  reconnect.onclick = () => { more.open = false; stop(true); void connect(); };
  enlarge.onclick = () => onFocus(tile);
  chat.onclick = () => onChat(tile);
  fullscreen.onclick = async () => {
    if (!rfb) return;
    if (wantsControl) watch();
    try { await video.enter(tile); }
    catch { status('Native video fullscreen is unavailable in this browser.'); setTimeout(() => { if (rfb) status(''); }, 4000); }
  };
  function update(value) {
    d = value;
    icon.hidden = !d.icon; if (d.icon && icon.getAttribute('src') !== d.icon) icon.src = d.icon;
    title.textContent = d.title || d.owner || 'Agent desktop';
    chat.disabled = !d.agentId;
    chat.title = d.agentId ? 'Open chat' : 'Chat needs a verified agent session';
    q('.where').textContent = `${d.host} · ${d.desktop}`;
    const badge = q('.status');
    badge.textContent = d.reconnecting ? 'Reconnecting' : !d.ready ? 'Unavailable' : d.agentStatus || 'Unknown';
    badge.dataset.status = badge.textContent;
    if (!d.ready || d.reconnecting) { stop(); status(d.reconnecting ? 'Host reconnecting' : 'Desktop unavailable'); }
    else void connect();
  }
  function layout({ shown: visible, sole: only, focused: big }) {
    shown = visible; sole = only; focused = big;
    root.hidden = !shown;
    root.classList.toggle('focused', focused);
    enlarge.textContent = focused ? 'Shrink' : 'Enlarge';
    enlarge.setAttribute('aria-pressed', String(focused));
    fullscreen.hidden = !sole;
    if (!shown) stop(); else { quality(); void connect(); if (rfb && sole) void prepareVideo(); }
  }
  const resize = new ResizeObserver(() => { if (shown) quality(); });
  resize.observe(screen);
  Object.assign(tile, {
    root, key, update, layout, stop, watch, quality,
    controlling: () => wantsControl,
    sendKey(code) { if (rfb && wantsControl) rfb.sendKey(code); },
    sendText(text) { for (const char of text) tile.sendKey(keysym(char)); },
    dispose() { disposed = true; resize.disconnect(); stop(); root.remove(); }
  });
  return tile;
}
export { KEYS };
