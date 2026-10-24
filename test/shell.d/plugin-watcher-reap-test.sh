#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

registry="$ROOT/shell/services/PluginRegistry.qml"
source_text=$(cat "$registry")

# Source wiring: shell start reaps orphaned watchers before starting its
# own, spares one still parented to a live shell, and a graceful stop
# takes its watcher with it.
[[ $source_text == *"function reapOrphanedPluginWatchers()"* ]] ||
  fail "plugin registry reaps orphaned watchers at startup"
[[ $source_text == *"ps -o comm="* && $source_text == *"quickshell|qs"* ]] ||
  fail "watcher reaper spares watchers still parented to a live shell"
[[ $source_text == *"Component.onDestruction"* && $source_text == *"localPluginWatcher.running = false"* ]] ||
  fail "plugin watcher stops with its shell"
[[ $source_text == *"registry.reapOrphanedPluginWatchers()"* ]] ||
  fail "shell init runs the watcher reaper before starting the watcher"
pass "plugin watcher lifecycle is wired to the shell"

command -v inotifywait >/dev/null 2>&1 || { skip "inotifywait not installed; skipping watcher reap check"; exit 0; }
command -v node >/dev/null 2>&1 || { skip "node not installed; skipping watcher reap check"; exit 0; }

TMPDIR=$(mktemp -d)
trap 'pkill -f "inotifywait.*$TMPDIR" 2>/dev/null || true; rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/plugins" "$TMPDIR/plugins-backup" "$TMPDIR/other"

# The reap command exactly as PluginRegistry builds it, extracted rather
# than copied, so this test fails when the real command changes.
node -e '
  const fs = require("fs")
  const src = fs.readFileSync(process.argv[1], "utf8")
  const start = src.indexOf("watcherReaper.command")
  const end = src.indexOf("watcher-reaper", start)
  if (start < 0 || end < 0) process.exit(1)
  const parts = [...src.slice(start, end).matchAll(/"((?:[^"\\]|\\.)*)"/g)].map(m => JSON.parse(`"${m[1]}"`))
  if (parts.length < 3) process.exit(1)
  process.stdout.write(parts.slice(2).join(""))
' "$registry" >"$TMPDIR/reap.sh"
[[ -s $TMPDIR/reap.sh ]] || fail "could not extract the watcher reap command"
grep -q 'grep -Fxq' "$TMPDIR/reap.sh" || fail "watcher reaper matches the watched directory exactly"

start_watcher() { # dir, prints pid
  setsid -f inotifywait -m -r -q -e close_write,create,delete,move --format '%w%f' "$1" </dev/null >/dev/null 2>&1
  local pid=""
  for _ in {1..30}; do
    pid=$(pgrep -f "inotifywait -m -r -q -e close_write,create,delete,move --format %w%f $1" | head -1 || true)
    [[ -n $pid ]] && break
    sleep 0.1
  done
  printf '%s' "$pid"
}

orphan=$(start_watcher "$TMPDIR/plugins")
[[ -n $orphan ]] || fail "could not start an orphaned plugin watcher"

# Same flags, similarly named directory: not this shell's watcher.
backup=$(start_watcher "$TMPDIR/plugins-backup")
[[ -n $backup ]] || fail "could not start a similarly named directory's watcher"

# A watcher parented to a live shell (a stand-in process named
# quickshell, so this runs without a desktop session), found before the
# reap runs.
command -v python3 >/dev/null 2>&1 || { skip "python3 not installed; skipping watcher reap check"; exit 0; }
setsid -f python3 -c '
import ctypes, subprocess, sys, time
ctypes.CDLL(None).prctl(15, b"quickshell", 0, 0, 0)
child = subprocess.Popen(["inotifywait", "-m", "-r", "-q", "-e", "close_write,create,delete,move", "--format", "%w%f", sys.argv[1]])
open(sys.argv[2], "w").write(str(child.pid))
deadline = time.time() + 30
while child.poll() is None and time.time() < deadline:
    time.sleep(0.1)
' "$TMPDIR/plugins" "$TMPDIR/live.pid" </dev/null >"$TMPDIR/live.log" 2>&1
for _ in {1..30}; do [[ -s $TMPDIR/live.pid ]] && break; sleep 0.1; done
live=$(cat "$TMPDIR/live.pid" 2>/dev/null || true)
[[ -n $live ]] || fail "could not start a live shell's watcher"
pass "orphaned, similarly named, and live plugin watchers started"

# The reap itself, run the way shell init runs it ($1 is the plugins dir).
bash -c "$(cat "$TMPDIR/reap.sh")" watcher-reaper "$TMPDIR/plugins"

for _ in {1..30}; do
  kill -0 "$orphan" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$orphan" 2>/dev/null; then
  fail "watcher reaper stops an orphaned plugin watcher"
fi
pass "watcher reaper stops an orphaned plugin watcher"

kill -0 "$backup" 2>/dev/null || fail "watcher reaper leaves a similarly named directory's watcher alone"
kill "$backup" 2>/dev/null || true
pass "watcher reaper leaves a similarly named directory's watcher alone"

kill -0 "$live" 2>/dev/null || fail "watcher reaper spares a live shell's watcher"
[[ $(ps -o stat= -p "$live" 2>/dev/null) != Z* ]] || fail "watcher reaper spares a live shell's watcher"
pass "watcher reaper spares a live shell's watcher"
