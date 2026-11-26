#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export OMARCHY_PATH="$ROOT"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ROOT="$ROOT" run_node_test <<'JS'
const dock = requireFromRoot('shell/plugins/dock/DockModel.js')

assertEqual(dock.normalizePosition('left'), 'left', 'dock accepts a valid position')
assertEqual(dock.normalizePosition(' Top '), 'top', 'dock reads a position loosely')
assertEqual(dock.normalizePosition('diagonal'), 'bottom', 'dock falls back to the bottom')
assertEqual(dock.normalizePosition(undefined), 'bottom', 'dock sits at the bottom by default')
assert(dock.isVertical('right') && !dock.isVertical('top'), 'dock runs vertically on the left and right')

assertDeepEqual(
  dock.pinnedIds({ pinned: ['chromium', 'org.gnome.Nautilus.desktop', 'chromium', ''] }, { pinned: ['spotify'] }),
  ['chromium', 'org.gnome.Nautilus'],
  'dock pins each desktop id once, without its .desktop suffix'
)
assertDeepEqual(dock.pinnedIds({}, { pinned: ['spotify'] }), ['spotify'], 'dock falls back to the default pins')
assertDeepEqual(dock.pinnedIds({ pinned: [] }, { pinned: ['spotify'] }), [], 'dock keeps an emptied pin list empty')

const app = (key, id, extra) => Object.assign({ key, id, hasEntry: true, workspaceId: 3 }, extra)
const items = dock.buildItems(['chromium', 'Alacritty'], [
  app('signal', 1),
  app('chromium', 2),
  app('signal', 3),
  app('org.omarchy.agent', 4, { hasEntry: false }),
  app('foot', 5, { workspaceId: -98 })
])
assertDeepEqual(
  items.map(item => [item.key, item.pinned, item.windows.map(window => window.id)]),
  [
    ['chromium', true, [2]],
    ['Alacritty', true, []],
    ['signal', false, [1, 3]]
  ],
  'dock lists pinned apps first, then running apps grouped by app, leaving out helpers and special workspaces'
)

assert(!dock.isDockWindow(app('foot', 6, { workspaceId: 0 })), 'dock leaves out windows without a regular workspace')
assert(
  dock.isDockWindow(app('xeyes', 7, { hasEntry: false, workspaceId: -99, minimized: true })),
  'dock keeps a minimized window without a desktop entry, so it can come back'
)
assertEqual(dock.dropIndex(2, 0, 40, 6), 2, 'dock keeps a barely dragged app in its slot')
assertEqual(dock.dropIndex(2, 85, 40, 6), 4, 'dock lands a dragged app as many slots on as the pointer went')
assertEqual(dock.dropIndex(2, -500, 40, 6), 0, 'dock lands an app dragged past the start in the first slot')
assertEqual(dock.dropIndex(2, 500, 40, 6), 5, 'dock lands an app dragged past the end in the last slot')

const allPins = ['chromium', 'Alacritty', 'spotify-not-installed', 'signal']
const pinned = { chromium: true, Alacritty: true, signal: true }
assertDeepEqual(
  dock.pinsInOrder(['signal', 'chromium', 'Alacritty', 'slack'], pinned, allPins),
  ['signal', 'chromium', 'Alacritty', 'spotify-not-installed'],
  'dock saves pins in its order, keeping pins it does not show'
)
assertDeepEqual(
  dock.pinsInOrder(['chromium', 'slack', 'Alacritty', 'signal'], Object.assign({ slack: true }, pinned), allPins),
  ['chromium', 'slack', 'Alacritty', 'signal', 'spotify-not-installed'],
  'dock pins a running app dragged in among the pins'
)

