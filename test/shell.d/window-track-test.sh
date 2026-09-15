#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Fake Hyprland event socket: two opens and one focus change.
cat >"$mock_bin/socat" <<'SH'
#!/bin/bash
printf '%s\n' \
  'openwindow>>abc123,1,Alacritty,~' \
  'activewindow>>firefox,GitHub — Mozilla Firefox' \
  'openwindow>>def456,2,firefox,GitHub, and more commas — Mozilla Firefox'
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/omarchy-activity" <<'SH'
#!/bin/bash
printf 'activity:%s\n' "$*" >>"$OMARCHY_TEST_ACTIVITY_LOG"
SH

chmod +x "$mock_bin"/*

export XDG_RUNTIME_DIR="$test_tmp/run"
export HYPRLAND_INSTANCE_SIGNATURE="test-sig"
export OMARCHY_TEST_ACTIVITY_LOG="$test_tmp/activity-log"

export PATH="$mock_bin:$PATH"
timeout 10 bash "$ROOT/bin/omarchy-hyprland-window-track" || true

grep -Fxq 'activity:record app alacritty  --via view' "$OMARCHY_TEST_ACTIVITY_LOG" ||
  fail "window tracker records opened windows as lowercased views" "$(cat "$OMARCHY_TEST_ACTIVITY_LOG" 2>/dev/null)"
pass "window tracker records opened windows as lowercased views"

grep -Fxq 'activity:record app firefox  --via view' "$OMARCHY_TEST_ACTIVITY_LOG" ||
  fail "window tracker survives commas in titles" "$(cat "$OMARCHY_TEST_ACTIVITY_LOG" 2>/dev/null)"
pass "window tracker survives commas in titles"

[[ $(grep -c '^activity:' "$OMARCHY_TEST_ACTIVITY_LOG") == "2" ]] ||
  fail "window tracker ignores non-open events" "$(cat "$OMARCHY_TEST_ACTIVITY_LOG" 2>/dev/null)"
pass "window tracker ignores non-open events"

grep -Fq 'hl.exec_cmd(o.launch("omarchy-hyprland-window-track"))' "$ROOT/default/hypr/autostart.lua" ||
  fail "window tracker starts with the session"
pass "window tracker starts with the session"
