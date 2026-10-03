#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
mkdir -p "$stub_dir" "$home_dir"

for stub in hyprctl omarchy-notification-send; do
  printf '#!/bin/bash\n:\n' >"$stub_dir/$stub"
  chmod +x "$stub_dir/$stub"
done

flag_file="$home_dir/.local/state/omarchy/toggles/hypr/workspace-compact.lua"

HOME="$home_dir" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-compact-toggle"
[[ -f $flag_file ]] || fail "workspace compact toggle installs the flag"
pass "workspace compact toggle installs the flag"

HOME="$home_dir" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$PATH" \
  "$ROOT/bin/omarchy-hyprland-workspace-compact-toggle"
[[ ! -f $flag_file ]] || fail "workspace compact toggle removes the flag"
pass "workspace compact toggle removes the flag"

# Load the flag against a fake Hyprland: dispatches move the fake windows, and
# timers run once the scenario has been set up.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "windows slide down to keep workspace numbers consecutive"
local windows, active, timers = {}, 1, {}

hl = {
  get_windows = function()
    local list = {}
    for _, window in ipairs(windows) do
      table.insert(list, { address = window.address, mapped = true, workspace = { id = window.workspace } })
    end
    return list
  end,
  get_active_workspace = function()
    return { id = active }
  end,
  dsp = {
    window = { move = function(args) return { kind = "move", args = args } end },
    focus = function(args) return { kind = "focus", args = args } end,
  },
  dispatch = function(action)
    if action.kind == "focus" then
      active = tonumber(action.args.workspace)
      return
    end

    local address = action.args.window:gsub("^address:", "")
    for _, window in ipairs(windows) do
      if window.address == address then
        window.workspace = tonumber(action.args.workspace)
      end
    end
  end,
  timer = function(fn) table.insert(timers, fn) end,
  on = function() end,
}

-- Windows are "<address><workspace>" pairs, e.g. "a1 b3"; returns "1=a 2=b active=2".
local function compact(spec, focused)
  windows, active, timers = {}, focused, {}
  for address, workspace in spec:gmatch("(%a)(%d+)") do
    table.insert(windows, { address = address, workspace = tonumber(workspace) })
  end

  dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/toggles/workspace-compact.lua")
  while #timers > 0 do
    table.remove(timers, 1)()
  end

  local by_workspace, ids = {}, {}
  for _, window in ipairs(windows) do
    if by_workspace[window.workspace] == nil then
      table.insert(ids, window.workspace)
    end
    by_workspace[window.workspace] = (by_workspace[window.workspace] or "") .. window.address
  end
  table.sort(ids)

  local parts = {}
  for _, id in ipairs(ids) do
    table.insert(parts, id .. "=" .. by_workspace[id])
  end
  table.insert(parts, "active=" .. active)
  return table.concat(parts, " ")
end

local function check(spec, focused, expected)
  local got = compact(spec, focused)
  assert(got == expected, spec .. " on " .. focused .. ": expected '" .. expected .. "' but got '" .. got .. "'")
end

check("a1 b2 c3", 1, "1=a 2=b 3=c active=1")   -- already consecutive
check("a1 b2 c4", 1, "1=a 2=b 3=c active=1")   -- a gap closes
check("a2 b5 c9", 5, "1=a 2=b 3=c active=2")   -- order is kept, focus follows its windows
check("a1 b3 c3 d6", 1, "1=a 2=bc 3=d active=1") -- windows sharing a workspace stay together
check("a1 b2", 2, "1=a 2=b active=2")
check("a1 b2", 3, "1=a 2=b active=3")           -- an empty workspace next in line is kept
check("a1 b2", 9, "1=a 2=b active=3")           -- an empty workspace past it lands on the next free number
check("a1 b3", 2, "1=a 3=b active=2")           -- the focused empty workspace fills the gap, so nothing moves
check("a2 b3", 1, "2=a 3=b active=1")           -- the focused workspace counts even when empty
check("a2 b3", 2, "1=a 2=b active=1")           -- and the focus follows its windows down
check("", 1, "active=1")
LUA
pass "windows slide down to keep workspace numbers consecutive"