assertDeepEqual(
  dock.orderWithKeyAt(['chromium', 'Alacritty', 'signal'], 'obsidian', 1),
  ['chromium', 'obsidian', 'Alacritty', 'signal'],
  'dock puts an app dropped from the app grid where it lands'
)
assertDeepEqual(
  dock.orderWithKeyAt(['chromium', 'Alacritty', 'signal'], 'chromium', 2),
  ['Alacritty', 'signal', 'chromium'],
  'dock moves an app it already shows to where it is dropped'
)
assertDeepEqual(
  dock.orderWithKeyAt(['chromium', 'slack', 'signal'], 'slack', 3),
  ['chromium', 'signal', 'slack'],
  'dock puts an app kept in the dock at the end'
)

const terminalEntries = [
  { id: 'nvim', execString: 'nvim %F', command: ['nvim', '%F'], runInTerminal: true },
  { id: 'HEY TUI', execString: 'xdg-terminal-exec --app-id=org.omarchy.hey -e hey tui', command: ['xdg-terminal-exec', '--app-id=org.omarchy.hey', '-e', 'hey', 'tui'], runInTerminal: false },
  { id: 'btop', execString: '/usr/bin/btop', command: ['/usr/bin/btop'], runInTerminal: true }
]
assertEqual(dock.claimingEntryId('org.omarchy.nvim', terminalEntries), 'nvim', 'dock gives Neovim launched by the TUI launcher its own entry')
assertEqual(dock.claimingEntryId('org.omarchy.btop', terminalEntries), 'btop', 'dock matches a terminal entry by its program name')

const standIns = ['omarchy-terminal', 'omarchy-browser']
assertEqual(dock.standInKey('foot', ['System', 'TerminalEmulator'], standIns), 'omarchy-terminal', 'a pinned Terminal claims the terminal it opened')
assertEqual(dock.standInKey('google-chrome', ['Network', 'WebBrowser'], standIns), 'omarchy-browser', 'a pinned Browser claims the browser it opened')
assertEqual(dock.standInKey('foot', ['TerminalEmulator'], ['foot', 'omarchy-terminal']), 'foot', 'a terminal pinned itself keeps its own windows')
assertEqual(dock.standInKey('foot', ['TerminalEmulator'], []), 'foot', 'an unpinned Terminal claims nothing')
assertEqual(dock.standInKey('YouTube', ['Network'], standIns), 'YouTube', 'a web app keeps its own windows')
assertEqual(dock.claimingEntryId('org.omarchy.hey', terminalEntries), 'HEY TUI', 'dock matches an entry that hands the terminal its app id')
assertEqual(dock.claimingEntryId('org.omarchy.agent', terminalEntries), '', 'dock leaves an app id no entry claims unclaimed')
assertEqual(dock.claimingEntryId('Alacritty', terminalEntries), '', 'dock leaves a terminal of its own to its own entry')

const webappEntries = [
  { id: 'Discord', execString: 'omarchy-launch-webapp "https://discord.com/app"', command: ['omarchy-launch-webapp', 'https://discord.com/app'], runInTerminal: false },
  { id: 'QuotedTui', execString: 'xdg-terminal-exec "--app-id=org.omarchy.quoted" -e top', command: ['xdg-terminal-exec'], runInTerminal: false }
]
assertEqual(dock.extractChromeWebappHost('chrome-discord.com__-Default'), 'discord.com', 'dock extracts the host from a Chromium webapp class')
assertEqual(dock.claimingEntryId('chrome-discord.com__-Default', webappEntries), 'Discord', 'dock matches Chromium PWA classes to their webapp desktop entry')
assertEqual(dock.claimingEntryId('org.omarchy.quoted', webappEntries), 'QuotedTui', 'dock strips surrounding quotes when matching --app-id flags')

assertEqual(dock.normalizeAddress('deadbeef'), '0xdeadbeef', 'dock normalizes valid bare hex addresses')
assertEqual(dock.normalizeAddress('0x1" ); bad'), '', 'dock rejects non-hex window addresses')
assertEqual(dock.minimizedOriginWorkspace(['foo', 'omarchy-minimized-from-12']), 12, 'dock extracts the origin workspace from minimized tags')
assertEqual(dock.slotOf(13), 3, 'dock maps per-monitor workspace ids to display slots 1-10')

