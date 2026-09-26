#!/bin/bash
# Tests for Issue B fix: default keybindings route through omarchy-switch-to-aw
# and omarchy-move-window-to-aw in global workspace mode.
#
# Two levels of coverage:
#   1. Binding inspection: tiling.lua workspace loop uses the wrapper scripts,
#      not raw hl.dsp.focus / hl.dsp.window.move.
#   2. End-to-end routing: SUPER+N in global/local mode calls the right script.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# ── 1. Binding inspection ─────────────────────────────────────────────────────
# Load tiling.lua under a minimal Lua stub that captures every o.bind() call,
# then verify that all workspace-number bindings use the wrapper commands.

bindings_output=$(OMARCHY_PATH="$ROOT" lua << 'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

-- Minimal stub: capture o.bind() calls; ignore everything else.
local captured = {}

o = setmetatable({}, {
  __index = function(_, key)
    return function() end   -- silently absorb any o.something() call
  end
})
o.bind = function(keys, description, action, opts)
  table.insert(captured, { keys = keys, description = description, action = action })
end

-- hl stub: proxy that returns harmless tables/functions for any chain.
local function proxy()
  return setmetatable({}, {
    __index = function(self, k)
      local v = proxy()
      rawset(self, k, v)
      return v
    end,
    __call = function() return {} end,
  })
end
hl = proxy()

require("default.hypr.bindings.tiling")

-- Print each captured workspace binding for shell inspection.
for _, b in ipairs(captured) do
  local keys = b.keys
  local action = tostring(b.action)
  -- SUPER+N only (no SHIFT, no ALT in modifiers before code:)
  if keys:match("^SUPER %+ code:1[0-9]$") then
    print("SWITCH|" .. keys .. "|" .. action)
  end
  -- SUPER+SHIFT+N only (no ALT)
  if keys:match("^SUPER %+ SHIFT %+ code:1[0-9]$") then
    print("MOVE|" .. keys .. "|" .. action)
  end
end
LUA
)

# SUPER+1..10 must use omarchy-switch-to-aw, not hl.dsp.focus.
switch_count=$(echo "$bindings_output" | grep -c '^SWITCH|' || true)
(( switch_count == 10 )) || fail "all 10 SUPER+N bindings are captured" "got $switch_count"
pass "all 10 SUPER+N bindings are captured by o.bind"

while IFS='|' read -r tag keys action; do
  [[ "$action" == *"omarchy-switch-to-aw"* ]] ||
    fail "SUPER+N binding routes through omarchy-switch-to-aw" "keys=$keys action=$action"
done < <(echo "$bindings_output" | grep '^SWITCH|')
pass "SUPER+N bindings route through omarchy-switch-to-aw (not raw hl.dsp.focus)"

# SUPER+SHIFT+1..10 must use omarchy-move-window-to-aw, not hl.dsp.window.move.
move_count=$(echo "$bindings_output" | grep -c '^MOVE|' || true)
(( move_count == 10 )) || fail "all 10 SUPER+SHIFT+N bindings are captured" "got $move_count"
pass "all 10 SUPER+SHIFT+N bindings are captured by o.bind"

while IFS='|' read -r tag keys action; do
  [[ "$action" == *"omarchy-move-window-to-aw"* ]] ||
    fail "SUPER+SHIFT+N binding routes through omarchy-move-window-to-aw" "keys=$keys action=$action"
done < <(echo "$bindings_output" | grep '^MOVE|')
pass "SUPER+SHIFT+N bindings route through omarchy-move-window-to-aw (not raw hl.dsp.window.move)"

# Slot numbers 1 and 10 (boundary values) must appear in the actions.
slot1_switch=$(echo "$bindings_output" | grep '^SWITCH|' | grep 'omarchy-switch-to-aw 1$' || true)
slot10_switch=$(echo "$bindings_output" | grep '^SWITCH|' | grep 'omarchy-switch-to-aw 10$' || true)
[[ -n "$slot1_switch" ]]  || fail "slot 1 switch binding present"  "bindings: $bindings_output"
[[ -n "$slot10_switch" ]] || fail "slot 10 switch binding present" "bindings: $bindings_output"
pass "boundary slots 1 and 10 both have switch bindings"

slot1_move=$(echo "$bindings_output" | grep '^MOVE|' | grep 'omarchy-move-window-to-aw 1$' || true)
slot10_move=$(echo "$bindings_output" | grep '^MOVE|' | grep 'omarchy-move-window-to-aw 10$' || true)
[[ -n "$slot1_move" ]]  || fail "slot 1 move binding present"  "bindings: $bindings_output"
[[ -n "$slot10_move" ]] || fail "slot 10 move binding present" "bindings: $bindings_output"
pass "boundary slots 1 and 10 both have move bindings"

# ── 1b. Binding inspection: SUPER+SHIFT+ALT+N must pass --silent ──────────────
# The ALT+SHIFT variant (silent move, no follow) must include --silent in the
# command so that local mode can distinguish it from the follow-move binding.
# This catches the regression where both bindings called the wrapper identically.

silent_output=$(OMARCHY_PATH="$ROOT" lua << 'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local captured = {}
o = setmetatable({}, {
  __index = function(_, key) return function() end end
})
o.bind = function(keys, description, action, opts)
  table.insert(captured, { keys = keys, description = description, action = action })
end

local function proxy()
  return setmetatable({}, {
    __index = function(self, k)
      local v = proxy()
      rawset(self, k, v)
      return v
    end,
    __call = function() return {} end,
  })
end
hl = proxy()

require("default.hypr.bindings.tiling")

for _, b in ipairs(captured) do
  local keys = b.keys
  local action = tostring(b.action)
  -- SUPER+SHIFT+ALT+N: the silent move binding
  if keys:match("^SUPER %+ SHIFT %+ ALT %+ code:1[0-9]$") then
    print("SILENT_MOVE|" .. keys .. "|" .. action)
  end
  -- SUPER+SHIFT+N: the follow-move binding
  if keys:match("^SUPER %+ SHIFT %+ code:1[0-9]$") then
    print("FOLLOW_MOVE|" .. keys .. "|" .. action)
  end
end
LUA
)

