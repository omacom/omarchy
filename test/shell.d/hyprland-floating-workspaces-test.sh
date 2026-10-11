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

# --- Setting a window aside ---------------------------------------------------

client() {
  local address=$1 workspace=$2 extra=${3:-"{}"}
  jq -cn --arg address "$address" --arg workspace "$workspace" --argjson extra "$extra" '{
    address: $address, pid: 42, class: "foot", initialClass: "foot", title: "Notes",
    workspace: { id: (if ($workspace | startswith("special:")) then -98 else ($workspace | tonumber) end), name: $workspace },
    monitor: 0, at: [400, 300], size: [900, 600], floating: true, fullscreen: 0, fullscreenClient: 0,
    pinned: false, tags: ["omarchy-mode-floated", "omarchy-floating-workspace"]
  } + $extra'
}

shelf_dir="$runtime_dir/omarchy/shelf"

printf '[%s]\n' "$(client 0xabc 2 '{ "pinned": true }')" >"$fake/clients.json"
reset_logs
run omarchy-hyprland-window-minimize 0xabc

record="$shelf_dir/0xabc.json"
[[ -f $record ]] || fail "setting a window aside notes where it came from"
[[ $(jq -r '.workspace' "$record") == "2" ]] || fail "the note names the workspace it was set aside from"
[[ $(jq -c '.at + .size' "$record") == "[400,300,900,600]" ]] || fail "the note keeps the window's place and size"
[[ $(jq -c '.monitorArea' "$record") == "[0,30,2560,1410]" ]] ||
  fail "the note keeps the usable area of the monitor it was on" "$(jq -c '.monitorArea' "$record")"
dispatched 'window.pin({ action = "disable", window = "address:0xabc" })' ||
  fail "a pinned window is unpinned to set it aside" "$(cat "$fake/hyprctl.log")"
dispatched 'window.move({ workspace = "special:shelf", follow = false, window = "address:0xabc" })' ||
  fail "the window moves onto the Shelf" "$(cat "$fake/hyprctl.log")"
! grep -qF 'omarchy-bar' "$fake/commands.log" ||
  fail "setting a window aside leaves the bar layout to the user" "$(cat "$fake/commands.log")"
pass "setting a window aside notes its place and moves it to the Shelf"

# A fullscreen window comes out of fullscreen first, and the size it comes back
# to is the one worth remembering.
printf '[%s,%s]\n' "$(client 0xabc special:shelf)" "$(client 0xdef 2 '{ "fullscreen": 1, "at": [0, 30], "size": [2560, 1410] }')" >"$fake/clients.json"
reset_logs
run omarchy-hyprland-window-minimize 0xdef
dispatched 'window.fullscreen_state({ internal = 0, client = 0, window = "address:0xdef" })' ||
  fail "a fullscreen window leaves fullscreen before it is set aside"
[[ $(jq '.fullscreen' "$shelf_dir/0xdef.json") == "1" ]] ||
  fail "the fullscreen state is remembered to return to"
pass "a fullscreen window is set aside with its fullscreen state remembered"

# The note of a window closed while it was set aside goes with it, and only that.
mkdir -p "$shelf_dir"
printf '{}\n' >"$shelf_dir/0xdead.json"
printf '[%s,%s,%s]\n' "$(client 0xabc special:shelf)" "$(client 0xdef special:shelf)" "$(client 0xfeed 2)" >"$fake/clients.json"
run omarchy-hyprland-window-minimize 0xfeed
[[ ! -e $shelf_dir/0xdead.json ]] || fail "the note of a closed window is dropped"
[[ -f $record && -f $shelf_dir/0xdef.json ]] || fail "the notes of windows still set aside are kept"
rm -f "$shelf_dir/0xfeed.json"
pass "notes of windows closed while set aside are dropped"

# A window already on a special workspace is set aside already.
printf '[%s]\n' "$(client 0x123 special:scratchpad)" >"$fake/clients.json"
reset_logs
run omarchy-hyprland-window-minimize 0x123
if dispatched 'window.move'; then
  fail "a window on a special workspace is not moved to the Shelf"
