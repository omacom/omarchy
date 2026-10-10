#!/bin/bash
# Tests for omarchy-monitor-base — run without a live Hyprland session.
# Exercises base allocation, persistence, idempotency, and print format.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

# ── Scratch state directory ────────────────────────────────────────────────────
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$STATE_DIR"' EXIT
export HOME="$STATE_DIR"   # omarchy-monitor-base uses ~/.local/state/omarchy/
BASES_FILE="$STATE_DIR/.local/state/omarchy/monitor-bases.json"

# ── No-arg / list on empty state prints nothing ───────────────────────────────
output=$(omarchy-monitor-base list 2>/dev/null)
[[ -z "$output" ]] || fail "list on empty state prints nothing" "got: $output"
pass "list on empty state prints nothing"

# ── sync with a stub hyprctl allocates bases ──────────────────────────────────
# Stub hyprctl so the test runs without a compositor.
FAKE_BIN=$(mktemp -d)
trap 'rm -rf "$STATE_DIR" "$FAKE_BIN"' EXIT

cat > "$FAKE_BIN/hyprctl" << 'STUB'
#!/bin/bash
# Return two monitors in Hyprland JSON shape.
echo '[{"id":0,"name":"HDMI-A-1"},{"id":1,"name":"DP-1"}]'
STUB
chmod +x "$FAKE_BIN/hyprctl"
export PATH="$FAKE_BIN:$ROOT/bin:$PATH"

output=$(omarchy-monitor-base sync 2>/dev/null)
[[ "$output" == *"HDMI-A-1 0"* ]] || fail "sync allocates base 0 to first monitor (id 0)" "got: $output"
[[ "$output" == *"DP-1 10"* ]]    || fail "sync allocates base 10 to second monitor (id 1)" "got: $output"
pass "sync allocates bases in Hyprland id order"

# ── bases.json is created and valid JSON ──────────────────────────────────────
[[ -f "$BASES_FILE" ]] || fail "sync creates monitor-bases.json"
pass "sync creates monitor-bases.json"

python3 -c "import json; d=json.load(open('$BASES_FILE')); assert d['HDMI-A-1']==0 and d['DP-1']==10" \
  || fail "monitor-bases.json is valid JSON with correct values"
pass "monitor-bases.json is valid JSON with correct values"

# ── sync is idempotent ────────────────────────────────────────────────────────
output2=$(omarchy-monitor-base sync 2>/dev/null)
[[ "$output" == "$output2" ]] || fail "repeated sync is a no-op" "first: $output  second: $output2"
pass "repeated sync is idempotent"

# ── list now prints the persisted bases ──────────────────────────────────────
output=$(omarchy-monitor-base list 2>/dev/null)
[[ "$output" == *"HDMI-A-1 0"* && "$output" == *"DP-1 10"* ]] \
  || fail "list reads persisted bases" "got: $output"
pass "list reads persisted bases"

# ── new monitor on next sync gets next free base ──────────────────────────────
cat > "$FAKE_BIN/hyprctl" << 'STUB'
#!/bin/bash
echo '[{"id":0,"name":"HDMI-A-1"},{"id":1,"name":"DP-1"},{"id":2,"name":"DP-2"}]'
STUB

output=$(omarchy-monitor-base sync 2>/dev/null)
[[ "$output" == *"DP-2 20"* ]] || fail "new monitor gets next free base (20)" "got: $output"
pass "new monitor on sync gets next free base"

# ── existing monitors keep their bases after hotplug ─────────────────────────
[[ "$output" == *"HDMI-A-1 0"* && "$output" == *"DP-1 10"* ]] \
  || fail "existing monitors keep their bases after a new monitor is added" "got: $output"
pass "existing monitors keep their bases after hotplug"

# ── hyprctl failure falls back to persisted data ─────────────────────────────
cat > "$FAKE_BIN/hyprctl" << 'STUB'
#!/bin/bash
exit 1
STUB

output=$(omarchy-monitor-base sync 2>/dev/null)
[[ "$output" == *"HDMI-A-1 0"* ]] || fail "hyprctl failure falls back to persisted bases" "got: $output"
pass "hyprctl failure falls back to persisted bases"
