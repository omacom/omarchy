#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

handoff=$ROOT/default/splash/shutdown-handoff
source "$handoff"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# connected_cards selects cards with a connected connector and ignores render nodes.
dri=$test_tmp/dev/dri
drm_sysfs=$test_tmp/sys/class/drm
mkdir -p "$dri" "$drm_sysfs/card0-eDP-1" "$drm_sysfs/card0-HDMI-A-1" "$drm_sysfs/card1-DP-1"
touch "$dri/card0" "$dri/card1" "$dri/renderD128"
printf 'connected\n' >"$drm_sysfs/card0-eDP-1/status"
printf 'connected\n' >"$drm_sysfs/card0-HDMI-A-1/status"
printf 'disconnected\n' >"$drm_sysfs/card1-DP-1/status"

found=$(connected_cards | tr '\n' ' ')
[[ $found == "$dri/card0 " ]] ||
  fail "connected_cards returns connected cards once without disconnected or render nodes" "found: $found"
pass "connected_cards returns connected cards once without disconnected or render nodes"

# Fallback when sysfs has no connected connectors returns all card* nodes.
printf 'disconnected\n' >"$drm_sysfs/card0-eDP-1/status"
printf 'disconnected\n' >"$drm_sysfs/card0-HDMI-A-1/status"
found=$(connected_cards | tr '\n' ' ')
[[ $found == "$dri/card0 $dri/card1 " ]] ||
  fail "connected_cards falls back to all card* nodes when none report connected" "found: $found"
pass "connected_cards falls back to all card* nodes when none report connected"

# wait_for_plymouth returns immediately when no Plymouth shutdown unit is active or queued.
call_file=$test_tmp/systemctl-calls
: >"$call_file"
systemctl() {
  printf 'x\n' >>"$call_file"
  printf 'ActiveState=inactive\nJob=\n\nActiveState=inactive\nJob=\n'
}
wait_timeout=2
wait_interval=0.01
wait_for_plymouth
calls=$(wc -l <"$call_file")
(( calls == 1 )) || fail "wait_for_plymouth exits immediately when no Plymouth unit is starting" "calls=$calls"
pass "wait_for_plymouth exits immediately when no Plymouth unit is starting"

# wait_for_plymouth waits while a Plymouth unit has a pending Job or is activating,
# then returns as soon as it transitions to active with no pending Job.
: >"$call_file"
systemctl() {
  printf 'x\n' >>"$call_file"
  case $(wc -l <"$call_file") in
    1) printf 'ActiveState=inactive\nJob=42\n' ;;
    2) printf 'ActiveState=activating\nJob=42\n' ;;
    *) printf 'ActiveState=active\nJob=\n' ;;
  esac
}
wait_for_plymouth
calls=$(wc -l <"$call_file")
(( calls == 3 )) || fail "wait_for_plymouth waits until Plymouth finishes activating" "calls=$calls"
pass "wait_for_plymouth waits until Plymouth finishes activating"

# wait_for_plymouth stops waiting at wait_timeout even if a unit stays activating.
: >"$call_file"
systemctl() {
  printf 'x\n' >>"$call_file"
  printf 'ActiveState=activating\nJob=99\n'
}
wait_timeout=1
wait_interval=0.05
SECONDS=0
wait_for_plymouth
calls=$(wc -l <"$call_file")
(( calls >= 2 && SECONDS <= 2 )) ||
  fail "wait_for_plymouth times out cleanly if Plymouth stalls" "calls=$calls seconds=$SECONDS"
pass "wait_for_plymouth times out cleanly if Plymouth stalls"
