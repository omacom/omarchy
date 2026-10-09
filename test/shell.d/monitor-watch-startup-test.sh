#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command timeout

test_tmp=$(mktemp -d)
fixture="$test_tmp/repo"
child_tmp="$test_tmp/child-tmp"
pid_file="$test_tmp/watcher.pid"

cleanup() {
  if [[ -s $pid_file ]]; then
    kill -KILL -- "-$(<"$pid_file")" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$fixture/bin" "$fixture/test/shell.d" "$child_tmp"
cp "$SHELL_TEST_DIR/base-test.sh" "$SHELL_TEST_DIR/monitor-watch-lock-test.sh" "$fixture/test/shell.d/"

# Run the real test harness in a fixture checkout, replacing only the watcher.
# Neither watcher connects to the FIFO or touches a compositor or hardware.
cat >"$fixture/bin/omarchy-hyprland-monitor-watch" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$OMARCHY_TEST_WATCH_PID_FILE"
if [[ $OMARCHY_TEST_STARTUP_MODE == "exit" ]]; then
  exit 42
else
  exec /usr/bin/sleep infinity
fi
SH
chmod +x "$fixture/bin/omarchy-hyprland-monitor-watch"

for mode in exit stall; do
  rm -f "$pid_file"
  output="$test_tmp/$mode.log"
  status=0
  TMPDIR="$child_tmp" \
  OMARCHY_TEST_WATCH_PID_FILE="$pid_file" \
  OMARCHY_TEST_STARTUP_MODE="$mode" \
    timeout --kill-after=1s 5s bash "$fixture/test/shell.d/monitor-watch-lock-test.sh" >"$output" 2>&1 || status=$?

  (( status == 1 )) || fail "$mode during watcher startup fails before the outer deadline" "status: $status; $(<"$output")"
  grep -qx 'not ok - the watcher finishes its startup sync' "$output" ||
    fail "$mode during watcher startup reports the readiness failure" "$(<"$output")"
  pass "$mode during watcher startup fails within the readiness deadline"

  [[ -s $pid_file ]] || fail "$mode fixture watcher started"
  if kill -0 "$(<"$pid_file")" 2>/dev/null; then
    fail "$mode during watcher startup cleans up the watcher"
  fi
  pass "$mode during watcher startup cleans up the watcher"

  shopt -s nullglob
  leftovers=("$child_tmp"/*)
  shopt -u nullglob
  (( ${#leftovers[@]} == 0 )) || fail "$mode during watcher startup removes its temporary FIFO" "leftovers: ${leftovers[*]}"
  pass "$mode during watcher startup removes its temporary FIFO"
done