fi
pass "a window on a special workspace is left where it is"

# Without its note a window would come back at the wrong size, or tiled when it
# floated on its own account, so one whose note cannot be saved stays put.
printf '[%s]\n' "$(client 0xbad 2)" >"$fake/clients.json"
printf 'not a directory\n' >"$tmpdir/runtime-file"
reset_logs
if run env XDG_RUNTIME_DIR="$tmpdir/runtime-file" omarchy-hyprland-window-minimize 0xbad 2>/dev/null; then
  fail "setting a window aside fails when its note cannot be saved"
fi
if dispatched 'window.move'; then
  fail "a window whose note cannot be saved is not moved to the Shelf" "$(cat "$fake/hyprctl.log")"
fi
pass "a window whose note cannot be saved stays where it is"

if run omarchy-hyprland-window-minimize 'address:0xabc; rm -rf /' 2>/dev/null; then
  fail "anything but a window address is refused"
fi
pass "the window address is checked before it reaches a dispatch"

# --- The Shelf listing ---------------------------------------------------------

printf '[%s,%s,%s]\n' \
  "$(client 0xabc special:shelf)" \
  "$(client 0xdef special:shelf '{ "title": "Fullscreen" }')" \
  "$(client 0x999 special:shelf '{ "pid": 7, "title": "Orphan" }')" >"$fake/clients.json"
jq '.order = 1' "$record" >"$record.tmp" && mv "$record.tmp" "$record"
jq '.order = 2' "$shelf_dir/0xdef.json" >"$shelf_dir/0xdef.json.tmp" && mv "$shelf_dir/0xdef.json.tmp" "$shelf_dir/0xdef.json"

listing=$(run omarchy-hyprland-window-shelf-list)
[[ $(jq -r '[.windows[].address] | join(",")' <<<"$listing") == "0xdef,0xabc,0x999" ]] ||
  fail "the Shelf lists the latest window set aside first" "$listing"
[[ $(jq -r '.windows[1].workspace' <<<"$listing") == "2" ]] ||
  fail "each window says where it was set aside from" "$listing"
[[ $(jq -r '.windows[2].workspace' <<<"$listing") == "" ]] ||
  fail "a window without a note of its own is still listed, without an origin" "$listing"
[[ $(jq -r '.available' <<<"$listing") == "false" ]] ||
  fail "the Shelf does not report floating in use when nothing floats" "$listing"

printf 'o.workspace_mode({ default = "floating" })\n' >"$modes_dir/all.lua"
listing=$(run omarchy-hyprland-window-shelf-list)
[[ $(jq -c '[.available, .allWorkspaces, .layout]' <<<"$listing") == '[true,true,"floating"]' ]] ||
  fail "the Shelf reports floating everywhere and the current workspace layout" "$listing"
rm -f "$modes_dir/all.lua"
pass "the Shelf lists every window on it, latest first, with the current layout"

# --- Bringing a window back ----------------------------------------------------

# Onto a floating workspace, the window returns to its place and size. Here the
# monitor is smaller than when it was set aside, so it is kept inside it.
printf 'o.workspace_mode({ workspace = "2", mode = "floating" })\n' >"$modes_dir/2.lua"
jq '.at = [2000, 900] | .size = [900, 600] | .floating = true | .pinned = true' "$record" >"$record.tmp" && mv "$record.tmp" "$record"
cat >"$fake/monitors.json" <<'EOF'
[{ "id": 0, "name": "eDP-1", "x": 0, "y": 0, "width": 1920, "height": 1200, "scale": 1, "transform": 0, "reserved": [0, 30, 0, 0] }]
EOF
reset_logs
run omarchy-hyprland-window-restore 0xabc

dispatched 'window.tag({ tag = "+omarchy-shelf-restoring", window = "address:0xabc" })' ||
  fail "the window is marked so the workspace mode leaves it to be put back"
