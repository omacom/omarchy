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
# Load tiling.lua under a minimal Lua stub that captures every o.bind() call.
# tiling.lua picks its workspace bindings at load time from the toggle's flag
# file: wrapper scripts in global mode, native Hyprland dispatchers in local mode.

# Print the workspace-number bindings tiling.lua registers for a given state dir.
capture_bindings() {
  local state_home="$1"
  XDG_STATE_HOME="$state_home" OMARCHY_PATH="$ROOT" lua << 'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local captured = {}

o = setmetatable({}, {
  __index = function(_, key)
    return function() end   -- silently absorb any o.something() call
  end
})
o.bind = function(keys, description, action, opts)
  table.insert(captured, { keys = keys, action = action })
end

-- hl stub: proxy that returns harmless tables for any chain, except the two
-- native dispatchers the workspace loop uses, which return a readable marker.
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
hl.dsp.focus = function(a)
  if a and a.workspace then return "native-focus " .. a.workspace end
  return {}
end
hl.dsp.window.move = function(a)
  if a and a.workspace then
    return "native-move " .. a.workspace .. (a.follow == false and " silent" or "")
  end
  return {}
end

require("default.hypr.bindings.tiling")

for _, b in ipairs(captured) do
  local keys, action = b.keys, tostring(b.action)
  if keys:match("^SUPER %+ code:1[0-9]$") then
    print("SWITCH|" .. keys .. "|" .. action)
  elseif keys:match("^SUPER %+ SHIFT %+ code:1[0-9]$") then
    print("MOVE|" .. keys .. "|" .. action)
  elseif keys:match("^SUPER %+ SHIFT %+ ALT %+ code:1[0-9]$") then
    print("SILENT_MOVE|" .. keys .. "|" .. action)
  end
end
LUA
}

count_tag() { echo "$1" | grep -c "^$2|" || true; }
all_actions() { echo "$1" | grep "^$2|" | cut -d'|' -f3; }

BIND_STATE=$(mktemp -d)
trap 'rm -rf "$BIND_STATE"' EXIT
mkdir -p "$BIND_STATE/omarchy/toggles/hypr"
touch "$BIND_STATE/omarchy/toggles/hypr/workspace-global.lua"
global_output=$(capture_bindings "$BIND_STATE")
rm "$BIND_STATE/omarchy/toggles/hypr/workspace-global.lua"
local_output=$(capture_bindings "$BIND_STATE")

# ── 1a. Global mode: bindings route through the wrapper scripts ───────────────
for tag in SWITCH MOVE SILENT_MOVE; do
  n=$(count_tag "$global_output" "$tag")
  (( n == 10 )) || fail "global mode: all 10 $tag bindings are captured" "got $n"
done
pass "global mode: all 30 workspace bindings are captured by o.bind"

while IFS= read -r action; do
  [[ "$action" =~ ^omarchy-switch-to-aw\ ([1-9]|10)$ ]] ||
    fail "global mode: SUPER+N routes through omarchy-switch-to-aw" "action=$action"
done < <(all_actions "$global_output" SWITCH)
pass "global mode: SUPER+N bindings route through omarchy-switch-to-aw"

while IFS= read -r action; do
  [[ "$action" =~ ^omarchy-move-window-to-aw\ ([1-9]|10)$ ]] ||
    fail "global mode: SUPER+SHIFT+N routes through omarchy-move-window-to-aw (no --silent)" "action=$action"
done < <(all_actions "$global_output" MOVE)
pass "global mode: SUPER+SHIFT+N bindings route through omarchy-move-window-to-aw without --silent"

while IFS= read -r action; do
  [[ "$action" =~ ^omarchy-move-window-to-aw\ --silent\ ([1-9]|10)$ ]] ||
    fail "global mode: SUPER+SHIFT+ALT+N passes --silent" "action=$action"
done < <(all_actions "$global_output" SILENT_MOVE)
pass "global mode: SUPER+SHIFT+ALT+N bindings pass --silent"

# Boundary slots 1 and 10 must both be bound.
for slot in 1 10; do
  echo "$global_output" | grep '^SWITCH|' | grep -q "omarchy-switch-to-aw $slot\$" ||
    fail "global mode: slot $slot switch binding present" "bindings: $global_output"
  echo "$global_output" | grep '^MOVE|' | grep -q "omarchy-move-window-to-aw $slot\$" ||
    fail "global mode: slot $slot move binding present" "bindings: $global_output"
done
pass "global mode: boundary slots 1 and 10 have switch and move bindings"

# ── 1b. Local mode: native dispatchers, no wrapper process per keypress ───────
for tag in SWITCH MOVE SILENT_MOVE; do
  n=$(count_tag "$local_output" "$tag")
  (( n == 10 )) || fail "local mode: all 10 $tag bindings are captured" "got $n"
done
pass "local mode: all 30 workspace bindings are captured by o.bind"

while IFS='|' read -r tag keys action; do
  [[ "$action" != *omarchy-* ]] ||
    fail "local mode: workspace bindings must not spawn omarchy-* wrappers" "keys=$keys action=$action"
done < <(echo "$local_output")
pass "local mode: no workspace binding routes through an omarchy-* wrapper"

while IFS='|' read -r tag keys action; do
  slot=$(( ${keys##*code:} - 9 ))
  case "$tag" in
    SWITCH)      want="native-focus $slot" ;;
    MOVE)        want="native-move $slot" ;;
    SILENT_MOVE) want="native-move $slot silent" ;;
  esac
  [[ "$action" == "$want" ]] ||
    fail "local mode: $keys uses the native dispatcher" "want=$want got=$action"
done < <(echo "$local_output")
pass "local mode: SUPER+N, SUPER+SHIFT+N and SUPER+SHIFT+ALT+N use native dispatchers for slots 1-10"

# ── 2. End-to-end routing ─────────────────────────────────────────────────────
# Verify that omarchy-switch-to-aw and omarchy-move-window-to-aw (the targets
# of the new bindings) correctly route to the global helper when the flag is set
# and fall back to hyprctl when it is not.

FAKE_BIN=$(mktemp -d)
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$FAKE_BIN" "$STATE_DIR" "$BIND_STATE"' EXIT

GLOBAL_FLAG="$STATE_DIR/.local/state/omarchy/toggles/hypr/workspace-global.lua"
export HOME="$STATE_DIR"
export XDG_STATE_HOME="$STATE_DIR/.local/state"  # bin scripts honor XDG_STATE_HOME over $HOME

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
