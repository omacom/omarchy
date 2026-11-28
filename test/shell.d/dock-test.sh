#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export OMARCHY_PATH="$ROOT"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ROOT="$ROOT" run_node_test <<'JS'
const dock = requireFromRoot('shell/plugins/dock/DockModel.js')

const coordinateQml = require('fs').readFileSync(process.env.ROOT + '/shell/plugins/dock/DockWindow.qml', 'utf8')
const bodyHoverBlock = coordinateQml.match(/    HoverHandler \{\n      id: bodyHover[\s\S]*?\n    \}/)[0]
const hoverParentMatch = bodyHoverBlock.match(/^\s*parent:\s*([^\n]+)/m)
const hoverParentExpr = hoverParentMatch ? hoverParentMatch[1].trim() : 'body'
const coordinateMoveBody = bodyHoverBlock.match(/onPointChanged: \{([\s\S]*?)\n      \}/)[1]
const releaseBody = coordinateQml.match(/mouse\.onReleased: function\(event\) \{([\s\S]*?)\n    \}/)[1]
const coordinateMove = new Function('window', 'body', 'hitStrip', 'point', 'Style', coordinateMoveBody)
const coordinateRelease = new Function('window', 'body', 'hitStrip', 'appSlot', 'event', releaseBody)
const makeItem = (x, y) => ({
  x,
  y,
  mapToItem(target, px, py) { return { x: this.x + px - target.x, y: this.y + py - target.y } }
})
const inwardReach = 66 * 0.35 - 6
const sideReach = 66 * 0.35 / 2 - 6
const contentItem = makeItem(0, 0)
const bodyItem = makeItem(100, 120)
const hitStripItem = makeItem(bodyItem.x - sideReach, bodyItem.y - inwardReach)
const appSlotItem = makeItem(bodyItem.x + 78, bodyItem.y)
appSlotItem.mouse = makeItem(appSlotItem.x, appSlotItem.y - inwardReach)
appSlotItem.lifted = true
appSlotItem.dragged = false
const coordinateWindow = {
  contentItem,
  hoverStale: false,
  dragging: true,
  dragIndex: 1,
  dropIndex: 2,
  dropPoint: null,
  endDrag() { this.dragging = false; this.hoverStale = true },
  dock: { moveItem() {} }
}
const hoverParent = new Function('window', 'body', 'hitStrip', 'return ' + hoverParentExpr)(coordinateWindow, bodyItem, hitStripItem)
coordinateRelease(coordinateWindow, bodyItem, hitStripItem, appSlotItem, contentItem.mapToItem(appSlotItem.mouse, 210, 150))
assert(coordinateWindow.hoverStale, 'releasing a dock drag marks hover stale')
coordinateMove(coordinateWindow, bodyItem, hitStripItem, { position: contentItem.mapToItem(hoverParent, 211, 150) }, { space: n => n })
assert(coordinateWindow.hoverStale, 'one pixel after a drag release preserves post-drag hover suppression across item origins')
coordinateMove(coordinateWindow, bodyItem, hitStripItem, { position: contentItem.mapToItem(hoverParent, 217, 150) }, { space: n => n })
assert(!coordinateWindow.hoverStale, 'a deliberate move after a drag release clears post-drag hover suppression')


for (const [icon, count, length, extra] of [[66, 12, 742, 0], [36, 29, 1280, 24], [36, 120, 742, 24]]) {
  const fit = dock.fitSlots(icon, 6, count, length, extra)
  assert((fit.iconSize + fit.inset * 2) * count + extra <= length + 0.0001, 'all dock slots fit the available edge: ' + count + ' slots on ' + length)
  assert(fit.iconSize > 0 && fit.iconSize <= icon, 'fitting keeps every icon visible without enlarging requested icons')
}
const dragQml = require('fs').readFileSync(process.env.ROOT + '/shell/plugins/dock/DockWindow.qml', 'utf8')
const method = name => dragQml.match(new RegExp('function ' + name + '\\([^)]*\\) \\{([\\s\\S]*?)\\n  \\}'))[1]
const dropWindow = { position: 'left', vertical: true, width: 240, height: 742, gap: 3, shown: true, autohide: false, insertIndex: -1, externalDropArea: null,
  origin: () => ({x: 0, y: 0}), slotIndexAt: () => 5, settleShifts: () => {}, dock: {pinAt: key => { pinnedDrop = key }} }
Object.defineProperty(dropWindow, 'slotSize', {get() { const fit = dock.fitSlots(66, 6, 12 + (this.insertIndex >= 0 ? 1 : 0), 736, 0); return fit.iconSize + fit.inset * 2 }})
const dropBody = { x: 3, get y() { return (742 - this.height) / 2 }, get width() { return dropWindow.slotSize }, get height() { return dropWindow.slotSize * (12 + (dropWindow.insertIndex >= 0 ? 1 : 0)) } }
const moveDrop = new Function('window', 'body', 'Qt', 'screenX', 'screenY', method('moveExternalDrag'))
dropWindow.moveExternalDrag = (x, y) => moveDrop(dropWindow, dropBody, {point: (x,y) => ({x,y})}, x, y)
const initialSlot = dropWindow.slotSize
dropWindow.moveExternalDrag(120, 371)
assert(dropWindow.insertIndex >= 0 && dropWindow.slotSize < initialSlot, 'a crowded dock shows a fitted app-drop preview')
dropWindow.moveExternalDrag(120, 371)
assert(dropWindow.insertIndex >= 0, 'preview shrink cannot reject the stationary drag pointer')
let pinnedDrop = null
const timer = {restart() {}}
dropWindow.endExternalDrag = () => new Function('window', 'collapseTimer', 'hideTimer', method('endExternalDrag'))(dropWindow, timer, timer)
new Function('window', 'screenX', 'screenY', 'key', method('dropExternalDrag'))(dropWindow, 120, 371, 'org.example.Drop')
assertEqual(pinnedDrop, 'org.example.Drop', 'releasing a crowded preview pins the app')
assertEqual(dropWindow.externalDropArea, null, 'the next drag starts with fresh acceptance bounds')

const roomy = dock.fitSlots(36, 6, 4, 1280, 0)
assertEqual(roomy.iconSize, 36, 'a dock that already fits keeps its normal icon size')
assertEqual(roomy.inset, 6, 'a dock that already fits keeps its normal spacing')

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

omarchy_dock icon-size 24 >/dev/null
omarchy_dock magnification 30 >/dev/null
[[ $(omarchy_dock icon-size) == 24 && $(omarchy_dock magnification) == 30 ]] || fail "dock amounts persist"
omarchy_dock icon-size 66 >/dev/null
[[ $(omarchy_dock icon-size) == 66 ]] || fail "dock accepts the largest size choice"
for value in 0 67 invalid; do
  if omarchy_dock icon-size "$value" 2>/dev/null; then fail "icon size rejects invalid values"; fi
done
pins_before=$(omarchy_dock pinned)
omarchy_dock position left >/dev/null
omarchy_dock autohide on >/dev/null
omarchy_dock reset >/dev/null
[[ $(omarchy_dock icon-size) == 36 && $(omarchy_dock magnification) == 15 && $(omarchy_dock pinned) == "$pins_before" ]] || fail "dock amount reset preserves pins"
[[ $(omarchy_dock position) == bottom && $(omarchy_dock autohide) == off ]] || fail "dock reset restores native position and auto-hide defaults"
pass "dock amount controls validate and reset independently"

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