# SUPER+SHIFT+ALT+N must pass --silent to the move wrapper.
while IFS='|' read -r tag keys action; do
  [[ "$action" == *"--silent"* ]] ||
    fail "SUPER+SHIFT+ALT+N passes --silent to omarchy-move-window-to-aw" \
      "keys=$keys action=$action (missing --silent — local mode will silently move without it)"
done < <(echo "$silent_output" | grep '^SILENT_MOVE|')
pass "SUPER+SHIFT+ALT+N bindings all pass --silent to omarchy-move-window-to-aw"

# SUPER+SHIFT+N must NOT pass --silent (it should follow the window).
while IFS='|' read -r tag keys action; do
  [[ "$action" != *"--silent"* ]] ||
    fail "SUPER+SHIFT+N does NOT pass --silent (follow move should follow)" \
      "keys=$keys action=$action (--silent should only appear on the ALT variant)"
done < <(echo "$silent_output" | grep '^FOLLOW_MOVE|')
pass "SUPER+SHIFT+N bindings do NOT pass --silent (follow move follows the window)"

# ── 2. End-to-end routing ─────────────────────────────────────────────────────
# Verify that omarchy-switch-to-aw and omarchy-move-window-to-aw (the targets
# of the new bindings) correctly route to the global helper when the flag is set
# and fall back to hyprctl when it is not.

FAKE_BIN=$(mktemp -d)
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$FAKE_BIN" "$STATE_DIR"' EXIT

GLOBAL_FLAG="$STATE_DIR/.local/state/omarchy/toggles/hypr/workspace-global.lua"
export HOME="$STATE_DIR"

# Stub the global helpers so we can observe routing without a compositor.
cat > "$FAKE_BIN/omarchy-hyprland-workspace-global-switch" << 'STUB'
#!/bin/bash
echo "global-switch $*"
STUB
chmod +x "$FAKE_BIN/omarchy-hyprland-workspace-global-switch"

cat > "$FAKE_BIN/omarchy-hyprland-workspace-global-move-window" << 'STUB'
#!/bin/bash
echo "global-move $*"
STUB
chmod +x "$FAKE_BIN/omarchy-hyprland-workspace-global-move-window"

cat > "$FAKE_BIN/hyprctl" << 'STUB'
#!/bin/bash
echo "hyprctl $*"
STUB
chmod +x "$FAKE_BIN/hyprctl"

export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

# Global mode: switch routes to omarchy-hyprland-workspace-global-switch.
mkdir -p "$(dirname "$GLOBAL_FLAG")" && touch "$GLOBAL_FLAG"

output=$("$ROOT/bin/omarchy-switch-to-aw" 5 2>/dev/null)
[[ "$output" == "global-switch 5" ]] ||
  fail "global mode: SUPER+5 routes to global switch helper" "got: $output"
pass "global mode: omarchy-switch-to-aw routes to global switch helper"

# Global mode: move routes to omarchy-hyprland-workspace-global-move-window.
output=$("$ROOT/bin/omarchy-move-window-to-aw" 5 2>/dev/null)
[[ "$output" == "global-move 5" ]] ||
  fail "global mode: SUPER+SHIFT+5 routes to global move helper" "got: $output"
pass "global mode: omarchy-move-window-to-aw routes to global move helper"

# Local mode: switch falls back to hyprctl.
rm "$GLOBAL_FLAG"
output=$("$ROOT/bin/omarchy-switch-to-aw" 5 2>/dev/null)
[[ "$output" == *"hyprctl"* && "$output" != *"global-switch"* ]] ||
  fail "local mode: SUPER+5 falls back to hyprctl" "got: $output"
pass "local mode: omarchy-switch-to-aw falls back to hyprctl"

# Local mode: move falls back to hyprctl.
output=$("$ROOT/bin/omarchy-move-window-to-aw" 5 2>/dev/null)
[[ "$output" == *"hyprctl"* && "$output" != *"global-move"* ]] ||
  fail "local mode: SUPER+SHIFT+5 falls back to hyprctl" "got: $output"
pass "local mode: omarchy-move-window-to-aw falls back to hyprctl"

# Local mode: follow move (no --silent) must NOT include follow=false.
# In Hyprland 0.56.2, moveToWorkspace without follow=false switches to the
# target workspace alongside the window. With follow=false it stays silent.
output=$("$ROOT/bin/omarchy-move-window-to-aw" 5 2>/dev/null)
[[ "$output" != *"follow = false"* ]] ||
  fail "local mode follow: SUPER+SHIFT+5 must NOT pass follow=false" "got: $output"
pass "local mode: follow move (no --silent) omits follow=false — window and display move together"

# Local mode: silent move (--silent flag) MUST include follow=false.
output=$("$ROOT/bin/omarchy-move-window-to-aw" --silent 5 2>/dev/null)
[[ "$output" == *"follow = false"* ]] ||
  fail "local mode silent: SUPER+SHIFT+ALT+5 must pass follow=false" "got: $output"
pass "local mode: silent move (--silent) passes follow=false — window moves, display stays"
