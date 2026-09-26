#!/bin/bash
# Tests for omarchy-hyprland-workspace-global-move-window — run without a compositor.
# Exercises slot validation, fallback behaviour, and the set -euo pipefail
# compatibility of the TARGET_WS assignment (Issue D fix).

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

# Helper: write a hyprctl stub with configurable activewindow / monitors responses.
#   make_hyprctl_stub <activewindow_json> <monitors_json>
# Pass "" for activewindow_json to simulate no active window.
# Pass "FAIL_MONITORS" to make hyprctl monitors exit 1.
make_hyprctl_stub() {
  local activewindow_json="$1"
  local monitors_json="$2"
  local stub="$FAKE_BIN/hyprctl"

  cat > "$stub" <<STUB
#!/bin/bash
case "\$1" in
  activewindow)
    echo '$activewindow_json'
    ;;
  monitors)
STUB

  if [[ "$monitors_json" == "FAIL_MONITORS" ]]; then
    echo '    exit 1 ;;' >> "$stub"
  else
    cat >> "$stub" <<STUB
    echo '$monitors_json'
    ;;
STUB
  fi

  cat >> "$stub" <<STUB
  dispatch)
    echo "\$*" >> "$DISPATCH_LOG"
    ;;
esac
STUB
  chmod +x "$stub"
}

export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

# ── Slot validation ───────────────────────────────────────────────────────────
make_hyprctl_stub '{"address":"0x1","monitor":"eDP-1"}' '[{"name":"eDP-1","focused":true}]'

status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 0 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 0 is rejected"
pass "slot 0 is rejected"

status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 11 2>/dev/null || status=$?
(( status != 0 )) || fail "slot 11 is rejected"
pass "slot 11 is rejected"

status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" "" 2>/dev/null || status=$?
(( status != 0 )) || fail "empty slot is rejected"
pass "empty slot is rejected"

# ── No active window → silent no-op ─────────────────────────────────────────
make_hyprctl_stub '{}' '[{"name":"eDP-1","focused":true}]'
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 3 2>/dev/null || true
dispatch_count=$(grep -c 'dispatch' "$DISPATCH_LOG" 2>/dev/null || echo 0)
(( dispatch_count == 0 )) || fail "no active window is a silent no-op" \
  "dispatched $dispatch_count times: $(cat "$DISPATCH_LOG" 2>/dev/null)"
pass "no active window: silent no-op"

# ── No bases file → raw slot fallback ────────────────────────────────────────
make_hyprctl_stub '{"address":"0x1"}' '[{"name":"eDP-1","focused":true}]'
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 4 2>/dev/null || true
log=$(cat "$DISPATCH_LOG" 2>/dev/null || true)
[[ "$log" == *'workspace = "4"'* ]] || fail "no bases file falls back to raw slot" "got: $log"
pass "no bases file: falls back to raw slot dispatch"

# ── Setup: bases file with one monitor ───────────────────────────────────────
cat > "$BASES_FILE" << 'JSON'
{ "eDP-1": 0 }
JSON

# ── Normal path: monitor in map → moves to base+slot ────────────────────────
make_hyprctl_stub '{"address":"0x1"}' '[{"name":"eDP-1","focused":true}]'
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 3 2>/dev/null || true
log=$(cat "$DISPATCH_LOG" 2>/dev/null || true)
# eDP-1 base=0, slot=3 → workspace 3
[[ "$log" == *'workspace = "3"'* && "$log" == *'follow = false'* ]] ||
  fail "monitor in map moves window to base+slot" "got: $log"
pass "monitor in bases map: moves window to base+slot with follow=false"

# ── Issue D: monitor NOT in map → fallback reachable under set -euo pipefail ──
# HDMI-A-1 is focused but has no entry in the bases file.
# Before the fix, the Python subprocess exited 1 and set -e killed the script
# before reaching the fallback, so no dispatch occurred at all.
# After the fix, the fallback executes and moves the window to the raw slot.
make_hyprctl_stub '{"address":"0x1"}' '[{"name":"HDMI-A-1","focused":true}]'
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 5 2>/dev/null || true
log=$(cat "$DISPATCH_LOG" 2>/dev/null || true)
[[ -n "$log" ]] ||
  fail "monitor not in map: fallback dispatch is reached under set -euo pipefail" \
    "(no dispatch logged — script aborted before fallback)"
[[ "$log" == *'workspace = "5"'* ]] ||
  fail "monitor not in map: fallback dispatches raw slot number" "got: $log"
pass "monitor not in map: fallback is reachable under set -euo pipefail"
pass "monitor not in map: fallback dispatches raw slot number"

# ── Issue D: also verify the script does NOT abort (exit non-zero) ────────────
make_hyprctl_stub '{"address":"0x1"}' '[{"name":"HDMI-A-1","focused":true}]'
rm -f "$DISPATCH_LOG"
status=0
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 5 2>/dev/null || status=$?
(( status == 0 )) ||
  fail "monitor not in map: script exits cleanly (not aborted by set -e)" \
    "exit status: $status"
pass "monitor not in map: script exits 0 (set -e does not abort on fallback path)"

# ── Slot boundary: slot 10 on base-10 monitor → workspace 20 ─────────────────
cat > "$BASES_FILE" << 'JSON'
{ "DP-1": 10 }
JSON
make_hyprctl_stub '{"address":"0x1"}' '[{"name":"DP-1","focused":true}]'
rm -f "$DISPATCH_LOG"
"$ROOT/bin/omarchy-hyprland-workspace-global-move-window" 10 2>/dev/null || true
log=$(cat "$DISPATCH_LOG" 2>/dev/null || true)
[[ "$log" == *'workspace = "20"'* ]] ||
  fail "slot 10 on base-10 monitor dispatches workspace 20" "got: $log"
pass "slot 10 on base-10 monitor: workspace 20 (base+slot boundary)"
