// Everything that touches a nested desktop. Each nest is reachable under the
// stable names the launcher keeps symlinked (wayland-agent-N, :9N, hypr/agent-N),
// so every command here runs with those in its environment and can only ever
// reach that nest: the real seat's names are never set on anything this file
// spawns. `run` is injectable so the tool layer can be tested without a nest.
import { execFile } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const execFileP = promisify(execFile);
const HERE = dirname(fileURLToPath(import.meta.url));
export const OUTPUT = 'agent-main';
const RUN = process.env.XDG_RUNTIME_DIR || `/run/user/${process.getuid()}`;
const PROFILES = join(homedir(), '.local/share/agent-desktop/profiles');
const BROWSERS = new Set(['brave', 'chromium', 'google-chrome', 'google-chrome-stable', 'brave-browser']);
const MAX_OUTPUT = 20000;

export function nestEnv(n) {
  return {
    ...Object.fromEntries(Object.entries(process.env).filter(([key]) => key !== 'ELECTRON_RUN_AS_NODE')),
    WAYLAND_DISPLAY: `wayland-agent-${n}`,
    DISPLAY: `:9${n}`,
    HYPRLAND_INSTANCE_SIGNATURE: `agent-${n}`,
    XDG_RUNTIME_DIR: RUN,
    AGENT_DESKTOP: String(n),
    AGENT_DESKTOP_OUTPUT: OUTPUT
  };
}

function resolveLauncher() {
  const inRepo = join(HERE, '..', '..', 'bin', 'agent-desktop');
  return existsSync(inRepo) ? inRepo : 'agent-desktop';
}

const KEY_ALIASES = { enter: 'Return', esc: 'Escape', space: 'space', tab: 'Tab', backspace: 'BackSpace', del: 'Delete', delete: 'Delete', up: 'Up', down: 'Down', left: 'Left', right: 'Right', home: 'Home', end: 'End', pageup: 'Prior', pagedown: 'Next' };
const MODS = new Set(['ctrl', 'shift', 'alt', 'logo', 'super', 'win']);

// "ctrl+shift+t" -> wtype args that press the modifiers, tap the key, release.
export function keyArgs(combo) {
  const parts = combo.split('+').map(p => p.trim()).filter(Boolean);
  if (!parts.length) throw new Error('empty key combo');
  const key = parts.pop();
  const mods = parts.map(m => m.toLowerCase()).map(m => (m === 'win' ? 'logo' : m === 'super' ? 'logo' : m));
  for (const m of mods) if (!MODS.has(m)) throw new Error(`unknown modifier ${m}`);
  const name = KEY_ALIASES[key.toLowerCase()] ?? key;
  return [...mods.flatMap(m => ['-M', m]), '-k', name, ...[...mods].reverse().flatMap(m => ['-m', m])];
}

