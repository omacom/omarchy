#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# Reload this session's Hyprland, as a desktop does, even when run over ssh.
export HYPRLAND_INSTANCE_SIGNATURE=test

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
assert(bar.bar_color == "rgb(223344)", "titlebars do not stand out from the window background: " .. tostring(bar.bar_color))
assert(bar.inactive_button_color == "rgb(223344)", "titlebar buttons do not match the titlebar")
for _, button in ipairs(s.buttons) do
  assert(button.bg_color == "rgb(223344)", "a titlebar button does not match the titlebar")
end
assert(bar.col.text == "rgb(ddeeff)", "titlebar text does not follow the theme foreground")
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

# A floating window dropped with its titlebar out of reach is brought back
# below the top bar, when Appearance > Windows > Titlebar Snap is on.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a floating window dropped under the top bar keeps its titlebar in reach"
local handlers, binds, timers, dispatched = {}, {}, {}, {}
local active, cursor = nil, { x = 0, y = 0 }
local workspace_windows = {}
local commands = {}

-- Two screens stacked: the top bar reserves 26 at the top of each.
local upper = { id = 0, name = "DP-1", x = 0, y = 0, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } }
local lower = { id = 1, name = "DP-2", x = 0, y = 1080, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } }
local config = { ["plugin.hyprbars.bar_height"] = 30, ["general.border_size"] = 2 }
local monitors = { upper, lower }

