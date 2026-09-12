#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Ghostty fullscreen freezes on fractional scale; the launcher must fall back to
# foot for the screensaver only (issue #10420).

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
hypr_dir="$test_tmp/hypr"
eval_log="$test_tmp/hyprctl-eval.log"
mkdir -p "$stub_bin" "$home_dir" "$hypr_dir"

# Minimal Hyprland event socket so wait_for_screensaver_window can open socat.
# An empty FIFO never delivers openwindow events; the 5s deadline is too slow
# for a unit test, so stub socat to close immediately (wait returns, loop ends).
cat >"$stub_bin/socat" <<'SH'
#!/bin/bash
# Consume nothing and exit so the event reader hits EOF immediately.
exit 0
SH

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
case "$1" in
monitors)
  # OMARCHY_TEST_MONITORS_JSON is a full JSON array of monitors.
  printf '%s\n' "${OMARCHY_TEST_MONITORS_JSON:?}"
  ;;
dispatch)
  printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"
  ;;
*)
  exit 1
  ;;
esac
SH

cat >"$stub_bin/xdg-terminal-exec" <<'SH'
#!/bin/bash
[[ $1 == "--print-id" ]] || exit 1
printf '%s\n' "${OMARCHY_TEST_TERMINAL_ID:?}"
SH

cat >"$stub_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf '%s\n' "eDP-1"
SH

cat >"$stub_bin/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
# No screensaver already running.
exit 1
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "foot" ]] && exit "${OMARCHY_TEST_FOOT_PRESENT:-0}"
exit 1
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFY_LOG"
SH

chmod +x "$stub_bin"/*

run_launcher() {
  : >"$eval_log"
  HOME="$home_dir" \
    PATH="$stub_bin:/usr/bin:/bin" \
    OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$test_tmp" \
    HYPRLAND_INSTANCE_SIGNATURE=test \
    OMARCHY_TEST_HYPRCTL_LOG="$eval_log" \
    OMARCHY_TEST_NOTIFY_LOG="$test_tmp/notify.log" \
    OMARCHY_TEST_TERMINAL_ID="${1:?}" \
    OMARCHY_TEST_MONITORS_JSON="${2:?}" \
    OMARCHY_TEST_FOOT_PRESENT="${3:-0}" \
    bash "$ROOT/bin/omarchy-launch-screensaver" >/dev/null 2>&1 || true
}

fractional='[{"name":"DP-1","scale":1.25},{"name":"eDP-1","scale":1}]'
integer='[{"name":"DP-1","scale":2},{"name":"eDP-1","scale":1}]'

# Ghostty + fractional scale → foot.
run_launcher "com.mitchellh.ghostty" "$fractional" 0
grep -E 'foot .*org\.omarchy\.screensaver' "$eval_log" >/dev/null ||
  fail "ghostty on fractional scale launches foot screensaver" "$(cat "$eval_log")"
grep -E 'ghostty ' "$eval_log" >/dev/null &&
  fail "ghostty on fractional scale must not launch ghostty" "$(cat "$eval_log")"
pass "ghostty on fractional scale launches foot screensaver"

# Ghostty + integer scale → ghostty (no unnecessary fallback).
run_launcher "com.mitchellh.ghostty" "$integer" 0
grep -E 'ghostty .*org\.omarchy\.screensaver' "$eval_log" >/dev/null ||
  fail "ghostty on integer scale keeps ghostty" "$(cat "$eval_log")"
grep -E 'foot ' "$eval_log" >/dev/null &&
  fail "ghostty on integer scale must not fall back to foot" "$(cat "$eval_log")"
pass "ghostty on integer scale keeps ghostty"

# Ghostty + fractional but foot missing → keep ghostty (best effort).
run_launcher "com.mitchellh.ghostty" "$fractional" 1
grep -E 'ghostty .*org\.omarchy\.screensaver' "$eval_log" >/dev/null ||
  fail "ghostty fractional without foot still launches ghostty" "$(cat "$eval_log")"
pass "ghostty fractional without foot still launches ghostty"

# Foot default is unchanged on fractional scale.
run_launcher "foot.desktop" "$fractional" 0
grep -E 'foot .*org\.omarchy\.screensaver' "$eval_log" >/dev/null ||
  fail "foot default still launches foot" "$(cat "$eval_log")"
pass "foot default still launches foot"

# Alacritty is never rewritten to foot.
run_launcher "Alacritty" "$fractional" 0
grep -E 'alacritty .*org\.omarchy\.screensaver' "$eval_log" >/dev/null ||
  fail "alacritty on fractional scale keeps alacritty" "$(cat "$eval_log")"
pass "alacritty on fractional scale keeps alacritty"
