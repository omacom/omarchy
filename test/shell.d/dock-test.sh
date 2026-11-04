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

// The app grid: which app an arrow key lands on. 25 apps in 7 columns fill
// rows 0-2 and put apps 21-24 on row 3.
const step = (index, rows, count = 25, columns = 7) => dock.gridStepRows(index, count, columns, rows)
assertEqual(step(3, 1), 10, 'app grid moves Down to the app below')
assertEqual(step(10, -1), 3, 'app grid moves Up to the app above')
assertEqual(step(3, -1), 3, 'app grid stays put on Up in the first row instead of jumping to the first app')
assertEqual(step(22, 1), 22, 'app grid stays put on Down in the last row instead of jumping to the last app')
assertEqual(step(20, 1), 24, 'app grid lands on the last app when Down goes below a short last row')
assertEqual(step(17, 1), 24, 'app grid lands on the app directly below when there is one')
assertEqual(step(17, -3), 3, 'app grid lands a page up that would leave the grid on the first row in the same column')
assertEqual(step(5, 3), 24, 'app grid lands a page down that would leave the grid on the last app')
assertEqual(step(0, 1, 0), 0, 'app grid has nowhere to go when it is empty')
assertEqual(step(2, 1, 5, 1), 3, 'app grid moves one app at a time in a single column')
assertEqual(step(2, 1, 25, 0), 3, 'app grid reads no columns as one column')

// Whatever its size, a move goes only the way it was asked, never wraps,
// never leaves the grid, and goes no further than it was asked.
for (let count = 1; count <= 40; count++) {
  for (let columns = 1; columns <= 8; columns++) {
    for (let index = 0; index < count; index++) {
      for (let rows = -4; rows <= 4; rows++) {
        const next = dock.gridStepRows(index, count, columns, rows)
        const from = Math.floor(index / columns)
        const to = Math.floor(next / columns)
        const ok = next >= 0 && next < count
          && (rows === 0 ? next === index : true)
          && (rows > 0 ? to >= from && to <= from + rows : true)
          && (rows < 0 ? to <= from && to >= from + rows : true)
          && (next === index || to !== from)
          && (rows > 0 ? next >= index : next <= index)
        if (!ok) fail('app grid moves stay inside the grid and go the way they were asked',
          `count ${count}, columns ${columns}, index ${index}, rows ${rows} gave ${next}`)
      }
    }
  }
}
pass('app grid moves stay inside the grid and go the way they were asked')

// A 600px view over 1000px of rows, 150px each, with a 56px peek.
const gridView = (contentY, originY = 0) => ({ contentY, originY, height: 600, contentHeight: 1000 })
const peeked = (contentY, row, next, previous, originY = 0) =>
  dock.gridPeekedContentY(gridView(contentY, originY), { y: row * 150, height: 150 }, 56, next, previous)
assertEqual(peeked(0, 1, true, true), 0, 'app grid leaves the view alone for a row with room around it')
assertEqual(peeked(0, 3, true, true), 56, 'app grid scrolls a peek of the next row into view past a row flush with the bottom')
assertEqual(peeked(0, 3, false, true), 0, 'app grid has no next row to peek at after the last row')
assertEqual(peeked(300, 2, true, true), 244, 'app grid scrolls a peek of the previous row into view past a row flush with the top')
assertEqual(peeked(300, 2, true, false), 300, 'app grid has no previous row to peek at before the first row')
assertEqual(peeked(0, 0, true, true), 0, 'app grid never scrolls above its origin')
assertEqual(peeked(380, 6, true, false), 400, 'app grid never scrolls past the end of its content')
assertEqual(
  dock.gridPeekedContentY({ contentY: 100, originY: 100, height: 600, contentHeight: 1000 }, { y: 100, height: 150 }, 56, false, true),
  100,
  'app grid never scrolls above a non-zero origin'
)

// The selected tile is as tall as its icon and name, not its cell, which has
// room for two lines: cut to the cell it leaves empty space under a one-line name.
const [gutter, padding, icon, gap, line] = [4, 10, 56, 6, 16]
const oneLine = dock.gridTileHeight(padding, icon, gap, line)
const twoLines = dock.gridTileHeight(padding, icon, gap, line * 2)
assertEqual(oneLine, padding * 2 + icon + gap + line, 'app grid tile is as tall as its icon, name and padding')
assertEqual(oneLine - (padding + icon + gap + line), padding, 'app grid tile has as much air below a one-line name as above its icon')
assertEqual(twoLines - oneLine, line, 'app grid tile grows by exactly the line a longer name adds')
assertEqual(dock.gridTileHeight(padding, icon, gap, 15.2), padding * 2 + icon + gap + 16, 'app grid rounds a fractional name height up so the name is not clipped')
assertEqual(dock.gridCellHeight(gutter, padding, icon, gap, line * 2), gutter * 2 + twoLines, 'app grid cell holds a two-line tile and a gutter on both sides')

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
