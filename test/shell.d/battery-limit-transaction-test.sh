#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

# Source the real setter, replacing only privilege entry and the sysfs write
# primitive. No elevated process, host battery, or /etc path is used.
cat > "$fixture/run" <<'SH'
#!/bin/bash
set -euo pipefail
source "$ROOT/bin/omarchy-battery-limit-set"
require_root() { :; }
power_supply_path="$FIXTURE/sys"
STATE_FILE="$FIXTURE/config/battery-limit"
LOCK_FILE="$FIXTURE/lock"
write_threshold() {
  local path=$1 value=$2
  printf '%s %s\n' "${path#"$FIXTURE/sys/"}" "$value" >> "$FIXTURE/writes"
  if [[ $FAULT == "reject" && $path == */BAT1/* && $value == "80" ]]; then return 1; fi
  if [[ $FAULT == "partial" && $path == */BAT1/* && $value == "80" ]]; then
    printf '85\n' > "$path"
    return 1
  fi
  if [[ $FAULT == "rollback" && $value == "100" ]]; then return 1; fi
  if [[ $FAULT == "clamp" || $FAULT == "rollback" ]] && [[ $value == "80" ]]; then
    printf '85\n' > "$path"
  else
    printf '%s\n' "$value" > "$path"
  fi
  if [[ $COUPLED == "true" && $path == */charge_control_end_threshold ]]; then
    printf '%s\n' "$((value - 5))" > "${path%/*}/charge_control_start_threshold"
  fi
  if [[ $FAULT == "interrupt" && $value == "80" ]]; then kill -TERM "$BASHPID"; fi
  if [[ $FAULT == "slow" && $value == "80" ]]; then
    touch "$FIXTURE/started"
    sleep 0.3
  fi
}
if [[ $FAULT == "save" ]]; then mv() { return 1; }; fi
if [[ $FAULT == "prepare" ]]; then mktemp() { return 1; }; fi
main "$PRESET"
SH

export FIXTURE="$fixture" FAULT=none PRESET=80 COUPLED=false
reset_fixture() {
  rm -rf "$fixture/sys" "$fixture/config"
  mkdir -p "$fixture/sys/BAT0" "$fixture/sys/BAT1" "$fixture/config"
  printf '100\n' > "$fixture/sys/BAT0/charge_control_end_threshold"
  printf '100\n' > "$fixture/sys/BAT1/charge_control_end_threshold"
  printf '100\n' > "$fixture/config/battery-limit"
  : > "$fixture/writes"
  FAULT=none COUPLED=false
}
run_apply() {
  set +e
  bash "$fixture/run" > "$fixture/output" 2>&1
  status=$?
  set -e
}
assert_value() {
  [[ $(<"$1") == "$2" ]] || fail "$3" "got: $(<"$1")"
}
assert_restored() {
  assert_value "$fixture/sys/BAT0/charge_control_end_threshold" 100 "first battery restored"
  assert_value "$fixture/sys/BAT1/charge_control_end_threshold" 100 "second battery restored"
  assert_value "$fixture/config/battery-limit" 100 "saved choice unchanged"
  [[ -z $(find "$fixture/config" -name '.battery-limit.*' -print -quit) ]] || fail "temporary state cleaned up"
}

reset_fixture
run_apply
(( status == 0 )) || fail "successful apply" "$(cat "$fixture/output")"
assert_value "$fixture/sys/BAT0/charge_control_end_threshold" 80 "first battery applied"
assert_value "$fixture/sys/BAT1/charge_control_end_threshold" 80 "second battery applied"
assert_value "$fixture/config/battery-limit" 80 "verified choice persisted"
[[ $(stat -c %a "$fixture/config/battery-limit") == "644" ]] || fail "saved choice is readable"
pass "all batteries are verified before saving the preset"

for fault in clamp reject partial save interrupt; do
  reset_fixture
  FAULT=$fault
  run_apply
  (( status != 0 )) || fail "$fault must fail"
  assert_restored
  pass "$fault restores battery thresholds and preserves the saved choice"