dispatched 'window.move({ workspace = "2", follow = true, window = "address:0xabc" })' ||
  fail "the window comes to the workspace in front of the user" "$(cat "$fake/hyprctl.log")"
dispatched 'window.float({ action = "on", window = "address:0xabc" })' ||
  fail "a window restored onto a floating workspace floats"
dispatched 'window.resize({ x = 900, y = 600, relative = false, window = "address:0xabc" })' ||
  fail "the window keeps its size" "$(cat "$fake/hyprctl.log")"
dispatched 'window.move({ x = 1018, y = 598, relative = false, window = "address:0xabc" })' ||
  fail "a window set aside on a bigger monitor comes back inside this one" "$(cat "$fake/hyprctl.log")"
dispatched 'window.pin({ action = "enable", window = "address:0xabc" })' ||
  fail "a window that was pinned is pinned again"
dispatched 'window.tag({ tag = "+omarchy-floating-workspace", window = "address:0xabc" })' ||
  fail "a window restored onto a floating workspace gets its titlebar"
tail -n 1 "$fake/hyprctl.log" | grep -qF -- '-omarchy-shelf-restoring' ||
  fail "the restoring mark is the last thing removed" "$(tail -n 3 "$fake/hyprctl.log")"
[[ ! -e $record ]] || fail "the note is dropped once the window is back"
pass "a window restored onto a floating workspace returns to its place and size"

# Onto a tiled workspace, a window the mode floated joins the layout.
rm -f "$modes_dir/2.lua"
printf '[%s]\n' "$(client 0xdef special:shelf)" >"$fake/clients.json"
reset_logs
run omarchy-hyprland-window-restore 0xdef
dispatched 'window.float({ action = "off", window = "address:0xdef" })' ||
  fail "a window the mode floated is tiled on a tiled workspace" "$(cat "$fake/hyprctl.log")"
dispatched 'window.tag({ tag = "-omarchy-mode-floated", window = "address:0xdef" })' ||
  fail "the mode gives up its claim on a window tiled again"
dispatched 'window.tag({ tag = "-omarchy-floating-workspace", window = "address:0xdef" })' ||
  fail "a window on a tiled workspace has no titlebar"
pass "a window restored onto a tiled workspace joins its layout"

# A dialog that floated before any mode touched it keeps floating anywhere.
printf '[%s]\n' "$(client 0x777 special:shelf '{ "tags": [] }')" >"$fake/clients.json"
mkdir -p "$shelf_dir"
client 0x777 2 '{ "tags": [] }' >"$shelf_dir/0x777.json"
reset_logs
run omarchy-hyprland-window-restore 0x777
dispatched 'window.float({ action = "on", window = "address:0x777" })' ||
  fail "a window floating on its own account floats on a tiled workspace" "$(cat "$fake/hyprctl.log")"
if dispatched 'window.tag({ tag = "+omarchy-mode-floated"'; then
  fail "a window floating on its own account is not claimed by the mode"
fi
pass "a window that floats on its own account keeps floating when restored"

# A note left by a window that has since closed says nothing about a new window
# that was given the same address.
printf '[%s]\n' "$(client 0x888 special:shelf '{ "pid": 99 }')" >"$fake/clients.json"
client 0x888 2 '{ "tags": [], "pinned": true }' >"$shelf_dir/0x888.json"
reset_logs
run omarchy-hyprland-window-restore 0x888
if dispatched 'window.pin'; then
  fail "a note from another window is not applied" "$(cat "$fake/hyprctl.log")"
fi
pass "a note from a window that has since closed is ignored"

# A window not on the Shelf is not the restore command's to move.
printf '[%s]\n' "$(client 0xabc 2)" >"$fake/clients.json"
reset_logs
if run omarchy-hyprland-window-restore 0xabc; then
  fail "restoring a window that is not on the Shelf fails"
fi
[[ ! -s $fake/hyprctl.log ]] || fail "restoring a window that is not on the Shelf touches nothing"
pass "only a window on the Shelf can be restored"