hl = {
  on = function(event, callback) handlers[event] = callback end,
  bind = function(keys, callback, opts) table.insert(binds, { callback = callback, opts = opts or {} }) end,
  timer = function(callback) table.insert(timers, callback) end,
  get_active_window = function() return active end,
  get_workspace_windows = function() return workspace_windows end,
  exec_cmd = function(command) table.insert(commands, command) end,
  get_windows = function(filter)
    local found = {}
    for _, w in ipairs(workspace_windows) do
      for _, tag in ipairs(w.tags or {}) do
        if tag == filter.tag then table.insert(found, w) end
      end
    end
    return found
  end,
  get_cursor_pos = function() return cursor end,
  get_monitors = function() return monitors end,
  get_config = function(key) return config[key] end,
  plugin = { hyprbars = {} },
  dispatch = function(dispatcher)
    table.insert(dispatched, dispatcher)
    if dispatcher.kind == "move" and dispatcher.x then dispatcher.window.at = { x = dispatcher.x, y = dispatcher.y } end
    if dispatcher.kind == "move" and dispatcher.workspace then dispatcher.window.moved_to = dispatcher.workspace end
    if dispatcher.kind == "resize" then dispatcher.window.size = { x = dispatcher.x, y = dispatcher.y } end
    if dispatcher.kind == "tag" then
      local name, kept = dispatcher.tag:sub(2), {}
      for _, tag in ipairs(dispatcher.window.tags or {}) do if tag ~= name then table.insert(kept, tag) end end
      if dispatcher.tag:sub(1, 1) == "+" then table.insert(kept, name) end
      dispatcher.window.tags = kept
    end
  end,
  dsp = { window = {
    move = function(args) args.kind = "move"; return args end,
    resize = function(args) args.kind = "resize"; return args end,
    tag = function(args) args.kind = "tag"; return args end,
    fullscreen = function(args) args.kind = "fullscreen"; return args end,
  } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
o = o or {}
local bounds = require("default.hypr.floating-bounds")

local function window(y, extra)
  local w = { address = "0xabc", floating = true, fullscreen = 0, workspace = { id = 1 }, monitor = upper,
    tags = { "omarchy-floating-workspace" }, class = "foot", at = { x = 400, y = 300 }, size = { x = 800, y = 600 } }
  for key, value in pairs(extra or {}) do w[key] = value end
  w.at = { x = 400, y = y }
  return w
end

-- The window becomes active as a drag starts, and again where it is dropped.
local function drop(w, to_y, pointer)
  dispatched = {}
  active = w
  handlers["window.active"]()
  for _, run in ipairs(timers) do run() end
  timers = {}
  w.at = { x = w.at.x, y = to_y }
  cursor = pointer or { x = w.at.x + 100, y = to_y - 10 }
  handlers["window.active"]()
  for _, run in ipairs(timers) do run() end
  timers = {}
  return dispatched
end

local function click(pointer)
  dispatched = {}
  cursor = pointer
  binds[1].callback()
  for _, run in ipairs(timers) do run() end
  timers = {}
  return dispatched
end

assert(#drop(window(300), 40) == 0, "nothing moves until the toggle switches it on")
bounds.keep_title_bar = true

local moved = drop(window(300), 40)
assert(#moved == 1 and moved[1].kind == "move" and moved[1].y == 26 + 2 + 30,
  "a titlebar dropped under the top bar comes down to just below it")

assert(#drop(window(300), 200) == 0, "a window dropped in the clear stays where it was put")
assert(#click({ x = 900, y = 10 }) == 0, "a click on the bar afterwards moves nothing")

local framed = drop(window(300, { tags = { "omarchy-floating-workspace", "omarchy-self-framed*" } }), 10, { x = 500, y = 30 })
assert(#framed == 1 and framed[1].y == 26 + 2, "an app drawing its own header has no titlebar to clear")

local straddling = drop(window(1300, { monitor = lower }), 1070, { x = 500, y = 1060 })
assert(#straddling == 0, "a titlebar showing on the screen above is left where it is")

-- Dragged sideways until its middle is off every screen, a titlebar still in
-- the clear stays put, while one taken above the screens still comes down.
local aside = window(300)
active = aside
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
aside.at = { x = -600, y = 300 }
cursor = { x = -500, y = 280 }
dispatched = {}
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
assert(#dispatched == 0, "a sideways drag off the screen's edge does not jump the window up")

local above = window(300)
active = above
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
above.at = { x = -600, y = -200 }
cursor = { x = -500, y = -220 }
dispatched = {}
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
assert(#dispatched == 1 and dispatched[1].y == 26 + 2 + 30, "a window taken above and off the side comes down on its own screen")

assert(#drop(window(300, { workspace = { id = -98 } }), 10) == 0, "the scratchpad is left to its own rules")
assert(#drop(window(300, { tags = {} }), 10) == 0, "a window on a tiled workspace is left to the layout")

local w = window(300)
active = w
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
w.at = { x = 400, y = 40 }; w.size = { x = 900, y = 600 }
dispatched = {}
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
assert(#dispatched == 0, "a resize from the top edge is not taken for a drop")

assert(#drop(window(300), 40, { x = 50, y = 900 }) == 0, "a window moved while the pointer is elsewhere is not taken for a drop")

local function maximized(list)
  for _, dispatcher in ipairs(list) do
    if dispatcher.kind == "fullscreen" and dispatcher.mode == "maximized" and dispatcher.action == "set" then
      return true
    end
  end
  return false
end

assert(not maximized(drop(window(300), 20, { x = 500, y = 10 })), "nothing maximizes until the toggle switches it on")
bounds.drop_maximize = true

local dropped = drop(window(300), 20, { x = 500, y = 10 })
assert(maximized(dropped), "a window dropped with the pointer on the top bar maximizes")
assert(dropped[1].kind == "move", "its titlebar is brought into reach first, for when it is restored")

assert(not maximized(drop(window(300), 40)), "a window dropped partly under the bar keeps its size")
assert(not maximized(click({ x = 900, y = 10 })), "a click on the bar after a correction maximizes nothing")

-- Hyprland still counts the window on the screen below as it crosses over.
local below = window(1400, { monitor = lower })
assert(not maximized(drop(below, 20, { x = 500, y = 10 })), "the pointer on another screen's bar does not maximize")

-- A drag the mouse binds see ends on the button's release, with no focus
-- event after it: the window was already active when the press landed.
local press, release
for _, bind in ipairs(binds) do
  if bind.opts.release then release = bind.callback else press = bind.callback end
end
assert(press and release, "the left button is watched as it goes down and as it comes up")
assert(binds[1].opts.non_consuming and binds[2].opts.non_consuming, "the click still reaches the window")

local held = window(300)
active = held
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
press(); for _, run in ipairs(timers) do run() end; timers = {}
held.at = { x = 400, y = 20 }
cursor = { x = 500, y = 10 }
dispatched = {}
release(); for _, run in ipairs(timers) do run() end; timers = {}
assert(maximized(dispatched), "a window released over the top bar maximizes without another focus event")

-- While the window is dragged with the pointer on the top bar, the shell shows
-- the box it will fill, growing from its frame, and takes it down as the
-- pointer leaves the bar or the window is dropped.
local function step()
  local queued = timers
  timers = {}
  for _, run in ipairs(queued) do run() end
end
local function last_command() return commands[#commands] or "" end

local dragged = window(300)
active = dragged
commands = {}
handlers["window.active"](); step(); step()
assert(#commands == 0, "a window taken up shows nothing until it moves")
dragged.at = { x = 400, y = 20 }
cursor = { x = 500, y = 10 }
step()
assert(last_command():find("omarchy.window-snap show", 1, true), "the preview shows while the pointer is on the top bar")
assert(last_command():find('"monitor":"DP-1"', 1, true)
  and last_command():find('"from":{"x":398,"y":-12,"width":804,"height":634}', 1, true)
  and last_command():find('"to":{"x":0,"y":26,"width":1920,"height":1054}', 1, true),
  "it grows from the window's frame to what the top bar leaves of the screen")
local shown = #commands
dragged.at = { x = 410, y = 22 }
step()
assert(#commands == shown, "the shell is told only when the answer changes")
dragged.at = { x = 400, y = 310 }
cursor = { x = 500, y = 300 }
step()
assert(last_command() == "omarchy-shell -q omarchy.window-snap hide", "it goes as the pointer leaves the bar")
dragged.at = { x = 400, y = 20 }
cursor = { x = 500, y = 10 }
step()
assert(last_command():find("show", 1, true), "and comes back with it")
dispatched = {}
handlers["window.active"](); step()
assert(maximized(dispatched) and last_command():find("hide", 1, true), "dropped there, the window maximizes and the preview goes")
-- Standing still with the pointer on it, the window may be a drag paused
-- there: it is read more slowly for a while, then left.
cursor = { x = 500, y = 40 }
for _ = 1, 45 do step() end
assert(#timers == 1, "a window standing still under the pointer is still read")
for _ = 1, 130 do step() end
assert(#timers == 0, "and left once it has stood still for long enough")

-- A drag paused away from the edges gets its preview back as it carries on.
local paused = window(300)
active = paused
commands = {}
handlers["window.active"](); step(); step()
paused.at = { x = 400, y = 200 }; cursor = { x = 500, y = 180 }; step()
for _ = 1, 60 do step() end
assert(#commands == 0, "nothing shows while the drag is paused in the clear")
paused.at = { x = 400, y = 20 }; cursor = { x = 500, y = 10 }; step()
assert(last_command():find("omarchy.window-snap show", 1, true), "a paused drag that carries on to the bar shows the preview")
handlers["window.active"](); step()

-- With the pointer off the window, it stops being read once it stands still.
local left_alone = window(300)
active = left_alone
handlers["window.active"](); step(); step()
cursor = { x = 1800, y = 1000 }
for _ = 1, 45 do step() end
assert(#timers == 0, "a window standing still with the pointer elsewhere is no longer read")

-- Dropped with the pointer against the left or right edge, a window fills
-- that half of what the top bar leaves, its frame inside the half.
local function drag_to(w, at, pointer)
  active = w
  handlers["window.active"](); step(); step()
  w.at = at
  cursor = pointer
  step()
  local preview = last_command()
  dispatched = {}
  handlers["window.active"](); step()
  for _ = 1, 45 do step() end
  return preview, dispatched
end
local function landed(w) return w.at.x, w.at.y, w.size.x, w.size.y end

local left_drop = window(300)
local preview = drag_to(left_drop, { x = -100, y = 300 }, { x = 5, y = 280 })
assert(preview:find('"to":{"x":0,"y":26,"width":960,"height":1054}', 1, true), "the preview shows the left half")
local x, y, width, height = landed(left_drop)
assert(x == 2 and y == 26 + 30 + 2 and width == 960 - 4 and height == 1054 - 30 - 4, "a window dropped on the left edge fills the left half")

-- Snapped to a half, the window is marked so the dock hides for it, and the
-- dock is asked to read its windows again; it stays marked through a click,
-- and loses the mark once it is dragged away.
local function snapped(w)
  for _, tag in ipairs(w.tags) do if tag == "omarchy-snapped" then return true end end
  return false
end
local asked = false
for _, command in ipairs(commands) do
  if command == "omarchy-shell -q omarchy.dock refreshWindows" then asked = true end
end
assert(snapped(left_drop) and asked, "a window snapped to a half is marked for the dock, which reads its windows again")
active = left_drop
handlers["window.active"](); step()
for _ = 1, 45 do step() end
assert(snapped(left_drop), "a click on a snapped window leaves it marked")
handlers["window.active"](); step(); step()
left_drop.at = { x = 600, y = 400 }
cursor = { x = 700, y = 380 }
handlers["window.active"](); step()
for _ = 1, 45 do step() end
assert(not snapped(left_drop), "dragged away from the half, it is no longer marked")

-- Resized from the keyboard, with no click or focus change after it, a
-- snapped window still loses the mark; one left alone keeps it.
local keyed = window(300, { address = "0xkey" })
table.insert(workspace_windows, keyed)
drag_to(keyed, { x = -100, y = 300 }, { x = 5, y = 280 })
assert(snapped(keyed), "the window is snapped to begin with")
for _ = 1, 5 do step() end
assert(snapped(keyed), "a snapped window left alone keeps its mark")
keyed.size = { x = keyed.size.x - 100, y = keyed.size.y }
for _ = 1, 3 do step() end
assert(not snapped(keyed), "a snapped window resized from the keyboard is no longer marked")

local right_drop = window(300)
preview = drag_to(right_drop, { x = 1500, y = 300 }, { x = 1915, y = 280 })
assert(preview:find('"to":{"x":960,"y":26,"width":960,"height":1054}', 1, true), "the preview shows the right half")
x, y, width, height = landed(right_drop)
assert(x == 962 and width == 956 and height == 1020, "a window dropped on the right edge fills the right half")

-- An edge snaps just the same where another screen continues from it.
monitors = { upper, lower, { id = 2, name = "DP-3", x = 1920, y = 0, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 } } }
local beside = window(300)
drag_to(beside, { x = 1500, y = 300 }, { x = 1915, y = 280 })
x, y, width, height = landed(beside)
assert(x == 962 and width == 956, "an edge shared with another screen snaps too")
monitors = { upper, lower }

-- Two screens side by side, a small one on the left. A window on the big one
-- held by the far end of its titlebar and pulled to that screen's left edge
-- hangs mostly over the small screen, which Hyprland then counts it on, and
-- the pointer overshoots the edge into the small screen's own margin. It
-- still snaps to the left half of the screen it came from.
local small = { id = 3, name = "DP-2", x = 0, y = 0, width = 1360, height = 768, scale = 1, transform = 0, reserved = { top = 26 }, active_workspace = { id = 11 } }
local big = { id = 4, name = "DP-1", x = 1360, y = 0, width = 1920, height = 1080, scale = 1, transform = 0, reserved = { top = 26 }, active_workspace = { id = 1 } }
monitors = { small, big }
local pulled = window(300, { monitor = big })
pulled.at = { x = 2000, y = 300 }
active = pulled
commands = {}
cursor = { x = 2750, y = 280 }
handlers["window.active"](); step(); step()
pulled.at = { x = 700, y = 300 }; pulled.monitor = small
cursor = { x = 1355, y = 280 }
step()
assert(last_command():find('"monitor":"DP-1"', 1, true) and last_command():find('"to":{"x":0,"y":26,"width":960,"height":1054}', 1, true),
  "overshooting the shared edge still previews the left half of the screen the pointer came from")
dispatched = {}
handlers["window.active"](); step()
for _ = 1, 45 do step() end
assert(pulled.moved_to == "1" and pulled.at.x == 1360 + 2 and pulled.size.x == 960 - 4,
  "dropped there, it goes to that screen's workspace and fills its left half")

-- Coming the other way, from the small screen, the same edge is the small
-- screen's right side.
local pushed = window(300, { monitor = small })
pushed.at = { x = 200, y = 300 }
active = pushed
cursor = { x = 400, y = 280 }
handlers["window.active"](); step(); step()
pushed.at = { x = 1000, y = 300 }
cursor = { x = 1365, y = 280 }
step()
assert(last_command():find('"monitor":"DP-2"', 1, true) and last_command():find('"to":{"x":680,"y":26,"width":680,"height":742}', 1, true),
  "from the small screen, the shared edge snaps to the small screen's right half")
handlers["window.active"](); step()
for _ = 1, 45 do step() end
monitors = { upper, lower }

-- Moving between zones while still dragging, the preview follows.
local roaming = window(300)
active = roaming
commands = {}
handlers["window.active"](); step(); step()
roaming.at = { x = 400, y = 20 }; cursor = { x = 500, y = 10 }; step()
roaming.at = { x = -100, y = 300 }; cursor = { x = 5, y = 280 }; step()
assert(#commands == 2 and commands[2]:find('"to":{"x":0,"y":26,"width":960', 1, true), "the preview moves from the whole screen to the left half")
handlers["window.active"](); step()
for _ = 1, 45 do step() end

-- Hyprland keeps one maximized window per workspace. A window another one is
-- maximized over keeps its full size, and gets its own back once it is
-- maximized and restored itself.
local function settle_fullscreen(w)
  dispatched = {}
  handlers["window.fullscreen"](w)
  for _, run in ipairs(timers) do run() end
  timers = {}
  return dispatched
end

local terminal = window(300, { address = "0x1" })
local mail = window(500, { address = "0x2" })
workspace_windows = { terminal, mail }
terminal.fullscreen = 1; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1030 }
assert(#settle_fullscreen(terminal) == 0, "a window being maximized is only noted")

-- Hyprland hands the state over: the terminal falls back to its own size.
mail.fullscreen = 1; mail.at = { x = 12, y = 58 }; mail.size = { x = 1896, y = 1030 }
terminal.fullscreen = 0; terminal.at = { x = 400, y = 300 }; terminal.size = { x = 870, y = 522 }
settle_fullscreen(mail)
assert(terminal.size.x == 1896 and terminal.size.y == 1030 and terminal.at.x == 12 and terminal.at.y == 58,
  "a window another one is maximized over keeps exactly its maximized box")
local function behind(w)
  for _, tag in ipairs(w.tags) do if tag == "omarchy-maximized-behind" then return true end end
  return false
end
assert(behind(terminal), "it is marked, so the dock hides for it as for a maximized window")

mail.fullscreen = 0; mail.at = { x = 300, y = 200 }; mail.size = { x = 1100, y = 734 }
assert(#settle_fullscreen(mail) == 0, "restoring the window in front leaves the one behind as it is")

terminal.fullscreen = 1; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1030 }
settle_fullscreen(terminal)
assert(not behind(terminal), "maximized for real, it is no longer marked")
terminal.fullscreen = 0; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1000 }
settle_fullscreen(terminal)
assert(terminal.size.x == 870 and terminal.size.y == 522 and terminal.at.x == 400 and terminal.at.y == 300,
  "maximized and restored again, it gets back the size it had before")

-- Omarchy un-maximizes a window when another one opens next to it, so the two
-- share the workspace; with nothing maximized in front, that is left alone.
terminal.fullscreen = 1; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1030 }
settle_fullscreen(terminal)
terminal.fullscreen = 0; terminal.at = { x = 400, y = 300 }; terminal.size = { x = 870, y = 522 }
assert(#settle_fullscreen(terminal) == 0, "a window un-maximized with nothing in front keeps its own size")

-- Moved by the user, it is an ordinary window again and the dock comes back.
mail.fullscreen = 1; terminal.fullscreen = 1; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1030 }
settle_fullscreen(terminal)
terminal.fullscreen = 0
settle_fullscreen(mail)
assert(behind(terminal), "kept at full size behind again")
mail.fullscreen = 0
active = terminal
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
terminal.at = { x = 200, y = 300 }
cursor = { x = 300, y = 280 }
handlers["window.active"](); for _, run in ipairs(timers) do run() end; timers = {}
assert(not behind(terminal), "dragged away, it is no longer marked")

-- Its earlier size goes with the mark: maximized and restored after the user
-- moved it, it keeps the box Hyprland restores rather than the old one.
mail.fullscreen = 0
settle_fullscreen(mail)
terminal.fullscreen = 1; terminal.at = { x = 12, y = 58 }; terminal.size = { x = 1896, y = 1030 }
settle_fullscreen(terminal)
terminal.fullscreen = 0; terminal.at = { x = 200, y = 300 }; terminal.size = { x = 1896, y = 1030 }
settle_fullscreen(terminal)
assert(terminal.at.x == 200 and terminal.size.x == 1896, "a window moved after being kept behind is restored where the user put it")

-- Handed over twice, a window still gets back the size it had before the first.
local first, second = window(300, { address = "0xa" }), window(500, { address = "0xb" })
workspace_windows = { first, second }
local function maximize(w) w.fullscreen = 1; w.at = { x = 12, y = 58 }; w.size = { x = 1896, y = 1030 } end
first.at = { x = 400, y = 300 }; first.size = { x = 870, y = 522 }
maximize(first); settle_fullscreen(first)
maximize(second); first.fullscreen = 0; first.at = { x = 400, y = 300 }; first.size = { x = 870, y = 522 }
settle_fullscreen(second)
maximize(first); second.fullscreen = 0; second.at = { x = 300, y = 200 }; second.size = { x = 1100, y = 734 }
settle_fullscreen(first)
maximize(second); first.fullscreen = 0; first.at = { x = 12, y = 58 }; first.size = { x = 1896, y = 1030 }
settle_fullscreen(second)
second.fullscreen = 0; settle_fullscreen(second)
maximize(first); settle_fullscreen(first)
first.fullscreen = 0; settle_fullscreen(first)
assert(first.size.x == 870 and first.size.y == 522 and first.at.x == 400,
  "a window maximized over twice gets back the size it had before the first time")

-- With Drag Maximize off, nothing would clear the marks, so a load without it
-- clears them and has the dock read its windows again.
local marks = require("default.hypr.floating-marks")
local marked = window(300, { address = "0xc", tags = { "omarchy-floating-workspace", marks.behind } })
local half = window(300, { address = "0xd", tags = { "omarchy-floating-workspace", marks.snapped } })
workspace_windows = { marked, half }
commands = {}
marks.clear()
assert(not behind(marked) and #half.tags == 1 and commands[#commands] == "omarchy-shell -q omarchy.dock refreshWindows",
  "clearing the marks takes them off windows kept behind and snapped ones, and has the dock read its windows")
commands = {}
marks.clear()
assert(#commands == 0, "with nothing marked, the dock is left alone")
workspace_windows = {}

LUA
pass "a floating window dropped under the top bar keeps its titlebar in reach"


run_node_test <<'JS'
const source = require('fs').readFileSync(path.join(root, 'shell/plugins/bar/widgets/Workspaces.qml'), 'utf8')

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
