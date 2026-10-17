#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command timeout

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/hypr"
export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_MONITORS="$test_tmp/monitors.json"
export OMARCHY_TEST_MONITOR_LOG="$test_tmp/calls"
export OMARCHY_TEST_AFTER_RELOAD="$test_tmp/after-reload.json"
unset OMARCHY_MONITOR_SNAPSHOT

toggles="$HOME/.local/state/omarchy/toggles/hypr"
mkdir -p "$toggles"
printf 'local omarchy_monitor_scale = "auto"\n' >"$HOME/.config/hypr/monitors.lua"

cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
case "$*" in
  "monitors all -j")
    echo query >>"$OMARCHY_TEST_MONITOR_LOG"
    case ${OMARCHY_TEST_QUERY_MODE:-} in
      hang) exec sleep 20 ;;
      fail) printf '[]\n'; exit 1 ;;
    esac
    cat "$OMARCHY_TEST_MONITORS"
    ;;
  reload)
    echo reload >>"$OMARCHY_TEST_MONITOR_LOG"
    if [[ -f $OMARCHY_TEST_AFTER_RELOAD ]]; then
      cp "$OMARCHY_TEST_AFTER_RELOAD" "$OMARCHY_TEST_MONITORS"
    fi
    ;;
  *) printf '%s\n' "$*" >>"$OMARCHY_TEST_MONITOR_LOG" ;;
esac
SH
cat >"$test_tmp/bin/omarchy-hw-clamshell" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_CLAMSHELL:-0} == 1 ]]
SH
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin/"*

internal='[{"name":"eDP-1","disabled":false,"scale":1.5}]'
extended='[{"name":"eDP-1","disabled":false,"scale":1.5},{"name":"DP-1","disabled":false,"mirrorOf":"none"}]'
mirrored='[{"name":"eDP-1","disabled":false,"scale":1.5},{"name":"DP-1","disabled":false,"mirrorOf":"eDP-1"}]'

reset_case() {
  rm -f "$toggles/"* "$OMARCHY_TEST_AFTER_RELOAD"
  : >"$OMARCHY_TEST_MONITOR_LOG"
  printf '%s\n' "$1" >"$OMARCHY_TEST_MONITORS"
}

query_count() {
  grep -c '^query$' "$OMARCHY_TEST_MONITOR_LOG" || true
}

assert_queries() {
  [[ $(query_count) == "$1" ]] || fail "$2" "$(<"$OMARCHY_TEST_MONITOR_LOG")"
}

reset_case "$internal"
omarchy-hyprland-monitor-clamshell
assert_queries 1 "unchanged clamshell reconciliation reads the compositor once"
[[ $(<"$OMARCHY_TEST_MONITOR_LOG") == query ]] || fail "healthy recovery does not wake or reload displays"
pass "unchanged reconciliation uses one monitor query and leaves auto scale and DPMS alone"

reset_case "$mirrored"
touch "$toggles/internal-monitor-mirror.lua"
omarchy-hyprland-monitor-clamshell
assert_queries 1 "mirror recovery shares the clamshell snapshot"
[[ -f $toggles/internal-monitor-mirror.lua ]] || fail "a mirrored external is not mistaken for an unplug"
[[ $(<"$OMARCHY_TEST_MONITOR_LOG") == query ]] || fail "healthy mirror recovery does not wake or reload"
pass "a mirrored external stays active during reconciliation without redundant queries"

reset_case "$extended"
OMARCHY_TEST_CLAMSHELL=1 omarchy-hyprland-monitor-clamshell
assert_queries 1 "closed-lid reconciliation shares the internal scale snapshot"
[[ -f $toggles/internal-monitor-clamshell.lua ]] || fail "closed lid disables the internal panel"
[[ $(<"$toggles/internal-monitor-scale") == 1.5 ]] || fail "closed lid remembers the actual internal scale"
pass "closed-lid recovery preserves the panel scale with one monitor query"

# Removing the clamshell flag causes a reload. The current automatic scale must
# then come from the new compositor state rather than the disabled snapshot.
reset_case '[{"name":"eDP-1","disabled":true,"scale":null}]'
touch "$toggles/internal-monitor-clamshell.lua"
printf '%s\n' '[{"name":"eDP-1","disabled":false,"scale":3}]' >"$OMARCHY_TEST_AFTER_RELOAD"
omarchy-hyprland-monitor-clamshell
assert_queries 2 "a clamshell reload invalidates the snapshot once"
[[ ! -f $toggles/internal-monitor-clamshell.lua ]] || fail "opening the lid clears the clamshell flag"
! grep -q '^eval ' "$OMARCHY_TEST_MONITOR_LOG" || fail "auto scale after reload is not replaced by the fallback"
pass "opening the lid refreshes after reload and preserves the newly resolved auto scale"

reset_case '[{"name":"eDP-1","disabled":true,"scale":null}]'
touch "$toggles/internal-monitor-disable.lua" "$toggles/internal-monitor-mirror.lua"
printf '%s\n' "$internal" >"$OMARCHY_TEST_AFTER_RELOAD"
omarchy-hyprland-monitor-clamshell
assert_queries 2 "toggle recovery refreshes once after its state changes"
[[ ! -f $toggles/internal-monitor-disable.lua && ! -f $toggles/internal-monitor-mirror.lua ]] ||
  fail "unplugging the external recovers both display toggles"
