#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command awk
real_awk=$(type -P awk)
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

proc_root="$test_tmp/proc"
candidates="$test_tmp/candidates"
call_log="$test_tmp/calls"
mkdir -p "$proc_root" "$test_tmp/home"

# These synthetic PIDs are above Linux's PID limit; they never identify a host
# process. Both signal commands are functions that only record their arguments.
first_pid=71000001
second_pid=71000002
third_pid=71000003

write_status() {
  local pid="$1" mask="$2"
  mkdir -p "$proc_root/$pid"
  printf 'Name:\topencode\nSigIgn:\t0000000000000800\n' >"$proc_root/$pid/status"
  [[ -z $mask ]] || printf 'SigCgt:\t%s\n' "$mask" >>"$proc_root/$pid/status"
  return 0
}

run_restart() (
  export OMARCHY_TEST_PROC_ROOT="$proc_root" OMARCHY_TEST_CANDIDATES="$candidates"
  export OMARCHY_TEST_CALL_LOG="$call_log" OMARCHY_TEST_REAL_AWK="$real_awk"

  pgrep() {
    [[ $* == "-x opencode" ]] || return 2
    local pid
    while IFS= read -r pid; do printf '%s\n' "$pid"; done <"$OMARCHY_TEST_CANDIDATES"
    [[ -s $OMARCHY_TEST_CANDIDATES ]]
  }
  awk() {
    (( $# == 2 )) && [[ $2 =~ ^/proc/([0-9]+)/status$ ]] || return 2
    # Keep the real awk parser; redirect its proc read into the private fixture.
    "$OMARCHY_TEST_REAL_AWK" "$1" "$OMARCHY_TEST_PROC_ROOT/${BASH_REMATCH[1]}/status"
  }
  kill() { printf 'kill %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"; }
  killall() { printf 'killall %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"; }
  export -f pgrep awk kill killall

  HOME="$test_tmp/home" env -u BASH_ENV -u ENV /bin/bash "$ROOT/bin/omarchy-restart-opencode"
)

assert_calls() {
  local expected="$1" description="$2" output status=0
  : >"$call_log"
  output=$(run_restart 2>&1) || status=$?
  (( status == 0 )) || fail "$description" "exit $status: $output"
  [[ -z $output && $(<"$call_log") == "$expected" ]] ||
    fail "$description" "signals: $(<"$call_log") output: $output"
  pass "$description"
}

printf '%s\n' "$first_pid" >"$candidates"
write_status "$first_pid" "0000000000000000"
assert_calls "" "a process without caught signals receives no reload signal"

write_status "$first_pid" "0000000000000800"
assert_calls "kill -USR2 $first_pid" "a process catching SIGUSR2 receives exactly one reload signal"

write_status "$first_pid" "0000000000008800"
assert_calls "kill -USR2 $first_pid" "other caught signals do not prevent SIGUSR2 reload"

write_status "$first_pid" "0000000000000200"
assert_calls "" "catching another signal does not permit SIGUSR2"

write_status "$first_pid" "8000000000000800"
assert_calls "kill -USR2 $first_pid" "the SIGUSR2 bit survives a high 64-bit caught-signal mask"

write_status "$first_pid" "8000000000000000"
assert_calls "" "a high 64-bit caught-signal mask without SIGUSR2 receives no signal"

write_status "$first_pid" ""
assert_calls "" "a missing caught-signal mask is not confused with an ignored signal"

rm -f "$proc_root/$first_pid/status"
assert_calls "" "a candidate that vanished before its status was read receives no signal"

: >"$candidates"
assert_calls "" "no opencode candidates means no signal or error"

printf '%s\n' "$first_pid" "$second_pid" "$third_pid" >"$candidates"
write_status "$first_pid" "0000000000000800"
write_status "$third_pid" "0000000000000200"
assert_calls "kill -USR2 $first_pid" "mixed candidates skip a vanished process and a process lacking the handler"

write_status "$third_pid" "8000000000000800"
assert_calls "$(printf 'kill -USR2 %s\nkill -USR2 %s' "$first_pid" "$third_pid")" \
  "a vanished candidate does not prevent later handler processes from reloading"
