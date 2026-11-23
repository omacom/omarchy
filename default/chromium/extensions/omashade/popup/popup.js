const $ = (id) => document.getElementById(id);
const T = OmashadeTheme;
const DARK = T.normalize(T.DARK);

let settings = T.normalizeSettings();
let hostname = '';

function paint(palette) {
  const m = T.createMapper(palette);
  const root = document.documentElement.style;
  root.setProperty('--bg', palette.bg);
  root.setProperty('--fg', palette.fg);
  root.setProperty('--accent', palette.accent);
  root.setProperty('--muted', m.ramp(0.55));
  root.setProperty('--line', m.ramp(0.14));
  root.setProperty('--field', m.ramp(0.06));
  root.setProperty('--ok', palette.green || palette.accent);
  root.setProperty('--fail', palette.red || palette.accent);
  document.documentElement.style.colorScheme = palette.mode;
}

async function save() {
  await chrome.storage.local.set({ settings });
}

const check = (group, mode) => {
  for (const b of group.querySelectorAll('button')) b.setAttribute('aria-checked', String(b.dataset.mode === mode));
};

async function render() {
  const st = await chrome.storage.local.get(['settings', 'active', 'omarchy', 'host']);
  settings = T.normalizeSettings(st.settings);
  // What the current tab shows: its own override, else the default.
  const mode = T.siteModeOf(settings, hostname);

  check($('modes'), settings.mode);
  $('site').textContent = hostname ? T.siteKey(hostname) : 'Not available on this page';
  // The switch is Alt+Shift+O: on while the site is themed, off when it shows as it is.
  const on = !!hostname && mode !== 'normal';
  const toggle = $('siteToggle');
  toggle.disabled = !hostname;
  toggle.setAttribute('aria-checked', String(on));
  toggle.textContent = on ? 'on' : 'off';

  if (mode === 'dark') paint(DARK);
  else if (st.active) paint(st.active.palette);

  const status = $('status');
  const live = mode === 'omarchy' && !!(st.host && st.host.connected);
  status.hidden = live;
  status.dataset.state = mode === 'omarchy' ? (live ? 'live' : 'offline') : mode;
  if (live) {
    status.textContent = '';
  } else if (mode === 'normal') {
    status.textContent = 'Pages shown as they are';
  } else if (mode === 'dark') {
    status.textContent = 'Pitch black · page hues kept';
  } else {
    status.textContent = 'Theme sync offline · run omarchy-install-chromium-omashade ';
    const retry = document.createElement('button');
    retry.textContent = 'retry';
    retry.onclick = () => chrome.runtime.sendMessage({ type: 'reconnect' });
    status.append(retry);
  }
}

// The mode row is a radio group: click to pick, arrow keys to move like a native one.
function radioGroup(group, selected, pick) {
  const modes = () => [...group.querySelectorAll('button')].map((b) => b.dataset.mode);
  group.onclick = (e) => {
    const b = e.target.closest('button[data-mode]');
    if (b && !b.disabled && b.dataset.mode !== selected()) pick(b.dataset.mode).then(save);
  };
  group.onkeydown = (e) => {
    if ((e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') || group.querySelector('button:disabled')) return;
    const list = modes();
    const i = list.indexOf(selected()) + (e.key === 'ArrowRight' ? 1 : -1);
    const next = list[(i + list.length) % list.length];
    pick(next).then(save).then(() => group.querySelector(`[data-mode="${next}"]`).focus());
  };
}

radioGroup($('modes'), () => settings.mode, async (mode) => {
  settings = { ...settings, mode };
});
$('siteToggle').onclick = () => {
  if (!hostname) return;
  settings = T.toggleSite(settings, hostname);
  save();
};

chrome.storage.onChanged.addListener((changes, area) => {
  if (area === 'local') render();
});

(async () => {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    const url = new URL(tab.url);
    if (/^https?:$/.test(url.protocol)) hostname = url.hostname;
  } catch {}
  render();
})();
