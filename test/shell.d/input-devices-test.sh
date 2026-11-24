#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

input_devices="$ROOT/shell/Commons/InputDevices.qml"
untyped_input="$ROOT/shell/Commons/UntypedInput.qml"
command -v inotifywait >/dev/null 2>&1 || { skip "inotifywait not installed; skipping input watcher reap check"; exit 0; }
command -v node >/dev/null 2>&1 || { skip "node not installed; skipping input watcher reap check"; exit 0; }
command -v python3 >/dev/null 2>&1 || { skip "python3 not installed; skipping input watcher reap check"; exit 0; }

TMPDIR=$(mktemp -d)
trap 'pkill -f "inotifywait.*$TMPDIR" 2>/dev/null || true; rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/dev/input" "$TMPDIR/dev-other/input" "$TMPDIR/run/udev/data" "$TMPDIR/bin"

# Extract the real command from InputDevices.qml, and the bash reap portion
# stopping right before exec inotifywait so the reap logic runs against our
# fixture processes.
node -e '
  const fs = require("fs")
  const src = fs.readFileSync(process.argv[1], "utf8")
  const watcherIdx = src.indexOf("id: watcher")
  const start = src.indexOf("command: [", watcherIdx)
  const end = src.indexOf("\"input-devices\"", start)
  if (watcherIdx < 0 || start < 0 || end < 0) process.exit(1)
  const parts = [...src.slice(start, end).matchAll(/"((?:[^"\\]|\\.)*)"/g)].map(m => JSON.parse(`"${m[1]}"`))
  const bashIdx = parts.indexOf("-c")
  if (bashIdx < 0) process.exit(1)
  const prefix = parts.slice(0, bashIdx + 1)
  const script = parts.slice(bashIdx + 1).join("")
  const cut = script.indexOf("exec inotifywait")
  if (cut < 0) process.exit(1)
  fs.writeFileSync(process.argv[2], script.slice(0, cut))
  fs.writeFileSync(process.argv[3], JSON.stringify([...prefix, script, "input-devices"]))
' "$input_devices" "$TMPDIR/reap.sh" "$TMPDIR/input-cmd.json"
[[ -s $TMPDIR/reap.sh && -s $TMPDIR/input-cmd.json ]] || fail "could not extract the input watcher command"

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

# A killed shell cannot run Component.onDestruction. Verify setpriv --pdeathsig
# makes the kernel stop both the input-device watcher and pactl subscribe when
# their parent dies with SIGKILL.
assert_dies_on_parent_sigkill() {
  local label=$1 expected_comm=$2 cmd_json=$3 path_prefix=${4:-}
  shift 4
  local parent_pid="" child_pid="" comm=""

  PATH="${path_prefix:+$path_prefix:}$PATH" setsid -f python3 -c '
import json, os, subprocess, sys, time
cmd = json.loads(open(sys.argv[1]).read()) + sys.argv[4:]
child = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
with open(sys.argv[2] + ".tmp", "w") as f:
    f.write(str(os.getpid()))
os.replace(sys.argv[2] + ".tmp", sys.argv[2])
with open(sys.argv[3] + ".tmp", "w") as f:
    f.write(str(child.pid))
os.replace(sys.argv[3] + ".tmp", sys.argv[3])
time.sleep(30)
' "$cmd_json" "$TMPDIR/parent.pid" "$TMPDIR/child.pid" "$@" </dev/null >/dev/null 2>&1

  for _ in {1..40}; do
    [[ -s $TMPDIR/parent.pid && -s $TMPDIR/child.pid ]] && break
    sleep 0.05
  done
  parent_pid=$(cat "$TMPDIR/parent.pid" 2>/dev/null || true)
  child_pid=$(cat "$TMPDIR/child.pid" 2>/dev/null || true)
  rm -f "$TMPDIR/parent.pid" "$TMPDIR/child.pid"
  [[ -n $parent_pid && -n $child_pid ]] || fail "$label failed to start"

  # Wait until the final exec'd watcher is alive (past setpriv / bash startup).
  for _ in {1..40}; do
    read -r comm <"/proc/$child_pid/comm" 2>/dev/null || comm=""
    [[ $comm == "$expected_comm" ]] && break
    sleep 0.05
  done
  [[ $comm == "$expected_comm" ]] || {
    kill -KILL "$parent_pid" "$child_pid" 2>/dev/null || true
    fail "$label reached $expected_comm before parent was killed" "comm=$comm"
  }

  kill -KILL "$parent_pid" 2>/dev/null || true
  for _ in {1..40}; do
    kill -0 "$child_pid" 2>/dev/null || break
    sleep 0.05
  done
  if kill -0 "$child_pid" 2>/dev/null; then
    kill -KILL "$child_pid" 2>/dev/null || true
    fail "$label exits when its parent is SIGKILLed" "child $child_pid outlived parent $parent_pid"
  fi
  pass "$label exits when its parent is SIGKILLed"
}

mkdir -p "$TMPDIR/dev-pdeath/input"
assert_dies_on_parent_sigkill "input-devices watcher" "inotifywait" "$TMPDIR/input-cmd.json" "" \
  "$TMPDIR/dev-pdeath/input" "$TMPDIR/dev-pdeath" "$TMPDIR/run/udev/data"

node -e '
  const fs = require("fs")
  const src = fs.readFileSync(process.argv[1], "utf8")
  const block = src.match(/id:\s*events[\s\S]*?command:\s*(\[[^\]]+\])/)
  if (!block) process.exit(1)
  fs.writeFileSync(process.argv[2], JSON.stringify(JSON.parse(block[1])))
' "$untyped_input" "$TMPDIR/untyped-cmd.json"
[[ -s $TMPDIR/untyped-cmd.json ]] || fail "could not extract the untyped input watcher command"

cat >"$TMPDIR/bin/pactl" <<'SH'
#!/bin/bash
exec sleep 30
SH
chmod +x "$TMPDIR/bin/pactl"

assert_dies_on_parent_sigkill "untyped-input pactl watcher" "sleep" "$TMPDIR/untyped-cmd.json" "$TMPDIR/bin"
