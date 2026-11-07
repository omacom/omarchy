#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

unit="$ROOT/default/systemd/system/omarchy-charge-policy.service"
leaf="$ROOT/install/hardware/apple/charge-policy.sh"

mapfile -t migrations < <(grep -l 'OMARCHY_CHARGE_POLICY_UNIT_SRC' "$ROOT"/migrations/*.sh)
(( ${#migrations[@]} == 1 )) ||
  fail "one migration installs the charge policy unit" "${migrations[*]-}"
migration=${migrations[0]}

grep -Fx 'ConditionPathExists=/sys/class/power_supply/macsmc-battery/charge_control_end_threshold' "$unit" >/dev/null ||
  fail "the charge policy unit runs only when the Apple SMC battery node exists"
grep -Fx 'ExecStart=/usr/bin/omarchy-charge-policy run' "$unit" >/dev/null ||
  fail "the charge policy unit starts the shipped program"
pass "the charge policy unit is conditional and starts the shipped program"

grep -q 'apple/charge-policy.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup installs the charge policy unit"
if grep -Eq 'systemctl[[:space:]]+(enable|start|--now)' "$unit" "$leaf" "$migration"; then
  fail "the charge policy unit is not enabled or started"
fi
pass "the charge policy unit is not enabled or started"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cp "$ROOT/bin/omarchy-charge-policy" "$tmpdir/charge_policy.py"
cp "$ROOT/test/shell.d/fixtures/charge-policy/test_policy.py" "$tmpdir/test_policy.py"
output=$(cd "$tmpdir" && python3 test_policy.py 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "the Apple SMC charge policy tests pass"
}
grep -q 'Ran 43 tests' <<<"$output" || {
  printf '%s\n' "$output" >&2
  fail "the Apple SMC charge policy tests cover the patched decision suite"
}
grep -qx 'OK' <<<"$output" || {
  printf '%s\n' "$output" >&2
  fail "the Apple SMC charge policy tests pass"
}
pass "the Apple SMC charge policy tests pass"
