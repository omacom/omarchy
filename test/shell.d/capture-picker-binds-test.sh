#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

ROOT="$ROOT" lua -E - <<'LUA' || fail "screenshot picker leaves the user's binds on its keys alone"
local binds = {}
local handlers = {}

-- Like Hyprland's, unbinding removes every bind on the chord and expires their handles.
local function unbind(keys)
  for index = #binds, 1, -1 do
    if binds[index].keys == keys then
      binds[index].expired = true
      table.remove(binds, index)
    end
  end
end

local function bind(keys)
  local keybind = { keys = keys, enabled = true }

  -- Hyprland's methods crash on an expired handle; only tostring() reports it.
  local function live(self)
    assert(not self.expired, "called a method on an expired handle: " .. self.keys)
  end

  function keybind:set_enabled(enabled)
    live(self)
    self.enabled = enabled
  end

  function keybind:unbind()
    live(self)
    unbind(self.keys)
  end

  table.insert(binds, keybind)
  return setmetatable(keybind, {
    __tostring = function(self)
      return self.expired and "HL.Keybind(expired)" or "HL.Keybind(live)"
    end,
  })
end

hl = {
  bind = bind,
  unbind = unbind,
  dsp = { exec_cmd = function(command) return command end },
  on = function(event, handler) handlers[event] = handler end,
}
o = setmetatable({}, { __index = function() return function() end end })

dofile(os.getenv("ROOT") .. "/default/hypr/bindings/utilities.lua")

local user = bind("CTRL + TAB")

local function enabled_picker_binds()
  local count = 0
  for _, keybind in ipairs(binds) do
    if keybind ~= user and keybind.enabled then
      count = count + 1
    end
  end
  return count
end

local function use_picker()
  handlers["layer.opened"]({ namespace = "selection" })
  handlers["layer.opened"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 8, "the picker enables its eight binds while open")

  handlers["layer.closed"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 8, "the picker keeps its binds while a layer is still open")

  handlers["layer.closed"]({ namespace = "selection" })
  assert(enabled_picker_binds() == 0, "the picker disables its binds once every layer closes")
end

use_picker()
use_picker()

local kept = false
for _, keybind in ipairs(binds) do
  kept = kept or keybind == user
end
assert(kept and user.enabled, "the user's own CTRL + TAB survives the picker")
assert(#binds == 9, "the picker reuses its binds rather than adding more each time")

hl.unbind("TAB")
use_picker()
assert(#binds == 9, "the picker binds a chord again after something else unbinds it")

handlers["layer.opened"]({ namespace = "selection" })
hl.unbind("RETURN")
handlers["layer.closed"]({ namespace = "selection" })
assert(enabled_picker_binds() == 0, "the picker closes cleanly after a chord is unbound while open")
LUA

pass "screenshot picker leaves the user's binds on its keys alone"

# A bare click on a monitor other than the focused one snaps to that monitor.
stub_bin=$(mktemp -d)
trap 'rm -rf "$stub_bin"' EXIT

cat >"$stub_bin/hyprctl" <<'STUB'
#!/bin/bash
case $1 in
monitors)
  echo '[
    {"name": "eDP-1", "focused": true, "x": 0, "y": 0, "width": 1920, "height": 1200, "scale": 1, "transform": 0, "mirrorOf": "none", "activeWorkspace": {"id": 1}},
    {"name": "DP-1", "focused": false, "x": 1920, "y": 0, "width": 2560, "height": 1440, "scale": 1, "transform": 0, "mirrorOf": "none", "activeWorkspace": {"id": 2}}
  ]'
  ;;
clients)
  echo '[
    {"at": [2000, 100], "size": [800, 600], "hidden": false, "workspace": {"id": 2}},
    {"at": [2100, 200], "size": [300, 300], "hidden": false, "workspace": {"id": 3}}
  ]'
  ;;
esac
STUB
printf '#!/bin/bash\ncat >"$SLURP_RECTS"\necho "$SLURP_OUT"\n' >"$stub_bin/slurp"
printf '#!/bin/bash\n' >"$stub_bin/hyprpicker"
chmod +x "$stub_bin"/*

picked=$(SLURP_OUT="2200,300 1x1" SLURP_RECTS="$stub_bin/rects" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-capture-region" smart --match-monitor)
[[ $picked == "monitor:DP-1" ]] || fail "a bare click on an unfocused monitor snaps to it (got: $picked)"

rects=$(<"$stub_bin/rects")
[[ $rects == *"2000,100 800x600"* && $rects != *"2100,200 300x300"* ]] || fail "the picker hints windows on every visible workspace and no hidden one (got: $rects)"

pass "capture picker snaps a bare click on any monitor"
