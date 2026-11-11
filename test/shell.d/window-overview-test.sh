#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const overview = requireFromRoot('shell/plugins/window-overview/OverviewModel.js')
const windows = [
  {address: 'a', workspace: {id: 2}, wayland: {title: 'One'}},
  {address: 'b', workspace: {id: 2}, wayland: {title: 'Two'}},
  {address: 'dialog', workspace: {id: 2}, wayland: {parent: {}}},
  {address: 'other', workspace: {id: 3}, wayland: {}},
  {address: 'minimized', workspace: {id: -99}, wayland: {}}
]
assertDeepEqual(overview.windowsOnWorkspace(windows, 2).map(w => w.address), ['a', 'b'], 'overview selects top-level windows only on its workspace')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[1]]), 0, 'selection follows window identity after a preceding window closes')
assertEqual(overview.selectionAfterChange(windows, 1, [windows[0]]), 0, 'closing the selected window selects a remaining window')
assertEqual(overview.selectionAfterChange(windows, 1, []), -1, 'empty overview has no selection')
JS

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/home" "$tmp/bin"
export HOME="$tmp/home" OMARCHY_PATH="$ROOT" PATH="$tmp/bin:$ROOT/bin:$PATH"
export OVERVIEW_CALLS="$tmp/calls"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OVERVIEW_CALLS"\n' >"$tmp/bin/hyprctl"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OVERVIEW_CALLS"\n' >"$tmp/bin/omarchy-shell"
printf '#!/bin/bash\necho "${OVERVIEW_LAYOUT:-dwindle}"\n' >"$tmp/bin/omarchy-hyprland-workspace-layout-current"
chmod +x "$tmp/bin/"*

[[ $(omarchy-hyprland-window-overview middle-click) == "off" ]] || fail "overview middle-click is opt-in"
omarchy-hyprland-window-overview middle-click on
[[ $(omarchy-hyprland-window-overview middle-click) == "on" ]] || fail "overview middle-click preference persists"
omarchy-hyprland-window-overview middle-click toggle
[[ $(omarchy-hyprland-window-overview middle-click) == "off" ]] || fail "overview middle-click toggles off"
if omarchy-hyprland-window-overview middle-click invalid; then fail "overview rejects invalid toggle values"; fi
: >"$OVERVIEW_CALLS"
omarchy-hyprland-window-overview
[[ ! -s $OVERVIEW_CALLS ]] || fail "overview leaves tiled workspaces alone"
OVERVIEW_LAYOUT=floating omarchy-hyprland-window-overview
grep -qxF 'shell toggle omarchy.window-overview' "$OVERVIEW_CALLS" || fail "floating workspace invokes the overview lifecycle"
pass "middle-click is opt-in and overview preserves tiled workspace input"

mkdir -p "$HOME/.local/state/omarchy/toggles"
touch "$HOME/.local/state/omarchy/toggles/window-overview-middle-click"
ROOT="$ROOT" lua <<'LUA'
local floating, binds, unbinds = false, 0, 0
local callback, up, fourUp, dispatched
local events, timers = {}, {}
local function flush()
  local queued = timers
  timers = {}
  for _, fn in ipairs(queued) do fn() end
end
package.preload["default.hypr.paths"] = function() return { home = os.getenv("HOME") } end
package.preload["default.hypr.workspace-modes"] = function()
  return { is_floating = function() return floating end, on_change = function(fn) callback = fn end }
end
hl = {
  get_active_workspace = function() return { id = 2 } end,
  on = function(event, fn) events[event] = fn end,
  timer = function(fn) table.insert(timers, fn) end,
  bind = function()
    binds = binds + 1
    return { unbind = function() unbinds = unbinds + 1 end }
  end,
  gesture = function(spec)
    if spec.fingers == 3 and spec.direction == "up" then up = spec end
    if spec.fingers == 4 and spec.direction == "up" then fourUp = spec end
  end,
  dispatch = function(value) dispatched = value end,
  dsp = { exec_cmd = function(command) return command end, workspace = { toggle_special = function(name) return name end } },
}
dofile(os.getenv("ROOT") .. "/default/hypr/window-overview.lua")
assert(binds == 0, "tiled workspace keeps middle-click")
floating = true; callback(); callback(); flush()
assert(binds == 1, "floating workspace binds once")
floating = false; callback(); flush()
assert(unbinds == 1, "leaving floating releases middle-click")
-- Workspace and monitor events precede the new focused state.
events["workspace.active"](); events["monitor.focused"]()
assert(#timers == 1, "focus events coalesce into one deferred update")
floating = true; flush()
assert(binds == 2, "entering floating binds using destination state")
events["monitor.focused"](); events["workspace.active"]()
floating = false; flush()
assert(unbinds == 2, "entering tiled releases using destination state")
dofile(os.getenv("ROOT") .. "/default/hypr/gestures.lua")
assert(up.action == "special" and up.workspace_name == "qconsole", "three-finger up preserves the console")
assert(fourUp and type(fourUp.action) == "function", "four-finger up is available without a toggle")
fourUp.action(); assert(dispatched == nil, "four-finger up leaves tiled workspaces alone")
floating = true; fourUp.action()
assert(dispatched == "omarchy-hyprland-window-overview", "four-finger up opens floating overview")
LUA
pass "middle-click releases on tiling, four-finger up opens floating overview, and three-finger up retains the console"
