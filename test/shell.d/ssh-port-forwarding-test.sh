#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/ssh-port-forwarding"

test_tmp=$(mktemp -d)
cleanup() {
  local pid
  for pid in $(jobs -pr); do
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
  rm -rf "$test_tmp"
}
trap cleanup EXIT
calls="$test_tmp/pkill-calls"

# Record the process-killing boundary without terminating any real processes.
pkill() { printf '%s\n' "$@" >>"$calls"; }

for port in '1|.*' '' '.*' '-1' '22:localhost:22' '22 80' $'22\n80'; do
  : >"$calls"
  if dip 8080 "$port" >"$test_tmp/output" 2>&1; then
    fail "dip rejects a nonnumeric port" "$(cat "$test_tmp/output")"
  fi
  [[ ! -s $calls ]] || fail "dip validates all ports before stopping any forward" "$(cat "$calls")"
done
pass "nonnumeric ports are rejected before any process can be killed"

: >"$calls"
dip 22 8080 >"$test_tmp/output"
[[ $(cat "$calls") == $'-f\nssh.*-L 22:localhost:22\n-f\nssh.*-L 8080:localhost:8080' ]] ||
  fail "dip still stops each requested numeric port" "$(cat "$calls")"
pass "numeric ports still reach the process-killing command"

# Exercise real process matching, restricted to this test's own children.
test_parent=$BASHPID
pkill() { command pkill -P "$test_parent" "$@"; }
for port in 18080 18081; do
  bash -c 'exec -a "$1" sleep 30' _ "ssh -N -L $port:localhost:$port test-fixture" >/dev/null 2>&1 &
  for attempt in {1..50}; do
    if pgrep -P "$test_parent" -f "^ssh -N -L $port:localhost:$port test-fixture" >/dev/null; then
      break
    fi
    sleep 0.02
  done
  pgrep -P "$test_parent" -f "^ssh -N -L $port:localhost:$port test-fixture" >/dev/null ||
    fail "disposable forwarding process starts"
done

if dip 18080 '1|.*' >"$test_tmp/output" 2>&1; then
  fail "mixed valid and invalid input is rejected"
fi
for port in 18080 18081; do
  pgrep -P "$test_parent" -f "^ssh -N -L $port:localhost:$port test-fixture" >/dev/null ||
    fail "invalid input leaves every disposable forward running"
done
pass "invalid input leaves real processes untouched"

dip 18080 >"$test_tmp/output"
for attempt in {1..50}; do
  if ! pgrep -P "$test_parent" -f '^ssh -N -L 18080:localhost:18080 test-fixture' >/dev/null; then
    break
  fi
  sleep 0.02
done
if pgrep -P "$test_parent" -f '^ssh -N -L 18080:localhost:18080 test-fixture' >/dev/null; then
  fail "numeric input terminates its disposable forward"
fi
pgrep -P "$test_parent" -f '^ssh -N -L 18081:localhost:18081 test-fixture' >/dev/null ||
  fail "numeric input leaves the other disposable forward running"
pass "numeric input terminates only the requested disposable forward"
