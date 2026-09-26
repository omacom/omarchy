#!/bin/bash
# Tests for omarchy-hyprland-workspace-global-switch — run without a compositor.
# Exercises slot validation, fallback behaviour, and focused-monitor-last ordering.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# ── Scratch environment ────────────────────────────────────────────────────────
FAKE_BIN=$(mktemp -d)
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$FAKE_BIN" "$STATE_DIR"' EXIT

BASES_FILE="$STATE_DIR/.local/state/omarchy/monitor-bases.json"
mkdir -p "$(dirname "$BASES_FILE")"
export HOME="$STATE_DIR"

DISPATCH_LOG="$STATE_DIR/dispatch.log"

# Helper: write a hyprctl stub that logs dispatch calls and optionally
# returns a fixed JSON response for 'activeworkspace'.
# Usage: make_hyprctl_stub [focused_monitor_name|"fail"]
#   focused_monitor_name  → activeworkspace returns that monitor name
#   "fail"                → activeworkspace exits 1
#   (omitted)             → activeworkspace returns empty monitor name
make_hyprctl_stub() {
  local focused="${1:-}"
  local stub="$FAKE_BIN/hyprctl"

  if [[ "$focused" == "fail" ]]; then
    cat > "$stub" <<STUB
#!/bin/bash
if [[ "\$1" == "activeworkspace" ]]; then
  exit 1
fi
echo "\$*" >> "$DISPATCH_LOG"
STUB
  elif [[ -n "$focused" ]]; then
    cat > "$stub" <<STUB
#!/bin/bash
if [[ "\$1" == "activeworkspace" ]]; then
  echo '{"id":1,"monitor":"$focused"}'
  exit 0
fi
echo "\$*" >> "$DISPATCH_LOG"
STUB
  else
    cat > "$stub" <<STUB
#!/bin/bash
echo "\$*" >> "$DISPATCH_LOG"
STUB
  fi
  chmod +x "$stub"
}

export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

# ── Slot validation ───────────────────────────────────────────────────────────
make_hyprctl_stub
status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 0 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 0 is rejected"
pass "slot 0 is rejected"

status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 11 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 11 is rejected"
pass "slot 11 is rejected"

status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" "" 2>/dev/null || status=$?
(( status != 0 )) || fail "empty slot is rejected"
pass "empty slot is rejected"

# ── No bases file → raw slot fallback ────────────────────────────────────────
# No monitor-bases.json exists yet; should fall back to a raw hyprctl dispatch.
make_hyprctl_stub
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 3 2>/dev/null || true
log=$(cat "$DISPATCH_LOG" 2>/dev/null || true)
[[ "$log" == *'workspace = "3"'* ]] || fail "no bases file falls back to raw slot dispatch" "got: $log"
pass "no bases file falls back to raw slot dispatch"

# ── Setup: bases file with three monitors ────────────────────────────────────
# eDP-1    base=0  → slot 2 = workspace 2  (will be set as focused)
# HDMI-A-1 base=10 → slot 2 = workspace 12
# DP-1     base=20 → slot 2 = workspace 22
cat > "$BASES_FILE" << 'JSON'
{
  "DP-1": 20,
  "HDMI-A-1": 10,
  "eDP-1": 0
}
JSON

# ── Focused monitor dispatched last ──────────────────────────────────────────
# eDP-1 (base=0) is focused. Expected dispatch order: HDMI-A-1(12), DP-1(22), eDP-1(2).
make_hyprctl_stub "eDP-1"
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 2 2>/dev/null

# Last dispatch must be eDP-1's workspace (base 0 + slot 2 = 2).
last_ws=$(grep 'workspace' "$DISPATCH_LOG" | tail -1 | grep -o '"[0-9]*"' | tr -d '"' || true)
[[ "$last_ws" == "2" ]] || fail "focused monitor (eDP-1, base=0) is dispatched last" \
  "last workspace dispatched: $last_ws; full log:
$(cat "$DISPATCH_LOG")"
pass "focused monitor is dispatched last"

# All three monitors receive a dispatch.
dispatch_count=$(grep -c 'workspace' "$DISPATCH_LOG" || true)
(( dispatch_count == 3 )) || fail "all three monitors are dispatched" \
  "count: $dispatch_count, log:
$(cat "$DISPATCH_LOG")"
pass "all three monitors receive a dispatch"

# Non-focused monitors appear before the focused one.
first_ws=$(grep 'workspace' "$DISPATCH_LOG" | head -1 | grep -o '"[0-9]*"' | tr -d '"' || true)
[[ "$first_ws" != "2" ]] || fail "non-focused monitor dispatched before focused monitor" \
  "first workspace dispatched was eDP-1's (2); full log:
$(cat "$DISPATCH_LOG")"
pass "non-focused monitors dispatched before focused monitor"

# ── Different focused monitor: HDMI-A-1 (base=10) goes last ──────────────────
make_hyprctl_stub "HDMI-A-1"
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 2 2>/dev/null

last_ws=$(grep 'workspace' "$DISPATCH_LOG" | tail -1 | grep -o '"[0-9]*"' | tr -d '"' || true)
[[ "$last_ws" == "12" ]] || fail "focused monitor (HDMI-A-1, base=10) is dispatched last" \
  "last workspace: $last_ws; log:
$(cat "$DISPATCH_LOG")"
pass "HDMI-A-1 as focused monitor is dispatched last (workspace 12)"

# ── Graceful degradation: activeworkspace fails ───────────────────────────────
# When hyprctl activeworkspace exits non-zero, the focused monitor name is empty.
# All monitors must still be dispatched (base-ascending order, no abort).
make_hyprctl_stub "fail"
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-switch" 2 2>/dev/null

dispatch_count=$(grep -c 'workspace' "$DISPATCH_LOG" || true)
(( dispatch_count == 3 )) || fail "all monitors dispatched when activeworkspace fails" \
  "count: $dispatch_count, log:
$(cat "$DISPATCH_LOG")"
pass "all monitors dispatched when activeworkspace fails (graceful degradation)"