const statWindows = [
  { title: 'shell', pid: 101, activated: false, minimized: true, focusHistoryID: 3 },
  { title: 'shell', pid: 102, activated: true, minimized: false, focusHistoryID: 0 },
  { title: 'logs', pid: 103, activated: false, minimized: false, focusHistoryID: 1 },
  { title: 'build', pid: 104, activated: false, minimized: false, focusHistoryID: 2 },
  { title: 'extra', pid: 105, activated: false, minimized: true, focusHistoryID: 4 }
]
assertDeepEqual(dock.itemStats(statWindows), { total: 5, minimized: 2, open: 3, activated: true }, 'dock summarizes total, open, minimized, and active counts')
assertDeepEqual(
  dock.representativeDots(statWindows, 4).map(w => w.pid),
  [102, 103, 104, 101],
  'dock orders representative indicator dots with active and open windows ahead of minimized ones'
)

const orderedItems = dock.buildItems(['foot'], [
  app('foot', 1, { title: 'foot', pid: 101, minimized: true, focusHistoryID: 2 }),
  app('foot', 2, { title: 'foot', pid: 102, activated: true, focusHistoryID: 0 }),
  app('foot', 3, { title: 'foot', pid: 103, focusHistoryID: 1 })
], { '101': { prog: 'nvim', cwd: 'dots', hint: '' }, '102': { prog: 'zsh', cwd: 'Work', hint: '' }, '103': { prog: 'zsh', cwd: 'Work', hint: '' } })
assertDeepEqual(
  orderedItems[0].windows.map(w => [w.id, w.displayTitle]),
  [
    [2, 'zsh · Work #1'],
    [3, 'zsh · Work #2'],
    [1, 'nvim · dots']
  ],
  'dock orders app windows by active/open/MRU and disambiguates duplicate terminal labels'
)

assertDeepEqual(
  dock.orderItems([{ key: 'chromium' }, { key: 'signal' }, { key: 'slack' }, { key: 'foot' }], ['slack', 'gone', 'chromium']).map(item => item.key),
  ['slack', 'chromium', 'signal', 'foot'],
  'dock keeps its own order, with apps that join going at the end'
)
const foot = [
  { workspaceId: 2, minimized: false, activated: false },
  { workspaceId: -99, minimized: true, activated: false },
  { workspaceId: 4, minimized: false, activated: false }
]
assertEqual(dock.pickWindow(foot, 4), 2, 'dock brings forward the window on the workspace in front of the user first')
assertEqual(dock.pickWindow(foot, 3), 1, 'dock restores a minimized window before leaving for another workspace')
assertEqual(dock.pickWindow(foot.map((w, i) => Object.assign({}, w, { activated: i === 2 })), 4), 1, 'dock cycles from the window here to the minimized one')
assertEqual(dock.pickWindow([], 4), -1, 'dock has no window to pick for an app that is not running')
assertEqual(dock.pickClickWindow('', foot, 3), 1, 'a click on a running app brings a window forward')
assertEqual(dock.pickClickWindow('new', foot, 4), 1, 'a click on an app that asks for new windows restores a minimized one first')
assertEqual(dock.pickClickWindow('new', [foot[0], foot[2]], 4), -1, 'a click on an app that asks for new windows starts another')
assertEqual(dock.pickClickWindow('workspace', foot, 4), 2, 'a click on a workspace app brings forward the one on this workspace')
assertEqual(dock.pickClickWindow('workspace', foot, 3), 1, 'a click on a workspace app restores a minimized one rather than leaving for another workspace')
assertEqual(dock.pickClickWindow('workspace', [foot[0], foot[2]], 3), -1, 'a click on a workspace app opens another when none is on this workspace')

