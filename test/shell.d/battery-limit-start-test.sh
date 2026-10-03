#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

source "$ROOT/bin/omarchy-battery-limit-set"
power_supply_path="$fixture/sys"
STATE_FILE="$fixture/config/limit"
LOCK_FILE="$fixture/lock"
systemctl() { :; }
write_threshold() {
  local path=$1 value=$2 battery=${1%/*}
  if [[ $path == */charge_control_start_threshold ]]; then
    [[ $FAULT != "reject-start" || $value != "85" ]] || return 1
    if [[ $FAULT == "clamp-start" && $value == "85" ]]; then value=84; fi
    (( value < $(cat "$battery/charge_control_end_threshold") )) || return 1
  else
    [[ $FAULT != "readonly-end" ]] || return 1
    (( value > $(cat "$battery/charge_control_start_threshold") )) || return 1
  fi
  printf '%s\n' "$value" > "$path"
}
reset_fixture() {
  rm -rf "$fixture/sys" "$fixture/config"
  mkdir -p "$fixture/sys/BAT0" "$fixture/config"
  printf '75\n' > "$fixture/sys/BAT0/charge_control_start_threshold"
  printf '80\n' > "$fixture/sys/BAT0/charge_control_end_threshold"
  printf '80\n' > "$STATE_FILE"
  FAULT=none
}
assert_pair() {
  [[ $(cat "$fixture/sys/BAT0/charge_control_start_threshold") == "$1" ]] || fail "expected start $1"
  [[ $(cat "$fixture/sys/BAT0/charge_control_end_threshold") == "$2" ]] || fail "expected end $2"
  [[ $(cat "$STATE_FILE") == "$2" ]] || fail "expected saved maximum $2"
}

reset_fixture
apply_limit 90
assert_pair 85 90
(( 78 < $(cat "$fixture/sys/BAT0/charge_control_start_threshold") )) || fail "78% must be eligible to charge after selecting 90%"
pass "raising the maximum makes a battery at 78% eligible to resume charging"

apply_limit 100
assert_pair 95 100
apply_limit 80
assert_pair 75 80
pass "raising and lowering presets respects drivers requiring start below end"

for fault in reject-start clamp-start; do
  reset_fixture
  FAULT=$fault
  set +e
  (set -e; apply_limit 90) > "$fixture/output" 2>&1
  status=$?
  set -e
  (( status != 0 )) || fail "$fault must fail"
  assert_pair 75 80
  pass "$fault restores the original thresholds and saved maximum"
done

reset_fixture
mv() { return 1; }
set +e
(set -e; apply_limit 90) > "$fixture/output" 2>&1
status=$?
set -e
unset -f mv
(( status != 0 )) || fail "failed save must fail"
assert_pair 75 80
pass "failed save rolls back both independently changed thresholds"

reset_fixture
apply_limit 100
FAULT=readonly-end
set +e
(set -e; apply_limit 80) > "$fixture/output" 2>&1
status=$?
set -e
(( status != 0 )) || fail "read-only end must fail"
assert_pair 95 100
grep -q 'Previous battery thresholds restored' "$fixture/output" || fail "must restore start without rewriting read-only end"
pass "read-only end restores a lowered start without a redundant end write"
