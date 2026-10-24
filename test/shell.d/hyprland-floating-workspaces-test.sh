#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
fake="$tmpdir/hyprland"
home_dir="$tmpdir/home"
state_home="$home_dir/.local/state"
runtime_dir="$tmpdir/runtime"
modes_dir="$state_home/omarchy/workspace-layouts"
mkdir -p "$stub_dir" "$fake" "$home_dir" "$runtime_dir"

# Answers come from files the cases write, and everything else is logged.
cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash

case "$1" in
  activeworkspace) cat "$FAKE/activeworkspace.json" ;;
  activewindow) cat "$FAKE/activewindow.json" ;;
  clients) cat "$FAKE/clients.json" ;;
  monitors) cat "$FAKE/monitors.json" ;;
  workspaces) cat "$FAKE/workspaces.json" ;;
  plugin) printf '[]\n' ;;
  getoption) printf '{"option": "%s", "str": "%s"}\n' "$2" "${HYPRCTL_LAYOUT:-dwindle}" ;;
  *) printf '%s\n' "$*" >>"$FAKE/hyprctl.log" ;;
esac
EOF

for command in omarchy-notification-send omarchy-bar omarchy-shell; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"$FAKE/commands.log"\n' "$command" >"$stub_dir/$command"
done
chmod +x "$stub_dir"/*

run() {
  env HOME="$home_dir" XDG_STATE_HOME="$state_home" XDG_RUNTIME_DIR="$runtime_dir" FAKE="$fake" \
    PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

dispatched() {
  grep -F "dispatch hl.dsp.$1" "$fake/hyprctl.log" >/dev/null
}

reset_logs() {
  : >"$fake/hyprctl.log"
  : >"$fake/commands.log"
}

cat >"$fake/monitors.json" <<'EOF'
[{ "id": 0, "name": "DP-1", "x": 0, "y": 0, "width": 2560, "height": 1440, "scale": 1, "transform": 0, "reserved": [0, 30, 0, 0] }]
EOF
printf '{ "id": 2, "name": "2", "tiledLayout": "dwindle" }\n' >"$fake/activeworkspace.json"
printf '[{ "id": 2, "name": "2", "tiledLayout": "dwindle" }, { "id": 4, "name": "4", "tiledLayout": "scrolling" }]\n' >"$fake/workspaces.json"
printf '[]\n' >"$fake/clients.json"
reset_logs

# --- Which layout a workspace is in -------------------------------------------

[[ $(run omarchy-hyprland-workspace-layout-current) == "dwindle" ]] ||
  fail "a workspace with nothing saved reports Hyprland's tiled layout"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "scrolling" ]] ||
  fail "another workspace reports its own tiled layout"

mkdir -p "$modes_dir"
printf 'o.workspace_mode({ workspace = "4", mode = "floating" })\n' >"$modes_dir/4.lua"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "floating" ]] ||
  fail "a saved floating mode is reported, though Hyprland cannot report it"
pass "the layout of a workspace comes from its saved mode before Hyprland's"

# --- The default layout -------------------------------------------------------

[[ $(run omarchy-hyprland-workspace-layout-default) == "dwindle" ]] || fail "the default layout starts as tiling"
[[ $(HYPRCTL_LAYOUT=scrolling run omarchy-hyprland-workspace-layout-default) == "scrolling" ]] ||
  fail "without a saved default, Hyprland's own layout is the default"
run omarchy-hyprland-workspace-layout-default scrolling
grep -qxF 'o.workspace_mode({ default = "scrolling" })' "$modes_dir/default.lua" ||
  fail "the default layout is saved" "$(cat "$modes_dir/default.lua" 2>&1)"
[[ $(run omarchy-hyprland-workspace-layout-default) == "scrolling" ]] || fail "the saved default is reported"
grep -qx 'reload' "$fake/hyprctl.log" || fail "a new default reloads Hyprland"
grep -qF 'omarchy-shell -q omarchy.workspaces refresh' "$fake/commands.log" || fail "a new default refreshes the bar"
grep -qF 'omarchy-shell -q omarchy.dock refresh' "$fake/commands.log" || fail "a new default refreshes the dock"
pass "the default layout is saved, applied, and shown"

run omarchy-hyprland-workspace-layout-default floating
[[ $(run omarchy-hyprland-workspace-layout-current 2) == "floating" ]] ||
  fail "a workspace without a layout of its own follows the default"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "floating" ]] ||
  fail "a saved floating workspace still reports floating"
printf 'o.workspace_mode({ workspace = "4", mode = "dwindle" })\n' >"$modes_dir/4.lua"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "dwindle" ]] ||
  fail "a workspace given its own layout keeps it under a floating default"
pass "workspaces without a layout of their own follow the default, others keep theirs"

if run omarchy-hyprland-workspace-layout-default sideways 2>/dev/null; then
  fail "an unknown default layout is refused"
fi
[[ $(run omarchy-hyprland-workspace-layout-default) == "floating" ]] || fail "a refused default leaves the saved one alone"
pass "an unknown default layout is refused"
rm -f "$modes_dir"/*.lua

# A new default leaves workspaces with windows on them as they are, saving the
# layout each one has as its own; empty ones take the new default.
printf '[{ "id": 2, "name": "2", "tiledLayout": "dwindle", "windows": 3 }, { "id": 4, "name": "4", "tiledLayout": "scrolling", "windows": 0 }, { "id": 6, "name": "6", "tiledLayout": "dwindle", "windows": 1 }]\n' >"$fake/workspaces.json"
printf 'o.workspace_mode({ workspace = "6", mode = "floating" })\n' >"$modes_dir/6.lua"
printf 'o.workspace_mode({ workspace = "4", mode = "dwindle" })\n' >"$modes_dir/4.lua"
printf 'o.workspace_mode({ workspace = "9", mode = "scrolling" })\n' >"$modes_dir/9.lua"
run omarchy-hyprland-workspace-layout-default floating
grep -qxF 'o.workspace_mode({ workspace = "2", mode = "dwindle" })' "$modes_dir/2.lua" ||
  fail "a workspace with windows kept the layout it had" "$(cat "$modes_dir/2.lua" 2>&1)"
[[ ! -e $modes_dir/4.lua && $(run omarchy-hyprland-workspace-layout-current 4) == "floating" ]] ||
  fail "an empty workspace takes the new default, even with a layout of its own"
[[ ! -e $modes_dir/9.lua ]] || fail "a workspace not opened yet takes the new default"
grep -qxF 'o.workspace_mode({ workspace = "6", mode = "floating" })' "$modes_dir/6.lua" ||
  fail "a workspace with a layout of its own keeps it"
pass "a new default leaves workspaces with windows as they are"

rm -f "$modes_dir"/*.lua
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/default.lua"
printf 'o.workspace_mode({ workspace = "4", mode = "floating" })\n' >"$modes_dir/4.lua"
printf 'o.workspace_mode({ workspace = "8", mode = "floating" })\n' >"$modes_dir/8.lua"
printf '[{ "id": 4, "name": "4", "windows": 0 }, { "id": 8, "name": "8", "windows": 0 }]\n' >"$fake/workspaces.json"
cat >"$fake/clients.json" <<'EOF'
[
  {
    "address": "0xabc",
    "workspace": { "name": "special:minimized", "type": "special" },
    "tags": ["omarchy-minimized-from-4"]
  },
  {
    "address": "0xdef",
    "workspace": { "name": "special:scratchpad", "type": "special" },
    "tags": ["omarchy-minimized-from-8"]
  }
]
EOF
run omarchy-hyprland-workspace-layout-default dwindle
grep -qxF 'o.workspace_mode({ workspace = "4", mode = "floating" })' "$modes_dir/4.lua" ||
  fail "a workspace with a minimized window keeps its floating layout" "$(cat "$modes_dir/4.lua" 2>&1)"
[[ ! -e $modes_dir/8.lua ]] || fail "a scratchpad window does not keep another workspace's layout"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "floating" ]] ||
  fail "the minimized window's workspace still reports floating"
[[ $(run omarchy-hyprland-workspace-layout-current 8) == "dwindle" ]] ||
  fail "an empty workspace takes the new default"
pass "a minimized window keeps its workspace floating, and an empty one does not"

rm -f "$modes_dir"/*.lua
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/default.lua"
printf '[{ "id": 2, "name": "2", "windows": 0 }]\n' >"$fake/workspaces.json"
printf '[{ "address": "0xabc", "workspace": { "name": "special:minimized" }, "tags": ["omarchy-minimized-from-2"] }]\n' >"$fake/clients.json"
run omarchy-hyprland-workspace-layout-default scrolling
grep -qxF 'o.workspace_mode({ workspace = "2", mode = "floating" })' "$modes_dir/2.lua" ||
  fail "a minimized window's workspace keeps floating when the default changes" "$(ls "$modes_dir"; echo '---'; cat "$modes_dir"/*.lua)"
grep -qxF 'o.workspace_mode({ default = "scrolling" })' "$modes_dir/default.lua" ||
  fail "the new default is still saved"
[[ $(run omarchy-hyprland-workspace-layout-current 2) == "floating" ]] ||
  fail "the minimized window's workspace stays floating"
pass "a minimized window pins the floating layout the default used to give its workspace"

rm -f "$modes_dir"/*.lua
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/default.lua"
printf '[{ "id": 2, "name": "2", "windows": 0 }]\n' >"$fake/workspaces.json"
jq -n '[range(200) | { address: "0x\(.)", workspace: { name: "3" }, title: ("x" * 1000) }] +
  [{ address: "0xabc", workspace: { name: "special:minimized" }, tags: ["omarchy-minimized-from-2"] }]' >"$fake/clients.json"
run omarchy-hyprland-workspace-layout-default scrolling ||
  fail "a new default is set however long the client list"
grep -qxF 'o.workspace_mode({ workspace = "2", mode = "floating" })' "$modes_dir/2.lua" ||
  fail "a long client list still keeps a minimized window's workspace floating"
pass "a client list longer than one argument still sets the default"

rm -f "$modes_dir"/*.lua
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/default.lua"
printf 'o.workspace_mode({ workspace = "2", mode = "floating" })\n' >"$modes_dir/2.lua"
cp "$modes_dir/default.lua" "$tmpdir/default.before"
printf '[{ "id": 2, "name": "2", "windows": 0 }]\n' >"$fake/workspaces.json"
printf 'not json\n' >"$fake/clients.json"
if run omarchy-hyprland-workspace-layout-default scrolling 2>/dev/null; then
  fail "a new default is refused when minimized windows cannot be read"
fi
[[ -f $modes_dir/2.lua ]] || fail "an unreadable client list keeps the saved layouts"
cmp -s "$modes_dir/default.lua" "$tmpdir/default.before" || fail "an unreadable client list keeps the old default"
pass "an unreadable client list leaves the saved layouts alone"
printf '[]\n' >"$fake/clients.json"

# A failed workspace query changes nothing, rather than taking every saved
# layout for an empty workspace's.
printf 'o.workspace_mode({ workspace = "2", mode = "dwindle" })\n' >"$modes_dir/2.lua"
cp "$modes_dir/default.lua" "$tmpdir/default.before"
printf 'not json\n' >"$fake/workspaces.json"
if run omarchy-hyprland-workspace-layout-default scrolling 2>/dev/null; then
  fail "a new default is refused when the workspaces cannot be read"
fi
[[ -f $modes_dir/2.lua ]] || fail "a failed workspace query keeps the saved layouts"
cmp -s "$modes_dir/default.lua" "$tmpdir/default.before" || fail "a failed workspace query keeps the old default"
pass "a failed workspace query leaves the saved layouts alone"
rm -f "$modes_dir"/*.lua
printf '[{ "id": 2, "name": "2", "tiledLayout": "dwindle" }, { "id": 4, "name": "4", "tiledLayout": "scrolling" }]\n' >"$fake/workspaces.json"

# --- The workspace mode in Hyprland --------------------------------------------

mkdir -p "$state_home/omarchy/current/theme"
cat >"$state_home/omarchy/current/theme/colors.toml" <<'EOF'
background = "#112233"
lighter_background = "#223344"
selection = "#334455"
foreground = "#ddeeff"
accent = "#ff8800"
EOF

lua_harness="$tmpdir/harness.lua"
cat >"$lua_harness" <<'LUA'
local all = {}
local subscriptions = {}
local plugin_loads = 0
local titlebar_config = nil
local buttons = {}
local config = { ["input.follow_mouse"] = 1, ["decoration.shadow.enabled"] = false }
local rules = {}
local placed = {}
local active = { id = 1 }
local titlebars_installed = os.getenv("TITLEBARS_INSTALLED") == "1"

local monitor = { width = 2560, height = 1440, scale = 1, transform = 0, reserved = { left = 0, right = 0, top = 30, bottom = 0 } }

function window(address, workspace, options)
  options = options or {}
  local created = {
    address = address,
    floating = options.floating or false,
    fullscreen = options.fullscreen or 0,
    pinned = false,
    tags = options.tags or {},
    workspace = { id = workspace },
    monitor = monitor,
  }
  table.insert(all, created)
  return created
end

function has_tag(target, tag)
  for _, held in ipairs(target.tags) do
    if held == tag then
      return true
    end
  end
  return false
end

local real_open = io.open
io.open = function(path, mode)
  if path == "/usr/lib/omarchy-hyprland-titlebars/titlebars.so" then
    return titlebars_installed and { close = function() end } or nil
  end
  return real_open(path, mode)
end

hl = {
  workspace_rule = function() end,
  window_rule = function(rule) table.insert(rules, rule) end,
  get_workspace_windows = function(selector)
    local found = {}
    for _, candidate in ipairs(all) do
      if tostring(candidate.workspace.id) == tostring(selector) then
        table.insert(found, candidate)
      end
    end
    return found
  end,
  get_windows = function(filter)
    local found = {}
    for _, candidate in ipairs(all) do
      if not filter or (filter.tag and has_tag(candidate, filter.tag)) then
        table.insert(found, candidate)
      end
    end
    return found
  end,
  dispatch = function(action)
    local target = action.window
    if action.kind == "place" then
      placed[target.address] = true
    elseif action.kind == "fullscreen" then
      if action.mode == "maximized" then
        target.fullscreen = action.action == "unset" and 0 or 1
      end
    elseif action.tag then
      local name = action.tag:sub(2)
      if action.tag:sub(1, 1) == "+" then
        if not has_tag(target, name) then
          table.insert(target.tags, name)
        end
      else
        for index, held in ipairs(target.tags) do
          if held == name then
            table.remove(target.tags, index)
            break
          end
        end
      end
    else
      target.floating = action.action == "on"
    end
  end,
  dsp = {
    window = {
      float = function(spec) return spec end,
      tag = function(spec) return spec end,
      resize = function(spec) spec.kind = "place" return spec end,
      center = function(spec) spec.kind = "place" return spec end,
      move = function(spec) spec.kind = "place" return spec end,
      fullscreen = function(spec) spec.kind = "fullscreen" return spec end,
    },
  },
  on = function(event, callback)
    subscriptions[event] = subscriptions[event] or {}
    table.insert(subscriptions[event], callback)
  end,
  timer = function(callback) callback() end,
  get_loaded_plugins = function()
    return os.getenv("HYPRBARS_RESIDENT") == "1" and { { name = "hyprbars" } } or {}
  end,
  get_active_workspace = function() return active end,
  get_config = function(key) return config[key] end,
  config = function(values)
    if values.plugin then
      titlebar_config = values.plugin.hyprbars
      return
    end
    local function flatten(prefix, options)
      for key, value in pairs(options) do
        if type(value) == "table" then
          flatten(prefix .. key .. ".", value)
        else
          config[prefix .. key] = value
        end
      end
    end
    flatten("", values)
  end,
  plugin = {
    load = function(path)
      plugin_loads = plugin_loads + 1
      assert(path == "/usr/lib/omarchy-hyprland-titlebars/titlebars.so", "the titlebars were loaded from the wrong place")
      if os.getenv("TITLEBARS_LOADED") == "1" then
        hl.plugin.hyprbars = { add_button = function(button) table.insert(buttons, button) end }
      end
    end,
  },
}

function state()
  return {
    plugin_loads = plugin_loads,
    titlebar_config = titlebar_config,
    buttons = buttons,
    config = config,
    rules = rules,
    placed = placed,
    subscriptions = subscriptions,
    active = active,
  }
end

function latest_open_rule(index)
  local found
  for _, rule in ipairs(rules) do
    if rule.name == "omarchy-floating-open-" .. tostring(index or 1) then
      found = rule
    end
  end
  return found
end

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.helpers")
LUA

run_lua() {
  local script=$1
  shift
  printf 'dofile("%s")\n%s\n' "$lua_harness" "$script" >"$tmpdir/case.lua"
  env HOME="$home_dir" XDG_STATE_HOME="$state_home" OMARCHY_PATH="$ROOT" "$@" lua "$tmpdir/case.lua"
}

rm -rf "$modes_dir"

# Nothing floats: the titlebar plugin stays out and nothing changes.
if ! run_lua '
local tiled = window("0x1", 1)
require("default.hypr.workspace-layouts")
local s = state()
assert(s.plugin_loads == 0, "the titlebar plugin was loaded with nothing floating")
assert(not tiled.floating, "a window floated with nothing floating")
assert(#s.rules == 0, "window rules were added with nothing floating")
' TITLEBARS_INSTALLED=1; then
  fail "nothing changes for a session where no workspace floats"
fi
pass "nothing changes for a session where no workspace floats"

# A floating default floats every regular workspace without a mode of its own,
# and leaves special workspaces and those with their own layout alone.
mkdir -p "$modes_dir"
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/default.lua"
printf 'o.workspace_mode({ workspace = "2", mode = "dwindle" })\n' >"$modes_dir/2.lua"

if ! run_lua '
local first = window("0x1", 1)
local dialog = window("0x2", 1, { floating = true })
local own_layout = window("0x3", 2)
local scratch = window("0x4", -98)
local fullscreen = window("0x5", 3, { fullscreen = 1 })
require("default.hypr.workspace-layouts")
local s = state()

assert(first.floating and has_tag(first, "omarchy-mode-floated"), "a window on an unsaved workspace was not floated")
assert(s.placed["0x1"], "a window the mode floated was not given a place")
assert(has_tag(first, "omarchy-floating-workspace"), "a floated window got no titlebar tag")
assert(has_tag(dialog, "omarchy-floating-workspace"), "a window floating already got no titlebar tag")
assert(not has_tag(dialog, "omarchy-mode-floated"), "a window floating already was claimed")
assert(not s.placed["0x2"], "a window floating already was moved")
assert(not own_layout.floating, "a workspace with its own layout was floated")
assert(not has_tag(own_layout, "omarchy-floating-workspace"), "a tiled window got a titlebar tag")
assert(not scratch.floating and #scratch.tags == 0, "a window on a special workspace was touched")
assert(not fullscreen.floating, "a fullscreen window was floated")
assert(has_tag(fullscreen, "omarchy-floating-workspace"), "a fullscreen window on a floating workspace got no titlebar tag")

-- Pointer focus follows the active workspace.
assert(s.config["input.follow_mouse"] == 0, "a floating workspace focused on hover")
s.active.id = 2
s.subscriptions["workspace.active"][1]()
assert(s.config["input.follow_mouse"] == 1, "a tiled workspace lost the user focus setting")

-- Shadows only for windows on floating workspaces, when the user has none.
assert(s.config["decoration.shadow.enabled"] == true, "floating windows got no shadows to tell them apart")
assert(#s.rules >= 3, "the floating window rules were not added")
' TITLEBARS_INSTALLED=1; then
  fail "a floating default floats every regular workspace without a layout of its own"
fi
pass "a floating default floats every regular workspace without a layout of its own"

# A tiled default is Hyprland's own layout for workspaces without a rule.
rm -f "$modes_dir"/*.lua
printf 'o.workspace_mode({ default = "scrolling" })\n' >"$modes_dir/default.lua"
if ! run_lua '
require("default.hypr.workspace-layouts")
assert(state().config["general.layout"] == "scrolling", "a scrolling default did not set the layout: " .. tostring(state().config["general.layout"]))
'; then
  fail "a scrolling default is Hyprland's default layout"
fi
pass "a scrolling default is Hyprland's default layout"

# Moving the default away from floating is a fresh start, and the windows it floated
# have to be given back even though nothing names their workspace any more. With
# no workspace given a layout of its own, no saved mode is left to start the mode.
rm -f "$modes_dir"/*.lua
if ! run_lua '
local floated = window("0x1", 1, { floating = true, tags = { "omarchy-mode-floated", "omarchy-floating-workspace" } })
local dialog = window("0x2", 1, { floating = true, tags = { "omarchy-floating-workspace" } })
local scratch = window("0x3", -98, { floating = true, tags = { "omarchy-mode-floated" } })
require("default.hypr.workspace-layouts")
assert(not floated.floating, "a window the mode floated stayed floating once floating was off")
assert(not has_tag(floated, "omarchy-mode-floated"), "a window given back is still claimed")
assert(not has_tag(floated, "omarchy-floating-workspace"), "a tiled window kept its titlebar tag")
assert(dialog.floating, "a dialog was tiled when floating was turned off")
assert(not has_tag(dialog, "omarchy-floating-workspace"), "a dialog on a tiled workspace kept its titlebar tag")
assert(scratch.floating and has_tag(scratch, "omarchy-mode-floated"), "a window on the scratchpad was tiled")
'; then
  fail "turning floating off gives back what it floated, but not what is on the scratchpad"
fi
pass "turning floating off gives back what it floated, but not what is on the scratchpad"

# A tiled window that was fullscreen when its workspace started floating is
# left as it is, and floats once it comes out of fullscreen.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
local video = window("0x1", 1, { fullscreen = 2 })
require("default.hypr.workspace-layouts")
assert(not video.floating, "a fullscreen window was floated")
video.fullscreen = 0
state().subscriptions["window.fullscreen"][1](video)
assert(video.floating and has_tag(video, "omarchy-mode-floated"), "a window leaving fullscreen on a floating workspace stayed tiled")
'; then
  fail "a window leaving fullscreen on a floating workspace floats"
fi
pass "a window leaving fullscreen on a floating workspace floats"

# A window opening on a floating workspace floats from its first frame through
# a window rule, which tags it the way rules do, with a trailing "*". The mode
# claims it as it opens, so it tiles again when the workspace stops floating,
# and the rule stops applying.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
require("default.hypr.workspace-layouts")
local function open_rule()
  local found
  for _, candidate in ipairs(state().rules) do
    if candidate.name == "omarchy-floating-open-1" then found = candidate end
  end
  return found
end
local rule = open_rule()
assert(rule and rule.float and rule.enabled and rule.match.workspace == "r[1-1]", "no open rule floats windows on the floating workspace")
local first_position = rule.move
local opened = window("0x1", 1, { floating = true, tags = { "omarchy-mode-opened*" } })
state().subscriptions["window.open"][1](opened)
assert(has_tag(opened, "omarchy-mode-floated"), "a window the open rule floated was not claimed by the mode")
assert(open_rule().move ~= first_position, "the next window opens exactly on top of the last")
o.workspace_mode({ workspace = "1", mode = "dwindle" })
assert(not opened.floating, "a window the open rule floated kept floating once the workspace tiled")
assert(open_rule().enabled == false, "the open rule still applies after the workspace tiled")
'; then
  fail "windows the open rule floats tile again when the workspace stops floating"
fi
pass "windows the open rule floats tile again when the workspace stops floating"

# A maximized window on a floating workspace comes back to its own size when
# another window opens there, and one on a tiled workspace is left maximized.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
require("default.hypr.workspace-layouts")
local maximized = window("0x1", 1, { floating = true, fullscreen = 1 })
local tiled_max = window("0x2", 2, { fullscreen = 1 })
local opening = window("0x3", 1, { floating = true })
state().subscriptions["window.open"][1](opening)
assert(maximized.fullscreen == 0, "a maximized window stayed maximized when another opened on its floating workspace")
local next_door = window("0x4", 2)
state().subscriptions["window.open"][1](next_door)
assert(tiled_max.fullscreen == 1, "a maximized window on a tiled workspace was unmaximized")
'; then
  fail "a new window on a floating workspace brings a maximized one back to size"
fi
pass "a new window on a floating workspace brings a maximized one back to size"

# Apps with float rules of their own keep them on a floating workspace: the
# open rule passes them over, so they open at their own size and the mode never
# claims them.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
o.window("^float-me$", { float = true })
o.window({ title = "^Picker$" }, { float = true })
o.window("^tile-me$", { opacity = "0.9" })
require("default.hypr.workspace-layouts")
local rule
for _, candidate in ipairs(state().rules) do
  if candidate.name == "omarchy-floating-open-1" then rule = candidate end
end
assert(rule.match.class == "negative:(?:^float-me$)", "the open rule does not pass over an app that floats on its own: " .. tostring(rule.match.class))
assert(rule.match.title == "negative:(?:^Picker$)", "the open rule does not pass over a window titled to float: " .. tostring(rule.match.title))
'; then
  fail "apps with float rules of their own are left to them on a floating workspace"
fi
pass "apps with float rules of their own are left to them on a floating workspace"

# Apps floated through a tag keep their floating too: one tagged into a tag a
# float rule matches is passed over, while a rule floating a tag together with
# a title passes over only that title, not everything with the tag.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
o.window("^1password$", { tag = "+floating-window" })
o.window({ tag = "floating-window" }, { float = true })
o.window("^chromium$", { tag = "+chromium-based-browser" })
o.window({ tag = "chromium-based-browser", title = "^Meet - .+" }, { float = true })
require("default.hypr.workspace-layouts")
local rule
for _, candidate in ipairs(state().rules) do
  if candidate.name == "omarchy-floating-open-1" then rule = candidate end
end
assert(rule.match.class == "negative:(?:^1password$)", "the open rule does not pass over an app tagged to float: " .. tostring(rule.match.class))
assert(rule.match.title == "negative:(?:^Meet - .+)", "the open rule does not pass over just the title a tag rule floats: " .. tostring(rule.match.title))
'; then
  fail "apps floated through a tag are left to it on a floating workspace"
fi
pass "apps floated through a tag are left to it on a floating workspace"

# The user config loads saved workspace modes before its personal-rule tail.
# Refresh exclusions before the first window, without relying on window.open.
if ! run_lua '
require("default.hypr.workspace-layouts")
o.window("^late-class$", { float = true })
assert(latest_open_rule().match.class == "negative:(?:^late-class$)", "a late class float rule did not refresh the first-window exclusion")
o.window({ title = "^Late picker$" }, { float = true })
assert(latest_open_rule().match.title == "negative:(?:^Late picker$)", "a late title float rule did not refresh the first-window exclusion")
'; then
  fail "personal float rules registered after saved modes exclude the first window"
fi
pass "personal float rules registered after saved modes exclude the first window"

# Either half of a tag relationship can arrive after the workspace modes.
if ! run_lua '
o.window("^tagged-before$", { tag = "+late-float-tag" })
o.window({ tag = "early-float-tag" }, { float = true })
require("default.hypr.workspace-layouts")
o.window({ tag = "late-float-tag" }, { float = true })
assert(latest_open_rule().match.class == "negative:(?:^tagged-before$)", "a late tag float rule missed an earlier tagged app")
o.window({ title = "^Tagged later$" }, { tag = "+early-float-tag" })
assert(latest_open_rule().match.title == "negative:(?:^Tagged later$)", "a late tagging rule missed an earlier float tag")
'; then
  fail "late tag relationships refresh exclusions in either registration order"
fi
pass "late tag relationships refresh exclusions in either registration order"

# Two personal rules added in the tail must also work in either order.
if ! run_lua '
require("default.hypr.workspace-layouts")
o.window("^tag-first$", { tag = "+tag-first" })
o.window({ tag = "tag-first" }, { float = true })
assert(latest_open_rule().match.class == "negative:(?:^tag-first$)", "two late rules missed the tag-first app")
o.window({ tag = "float-first" }, { float = true })
o.window({ title = "^Float first$" }, { tag = "+float-first" })
assert(latest_open_rule().match.title == "negative:(?:^Float first$)", "two late rules missed the float-first title")
'; then
  fail "tag and float rules both registered late exclude their first window"
fi
pass "tag and float rules both registered late exclude their first window"

if ! run_lua '
require("default.hypr.workspace-layouts")
o.workspace_mode({ workspace = "3", mode = "floating" })
o.window("^late-on-either$", { float = true })
for index = 1, 2 do
  assert(latest_open_rule(index).match.class == "negative:(?:^late-on-either$)", "a late rule missed a floating workspace")
end
o.workspace_mode({ workspace = "1", mode = "dwindle" })
o.workspace_mode({ workspace = "3", mode = "dwindle" })
o.window({ title = "^After tiling$" }, { float = true })
for index = 1, 2 do
  assert(latest_open_rule(index).enabled == false, "a late personal rule re-enabled floating mode")
end
'; then
  fail "late rules refresh all floating workspaces without reviving disabled modes"
fi
pass "late rules refresh all floating workspaces without reviving disabled modes"

if ! run_lua '
require("default.hypr.workspace-layouts")
local before = #state().rules
o.window("^ordinary-rule$", { opacity = "0.9" })
assert(#state().rules == before + 1, "an unrelated personal rule rebuilt floating rules")
package.loaded["default.hypr.helpers"] = nil
require("default.hypr.helpers")
before = #state().rules
o.window("^fresh-config$", { float = true })
assert(#state().rules == before + 1, "reloading helpers retained the previous modes callback")
'; then
  fail "unrelated rules and fresh helpers leave generated rules alone"
fi
pass "unrelated rules and fresh helpers leave generated rules alone"

# A window moved to a special workspace, like the scratchpad, is left alone.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
local moving = window("0x1", 1)
require("default.hypr.workspace-layouts")
local moved = state().subscriptions["window.move_to_workspace"][1]
assert(moving.floating, "the window was not floated to begin with")

moved(moving, { id = -98 })
assert(moving.floating and has_tag(moving, "omarchy-mode-floated"), "a window was tiled on its way to the scratchpad")

moved(moving, { id = 2 })
assert(not moving.floating, "a window carried to a tiled workspace kept floating")
'; then
  fail "the mode leaves windows on their way to a special workspace alone"
fi
pass "the mode leaves windows on their way to a special workspace alone"

# Titlebars: asked for only when installed, and themed once loaded.
if ! run_lua '
window("0x1", 1)
require("default.hypr.workspace-layouts")
assert(state().plugin_loads == 0, "titlebars were asked for without being installed")
'; then
  fail "a missing titlebar package leaves floating without titlebars"
fi

if ! run_lua '
window("0x1", 1)
require("default.hypr.workspace-layouts")
local s = state()
assert(s.plugin_loads == 1, "the titlebar plugin was not loaded with a workspace floating")
local bar = s.titlebar_config
assert(bar, "the titlebars were not configured once loaded")
assert(bar.workspace_tag == "omarchy-floating-workspace", "titlebars are not limited to floating workspaces")
assert(bar.bar_color == "rgb(223344)", "titlebars do not stand out from the window background: " .. tostring(bar.bar_color))
assert(bar.inactive_button_color == "rgb(223344)", "titlebar buttons do not match the titlebar")
for _, button in ipairs(s.buttons) do
  assert(button.bg_color == "rgb(223344)", "a titlebar button does not match the titlebar")
end
assert(bar.col.text == "rgb(ddeeff)", "titlebar text does not follow the theme foreground")
assert(not bar.edge_snap, "dragged windows snap to screen edges")
assert(#s.buttons == 3, "the titlebars do not have exactly close, maximize, and minimize")
local actions = s.buttons[1].action .. s.buttons[2].action .. s.buttons[3].action
assert(actions:find("window.close", 1, true), "no button closes the window")
assert(actions:find("maximized", 1, true), "no button maximizes the window")
assert(actions:find("omarchy-hyprland-window-minimize", 1, true), "no button minimizes the window to the dock")
assert(bar.on_double_click:find("maximized", 1, true), "double-clicking a titlebar does not maximize")
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1; then
  fail "titlebars load when a workspace floats and follow the theme"
fi
pass "titlebars load when a workspace floats and follow the theme"

# A workspace that starts floating after the config loaded, with Super + L,
# gets titlebars at once rather than on the next reload, and only once however
# many workspaces start floating after it.
rm -f "$modes_dir"/*.lua
if ! run_lua '
window("0x1", 3)
require("default.hypr.workspace-layouts")
assert(state().plugin_loads == 0, "the titlebar plugin was loaded with nothing floating")
o.workspace_mode({ workspace = "3", mode = "floating" })
local s = state()
assert(s.plugin_loads == 1, "a workspace that started floating did not load the titlebar plugin")
assert(s.titlebar_config and s.titlebar_config.enabled, "a workspace that started floating did not turn titlebars on")
local buttons = #s.buttons
o.workspace_mode({ workspace = "4", mode = "floating" })
assert(state().plugin_loads == 1 and #state().buttons == buttons, "titlebars were set up again for a second floating workspace")
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1; then
  fail "a workspace that starts floating gets titlebars without a reload"
fi
pass "a workspace that starts floating gets titlebars without a reload"

# Hyprland unloads a plugin the config stops asking for, and loading it again
# costs a cascade of reloads, so a session that has loaded titlebars keeps them.
if ! run_lua '
window("0x1", 3)
require("default.hypr.workspace-layouts")
local s = state()
assert(s.plugin_loads == 1, "the loaded titlebar plugin was not asked for with nothing floating")
assert(not s.titlebar_config, "titlebars were turned on with nothing floating")
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1 HYPRBARS_RESIDENT=1; then
  fail "a session that loaded titlebars keeps the plugin when nothing floats"
fi
pass "a session that loaded titlebars keeps the plugin when nothing floats"
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"

# A theme whose raised surface is its background would hide the titlebar again,
# so it takes the selection color instead.
theme="$state_home/omarchy/current/theme/colors.toml"
cp "$theme" "$theme.saved"
sed -i 's/^lighter_background = .*/lighter_background = "#112233"/' "$theme"
if ! run_lua '
window("0x1", 1)
require("default.hypr.workspace-layouts")
local bar = state().titlebar_config
assert(bar and bar.bar_color == "rgb(334455)", "a flat theme does not fall back to its selection color: " .. tostring(bar and bar.bar_color))
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1; then
  fail "titlebars stand out on a theme whose raised surface is its background"
