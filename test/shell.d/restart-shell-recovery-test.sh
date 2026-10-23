#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/bin/omarchy-restart-shell"

test_tmp=$(mktemp -d)
registry_pid=
unlisted_pid=

cleanup() {
  local pid
  for pid in $registry_pid $unlisted_pid; do
    builtin kill -KILL "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
  rm -rf "$test_tmp"
}
trap cleanup EXIT

bash -n "$SCRIPT"
pass "omarchy-restart-shell has valid bash syntax"

if ! grep -q "timeout 30 quickshell kill -p" "$SCRIPT"; then
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

if ! grep -q "process_dead" "$SCRIPT"; then
  fail "restart waits for process death before cleaning runtime dirs"
fi
pass "restart waits for process death before cleaning runtime dirs"

if ! grep -q "shell_process_matches_config" "$SCRIPT"; then
  fail "restart matches the config-path argument exactly, not a substring"
fi
pass "restart matches the config-path argument exactly, not a substring"

if ! grep -q "shell_instance_pids" "$SCRIPT"; then
  fail "restart collects config-matched pids from the quickshell registry"
fi
pass "restart collects matching pids from the quickshell registry"

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
  /while timeout 30 quickshell kill -p "\$CONFIG_DIR" --any-display/.test(source),
  'IPC kill loop is preserved'
)
assert(
  /shell_process_matches_config\(\)/.test(source) && /mapfile -t qs_pids/.test(source),
  'fallback collects quickshell pids matching the exact config path'
)
assert(
  /shell_instance_pids\(\)[\s\S]*?quickshell list -a -j[\s\S]*?startswith\(\$dir\)[\s\S]*?\.pid/.test(source),
  'fallback collects matching pids from the quickshell registry'
)
assert(
  /process_dead\(\)/.test(source) && /state.*Z/.test(source),
  'fallback waits for zombie/dead state before cleaning runtime dirs'
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

function_source=$(
  sed -n \
    -e '/^shell_instance_running() {/,/^}/p' \
    -e '/^shell_instance_pids() {/,/^}/p' \
    -e '/^shell_process_matches_config() {/,/^}/p' \
    -e '/^process_dead() {/,/^}/p' \
    -e '/^matching_shell_pids() {/,/^}/p' \
    -e '/^stop_shell_instances() {/,/^}/p' \
    "$SCRIPT"
)
[[ -n $function_source ]] || fail "restart recovery functions are available for focused tests"
eval "$function_source"

CONFIG_DIR="$test_tmp/omarchy/shell"
command sleep 60 &
registry_pid=$!
registry_cmdline=$(tr '\0' ' ' <"/proc/$registry_pid/cmdline")
[[ $registry_cmdline != *"-p"* ]] || fail "registry fixture must have no -p argument" "$registry_cmdline"

list_calls_file="$test_tmp/list-calls"
signals_file="$test_tmp/signals"
pgrep_file="$test_tmp/pgrep-calls"
: >"$list_calls_file"
: >"$signals_file"
: >"$pgrep_file"
test_scenario=running
declare -A term_sent=()

quickshell() {
  case $1 in
    kill)
      return 1
      ;;
    list)
      local calls=0
      if [[ -f $list_calls_file ]]; then
        calls=$(<"$list_calls_file")
      fi
      calls=$((calls + 1))
      printf '%s\n' "$calls" >"$list_calls_file"
      if [[ $test_scenario == "unlisted" ]]; then
        printf '[]\n'
      elif [[ $test_scenario == "running" || $calls == 1 ]]; then
        printf '[{"config_path":"%s/shell.qml","pid":%s}]\n' "$CONFIG_DIR" "$registry_pid"
      else
        printf '[]\n'
      fi
      ;;
  esac
}

timeout() {
  shift
  "$@"
}

sleep() {
  if [[ $test_scenario == "running" ]]; then
    SECONDS=$((SECONDS + 31))
  fi
  return 0
}

pgrep() {
  printf '%s\n' "$*" >>"$pgrep_file"
  if [[ $test_scenario == "unlisted" ]]; then
    printf '%s\n' "$unlisted_pid"
  else
    printf '%s\n' "$registry_pid"
  fi
}

kill() {
  case $1 in
    -TERM)
      printf 'TERM %s\n' "$2" >>"$signals_file"
      term_sent["$2"]=1
      ;;
    -KILL)
      printf 'KILL %s\n' "$2" >>"$signals_file"
      ;;
  esac
}

process_dead() {
  [[ ${term_sent[$1]:-0} == 1 ]]
}

mapfile -t matching_pids < <(matching_shell_pids)
(( ${#matching_pids[@]} == 1 )) && [[ ${matching_pids[0]} == $registry_pid ]] ||
  fail "registry finds a crash-restarted shell whose cmdline lacks -p" "${matching_pids[*]}"
: >"$list_calls_file"
stop_shell_instances
grep -F "TERM $registry_pid" "$signals_file" >/dev/null ||
  fail "signal fallback includes the registry pid without a -p cmdline"
pass "registry pid is signalled when its cmdline lacks -p"

test_scenario=exited
: >"$list_calls_file"
: >"$signals_file"
: >"$pgrep_file"
stop_shell_instances
[[ ! -s $signals_file ]] ||
  fail "signal fallback does not run after the wait loop sees the instance exit"
pass "signal fallback stays idle when the wait loop sees the instance exit"

# A shell whose instance.lock is gone is missing from quickshell list but still
# running; only its argv identifies it. It stops itself, so no child outlives it.
bash -c 'kill -STOP $$' quickshell -p "$CONFIG_DIR" >/dev/null 2>&1 &
unlisted_pid=$!
for (( i = 0; i < 100; i++ )); do
  [[ $(awk '{print $3}' "/proc/$unlisted_pid/stat") == "T" ]] && break
  command sleep 0.01
done
test_scenario=unlisted
: >"$signals_file"
stop_shell_instances
grep -F "TERM $unlisted_pid" "$signals_file" >/dev/null ||
  fail "signal fallback reaches a shell the registry no longer lists" "$(cat "$signals_file")"
pass "unlisted shell matching the config path is signalled"
