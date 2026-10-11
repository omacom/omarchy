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

# --- Float All Workspaces -----------------------------------------------------

printf 'hl.workspace_rule({ workspace = "1", layout = "scrolling" })\n' >"$modes_dir/1.lua"
run omarchy-toggle-floating-workspaces

[[ -f $modes_dir/all.lua ]] || fail "turning floating on everywhere saves it"
grep -qF 'o.workspace_mode({ default = "floating" })' "$modes_dir/all.lua" ||
  fail "floating everywhere is saved as the default mode" "$(cat "$modes_dir/all.lua")"
[[ ! -e $modes_dir/1.lua && ! -e $modes_dir/4.lua ]] ||
  fail "every workspace floats, including those with a layout of their own" "$(ls "$modes_dir")"
[[ -f $modes_dir/before-floating/1.lua ]] || fail "a workspace's own layout is set aside, not lost"
grep -qx 'reload' "$fake/hyprctl.log" || fail "turning floating on everywhere reloads Hyprland"
[[ $(run omarchy-hyprland-workspace-layout-current 2) == "floating" ]] ||
  fail "a workspace with no layout of its own floats once floating is on everywhere"
pass "Float All Workspaces floats every workspace and sets their own layouts aside"

# Super + L while floating everywhere gives one workspace a layout of its own.
printf 'o.workspace_mode({ workspace = "4", mode = "dwindle" })\n' >"$modes_dir/4.lua"
[[ $(run omarchy-hyprland-workspace-layout-current 4) == "dwindle" ]] ||
  fail "a workspace given its own layout keeps it while floating is on everywhere"

run omarchy-toggle-floating-workspaces
[[ ! -e $modes_dir/all.lua ]] || fail "turning floating off everywhere removes it"
grep -qF 'layout = "scrolling"' "$modes_dir/1.lua" ||
  fail "the layout a workspace had before comes back"
grep -qF 'mode = "dwindle"' "$modes_dir/4.lua" ||
  fail "a layout chosen while floating everywhere wins over the one set aside" "$(cat "$modes_dir/4.lua")"
[[ ! -e $modes_dir/before-floating ]] || fail "nothing is left set aside"
pass "turning Float All Workspaces off brings back each workspace's own layout"
rm -f "$modes_dir"/*.lua

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
local config = { ["input.follow_mouse"] = 1, ["general.resize_on_border"] = false, ["decoration.shadow.enabled"] = false }
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
    },
  },
  on = function(event, callback)
    subscriptions[event] = subscriptions[event] or {}
    table.insert(subscriptions[event], callback)
  end,
  timer = function(callback) callback() end,
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

# Float All Workspaces floats every regular workspace without a mode of its own,
# and leaves special workspaces and those with their own layout alone.
mkdir -p "$modes_dir"
printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/all.lua"
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

-- Pointer focus and edge resizing follow the active workspace.
assert(s.config["input.follow_mouse"] == 0, "a floating workspace focused on hover")
assert(s.config["general.resize_on_border"] == true, "a floating workspace did not resize from its edges")
s.active.id = 2
s.subscriptions["workspace.active"][1]()
assert(s.config["input.follow_mouse"] == 1, "a tiled workspace lost the user focus setting")
assert(s.config["general.resize_on_border"] == false, "a tiled workspace lost the user resize setting")

-- Shadows only for windows on floating workspaces, when the user has none.
assert(s.config["decoration.shadow.enabled"] == true, "floating windows got no shadows to tell them apart")
assert(#s.rules >= 3, "the floating window rules were not added")
' TITLEBARS_INSTALLED=1; then
  fail "Float All Workspaces floats every regular workspace without a layout of its own"
fi
pass "Float All Workspaces floats every regular workspace without a layout of its own"

# Turning it off is a fresh start with no default, and the windows it floated
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
assert(#s.buttons == 2, "the titlebars do not have exactly close and maximize")
local actions = s.buttons[1].action .. s.buttons[2].action
assert(actions:find("window.close", 1, true), "no button closes the window")
assert(actions:find("maximized", 1, true), "no button maximizes the window")
assert(bar.on_double_click:find("maximized", 1, true), "double-clicking a titlebar does not maximize")
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1; then
  fail "titlebars load when a workspace floats and follow the theme"
fi
pass "titlebars load when a workspace floats and follow the theme"

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
