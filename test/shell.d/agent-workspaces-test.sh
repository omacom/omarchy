#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Runs the placement module against a fake Hyprland: two monitors, DP-2 on the
# right and listed first, as Hyprland lists them. Prints the workspace each
# named rule sends its windows to, after the Lua given on stdin.
placements() {
  OMARCHY_PATH="$ROOT" lua - <<LUA
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules, handlers = {}, {}
local monitors = {
  { name = "DP-2", x = 2560, y = 0 },
  { name = "DP-3", x = 0, y = 0 },
}
local active = monitors[2]

hl = {
  window_rule = function(rule)
    rules[rule.name] = rule.workspace
  end,
  get_monitors = function()
    return monitors
  end,
  get_active_monitor = function()
    return active
  end,
  on = function(event, handler)
    handlers[event] = handler
  end,
}

local function focus(name)
  for _, monitor in ipairs(monitors) do
    if monitor.name == name then
      active = monitor
    end
  end
  handlers["monitor.focused"]()
end

local function show(label)
  local names = {}
  for name in pairs(rules) do
    table.insert(names, name)
  end
  table.sort(names)
  for _, name in ipairs(names) do
    print(label .. " " .. name .. " " .. rules[name])
  end
end

local agent_workspaces = require("default.hypr.agent-workspaces")
agent_workspaces.place("seat", { class = "seat" }, true)
agent_workspaces.place("loud", { class = "loud" })

$(cat)
LUA
}

output=$(placements <<<'show("default")')
[[ $output == $'default loud 10\ndefault seat 10 silent' ]] || fail "the seat gets 10 by default" "$output"
pass "the seat gets workspace 10 by default, silently where asked"

output=$(placements <<<'agent_workspaces.set({ seat = 8 }) show("moved")')
[[ $output == $'moved loud 8\nmoved seat 8 silent' ]] || fail "the user can move the seat's workspace" "$output"
pass "the user can move the seat's workspace"

output=$(placements <<<'focus("DP-2") show("shared")')
[[ $output == $'shared loud 10\nshared seat 10 silent' ]] || fail "one workspace is shared by every monitor by default" "$output"
pass "one workspace is shared by every monitor by default"

output=$(placements <<<'agent_workspaces.set({ per_monitor = 10 }) show("left") focus("DP-2") show("right") focus("DP-3") show("back")')
expected=$'left loud 10\nleft seat 10 silent\nright loud 20\nright seat 20 silent\nback loud 10\nback seat 10 silent'
[[ $output == "$expected" ]] || fail "each monitor gets its own seat workspace, counted from the left" "$output"
pass "each monitor gets its own seat workspace, counted from the left, following focus"

output=$(placements <<<'agent_workspaces.set({ per_monitor = 10, monitors = { "DP-2" } }) show("listed") focus("DP-2") show("first")')
expected=$'listed loud 20\nlisted seat 20 silent\nfirst loud 10\nfirst seat 10 silent'
[[ $output == "$expected" ]] || fail "listed monitors are counted first" "$output"
pass "listed monitors are counted first"

# The keybindings menu reads the user's config with a stand-in hl whose every
# field and call is itself. Moving the seat per monitor must not send that scan
# walking the stand-in until memory runs out.
home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
mkdir -p "$home/.config/hypr"
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.agent-workspaces").set({ per_monitor = 10 })
print("scanned")
LUA
awk '/lua -E - <<.LUA./ { scan = 1; next } /^LUA$/ { scan = 0 } scan' "$ROOT/bin/omarchy-menu-keybindings" >"$home/scan.lua"
output=$(ulimit -v 1000000; HOME=$home OMARCHY_PATH=$ROOT DEBUG=1 timeout 10 lua -E "$home/scan.lua" 2>&1)
[[ $output == *scanned* ]] || fail "the keybindings menu's scan gets through a per-monitor seat" "$output"
pass "the keybindings menu's scan gets through a per-monitor seat"
