#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/ssh-port-forwarding"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
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
