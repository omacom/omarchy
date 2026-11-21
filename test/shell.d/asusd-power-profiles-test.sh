#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir" "${unit_dir:-}"' EXIT

dropin="$ROOT/etc/systemd/system/asusd.service.d/10-omarchy-power-profiles.conf"
[[ -f $dropin ]] || fail "the asusd drop-in exists at $dropin"

mapfile -t lines < <(grep -vE '^[[:space:]]*(#|$)' "$dropin")
expected=(
  "[Service]"
  "ExecStartPost=-/usr/bin/busctl --system set-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform ChangePlatformProfileOnAc b false"
  "ExecStartPost=-/usr/bin/busctl --system set-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform ChangePlatformProfileOnBattery b false"
  "ExecStartPost=-/usr/bin/busctl --system set-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform PlatformProfileLinkedEpp b false"
)
[[ ${lines[*]} == "${expected[*]}" ]] ||
  fail "the asusd drop-in turns off exactly profile switching on AC and battery and linked EPP" "got: ${lines[*]}"
pass "the asusd drop-in turns off profile switching on AC and battery and linked EPP"

# A failed property write (a model without platform profiles, an older asusd)
# must not fail asusd's start.
if grep -E '^ExecStartPost=[^-]' "$dropin" >/dev/null; then
  fail "every asusd ExecStartPost ignores failure"
fi
pass "a refused asusd property write does not fail asusd's start"

if command -v systemd-analyze >/dev/null; then
  unit_dir=$(mktemp -d)
  mkdir -p "$unit_dir/asusd.service.d"
  printf '[Service]\nType=simple\nExecStart=/usr/bin/true\n' >"$unit_dir/asusd.service"
  cp "$dropin" "$unit_dir/asusd.service.d/"
  # asusd is a system unit; verifying in system scope needs no running user
  # manager, so this also runs headless and in CI.
  if output=$(SYSTEMD_UNIT_PATH="$unit_dir:" systemd-analyze verify --man=no "$unit_dir/asusd.service" 2>&1); then
    [[ $output != *"Unknown"* && $output != *"Invalid"* ]] || fail "the asusd drop-in parses cleanly" "$output"
    pass "the asusd drop-in parses"
  elif [[ $output == *"Failed to initialize manager"* || $output == *"Access denied"* ]]; then
    printf 'ok - the asusd drop-in parses # SKIP systemd-analyze cannot run here: %s\n' "${output%%$'\n'*}"
  else
    fail "the asusd drop-in parses" "$output"
  fi
fi

# The migration applies the same three settings to a running asusd, only on
# ROG hardware, only where a property is still on, and keeps going if asusd
# refuses a write. busctl, systemctl and the ROG check are stubbed, so nothing
# reaches the real system bus.
migration="$ROOT/migrations/1792122579.sh"
[[ $(stat -c %a "$migration") == 644 ]] || fail "the asusd migration is mode 0644"
[[ $(head -c 2 "$migration") != "#!" ]] || fail "the asusd migration has no shebang"
pass "the asusd migration has the migration file format"

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/omarchy-hw-asus-rog" <<'STUB'
#!/bin/bash
[[ ${STUB_ROG:-1} == 1 ]]
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
[[ $* == "is-active --quiet asusd.service" && ${STUB_ASUSD_ACTIVE:-1} == 1 ]]
STUB
cat >"$stub_bin/busctl" <<'STUB'
#!/bin/bash
state="${STUB_STATE:?}"
case "$2" in
  get-property)
    [[ -f $state/$6 ]] || exit 1
    printf 'b %s\n' "$(<"$state/$6")"
    ;;
  set-property)
    echo "$6 $7 $8" >>"$state/calls"
    [[ ${STUB_REFUSE:-} == "$6" ]] && exit 1
    printf '%s\n' "$8" >"$state/$6"
    ;;
  *) exit 2 ;;
esac
STUB
chmod +x "$stub_bin"/*

properties=(ChangePlatformProfileOnAc ChangePlatformProfileOnBattery PlatformProfileLinkedEpp)

reset_state() {
  rm -rf "$test_dir/state"
  mkdir -p "$test_dir/state"
  local property
  for property in "${properties[@]}"; do
    printf '%s\n' "$1" >"$test_dir/state/$property"
  done
}

run_migration() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" STUB_STATE="$test_dir/state" \
    PATH="$stub_bin:$PATH" "$@" bash -euo pipefail "$migration" 2>&1
}

calls() {
  cat "$test_dir/state/calls" 2>/dev/null || true
}

reset_state true
output=$(run_migration env) || fail "the asusd migration succeeds with asusd defaults" "$output"
for property in "${properties[@]}"; do
  [[ $(<"$test_dir/state/$property") == false ]] || fail "the asusd migration turns off $property" "$(calls)"
done
pass "the asusd migration turns off all three settings on a running asusd"

rm -f "$test_dir/state/calls"
output=$(run_migration env) || fail "the asusd migration reruns cleanly" "$output"
[[ -z $(calls) ]] || fail "a rerun of the asusd migration writes nothing" "$(calls)"
pass "the asusd migration is idempotent"

reset_state true
output=$(run_migration env STUB_ROG=0) || fail "the asusd migration succeeds on other hardware" "$output"
[[ -z $(calls) ]] || fail "the asusd migration does nothing on non-ROG hardware" "$(calls)"
output=$(run_migration env STUB_ASUSD_ACTIVE=0) || fail "the asusd migration succeeds without asusd running" "$output"
[[ -z $(calls) ]] || fail "the asusd migration does nothing when asusd is not running" "$(calls)"
pass "the asusd migration does nothing off ROG hardware or without a running asusd"

reset_state true
output=$(run_migration env STUB_REFUSE=ChangePlatformProfileOnAc) ||
  fail "a refused asusd write does not fail the migration" "$output"
[[ $output == *"Could not turn off asusd ChangePlatformProfileOnAc now"* ]] ||
  fail "a refused asusd write is reported" "$output"
[[ $(<"$test_dir/state/PlatformProfileLinkedEpp") == false ]] ||
  fail "the asusd migration keeps going after a refused write" "$(calls)"
pass "a refused asusd write is reported and the rest still apply"

reset_state true
rm "$test_dir/state/PlatformProfileLinkedEpp"
output=$(run_migration env) || fail "an asusd without a property does not fail the migration" "$output"
[[ $(calls) != *PlatformProfileLinkedEpp* ]] || fail "the asusd migration skips a property asusd lacks" "$(calls)"
pass "the asusd migration skips properties an older asusd lacks"
