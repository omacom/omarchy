#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The docked poll in omarchy-hyprland-monitor-watch syncs the clamshell state
# when the ACPI lid changes, not on every tick (#20570).

(( BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 401 )) || fail "this test runs under bash 4.1 or newer" "$BASH_VERSION"

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""

stop_watcher() {
  if [[ -n $watch_pid ]]; then
    kill -KILL -- "-$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    for _ in {1..100}; do
      pgrep -g "$watch_pid" -r R,S,D,T,t >/dev/null || break
      sleep 0.02
    done
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi

  return 0
}

trap 'stop_watcher; rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
lid="$test_tmp/lid"
events="$test_tmp/events"
sync_log="$test_tmp/syncs"
mkdir -p "$fake_bin" "$lid/LID0"
: >"$sync_log"

cat >"$fake_bin/socat" <<'SH'
#!/bin/bash

exec cat "$OMARCHY_TEST_EVENTS"
SH

# A laptop docked on an external monitor.
for command in omarchy-hw-laptop omarchy-hyprland-monitor-external-active omarchy-system-lid-inhibit; do
  printf '#!/bin/bash\n\nexit 0\n' >"$fake_bin/$command"
done

printf '#!/bin/bash\n\nexit 1\n' >"$fake_bin/omarchy-hyprland-monitor-modeless"

cat >"$fake_bin/omarchy-hyprland-monitor-clamshell" <<'SH'
#!/bin/bash

printf 'sync\n' >>"$OMARCHY_TEST_SYNC_LOG"
SH

chmod +x "$fake_bin"/*

set_lid() {
  printf 'state:      %s\n' "$1" >"$lid/LID0/state"
}

syncs() {
  grep -c '^sync$' "$sync_log" || true
}

syncs_at_least() {
  (( $(syncs) >= $1 ))
}

await() {
  local waited

  for (( waited = 0; waited < 300; waited++ )); do
    "$@" && return 0
    sleep 0.05
  done

  return 1
}

set_lid open
mkfifo "$events"

PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$test_tmp" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_ACPI_LID_PATH="$lid" \
  OMARCHY_TEST_EVENTS="$events" \
  OMARCHY_TEST_SYNC_LOG="$sync_log" \
  setsid "$ROOT/bin/omarchy-hyprland-monitor-watch" &
watch_pid=$!
exec {events_fd}>"$events"

# Startup syncs once, then retries after 1, 3 and 7 more seconds.
await syncs_at_least 4 || fail "the watcher syncs at startup and through its retries" "$(<"$sync_log")"

settled=$(syncs)
sleep 5
(( $(syncs) == settled )) || fail "a docked poll with the lid unchanged runs no sync" "$(<"$sync_log")"
pass "a docked poll with the lid unchanged runs no sync"

set_lid closed
await syncs_at_least $(( settled + 1 )) || fail "a docked poll syncs once the lid changes" "$(<"$sync_log")"
pass "a docked poll syncs once the lid changes"
