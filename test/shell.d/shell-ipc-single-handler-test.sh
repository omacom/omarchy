#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "ShellIpc single handler test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping ShellIpc single handler test"
  exit 0
fi

TMPDIR=$(mktemp -d)
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/shell-ipc-single-handler"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/shell-ipc-single-handler/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

ipc_call() {
  quickshell ipc -p "$config_dir" call "$@" 2>&1
}

for _ in {1..80}; do
  [[ $(ipc_call test.copy who) == "first" ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,120p' "$log" >&2
    fail "ShellIpc test quickshell exited before it answered"
  fi
  sleep 0.1
done

output=$(ipc_call test.copy who)
[[ $output == "first" ]] || fail "the first copy of a target answers" "got: $output"
if grep -q "will not be used" "$log"; then
  fail "only one copy of a target registers with Quickshell" "$(grep "will not be used" "$log")"
fi
pass "only the first copy of a target registers, and it answers"

output=$(ipc_call test.panel who)
[[ $output == "Target not found." ]] || fail "an inactive handler does not register" "got: $output"
ipc_call test.control addPanel >/dev/null
output=$(ipc_call test.panel who)
[[ $output == "active" ]] || fail "an inactive handler leaves its target to the next one" "got: $output"
pass "an inactive handler leaves its target to the next one"

ipc_call test.control drop >/dev/null
output=""
for _ in {1..40}; do
  output=$(ipc_call test.copy who)
  [[ $output == "second" ]] && break
  sleep 0.05
done
[[ $output == "second" ]] || fail "the next copy answers after the shell destroys the first" "got: $output"
if grep -q "will not be used" "$log"; then
  fail "the next copy registers without a warning" "$(grep "will not be used" "$log")"
fi
pass "the next copy answers after the shell destroys the first"