const wsA = { workspaceId: 4, minimized: false, activated: true, address: '0x100', focusHistoryID: 0 }
const wsB = { workspaceId: 4, minimized: false, activated: false, address: '0x200', focusHistoryID: 1 }
const wsC = { workspaceId: 4, minimized: false, activated: false, address: '0x300', focusHistoryID: 2 }
assertEqual(dock.pickClickWindow('workspace', [wsA, wsB, wsC], 4), 1, 'workspace click cycles from first window A to second B')
// Simulate Hyprland refreshing MRU order after B takes focus: [B, A, C]
const mruAfterB = [
  Object.assign({}, wsB, { activated: true, focusHistoryID: 0 }),
  Object.assign({}, wsA, { activated: false, focusHistoryID: 1 }),
  Object.assign({}, wsC, { activated: false, focusHistoryID: 2 })
]
assertEqual(dock.pickClickWindow('workspace', mruAfterB, 4), 2, 'workspace click continues to C instead of bouncing back to A when MRU reorders')
const mruAfterC = [
  Object.assign({}, wsC, { activated: true, focusHistoryID: 0 }),
  Object.assign({}, wsB, { activated: false, focusHistoryID: 1 }),
  Object.assign({}, wsA, { activated: false, focusHistoryID: 2 })
]
assertEqual(dock.pickClickWindow('workspace', mruAfterC, 4), 2, 'workspace click wraps cleanly from C back to A')

const fs = require('fs')
const vm = require('vm')
const dockQml = fs.readFileSync(path.join(root, 'shell/plugins/dock/Dock.qml'), 'utf8')
const bringForwardFn = dockQml.match(/function bringForward\(window\) \{[\s\S]*?\n  \}/)[0]
const dispatches = []
const unsets = []
const dockCtx = {
  Hyprland: {
    focusedMonitor: { activeWorkspace: { id: 2 } },
    dispatch(expr) { dispatches.push(expr) }
  },
  scheduleNoAnimUnset(addr) { unsets.push(addr) }
}
vm.runInNewContext(bringForwardFn, dockCtx)

let fallbackActivated = 0
dockCtx.bringForward({ address: '0x1" }); os.execute("id"); --', minimized: false, toplevel: { activate() { fallbackActivated += 1 } } })
assertEqual(dispatches.length, 0, 'dock bringForward rejects non-hex window addresses before Lua dispatch')
assertEqual(fallbackActivated, 1, 'dock bringForward falls back to toplevel.activate on invalid address')

dockCtx.bringForward({ address: 'deadbeef', minimized: false, toplevel: { activate() {} } })
assert(dispatches.length === 2 && dispatches.every(d => d.includes('address:0xdeadbeef')), 'dock bringForward dispatches valid hex addresses in-process')

dispatches.length = 0
dockCtx.bringForward({ address: '0xabcd', minimized: true, toplevel: { activate() {} } })
assertEqual(dispatches.length, 4, 'dock bringForward restores minimized windows and brings them forward in-process')
assertDeepEqual(unsets, ['0xabcd'], 'dock bringForward schedules no_anim unset after restoring a minimized window')

const monFnBody = [
  dockQml.match(/function monitorForWindow\(window, fallbackMonitor\) \{[\s\S]*?\n  \}/)[0],
  dockQml.match(/function moveWindowToNextMonitor\(window, currentMonitor\) \{[\s\S]*?\n  \}/)[0],
  dockQml.match(/function moveWindowToWorkspace\(window, destWorkspace, follow\) \{[\s\S]*?\n  \}/)[0],
  dockQml.match(/function dispatchSteps\(steps\) \{[\s\S]*?\n  \}/)[0]
].join('\n')
const monDispatches = []
const monA = { id: 0, name: 'DP-1', activeWorkspace: { id: 1 } }
const monB = { id: 1, name: 'HDMI-A-1', activeWorkspace: { id: 11 } }
const monCtx = {
  DockModel: dock,
  Hyprland: {
    monitors: { values: [monA, monB] },
    workspaces: { values: [{ id: 1, monitor: monA }, { id: 11, monitor: monB }] },
    dispatch(expr) { monDispatches.push(expr) }
  },
  hyprRefreshDebounce: { restart() {} }
}
vm.runInNewContext(monFnBody, monCtx)
monCtx.moveWindowToNextMonitor({ address: '0x999', workspaceId: 11, monitorName: 'HDMI-A-1', monitorId: 1 }, monA)
assert(monDispatches.some(d => d.includes('workspace = "1"')), 'moveWindowToNextMonitor picks the next monitor after the selected window rather than the dock screen')

