#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# SUPER+S used to always toggle special:scratchpad. Opening it empty steals the
# next spawn onto the special workspace (#10415). The bind must open only when
# the scratchpad already has windows, and must always close when it is showing.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "empty scratchpad toggle stays closed"
local dispatched = {}
local workspaces = {}
local active_special = nil
local toggle_fn = nil

local function proxy()
  return setmetatable({}, {
    __index = function(self, key)
      local value = proxy()
      rawset(self, key, value)
      return value
    end,
    __call = function()
      return { kind = "dsp" }
    end,
  })
end

hl = {
  dsp = proxy(),
  dispatch = function(action)
    table.insert(dispatched, action)
  end,
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if opts.description == "Toggle scratchpad" then
      assert(type(dispatcher) == "function", "toggle scratchpad bind must be a function")
      toggle_fn = dispatcher
    end
  end,
  get_active_special_workspace = function()
    return active_special
  end,
  get_workspace = function(selector)
    return workspaces[selector]
  end,
}

-- Mark toggle_special calls so assertions can tell them apart from other dsp stubs.
local real_toggle
do
  local workspace = hl.dsp.workspace
  real_toggle = function(name)
    assert(name == "scratchpad", "toggle targets scratchpad, got " .. tostring(name))
    return { kind = "toggle_special", name = name }
  end
  workspace.toggle_special = real_toggle
end

package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
require("default.hypr.bindings.tiling")

assert(toggle_fn, "SUPER+S / grave bind the toggle function")

local function run_toggle()
  dispatched = {}
  toggle_fn()
  return dispatched
end

-- Case 1: scratchpad does not exist yet — no-op (nothing to show).
workspaces = {}
active_special = nil
local got = run_toggle()
assert(#got == 0, "missing scratchpad does not open: dispatched " .. #got)

-- Case 2: scratchpad exists but is empty — no-op.
workspaces["special:scratchpad"] = {
  name = "special:scratchpad",
  windows = 0,
  special = true,
}
got = run_toggle()
assert(#got == 0, "empty scratchpad does not open: dispatched " .. #got)

-- Case 3: scratchpad has windows and is closed — open it.
workspaces["special:scratchpad"] = {
  name = "special:scratchpad",
  windows = 2,
  special = true,
}
got = run_toggle()
assert(#got == 1 and got[1].kind == "toggle_special", "populated scratchpad opens")

-- Case 4: scratchpad is already showing (even if windows hit 0 mid-close) — close it.
active_special = {
  name = "special:scratchpad",
  windows = 0,
  special = true,
}
got = run_toggle()
assert(#got == 1 and got[1].kind == "toggle_special", "open empty scratchpad still closes")

-- Case 5: bare name form still counts as the open scratchpad.
active_special = {
  name = "scratchpad",
  windows = 1,
  special = true,
}
got = run_toggle()
assert(#got == 1 and got[1].kind == "toggle_special", "bare scratchpad name still closes")

-- Case 6: a different special workspace is active — do not treat it as scratchpad open.
active_special = {
  name = "special:magic",
  windows = 1,
  special = true,
}
workspaces["special:scratchpad"] = {
  name = "special:scratchpad",
  windows = 0,
  special = true,
}
got = run_toggle()
assert(#got == 0, "other special workspace does not force a scratchpad open")

-- Case 7: other special active, but scratchpad has windows — open scratchpad.
workspaces["special:scratchpad"] = {
  name = "special:scratchpad",
  windows = 1,
  special = true,
}
got = run_toggle()
assert(#got == 1 and got[1].kind == "toggle_special", "populated scratchpad opens over another special")
LUA
pass "empty scratchpad toggle stays closed"

# Static: both toggle chords share the guarded function, not a bare dispatcher.
if grep -nE 'o\.bind\("SUPER \+ (S|grave)".*toggle_special' "$ROOT/default/hypr/bindings/tiling.lua" >/dev/null; then
  fail "toggle chords must not bind bare toggle_special"
fi
grep -q 'toggle_scratchpad' "$ROOT/default/hypr/bindings/tiling.lua" ||
  fail "tiling.lua defines toggle_scratchpad"
pass "both toggle chords use the empty-guard function"
