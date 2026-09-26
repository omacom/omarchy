#!/bin/bash
# Tests for omarchy-ensure-workspaces — run without a live Hyprland session.
# Exercises the connected-monitor filter and focus-restore behaviour (Issue C).

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# ── Scratch environment ────────────────────────────────────────────────────────
FAKE_BIN=$(mktemp -d)
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$FAKE_BIN" "$STATE_DIR"' EXIT

BASES_FILE="$STATE_DIR/.local/state/omarchy/monitor-bases.json"
mkdir -p "$(dirname "$BASES_FILE")"
export HOME="$STATE_DIR"
export HYPRLAND_INSTANCE_SIGNATURE="test-session"

DISPATCH_LOG="$STATE_DIR/dispatch.log"

# Helper: write a hyprctl stub with configurable responses.
#   make_hyprctl_stub <monitors_json> <workspaces_json> <activeworkspace_json> [fail_monitors]
# Pass "FAIL" as monitors_json to simulate hyprctl monitors failure.
make_hyprctl_stub() {
  local monitors_json="$1"
  local workspaces_json="$2"
  local activews_json="$3"
  local stub="$FAKE_BIN/hyprctl"

  cat > "$stub" <<STUB
#!/bin/bash
case "\$1" in
  monitors)
STUB

  if [[ "$monitors_json" == "FAIL" ]]; then
    echo '    exit 1 ;;' >> "$stub"
  else
    cat >> "$stub" <<STUB
    echo '$monitors_json'
    ;;
STUB
  fi

  cat >> "$stub" <<STUB
  workspaces)
    echo '$workspaces_json'
    ;;
  activeworkspace)
    echo '$activews_json'
    ;;
  dispatch)
    echo "\$*" >> "$DISPATCH_LOG"
    ;;
esac
STUB
  chmod +x "$stub"
}

export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

# ── Scenario 1: disconnected monitor skipped, connected monitor dispatched ─────
# Bases: eDP-1 (base=0), HDMI-A-1 (base=10).
# Connected: eDP-1 only. HDMI-A-1 is unplugged.
# Existing workspaces: 1-10 (eDP-1 slots exist, HDMI-A-1 slots do not).
# Expected: HDMI-A-1 slots (11-20) are NOT dispatched; eDP-1 slots already
# exist so nothing is dispatched at all.
cat > "$BASES_FILE" << 'JSON'
{ "eDP-1": 0, "HDMI-A-1": 10 }
JSON

existing_ws='[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5},{"id":6},{"id":7},{"id":8},{"id":9},{"id":10}]'
make_hyprctl_stub \
  '[{"name":"eDP-1"}]' \
  "$existing_ws" \
  '{"id":3}'

rm -f "$DISPATCH_LOG"
# Skip the sleep by overriding the script's sleep command.
PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  bash -c 'sleep() { :; }; export -f sleep; exec '"$ROOT/bin/omarchy-ensure-workspaces" 2>/dev/null || true

dispatch_count=$(grep -c 'dispatch' "$DISPATCH_LOG" 2>/dev/null || echo 0)
(( dispatch_count == 0 )) ||
  fail "disconnected monitor slots not dispatched when connected monitor slots exist" \
    "dispatched $dispatch_count times:
$(cat "$DISPATCH_LOG" 2>/dev/null)"
pass "disconnected monitor (HDMI-A-1) slots are not dispatched"
pass "no dispatch when all connected-monitor slots already exist"

# ── Scenario 2: missing slots on connected monitor are dispatched ──────────────
# Same bases. eDP-1 connected. Workspaces 1-5 exist, 6-10 are missing.
# Expected: workspaces 6-10 are dispatched, then focus restored to ws 3.
existing_ws='[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5}]'
make_hyprctl_stub \
  '[{"name":"eDP-1"}]' \
  "$existing_ws" \
  '{"id":3}'

rm -f "$DISPATCH_LOG"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  bash -c 'sleep() { :; }; export -f sleep; exec '"$ROOT/bin/omarchy-ensure-workspaces" 2>/dev/null || true

# Workspaces 6-10 must have been dispatched.
for ws in 6 7 8 9 10; do
  grep -q "\"$ws\"" "$DISPATCH_LOG" 2>/dev/null ||
    fail "missing workspace $ws is dispatched" \
      "dispatch log:
