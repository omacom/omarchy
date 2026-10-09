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
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "unreadable shell.json test"
require_command quickshell
require_command jq

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
log="$TMPDIR/quickshell.log"
config="$test_home/.config/omarchy/shell.json"
mkdir -p "$test_root" "$(dirname "$config")"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

fail_with_log() {
  sed -n '1,200p' "$log" >&2
  fail "$1"
}

# Wait until the running shell reports the bar position given.
wait_for_position() {
  local position="$1"
  for _ in {1..150}; do
    [[ $(shell_ipc shell listShellConfig 2>/dev/null | jq -r '.bar.position // "top"' 2>/dev/null) == "$position" ]] && return 0
    kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited"
    sleep 0.1
  done
  return 1
}

jq '.bar.position = "bottom"' "$ROOT/config/omarchy/shell.json" >"$config"

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

wait_for_position bottom || fail_with_log "shell loads the user's shell.json"

# A hand edit that drops the closing brace.
sed -i '$ d' "$config"
cp "$config" "$TMPDIR/broken.json"
wait_for_position top || fail_with_log "shell falls back to defaults on an unreadable shell.json"

reply=$(shell_ipc shell setBarWidget omarchy.clock format '"HH:mm"' '{}') || fail_with_log "bar widget setting is accepted"
[[ $reply == "ok" ]] || fail_with_log "bar widget setting is applied: $reply"
shell_ipc shell listShellConfig | jq -e 'any(.bar.layout[][]; .id == "omarchy.clock" and .format == "HH:mm")' >/dev/null ||
  fail_with_log "blocked persistence still applies the clock setting in memory"
pass "blocked persistence still applies the clock setting in memory"
sleep 1
cmp -s "$config" "$TMPDIR/broken.json" || fail "a bar change leaves an unreadable shell.json as the user left it" "$(cat "$config")"
pass "a bar change leaves an unreadable shell.json as the user left it"

printf '}\n' >>"$config"
wait_for_position bottom || fail_with_log "shell picks up shell.json once it is fixed"

reply=$(shell_ipc shell setBarWidget omarchy.clock format '"H:mm"' '{}') || fail_with_log "bar widget setting is accepted"
[[ $reply == "ok" ]] || fail_with_log "bar widget setting is applied: $reply"
saved='.bar.position == "bottom" and any(.bar.layout[][]; .id == "omarchy.clock" and .format == "H:mm")'
for _ in {1..40}; do
  jq -e "$saved" "$config" >/dev/null 2>&1 && break
  sleep 0.1
done
jq -e "$saved" "$config" >/dev/null || fail "a bar change is saved again once shell.json is fixed" "$(cat "$config")"
pass "a bar change is saved again once shell.json is fixed"
