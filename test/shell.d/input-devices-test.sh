#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

input_devices="$ROOT/shell/Commons/InputDevices.qml"
command -v inotifywait >/dev/null 2>&1 || { skip "inotifywait not installed; skipping input watcher reap check"; exit 0; }
command -v node >/dev/null 2>&1 || { skip "node not installed; skipping input watcher reap check"; exit 0; }
command -v python3 >/dev/null 2>&1 || { skip "python3 not installed; skipping input watcher reap check"; exit 0; }

TMPDIR=$(mktemp -d)
trap 'pkill -f "inotifywait.*$TMPDIR" 2>/dev/null || true; rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/dev/input" "$TMPDIR/dev-other/input" "$TMPDIR/run/udev/data"

# Extract the real bash script built by InputDevices.qml, stopping right before
# exec inotifywait so the reap logic runs against our fixture processes.
node -e '
  const fs = require("fs")
  const src = fs.readFileSync(process.argv[1], "utf8")
  const start = src.indexOf("command: [\"bash\", \"-c\",")
  const end = src.indexOf("\"input-devices\"", start)
  if (start < 0 || end < 0) process.exit(1)
  const parts = [...src.slice(start, end).matchAll(/"((?:[^"\\]|\\.)*)"/g)].map(m => JSON.parse(`"${m[1]}"`))
  const script = parts.slice(2).join("")
  const cut = script.indexOf("exec inotifywait")
  if (cut < 0) process.exit(1)
  process.stdout.write(script.slice(0, cut))
' "$input_devices" >"$TMPDIR/reap.sh"
[[ -s $TMPDIR/reap.sh ]] || fail "could not extract the input watcher reap command"

start_watcher() {
  local dev_dir=$1
  setsid -f inotifywait -m -q -e create,delete,delete_self,moved_to --format '%w|%e|%f' "$dev_dir" "$dev_dir/input" </dev/null >/dev/null 2>&1
  local pid=""
  for _ in {1..30}; do
    pid=$(pgrep -f "inotifywait -m -q -e create,delete,delete_self,moved_to --format %w\|%e\|%f $dev_dir " | head -1 || true)
    [[ -n $pid ]] && break
    sleep 0.1
  done
  printf '%s' "$pid"
}

orphan=$(start_watcher "$TMPDIR/dev")
[[ -n $orphan ]] || fail "could not start an orphaned input watcher"

other=$(start_watcher "$TMPDIR/dev-other")
[[ -n $other ]] || fail "could not start an input watcher for a different dev dir"

setsid -f python3 -c '
import ctypes, subprocess, sys, time
ctypes.CDLL(None).prctl(15, b"quickshell", 0, 0, 0)
child = subprocess.Popen(["inotifywait", "-m", "-q", "-e", "create,delete,delete_self,moved_to", "--format", "%w|%e|%f", sys.argv[1], sys.argv[1] + "/input"])
open(sys.argv[2], "w").write(str(child.pid))
deadline = time.time() + 30
while child.poll() is None and time.time() < deadline:
    time.sleep(0.1)
' "$TMPDIR/dev" "$TMPDIR/live.pid" </dev/null >"$TMPDIR/live.log" 2>&1
for _ in {1..30}; do [[ -s $TMPDIR/live.pid ]] && break; sleep 0.1; done
live=$(cat "$TMPDIR/live.pid" 2>/dev/null || true)
[[ -n $live ]] || fail "could not start a live shell input watcher"
pass "orphaned, other-dir, and live input watchers started"

bash -c "$(cat "$TMPDIR/reap.sh")" input-devices "$TMPDIR/dev/input" "$TMPDIR/dev" "$TMPDIR/run/udev/data"

for _ in {1..30}; do
  kill -0 "$orphan" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$orphan" 2>/dev/null; then
  fail "input watcher reaper stops an orphaned input watcher"
fi
pass "input watcher reaper stops an orphaned input watcher"

kill -0 "$other" 2>/dev/null || fail "input watcher reaper leaves another dev dir's watcher alone"
kill "$other" 2>/dev/null || true
pass "input watcher reaper leaves another dev dir's watcher alone"

kill -0 "$live" 2>/dev/null || fail "input watcher reaper spares a live shell's watcher"
[[ $(ps -o stat= -p "$live" 2>/dev/null) != Z* ]] || fail "input watcher reaper spares a live shell's watcher"
pass "input watcher reaper spares a live shell's watcher"
