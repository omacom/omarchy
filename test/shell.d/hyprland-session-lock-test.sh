#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

[[ ${1:-} == "-j" && ${2:-} == "monitors" ]] || exit 1
[[ ${OMARCHY_TEST_HYPRCTL_FAILS:-0} == 1 ]] && exit 4
printf '%s\n' "$OMARCHY_TEST_MONITORS"
SH

# The lockers running are given, so the live desktop's own shell stays out of it.
cat >"$fake_bin/pgrep" <<'SH'
#!/bin/bash

[[ $* == "-u $UID -x quickshell|qs|hyprlock" ]] || exit 3
[[ -n $OMARCHY_TEST_LOCKERS ]] || exit 1
printf '%s\n' $OMARCHY_TEST_LOCKERS
SH
chmod +x "$fake_bin"/*

LOCKED=0
UNLOCKED=1
UNDETERMINED=2

locked_monitors='[{"name":"HDMI-A-1","solitaryBlockedBy":["WINDOWED","LOCK","CANDIDATE"]}]'
unlocked_monitors='[{"name":"HDMI-A-1","solitaryBlockedBy":["WINDOWED","CANDIDATE"]}]'

# The stranded check asks the real omarchy-hyprland-session-locked, so
# $ROOT/bin follows the stubs on PATH.
exit_status() {
  local command="$1" monitors="$2" hyprctl_fails="$3" lockers="$4" actual=0

  PATH="$fake_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_MONITORS="$monitors" \
  OMARCHY_TEST_HYPRCTL_FAILS="$hyprctl_fails" \
  OMARCHY_TEST_LOCKERS="$lockers" \
    "$ROOT/bin/$command" 100 || actual=$?

  printf '%s\n' "$actual"
}

assert_status() {
  local expected="$1" monitors="$2" description="$3" hyprctl_fails="${4:-0}" actual

  actual=$(exit_status omarchy-hyprland-session-locked "$monitors" "$hyprctl_fails" "")
  (( actual == expected )) || fail "$description" "expected exit $expected, got $actual"
  pass "$description"
}

assert_stranded() {
  local expected="$1" monitors="$2" lockers="$3" description="$4" hyprctl_fails="${5:-0}" actual

  actual=$(exit_status omarchy-hyprland-session-lock-stranded "$monitors" "$hyprctl_fails" "$lockers")
  (( actual == expected )) || fail "$description" "expected exit $expected, got $actual"
  pass "$description"
}

# LOCK in solitaryBlockedBy is how an active ext-session-lock shows up.
assert_status $LOCKED "$locked_monitors" \
  "a locked session is detected"

assert_status $LOCKED \
  '[{"name":"eDP-1","solitaryBlockedBy":["WINDOWED"]},{"name":"DP-2","solitaryBlockedBy":["LOCK"]}]' \
  "a lock on any monitor counts as a locked session"

assert_status $UNLOCKED "$unlocked_monitors" \
  "an unlocked session is reported as unlocked"

# A monitor showing a solitary client has no blockers at all.
assert_status $UNLOCKED \
  '[{"name":"HDMI-A-1","solitaryBlockedBy":null}]' \
  "a monitor with no solitary blockers is reported as unlocked"

# LOCK only carries this meaning inside the reason list.
assert_status $UNLOCKED \
  '[{"name":"LOCK-1","description":"LOCK display","activeWorkspace":{"name":"LOCK"},"solitaryBlockedBy":["WINDOWED"]}]' \
  "LOCK elsewhere in the monitor payload is not a locked session"

# Guessing "unlocked" with nothing to read strands the session.
assert_status $UNDETERMINED '[]' \
  "a session with no monitors to read cannot say"

assert_status $UNDETERMINED '[]' \
  "an unreachable compositor cannot say" 1

assert_status $UNDETERMINED 'not json at all' \
  "an unreadable monitor payload cannot say"

# Hyprland stops at the first reason and never reaches the lock check.
assert_status $UNDETERMINED \
  '[{"name":"HDMI-A-1","solitaryBlockedBy":["WORKSPACE"]}]' \
  "a monitor with no workspace yet cannot say"

assert_status $UNLOCKED \
  '[{"name":"HDMI-A-1","solitaryBlockedBy":["WORKSPACE"]},{"name":"DP-2","solitaryBlockedBy":["WINDOWED"]}]' \
  "one readable monitor is enough to answer"

assert_status $LOCKED \
  '[{"name":"HDMI-A-1","solitaryBlockedBy":["WORKSPACE"]},{"name":"DP-2","solitaryBlockedBy":["LOCK"]}]' \
  "a lock is still found alongside a monitor that cannot say"

# A held lock is stranded only while no other locker is alive to own it.
assert_stranded 0 "$locked_monitors" "" "a lock with no locker alive is stranded"
assert_stranded 0 "$locked_monitors" "100" "the asking shell does not count as another locker"
assert_stranded 1 "$unlocked_monitors" "" "an unlocked session is not stranded"
assert_stranded 2 '[]' "" "a compositor that cannot say leaves it undetermined" 1
assert_stranded 2 "$locked_monitors" "100 200" "a lock another locker may hold is left undetermined, so it is never taken"