fi
mv "$theme.saved" "$theme"
pass "titlebars stand out on a theme whose raised surface is its background"

# omarchy-theme-set writes the current theme under ~/.local/state even when
# XDG_STATE_HOME points elsewhere, so that is where the titlebars find it.
other_state="$tmpdir/other-state"
mkdir -p "$other_state/omarchy/workspace-layouts"
cp "$modes_dir/1.lua" "$other_state/omarchy/workspace-layouts/"
if ! run_lua '
window("0x1", 1)
require("default.hypr.workspace-layouts")
local bar = state().titlebar_config
assert(bar and bar.bar_color == "rgb(223344)", "titlebars missed the theme with XDG_STATE_HOME elsewhere: " .. tostring(bar and bar.bar_color))
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1 XDG_STATE_HOME="$other_state"; then
  fail "titlebars follow the theme when XDG_STATE_HOME points elsewhere"
fi
pass "titlebars follow the theme when XDG_STATE_HOME points elsewhere"

run_node_test <<'JS'
const source = require('fs').readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')
assert(source.includes('function onActiveWorkspaceChanged() { root.showActiveMode() }'), 'a workspace switch shows the cached layout instead of running the script')
assert(source.includes('if (name === "configreloaded") root.refresh()'), 'a config reload drops every cached layout')

