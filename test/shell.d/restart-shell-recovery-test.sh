#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/bin/omarchy-restart-shell"

bash -n "$SCRIPT"
pass "omarchy-restart-shell has valid bash syntax"

if ! grep -q "timeout 5 quickshell kill -p" "$SCRIPT"; then
  fail "restart keeps the IPC kill path"
fi
pass "restart starts with IPC kill"

if ! grep -q "pgrep -x quickshell" "$SCRIPT"; then
  fail "restart falls back to process signals when IPC kill fails"
fi
pass "restart falls back to pgrep signal path for wedged shells"

if ! grep -q "kill -TERM" "$SCRIPT" || ! grep -q "kill -KILL" "$SCRIPT"; then
  fail "restart escalates from SIGTERM to SIGKILL"
fi
pass "restart escalates from SIGTERM to SIGKILL"

if ! grep -qE "runtime_dir=.*quickshell" "$SCRIPT"; then
  fail "restart defines the quickshell runtime directory cleanup"
fi
pass "restart cleans up stale quickshell runtime directories"

if ! grep -q "by-pid" "$SCRIPT" || ! grep -q "by-shell" "$SCRIPT"; then
  fail "restart removes stale by-pid and by-shell runtime entries"
fi
pass "restart removes stale by-pid and by-shell runtime entries"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/bin/omarchy-restart-shell', 'utf8')

assert(
  /while timeout 5 quickshell kill -p "\$CONFIG_DIR" --any-display/.test(source),
  'IPC kill loop is preserved'
)
assert(
  /mapfile -t qs_pids/.test(source) && /pgrep -x quickshell/.test(source),
  'fallback collects quickshell pids from /proc'
)
assert(
  /kill -TERM "\$pid"/.test(source) && /kill -KILL "\$pid"/.test(source),
  'fallback escalates SIGTERM to SIGKILL'
)
assert(
  /runtime_dir=\$\{XDG_RUNTIME_DIR:-\/run\/user\/\$UID\}\/quickshell/.test(source),
  'cleanup targets the quickshell runtime directory'
)
assert(
  /by-pid/.test(source) && /by-shell/.test(source),
  'cleanup removes both by-pid and by-shell stale entries'
)
pass('restart-shell recovery path includes IPC kill, signal fallback, and runtime cleanup')
JS
