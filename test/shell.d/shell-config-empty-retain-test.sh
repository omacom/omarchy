#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A shell.json that empties while the shell runs must not become the defaults,
# or the next shell-side write persists them over the user's layout (#12990).

test_tmp=""
qs_pid=""

cleanup() {
  if [[ -n $qs_pid ]] && kill -0 "$qs_pid" 2>/dev/null; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  # The plugin registry's inotifywait can outlive the shell and holds the runner's lock fd.
  [[ -n $test_tmp ]] && pkill -f "$test_tmp" 2>/dev/null || true
  [[ -n $test_tmp && -d $test_tmp ]] && rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

require_compositor "shell config truncation test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping shell config truncation test"
  exit 0
fi

require_command jq

test_tmp=$(mktemp -d)
test_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
log="$test_tmp/quickshell.log"
user_config="$test_home/.config/omarchy/shell.json"
mkdir -p "$test_root" "$test_home/.config/omarchy"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

shell_ipc() {
  OMARCHY_PATH="$test_root" HOME="$test_home" "$ROOT/bin/omarchy-shell" "$@"
}

fail_with_log() {
  sed -n '1,200p' "$log" >&2
  fail "$1"
}

effective() {
  jq -r "$1" <<<"$(shell_ipc shell listShellConfig)"
}

# An empty layout writes nothing back on its own, so this script is the file's only writer.
write_user_config() {
  cat >"$user_config" <<JSON
{
  "version": 1,
  "marker": "$1",
  "bar": { "position": "bottom", "transparent": false, "layout": { "left": [], "center": [], "right": [] } },
  "plugins": []
}
JSON
}

reload_until() {
  shell_ipc -q shell reloadConfig >/dev/null
  for _ in {1..40}; do
    [[ $(effective '.marker // "none"') == "$1" ]] && return 0
    kill -0 "$qs_pid" 2>/dev/null || fail_with_log "test shell exited while reloading shell.json"
    sleep 0.1
  done
  return 1
}

# Unchanged state proves nothing until the reload has landed, so wait for the shell to say it retained.
reload_retaining() {
  local before
  before=$(grep -c 'retaining last valid config' "$log" || true)
  shell_ipc -q shell reloadConfig >/dev/null
  for _ in {1..50}; do
    if (( $(grep -c 'retaining last valid config' "$log" || true) > before )); then
      [[ $(effective '.marker // "none"') == "$1" ]]
      return
    fi
    sleep 0.1
  done
  return 1
}

write_user_config first

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
qs_pid=$!

ready=0
for _ in {1..100}; do
  if [[ $(shell_ipc shell ping 2>/dev/null) == "ok" ]]; then
    ready=1
    break
  fi
  kill -0 "$qs_pid" 2>/dev/null || fail_with_log "test shell exited before IPC became available"
  sleep 0.1
done
(( ready )) || fail_with_log "test shell answers IPC"

reload_until first || fail_with_log "a valid shell.json applies"
pass "a valid shell.json applies"

: >"$user_config"
reload_retaining first || fail_with_log "an emptied shell.json keeps the loaded config (got $(effective '.marker // "none"'))"
pass "an emptied shell.json keeps the loaded config"

for _ in {1..50}; do
  [[ $(shell_ipc shell toggleBarTransparency) == "ok" ]] && break
  sleep 0.2
done
for _ in {1..40}; do
  [[ -s $user_config ]] && break
  sleep 0.1
done
[[ $(jq -r '.marker // "none"' "$user_config") == "first" && $(jq -r '.bar.position' "$user_config") == "bottom" ]] ||
  fail_with_log "the next shell-side write persists the user's config, not the defaults"
pass "the next shell-side write persists the user's config, not the defaults"

printf '{\n' >"$user_config"
reload_retaining first || fail_with_log "an unparseable shell.json keeps the loaded config"
pass "an unparseable shell.json keeps the loaded config"

write_user_config second
reload_until second || fail_with_log "a later valid shell.json still applies"
pass "a later valid shell.json still applies"