$(cat "$DISPATCH_LOG" 2>/dev/null)"
done
pass "missing slots on connected monitor are dispatched (ws 6-10)"

# HDMI-A-1 slots (11-20) must NOT appear in the dispatch log.
for ws in $(seq 11 20); do
  grep -q "\"$ws\"" "$DISPATCH_LOG" 2>/dev/null &&
    fail "disconnected monitor (HDMI-A-1) slot $ws must not be dispatched" \
      "dispatch log:
$(cat "$DISPATCH_LOG" 2>/dev/null)" || true
done
pass "disconnected monitor slots (11-20) never dispatched even when missing"

# Focus must be restored to the previously active workspace (ws 3), not ws 1.
last_dispatch=$(grep 'dispatch' "$DISPATCH_LOG" | tail -1 || true)
[[ "$last_dispatch" == *'"3"'* ]] ||
  fail "focus restored to previously active workspace (3), not hardcoded 1" \
    "last dispatch: $last_dispatch
full log:
$(cat "$DISPATCH_LOG")"
pass "focus restored to previously active workspace after creating missing slots"

# ── Scenario 3: no dispatch when all workspaces already exist ─────────────────
existing_ws='[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5},{"id":6},{"id":7},{"id":8},{"id":9},{"id":10}]'
make_hyprctl_stub \
  '[{"name":"eDP-1"}]' \
  "$existing_ws" \
  '{"id":5}'

rm -f "$DISPATCH_LOG"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  bash -c 'sleep() { :; }; export -f sleep; exec '"$ROOT/bin/omarchy-ensure-workspaces" 2>/dev/null || true

dispatch_count=$(grep -c 'dispatch' "$DISPATCH_LOG" 2>/dev/null || echo 0)
(( dispatch_count == 0 )) ||
  fail "no dispatch when all connected slots already exist" \
    "dispatched $dispatch_count times:
$(cat "$DISPATCH_LOG" 2>/dev/null)"
pass "no dispatch when all connected-monitor slots already exist"

# ── Scenario 4: hyprctl monitors failure → clean exit, no dispatch ────────────
make_hyprctl_stub "FAIL" "[]" '{"id":1}'

rm -f "$DISPATCH_LOG"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  bash -c 'sleep() { :; }; export -f sleep; exec '"$ROOT/bin/omarchy-ensure-workspaces" 2>/dev/null || true

dispatch_count=$(grep -c 'dispatch' "$DISPATCH_LOG" 2>/dev/null || echo 0)
(( dispatch_count == 0 )) ||
  fail "hyprctl monitors failure causes clean exit with no dispatch" \
    "dispatched $dispatch_count times"
pass "hyprctl monitors failure: clean exit with no dispatch"

# ── Scenario 5: two connected monitors, one with missing slots ────────────────
# Bases: eDP-1 (base=0), DP-1 (base=20). Both connected.
# eDP-1 slots 1-10 all exist. DP-1 slots 21-25 exist, 26-30 missing.
# Expected: workspaces 26-30 dispatched; focus restored to active ws.
cat > "$BASES_FILE" << 'JSON'
{ "DP-1": 20, "eDP-1": 0 }
JSON

existing_ws='[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5},{"id":6},{"id":7},{"id":8},{"id":9},{"id":10},{"id":21},{"id":22},{"id":23},{"id":24},{"id":25}]'
make_hyprctl_stub \
  '[{"name":"eDP-1"},{"name":"DP-1"}]' \
  "$existing_ws" \
  '{"id":2}'

rm -f "$DISPATCH_LOG"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" \
  bash -c 'sleep() { :; }; export -f sleep; exec '"$ROOT/bin/omarchy-ensure-workspaces" 2>/dev/null || true

for ws in 26 27 28 29 30; do
  grep -q "\"$ws\"" "$DISPATCH_LOG" 2>/dev/null ||
    fail "missing workspace $ws on DP-1 is dispatched" \
      "dispatch log:
$(cat "$DISPATCH_LOG" 2>/dev/null)"
done
pass "missing slots on second connected monitor (DP-1, ws 26-30) are dispatched"

last_dispatch=$(grep 'dispatch' "$DISPATCH_LOG" | tail -1 || true)
[[ "$last_dispatch" == *'"2"'* ]] ||
  fail "focus restored to previously active workspace (2) with two monitors" \
    "last dispatch: $last_dispatch"
pass "focus restored to previously active workspace with two connected monitors"