done

reset_fixture
rm "$fixture/config/battery-limit"
FAULT=reject
run_apply
(( status != 0 )) || fail "first-save rejection must fail"
[[ ! -e $fixture/config/battery-limit ]] || fail "first failed save must not create a saved policy"
assert_value "$fixture/sys/BAT0/charge_control_end_threshold" 100 "first-save rollback restores hardware"
pass "a failed first apply creates no saved policy"

reset_fixture
printf '75\n' > "$fixture/sys/BAT0/charge_control_start_threshold"
run_apply
(( status == 0 )) || fail "apply with an independent minimum"
assert_value "$fixture/sys/BAT0/charge_control_start_threshold" 75 "existing minimum is preserved"
pass "successful maximum-only changes preserve the independent minimum"

reset_fixture
FAULT=prepare
run_apply
(( status != 0 )) || fail "preparing state must fail"
[[ ! -s $fixture/writes ]] || fail "failed persistence preparation must not touch hardware"
assert_restored
pass "persistence is prepared before hardware writes"

reset_fixture
COUPLED=true FAULT=reject
printf '95\n' > "$fixture/sys/BAT0/charge_control_start_threshold"
printf '95\n' > "$fixture/sys/BAT1/charge_control_start_threshold"
run_apply
(( status != 0 )) || fail "coupled second-battery rejection must fail"
assert_restored
assert_value "$fixture/sys/BAT0/charge_control_start_threshold" 95 "coupled minimum restored"
assert_value "$fixture/sys/BAT1/charge_control_start_threshold" 95 "untouched minimum preserved"
pass "rollback restores the original pair on a driver that couples thresholds"

reset_fixture
FAULT=rollback
run_apply
(( status != 0 )) || fail "failed rollback must fail"
grep -q 'could not restore previous thresholds' "$fixture/output" || fail "failed rollback is reported"
assert_value "$fixture/config/battery-limit" 100 "failed rollback leaves saved choice unchanged"
pass "failed rollback is reported instead of claiming restoration"

reset_fixture
printf 'invalid\n' > "$fixture/sys/BAT1/charge_control_end_threshold"
run_apply
(( status != 0 )) || fail "invalid preflight must fail"
[[ ! -s $fixture/writes ]] || fail "all batteries are read before any write"
pass "invalid later battery prevents all writes"

reset_fixture
rm -rf "$fixture/sys/BAT0" "$fixture/sys/BAT1"
run_apply
(( status != 0 )) || fail "missing hardware must fail"
assert_value "$fixture/config/battery-limit" 100 "missing hardware preserves saved choice"
pass "no capable batteries preserves saved state"

reset_fixture
FAULT=slow bash "$fixture/run" > "$fixture/first-output" 2>&1 &
first=$!
for (( attempt=0; attempt<100; attempt++ )); do
  [[ ! -f $fixture/started ]] || break
  sleep 0.01
done
[[ -f $fixture/started ]] || fail "first transaction started"
PRESET=90 bash "$fixture/run" > "$fixture/second-output" 2>&1 &
second=$!
wait "$first" || fail "first serialized transaction" "$(cat "$fixture/first-output")"
wait "$second" || fail "second serialized transaction" "$(cat "$fixture/second-output")"
assert_value "$fixture/sys/BAT0/charge_control_end_threshold" 90 "second transaction applied first battery"
assert_value "$fixture/sys/BAT1/charge_control_end_threshold" 90 "second transaction applied second battery"
assert_value "$fixture/config/battery-limit" 90 "last completed transaction matches saved state"
expected=$'BAT0/charge_control_end_threshold 80\nBAT1/charge_control_end_threshold 80\nBAT0/charge_control_end_threshold 90\nBAT1/charge_control_end_threshold 90'
assert_value "$fixture/writes" "$expected" "concurrent writes do not interleave"
pass "concurrent applies serialize hardware and persistence together"
