#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v qs >/dev/null; then
  skip "quickshell unavailable; skipping IPC locale regression"
  exit 0
fi

test_tmp=$(mktemp -d)
server_pid=""
cleanup() {
  if [[ -n $server_pid ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$test_tmp/root/shell" "$test_tmp/run" "$test_tmp/home"
chmod 700 "$test_tmp/run"
cat >"$test_tmp/root/shell/shell.qml" <<'QML'
import Quickshell
import Quickshell.Io

ShellRoot {
  IpcHandler {
    target: "shell"
    function ping(): string { return "ok" }
    function reply(value: string): string { return value }
    function putBarWidget(id: string, placement: string): string { return "ok" }
  }
}
QML

export OMARCHY_PATH="$test_tmp/root"
export XDG_RUNTIME_DIR="$test_tmp/run"
export HOME="$test_tmp/home"
unset WAYLAND_DISPLAY
export PATH="$ROOT/bin:$PATH"
export QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE=
export QT_QUICK_BACKEND=software QS_DISABLE_FILE_WATCHER=1
ulimit -c 0 2>/dev/null || true

# This fixture has only Quickshell's IPC socket, forcing the fallback used
# when an update still has an older Omarchy shell running. Offscreen startup
# neither connects to the user's compositor nor changes their desktop.
LC_ALL=C.UTF-8 qs -n -p "$OMARCHY_PATH/shell" >"$test_tmp/server.log" 2>&1 &
server_pid=$!
ready=0
for _ in {1..100}; do
  if [[ $(LC_ALL=C.UTF-8 qs ipc -n -p "$OMARCHY_PATH/shell" call -- shell ping 2>/dev/null) == "ok" ]]; then
    ready=1
    break
  fi
  sleep 0.05
done
(( ready )) || fail "offscreen IPC fixture becomes ready" "$(cat "$test_tmp/server.log")"

shell_call() {
  env -u LC_ALL "$@" "$ROOT/bin/omarchy-shell" shell ping 2>"$test_tmp/errors"
}

for locale in C POSIX; do
  output=$(shell_call LC_ALL="$locale")
  [[ $output == "ok" ]] || fail "IPC reply is clean under $locale" "$output"
  pass "IPC reply is clean under $locale"
done

output=$(shell_call LANG=omarchy_MISSING.UTF-8)
[[ $output == "ok" ]] || fail "IPC reply survives an unavailable LANG" "$output"
pass "IPC reply survives an unavailable LANG"

for category in LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION; do
  output=$(shell_call LANG=C.UTF-8 "$category=omarchy_MISSING.UTF-8")
  [[ $output == "ok" ]] || fail "IPC reply survives an unavailable $category" "$output"
  pass "IPC reply survives an unavailable $category"
done

# bar put captures stderr as well as stdout to classify unavailable shells.
# An invalid LC_ALL must not add Bash's startup warning to a successful reply.
output=$(LC_ALL=omarchy_MISSING.UTF-8 "$ROOT/bin/omarchy-bar" put omarchy.elsewhen --after omarchy.clock 2>"$test_tmp/errors")
[[ $output == "omarchy.elsewhen is on the bar" ]] || fail "bar put survives an unavailable LC_ALL" "$output"
pass "bar put survives an unavailable LC_ALL"

payload="Lisboa — São Paulo — 東京"
output=$(LC_ALL=C "$ROOT/bin/omarchy-shell" shell reply "$payload")
[[ $output == $payload ]] || fail "IPC preserves Unicode arguments and replies" "$output"
pass "IPC preserves Unicode arguments and replies"

for target in shell missing; do
  output=$(LC_ALL=C "$ROOT/bin/omarchy-shell" "$target" missing 2>&1) &&
    fail "invalid IPC request still fails under C"
  [[ $output == "Function not found." || $output == "Target not found." ]] ||
    fail "invalid IPC request reports its exact error under C" "$output"
done
pass "invalid IPC requests still fail with their exact errors under C"

output=$(LC_ALL=C "$ROOT/bin/omarchy-shell" -q missing missing 2>&1)
[[ -z $output ]] || fail "quiet IPC errors stay silent under C" "$output"
pass "quiet IPC errors stay silent under C"