JS

home="$TMPDIR/home"
mkdir -p "$home/.config/omarchy"
mock_bin="$TMPDIR/bin"
mkdir -p "$mock_bin"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-shell"
chmod +x "$mock_bin/omarchy-shell"
omarchy_dock() { HOME="$home" PATH="$mock_bin:$ROOT/bin:$PATH" omarchy-dock "$@"; }

[[ $(omarchy_dock position) == "bottom" ]] || fail "dock position defaults to bottom"
omarchy_dock position left >/dev/null
jq -e '.dock.position == "left" and .version == 1' "$home/.config/omarchy/shell.json" >/dev/null ||
  fail "dock position is saved" "$(cat "$home/.config/omarchy/shell.json")"
[[ $(omarchy_dock position) == "left" ]] || fail "dock position reads back"
if omarchy_dock position diagonal 2>/dev/null; then
  fail "dock position rejects anything but top, bottom, left, and right"
fi
pass "dock position is set and read through omarchy-dock"

default_pins=$(jq -r '.dock.pinned[]' "$ROOT/config/omarchy/shell.json" | paste -sd " ")
[[ -n $default_pins && $(omarchy_dock pinned | paste -sd " ") == "$default_pins" ]] || fail "dock pins start from the defaults"
omarchy_dock unpin spotify >/dev/null
omarchy_dock pin com.example.App.desktop >/dev/null
omarchy_dock pin com.example.App >/dev/null
jq -e '
  .dock.pinned[-1] == "com.example.App" and
  (.dock.pinned | index("spotify")) == null and
  (.dock.pinned | map(select(. == "com.example.App")) | length) == 1 and
  .dock.position == "left"
' "$home/.config/omarchy/shell.json" >/dev/null ||
  fail "dock pins and unpins apps once each" "$(cat "$home/.config/omarchy/shell.json")"
pass "dock pins and unpins apps through omarchy-dock"

omarchy_dock pinned signal chromium.desktop signal >/dev/null
[[ $(omarchy_dock pinned | paste -sd ' ') == "signal chromium" ]] ||
  fail "dock pin order is set in one go" "$(cat "$home/.config/omarchy/shell.json")"
pass "dock pin order is set through omarchy-dock pinned"

[[ $(omarchy_dock autohide) == "off" ]] || fail "dock auto-hide starts off"
omarchy_dock autohide toggle >/dev/null
jq -e '.dock.autohide == true' "$home/.config/omarchy/shell.json" >/dev/null || fail "dock auto-hide toggles on"
[[ $(omarchy_dock autohide) == "on" ]] || fail "dock auto-hide reads back"
omarchy_dock autohide off >/dev/null
jq -e '.dock.autohide == false' "$home/.config/omarchy/shell.json" >/dev/null || fail "dock auto-hide turns off"
if omarchy_dock autohide sometimes 2>/dev/null; then
  fail "dock auto-hide takes only on, off, or toggle"
fi
pass "dock auto-hide is set through omarchy-dock autohide"

# Minimizing moves a window to the dock's hidden workspace without following
# it, then focuses the workspace it left, so the next window opens there and
# not beside the minimized one.
cat >"$mock_bin/hyprctl" <<STUB
#!/bin/bash
case "\$1" in
  clients) printf '[{"address":"0xabc","workspace":{"id":3}}]\n' ;;
  activewindow) printf '{"address":"0xdef","workspace":{"id":5}}\n' ;;
  dispatch) printf '%s\n' "\$2" >>"$TMPDIR/hyprctl.log" ;;