! grep -q '^eval ' "$OMARCHY_TEST_MONITOR_LOG" || fail "toggle recovery preserves automatic scale after reload"
pass "unplug recovery restores both toggles and refreshes their changed monitor state"

for helper in omarchy-hyprland-monitor-internal omarchy-hyprland-monitor-internal-mirror; do
  reset_case "$extended"
  "$helper" recover
  assert_queries 1 "direct recovery reads current monitors exactly once"
done
pass "direct internal and mirror recovery commands retain independent fresh queries"

reset_case '[{"name":"eDP-1","disabled":true},{"name":"DP-1","disabled":false,"mirrorOf":"eDP-1"},{"name":"DP-2","disabled":true},{"name":"DP-3","disabled":false,"mirrorOf":"none"}]'
[[ $(omarchy-hyprland-monitor-laptop) == eDP-1 ]] || fail "the laptop helper sees disabled internal outputs"
[[ $(omarchy-hyprland-monitor-external) == DP-3 ]] || fail "mirror target selection excludes disabled and already mirrored outputs"
omarchy-hyprland-monitor-external-active || fail "active external detection includes mirrors"
pass "direct selection preserves disabled-panel and active-mirror semantics"

for payload in '' 'not json' 'null' '{}' '[{}]' '[{"name":"DP-1","disabled":"false"}]' $'[]\n[]'; do
  reset_case "$payload"
  touch "$toggles/internal-monitor-disable.lua" "$toggles/internal-monitor-mirror.lua" "$toggles/internal-monitor-clamshell.lua"
  status=0
  omarchy-hyprland-monitor-clamshell || status=$?
  (( status == 2 )) || fail "invalid monitor data is unknown, not an empty display list" "payload: $payload, status: $status"
  [[ -f $toggles/internal-monitor-disable.lua && -f $toggles/internal-monitor-mirror.lua && -f $toggles/internal-monitor-clamshell.lua ]] ||
    fail "failed queries preserve every display toggle"
  [[ $(<"$OMARCHY_TEST_MONITOR_LOG") == query ]] || fail "failed queries do not reload or wake displays"
done
pass "empty, malformed, wrong-shape and multiple JSON responses preserve display state"

reset_case '[]'
status=0
omarchy-hyprland-monitor-external-active || status=$?
(( status == 1 )) || fail "a valid empty list means no external monitors"
reset_case 'null'
status=0
omarchy-hyprland-monitor-external-active || status=$?
(( status == 2 )) || fail "unknown compositor state differs from a valid empty list"
pass "external detection distinguishes no displays from an unanswered query"

for mode in fail hang; do
  reset_case "$extended"
  touch "$toggles/internal-monitor-disable.lua"
  start_us=${EPOCHREALTIME//[!0-9]/}
  status=0
  OMARCHY_TEST_QUERY_MODE="$mode" omarchy-hyprland-monitor-internal recover || status=$?
  elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))
  (( status == 2 )) || fail "$mode query is reported as unknown"
  [[ -f $toggles/internal-monitor-disable.lua ]] || fail "$mode query does not clear a display toggle"
  (( elapsed_us < 4000000 )) || fail "$mode query is bounded" "elapsed: $elapsed_us us"
done
pass "failed and stalled compositor queries return unknown promptly without changing toggles"

reset_case "$extended"
OMARCHY_MONITOR_SNAPSHOT="$extended" OMARCHY_TEST_QUERY_MODE=fail omarchy-hyprland-monitor-internal recover
assert_queries 0 "child recovery consumes its parent snapshot without IPC"
status=0
OMARCHY_MONITOR_SNAPSHOT='' omarchy-hyprland-monitor-internal recover || status=$?
(( status == 2 )) || fail "invalid inherited state is not silently treated as an empty monitor list"
assert_queries 0 "invalid inherited state does not mix in another compositor instant"
pass "scoped snapshots are reused and validated without another compositor query"

# Exercise the watcher's real poll-state transition without its event socket or
# unrelated delayed workers. The external-status helper remains the real one.
reset_case "$extended"
(
  poll_pid=""
  trap 'if [[ -n $poll_pid ]]; then kill "$poll_pid" 2>/dev/null || true; wait "$poll_pid" 2>/dev/null || true; fi' EXIT
  source <(sed -n '/^sync_poll_state() {/,/^}/p' "$ROOT/bin/omarchy-hyprland-monitor-watch")
  omarchy-hw-laptop() { return 0; }
  poll_clamshell_state() { exec sleep 20; }

  sync_poll_state
  [[ -n $poll_pid ]] && kill -0 "$poll_pid" || fail "a docked laptop starts reconciliation polling"
  original_pid=$poll_pid
  printf 'null\n' >"$OMARCHY_TEST_MONITORS"
  sync_poll_state
  [[ $poll_pid == "$original_pid" ]] && kill -0 "$poll_pid" || fail "unknown compositor state keeps recovery polling"
  printf '[]\n' >"$OMARCHY_TEST_MONITORS"
  sync_poll_state
  [[ -z $poll_pid ]] || fail "a confirmed disconnection stops reconciliation polling"
  wait "$original_pid" 2>/dev/null || true
)
pass "the watcher preserves polling through unknown state and stops only on confirmed disconnection"