// Run the widget's own cache logic against a fake Hyprland and process.
function body(pattern) {
  const match = source.match(pattern)
  if (!match) fail('Workspaces.qml cache logic can be extracted', String(pattern))
  return match[1]
}
// QML resolves bare calls like readMode() on the widget, so it is passed in too.
const args = ['root', 'Hyprland', 'modeProc', 'Qt', 'readMode']
const fn = name => new Function(...args, body(new RegExp(`\\n  function ${name}\\(\\) \\{([\\s\\S]*?)\\n  \\}`)))
const streamFinished = new Function(...args, 'text', body(/onStreamFinished: \{([\s\S]*?)\n      \}/))
const exited = new Function(...args, body(/onExited: \{([\s\S]*?)\n    \}/))

const hyprland = {}
const proc = { running: false, command: null, runs: [] }
const deferred = []
const qt = { callLater: callback => deferred.push(callback) }
// Each bar follows the workspace its own monitor shows.
const widget = { monitor: { activeWorkspace: { id: 1 } }, activeMode: 'dwindle', modeStale: false, modeCache: {}, modeGeneration: 0, modeProcWorkspace: -1, modeProcGeneration: 0 }
for (const name of ['activeWorkspaceId', 'showActiveMode', 'readMode', 'refresh']) {
  const call = fn(name)
  widget[name] = () => call(widget, hyprland, proc, qt, widget.readMode)
}
const start = () => { if (proc.running) proc.runs.push(proc.command[1]) }
// Quickshell still reports the process running while it signals exit, so a
// retry has to be deferred until after the handler returns.
const finish = output => {
  streamFinished(widget, hyprland, proc, qt, widget.readMode, output)
  exited(widget, hyprland, proc, qt, widget.readMode)
  proc.running = false
  while (deferred.length) deferred.shift()()
}
const focus = id => { widget.monitor.activeWorkspace = { id }; widget.showActiveMode(); start() }