# --- The workspace mode in Hyprland --------------------------------------------

mkdir -p "$state_home/omarchy/current/theme"
cat >"$state_home/omarchy/current/theme/colors.toml" <<'EOF'
background = "#112233"
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
local shelved = window("0x3", -98, { floating = true, tags = { "omarchy-mode-floated" } })
require("default.hypr.workspace-layouts")
assert(not floated.floating, "a window the mode floated stayed floating once floating was off")
assert(not has_tag(floated, "omarchy-mode-floated"), "a window given back is still claimed")
assert(not has_tag(floated, "omarchy-floating-workspace"), "a tiled window kept its titlebar tag")
assert(dialog.floating, "a dialog was tiled when floating was turned off")
assert(not has_tag(dialog, "omarchy-floating-workspace"), "a dialog on a tiled workspace kept its titlebar tag")
assert(shelved.floating and has_tag(shelved, "omarchy-mode-floated"), "a window on the Shelf was tiled while set aside")
'; then
  fail "turning floating off gives back what it floated, but not what is on the Shelf"
fi
pass "turning floating off gives back what it floated, but not what is on the Shelf"

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

# Moving a window to the Shelf, or one being restored from it, is left alone.
printf 'o.workspace_mode({ workspace = "1", mode = "floating" })\n' >"$modes_dir/1.lua"
if ! run_lua '
local moving = window("0x1", 1)
require("default.hypr.workspace-layouts")
local moved = state().subscriptions["window.move_to_workspace"][1]
assert(moving.floating, "the window was not floated to begin with")

moved(moving, { id = -98 })
assert(moving.floating and has_tag(moving, "omarchy-mode-floated"), "a window set aside was tiled on its way to the Shelf")

local restoring = window("0x2", -98, { tags = { "omarchy-shelf-restoring" } })
moved(restoring, { id = 1 })
assert(not restoring.floating, "a window being restored was arranged before it was put back")

moved(moving, { id = 2 })
assert(not moving.floating, "a window carried to a tiled workspace kept floating")
'; then
  fail "the mode leaves windows on their way to and from the Shelf alone"
fi
pass "the mode leaves windows on their way to and from the Shelf alone"

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
assert(bar.bar_color == "rgb(112233)", "titlebars do not follow the theme background: " .. tostring(bar.bar_color))
assert(bar.col.text == "rgb(ddeeff)", "titlebar text does not follow the theme foreground")
assert(bar.edge_snap == true, "edge snapping is off")
assert(#s.buttons == 3, "the titlebars do not have three buttons")
local actions = s.buttons[1].action .. s.buttons[2].action .. s.buttons[3].action
assert(actions:find("omarchy-hyprland-window-minimize %WINDOW%", 1, true), "no button sets the window aside")
assert(actions:find("window.close", 1, true), "no button closes the window")
assert(bar.on_double_click:find("maximized", 1, true), "double-clicking a titlebar does not maximize")
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1; then
  fail "titlebars load when a workspace floats and follow the theme"
fi
pass "titlebars load when a workspace floats and follow the theme"

# omarchy-theme-set writes the current theme under ~/.local/state even when
# XDG_STATE_HOME points elsewhere, so that is where the titlebars find it.
other_state="$tmpdir/other-state"
mkdir -p "$other_state/omarchy/workspace-layouts"
cp "$modes_dir/1.lua" "$other_state/omarchy/workspace-layouts/"
if ! run_lua '
window("0x1", 1)
require("default.hypr.workspace-layouts")
local bar = state().titlebar_config
assert(bar and bar.bar_color == "rgb(112233)", "titlebars missed the theme with XDG_STATE_HOME elsewhere: " .. tostring(bar and bar.bar_color))
' TITLEBARS_INSTALLED=1 TITLEBARS_LOADED=1 XDG_STATE_HOME="$other_state"; then
  fail "titlebars follow the theme when XDG_STATE_HOME points elsewhere"
fi
pass "titlebars follow the theme when XDG_STATE_HOME points elsewhere"