export function createNest({ run = (cmd, args, opts) => execFileP(cmd, args, { maxBuffer: 64 * 1024 * 1024, ...opts }), launcher = resolveLauncher() } = {}) {
  const chains = new Map();
  // One desktop, one input stream: parallel tool calls from the same session
  // must not interleave keystrokes or move the cursor under a click.
  const serial = (n, fn) => {
    const prev = chains.get(n) ?? Promise.resolve();
    const next = prev.then(fn, fn);
    chains.set(n, next.catch(() => {}));
    return next;
  };
  // The nest's signature travels in the environment: hyprctl -i wants an index
  // or a full signature, not the agent-N symlink name.
  const hyprctl = (n, args) => run('hyprctl', args, { env: nestEnv(n) });
  const repl = (n, lua) => hyprctl(n, ['repl', lua]);

  const focusOutput = n => repl(n, `hl.dispatch(hl.dsp.focus({ monitor = '${OUTPUT}' }))`);
  const appArgs = (n, command) => [
    '--user', '--collect', `--unit=agent-desktop-${n}-app-${randomUUID()}`,
    '-p', `BindsTo=agent-desktop-${n}.service`, '-p', `After=agent-desktop-${n}.service`,
    '--', 'env', '-u', 'ELECTRON_RUN_AS_NODE',
    ...['WAYLAND_DISPLAY', 'DISPLAY', 'HYPRLAND_INSTANCE_SIGNATURE', 'AGENT_DESKTOP', 'AGENT_DESKTOP_OUTPUT']
      .map(key => `${key}=${nestEnv(n)[key]}`),
    ...command
  ];

  return {
    ready(n) {
      return existsSync(`${RUN}/agent-desktop/${n}/env`) && existsSync(`${RUN}/wayland-agent-${n}`);
    },
    async start(n) {
      await run(launcher, ['start', String(n)], { timeout: 60000 });
    },
    async stop(n) {
      await run(launcher, ['stop', String(n)], { timeout: 60000 });
    },
    async windows(n) {
      const { stdout } = await hyprctl(n, ['-j', 'clients']);
      return JSON.parse(stdout)
        .filter(c => c.mapped)
        .map(c => ({ address: c.address, class: c.class, title: c.title, x: c.at[0], y: c.at[1], w: c.size[0], h: c.size[1], focused: c.focusHistoryID === 0 }));
    },
    async capture(n, { scale } = {}) {
      const args = ['-o', OUTPUT, '-c', '-t', 'png', '-l', '1'];
      if (scale && scale !== 1) args.push('-s', String(scale));
      args.push('-');
      const { stdout } = await run('grim', args, { env: nestEnv(n), encoding: 'buffer', timeout: 15000 });
      return stdout;
    },
    move(n, x, y) {
      return serial(n, () => repl(n, `hl.dispatch(hl.dsp.cursor.move({ x = ${Math.round(x)}, y = ${Math.round(y)} }))`));
    },
    click(n, x, y, button = 'left') {
      return serial(n, async () => {
        await repl(n, `hl.dispatch(hl.dsp.cursor.move({ x = ${Math.round(x)}, y = ${Math.round(y)} }))`);
        await run('wlrctl', ['pointer', 'click', button], { env: nestEnv(n), timeout: 5000 });
      });
    },
    scroll(n, x, y, dy, dx = 0) {
      return serial(n, async () => {
        await repl(n, `hl.dispatch(hl.dsp.cursor.move({ x = ${Math.round(x)}, y = ${Math.round(y)} }))`);
        await run('wlrctl', ['pointer', 'scroll', String(dy), String(dx)], { env: nestEnv(n), timeout: 5000 });
      });
    },
    type(n, text) {
      return serial(n, () => run('wtype', ['--', text], { env: nestEnv(n), timeout: 60000 }));
    },
    key(n, combo) {
      return serial(n, () => run('wtype', keyArgs(combo), { env: nestEnv(n), timeout: 5000 }));
    },
    // Launch and let go. Browsers get a profile of their own: single-instance
    // browsers otherwise hand the launch to the user's running instance.
    async open(n, command) {
      await focusOutput(n);
      const [bin, ...rest] = command;
      const args = BROWSERS.has(basename(bin)) ? [`--user-data-dir=${join(PROFILES, String(n), basename(bin))}`, '--no-first-run', ...rest] : rest;
      await run('systemd-run', ['--quiet', '--service-type=exec', ...appArgs(n, [bin, ...args])], { timeout: 15000 });
    },
    async exec(n, command, timeoutMs = 30000) {
      try {
        await focusOutput(n);
        const { stdout, stderr } = await run('systemd-run', ['--quiet', '--pipe', '--wait', '-p', `RuntimeMaxSec=${Math.ceil(timeoutMs / 1000)}`, ...appArgs(n, ['bash', '-c', command])], { env: nestEnv(n), timeout: timeoutMs + 5000 });
        return { code: 0, stdout: String(stdout).slice(0, MAX_OUTPUT), stderr: String(stderr).slice(0, MAX_OUTPUT) };
      } catch (e) {
        return { code: e.code ?? 1, stdout: String(e.stdout ?? '').slice(0, MAX_OUTPUT), stderr: String(e.stderr ?? e.message).slice(0, MAX_OUTPUT) };
      }
    }
  };
}