widget.refresh(); start()
finish('scrolling\n')
assertEqual(widget.activeMode, 'scrolling', 'the first read shows the focused layout')
focus(2); finish('floating\n')
focus(1)
assertEqual(widget.activeMode, 'scrolling', 'returning to a read workspace shows its cached layout')
assertDeepEqual(proc.runs, ['1', '2'], 'a cached workspace switch runs no script')

widget.refresh(); start()
assert(proc.running && proc.runs.length === 3, 'a refresh reads the focused layout again')
assertDeepEqual(widget.modeCache, {}, 'a refresh drops every cached layout')
widget.refresh()
assert(widget.modeStale, 'a refresh during a read marks it stale')
finish('dwindle\n')
assert(widget.modeCache[1] === undefined, 'a read that predates a refresh is not cached')
start()
assertDeepEqual(proc.runs, ['1', '2', '1', '1'], 'a stale read is retried once it exits')
finish('floating\n')
assertEqual(widget.activeMode, 'floating', 'the retried read shows the current layout')

widget.refresh(); start()
focus(2)
assert(widget.modeStale, 'switching to an uncached workspace during a read marks it pending')
finish('scrolling\n')
assertEqual(widget.modeCache[1], 'scrolling', 'the in-flight read still caches its own workspace')
assertEqual(widget.activeMode, 'floating', 'a read for a workspace no longer focused leaves the shown layout alone')
start()
assertEqual(proc.runs[proc.runs.length - 1], '2', 'the pending read follows the newly focused workspace')
finish('dwindle\n')
assertEqual(widget.activeMode, 'dwindle', 'the newly focused workspace shows its own layout')
JS