esac
STUB
chmod +x "$mock_bin/hyprctl"
printf '#!/bin/bash\n[[ $1 == 9 ]] && echo dwindle || echo floating\n' >"$mock_bin/omarchy-hyprland-workspace-layout-current"
chmod +x "$mock_bin/omarchy-hyprland-workspace-layout-current"
minimize() { PATH="$mock_bin:$ROOT/bin:$PATH" omarchy-hyprland-window-minimize "$@"; }

minimize 0xabc
grep -qxF 'hl.dsp.window.tag({ tag = "+omarchy-minimized-from-3", window = "address:0xabc" })' "$TMPDIR/hyprctl.log" ||
  fail "minimize remembers the workspace the window left" "$(cat "$TMPDIR/hyprctl.log")"
grep -qxF 'hl.dsp.window.move({ workspace = "special:minimized", follow = false, window = "address:0xabc" })' "$TMPDIR/hyprctl.log" ||
  fail "minimize moves the window to the dock's hidden workspace" "$(cat "$TMPDIR/hyprctl.log")"
[[ $(tail -1 "$TMPDIR/hyprctl.log") == 'hl.dsp.focus({ workspace = "3" })' ]] ||
  fail "minimize focuses the workspace the window left" "$(cat "$TMPDIR/hyprctl.log")"
: >"$TMPDIR/hyprctl.log"
minimize
grep -qF 'hl.dsp.window.tag({ tag = "+omarchy-minimized-from-5", window = "address:0xdef" })' "$TMPDIR/hyprctl.log" &&
  grep -qF 'address:0xdef' "$TMPDIR/hyprctl.log" && [[ $(tail -1 "$TMPDIR/hyprctl.log") == 'hl.dsp.focus({ workspace = "5" })' ]] ||
  fail "minimize takes the active window when given none" "$(cat "$TMPDIR/hyprctl.log")"
pass "minimize sends a window to the dock and keeps focus on its workspace"

cat >"$mock_bin/hyprctl" <<STUB
#!/bin/bash
case "\$1" in
  clients) printf '[{"address":"0xabc","workspace":{"id":7},"tags":["omarchy-minimized-from-3"]}]\n' ;;
  dispatch) printf '%s\n' "\$2" >>"$TMPDIR/hyprctl.log" ;;
esac
STUB
: >"$TMPDIR/hyprctl.log"
minimize 0xabc
grep -qxF 'hl.dsp.window.tag({ tag = "-omarchy-minimized-from-3", window = "address:0xabc" })' "$TMPDIR/hyprctl.log" ||
  fail "minimize forgets the previous workspace" "$(cat "$TMPDIR/hyprctl.log")"
grep -qxF 'hl.dsp.window.tag({ tag = "+omarchy-minimized-from-7", window = "address:0xabc" })' "$TMPDIR/hyprctl.log" ||
  fail "minimize remembers the workspace it leaves this time" "$(cat "$TMPDIR/hyprctl.log")"
pass "minimize remembers only the workspace the window is leaving"

# A tiled workspace has no dock to bring a window back from, so nothing there
# is minimized.
cat >"$mock_bin/hyprctl" <<STUB
#!/bin/bash
case "\$1" in
  activewindow) printf '{"address":"0x999","workspace":{"id":9}}\n' ;;
  dispatch) printf '%s\n' "\$2" >>"$TMPDIR/hyprctl.log" ;;
esac
STUB
: >"$TMPDIR/hyprctl.log"
minimize
[[ ! -s $TMPDIR/hyprctl.log ]] || fail "minimize leaves windows on a tiled workspace alone" "$(cat "$TMPDIR/hyprctl.log")"
pass "minimize leaves windows on a tiled workspace alone"
