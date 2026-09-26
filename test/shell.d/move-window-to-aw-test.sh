#!/bin/bash
# Tests for omarchy-move-window-to-aw — run without a live Hyprland session.
# Exercises slot validation and global/local routing logic.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# ── Scratch environment ────────────────────────────────────────────────────────
FAKE_BIN=$(mktemp -d)
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$FAKE_BIN" "$STATE_DIR"' EXIT

GLOBAL_FLAG="$STATE_DIR/.local/state/omarchy/toggles/hypr/workspace-global.lua"
export HOME="$STATE_DIR"

# Stub the global-mode callee.
cat > "$FAKE_BIN/omarchy-hyprland-workspace-global-move-window" << 'STUB'
#!/bin/bash
echo "global-move $*"
STUB
chmod +x "$FAKE_BIN/omarchy-hyprland-workspace-global-move-window"

# Stub hyprctl for local-mode dispatch.
cat > "$FAKE_BIN/hyprctl" << 'STUB'
#!/bin/bash
echo "hyprctl $*"
STUB
chmod +x "$FAKE_BIN/hyprctl"

export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

# ── Slot validation ───────────────────────────────────────────────────────────
status=0
"$ROOT/bin/omarchy-move-window-to-aw" 0 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 0 is rejected"
pass "slot 0 is rejected"

status=0
"$ROOT/bin/omarchy-move-window-to-aw" 11 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 11 is rejected"
pass "slot 11 is rejected"

status=0
"$ROOT/bin/omarchy-move-window-to-aw" "" 2>/dev/null || status=$?
(( status != 0 )) || fail "empty slot is rejected"
pass "empty slot is rejected"

for slot in 1 5 10; do
  output=$(HOME="$STATE_DIR" "$ROOT/bin/omarchy-move-window-to-aw" "$slot" 2>/dev/null)
  [[ "$output" != *"Usage:"* ]] || fail "slot $slot is accepted"
  pass "slot $slot is accepted"
done

# ── Local mode: routes through hyprctl ───────────────────────────────────────
[[ ! -f "$GLOBAL_FLAG" ]] || rm "$GLOBAL_FLAG"

output=$(HOME="$STATE_DIR" "$ROOT/bin/omarchy-move-window-to-aw" 3 2>/dev/null)
[[ "$output" == *"hyprctl"* ]] || fail "local mode calls hyprctl" "got: $output"
[[ "$output" != *"global-move"* ]] || fail "local mode does not call global-move" "got: $output"
pass "local mode routes through hyprctl"

# ── Local mode dispatch uses follow=false (silent move) ──────────────────────
[[ "$output" == *"follow = false"* ]] || fail "local mode passes follow=false for silent move" "got: $output"
pass "local mode passes follow=false for a silent window move"

# ── Global mode: routes through global-move-window ───────────────────────────
mkdir -p "$(dirname "$GLOBAL_FLAG")"
touch "$GLOBAL_FLAG"

output=$(HOME="$STATE_DIR" "$ROOT/bin/omarchy-move-window-to-aw" 3 2>/dev/null)
[[ "$output" == "global-move 3" ]] || fail "global mode calls global-move-window with slot" "got: $output"
pass "global mode routes through omarchy-hyprland-workspace-global-move-window"

# ── Toggle is checked at call time ───────────────────────────────────────────
rm "$GLOBAL_FLAG"
output=$(HOME="$STATE_DIR" "$ROOT/bin/omarchy-move-window-to-aw" 3 2>/dev/null)
[[ "$output" != *"global-move"* ]] || fail "removing flag switches back to local mode at runtime"
pass "toggle is evaluated at call time"
