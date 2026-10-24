#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/lenovo/fix-thinkpad-t14-display-power.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1792574886.sh"
config_name=thinkpad-t14-display-power.conf

bash -n "$leaf" || fail "the ThinkPad T14 display fix has valid syntax"
bash -n "$migration" || fail "the ThinkPad T14 display migration has valid syntax"

grep -q 'run_logged .*hardware/lenovo/fix-thinkpad-t14-display-power.sh' "$all" ||
  fail "the ThinkPad T14 display fix runs during hardware setup"
pass "the ThinkPad T14 display fix runs during hardware setup"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

# The stub above has to match what the real matcher does, or the machine the
# leaf picks is not the machine the leaf would pick in production.
grep -q 'product_name' "$ROOT/bin/omarchy-hw-match" ||
  fail "the real matcher reads the DMI product name"
grep -q 'product_family' "$ROOT/bin/omarchy-hw-match" ||
  fail "the real matcher reads the DMI product family"
grep -q 'grep -qi' "$ROOT/bin/omarchy-hw-match" ||
  fail "the real matcher matches case-insensitively"

# omarchy-hw-match greps the fixed /sys/class/dmi/id files; point it at fixtures.
mkdir -p "$scratch/dmi"
cat >"$scratch/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
grep -qi -- "$1" "$DMI_NAME_FILE" 2>/dev/null ||
  grep -qi -- "$1" "$DMI_FAMILY_FILE" 2>/dev/null
SH
cat >"$scratch/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
[[ ${TEST_SUDO_STATUS:-0} == 0 ]] || exit "$TEST_SUDO_STATUS"
exec "$@"
SH
cat >"$scratch/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio %s\n' "$*" >>"$CALL_LOG"
[[ -z ${TEST_MKINITCPIO_MESSAGE:-} ]] || printf '%s\n' "$TEST_MKINITCPIO_MESSAGE"
exit "${TEST_MKINITCPIO_STATUS:-0}"
SH
cat >"$scratch/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${TEST_LIMINE_PRESENT:-1} == 1 ]]
SH
cat >"$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'omarchy-state %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$scratch/bin"/*

export CALL_LOG="$scratch/calls.log"

# The leaf runs as root during hardware setup and as root from the migration, so
# it writes the drop-in without sudo. The stub above only stands in for the
# privilege the migration takes.
run_leaf() {
  local product_name="$1" product_family="$2" state="$3"
  : >"$CALL_LOG"
  printf '%s\n' "$product_name" >"$scratch/dmi/product_name"
  printf '%s\n' "$product_family" >"$scratch/dmi/product_family"
  DMI_NAME_FILE="$scratch/dmi/product_name" DMI_FAMILY_FILE="$scratch/dmi/product_family" \
    PATH="$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" \
    bash -eE -c 'source "$1"' bash "$leaf" </dev/null
}

run_migration() {
  local product_name="$1" product_family="$2" state="$3" strict="${4:-strict}"
  : >"$CALL_LOG"
  # A VAR=value prefix on a function call leaks in POSIX mode, so the value the
  # caller asked for is taken here and handed to the command explicitly, and the
  # environment is cleared for the next case either way.
  local mkinitcpio_status="${TEST_MKINITCPIO_STATUS:-0}" sudo_status="${TEST_SUDO_STATUS:-0}"
  local mkinitcpio_message="${TEST_MKINITCPIO_MESSAGE:-}"
  export TEST_MKINITCPIO_STATUS=0 TEST_SUDO_STATUS=0 TEST_MKINITCPIO_MESSAGE=""
  printf '%s\n' "$product_name" >"$scratch/dmi/product_name"
  printf '%s\n' "$product_family" >"$scratch/dmi/product_family"
  local runner=(bash -euo pipefail)
  [[ $strict == strict ]] || runner=(bash)
  DMI_NAME_FILE="$scratch/dmi/product_name" DMI_FAMILY_FILE="$scratch/dmi/product_family" \
    PATH="$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" \
    OMARCHY_THINKPAD_T14_DISPLAY_POWER_MARKER="$state/marker" \
    TEST_MKINITCPIO_STATUS="$mkinitcpio_status" TEST_SUDO_STATUS="$sudo_status" \
    TEST_MKINITCPIO_MESSAGE="$mkinitcpio_message" \
    "${runner[@]}" "$migration" </dev/null
}

config="$scratch/t14/limine-entry-tool.d/$config_name"

run_leaf "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/t14"
[[ -f $config ]] || fail "the ThinkPad T14 Gen 2i gets the display drop-in"
grep -Fxq 'KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"' "$config" ||
  fail "the drop-in carries the kernel parameters under the key the boot tooling reads" "$(cat "$config")"
mode=$(stat -c '%a' "$config" 2>/dev/null || stat -f '%A' "$config" 2>/dev/null)
[[ $mode == 644 ]] ||
  fail "the drop-in is readable by the user that runs the migration" "mode=$mode"
pass "the ThinkPad T14 Gen 2i gets the display drop-in"

# Rerunning the leaf must not change the drop-in: hardware setup runs again on
# every update, and a rewrite that differs would churn the boot config.
before=$(sha256sum "$config")
run_leaf "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/t14"
[[ $(sha256sum "$config") == "$before" ]] || fail "rerunning the fix leaves the drop-in unchanged"
pass "rerunning the fix leaves the drop-in unchanged"

# A different generation of the same line does not match, and neither does an
# unrelated machine.
for machine in "21HM0000|ThinkPad T14 Gen 3i" "XPS 13 9350|XPS 13 9350"; do
  name=${machine%%|*}
  family=${machine##*|}
  rm -rf "$scratch/other"
  run_leaf "$name" "$family" "$scratch/other"
  [[ ! -e $scratch/other ]] || fail "the $family machine gets no display drop-in"
done
pass "other ThinkPad generations and other machines get no display drop-in"

# An install that predates the leaf never ran it, and a kernel parameter in a
# Limine drop-in only reaches the boot entries on a rebuild.
run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/migrated"
[[ -f $scratch/migrated/limine-entry-tool.d/$config_name ]] ||
  fail "the migration applies the display drop-in"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "the migration rebuilds the boot entries"
[[ -f $scratch/migrated/marker ]] || fail "the migration records the rebuild"
grep -q '^omarchy-state set reboot-required' "$CALL_LOG" ||
  fail "the migration asks for the reboot that applies it"
pass "the migration applies the display drop-in and rebuilds the boot entries"

# The path a machine is actually in when the migration runs: the install-time
# leaf already wrote the drop-in during hardware setup.
rm -rf "$scratch/prewritten"
mkdir -p "$scratch/prewritten/limine-entry-tool.d"
printf '%s\n' 'KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"' \
  >"$scratch/prewritten/limine-entry-tool.d/$config_name"
run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/prewritten"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "the migration rebuilds a machine that already has the drop-in"
[[ -f $scratch/prewritten/marker ]] || fail "the migration records the rebuild of a machine that already has the drop-in"
pass "the migration rebuilds a machine that already has the drop-in"

# A drop-in that exists but does not carry the parameter is repaired rather
# than left in place: because omarchy-migrate stops on a failed migration, a
# file that only exists would block every later run until someone fixed it by
# hand.
rm -rf "$scratch/wrong-setting"
mkdir -p "$scratch/wrong-setting/limine-entry-tool.d"
printf '%s\n' 'KERNEL_CMDLINE[default]+=" i915.enable_something_else=0"' \
  >"$scratch/wrong-setting/limine-entry-tool.d/$config_name"
run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/wrong-setting"
grep -Fxq 'KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"' \
  "$scratch/wrong-setting/limine-entry-tool.d/$config_name" ||
  fail "a drop-in without the parameter is rewritten"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "a repaired drop-in is rebuilt"
[[ -f $scratch/wrong-setting/marker ]] || fail "a repaired drop-in records the marker"
pass "a drop-in without the parameter is repaired"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0, so
# its output decides whether the boot image carries the setting.
rm -rf "$scratch/rebuild-reported-failed"
status=0
TEST_MKINITCPIO_MESSAGE='mkinitcpio failed for kernel linux-omarchy' \
  run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/rebuild-reported-failed" || status=$?
(( status != 0 )) || fail "a rebuild that reports a failed kernel fails the migration"
[[ ! -e $scratch/rebuild-reported-failed/marker ]] ||
  fail "a rebuild that reports a failed kernel records no marker"
! grep -q '^omarchy-state set reboot-required' "$CALL_LOG" ||
  fail "a rebuild that reports a failed kernel asks for no reboot"
pass "a rebuild that reports a failed kernel leaves the migration pending"

# A rebuild that fails must leave the migration pending: the marker would stop
# every later retry, and the user would be told to reboot for a parameter that
# never reached the boot entries.
rm -rf "$scratch/rebuild-failed"
status=0
TEST_MKINITCPIO_STATUS=1 run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/rebuild-failed" || status=$?
(( status != 0 )) || fail "a failed rebuild fails the migration"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "a failed rebuild still attempted the rebuild"
[[ ! -e $scratch/rebuild-failed/marker ]] || fail "a failed rebuild records no marker"
! grep -q '^omarchy-state set reboot-required' "$CALL_LOG" ||
  fail "a failed rebuild asks for no reboot"
pass "a failed rebuild leaves the migration pending"

# The same has to hold without the runner's strict shell options: the marker
# would stop every later retry, so the rebuild's own check has to be what
# decides, not the shell the migration happens to be run under.
rm -rf "$scratch/rebuild-failed-loose"
status=0
TEST_MKINITCPIO_STATUS=1 run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/rebuild-failed-loose" loose || status=$?
(( status != 0 )) || fail "a failed rebuild fails the migration without strict shell options"
grep -q '^limine-mkinitcpio' "$CALL_LOG" ||
  fail "a failed rebuild still attempted the rebuild without strict shell options"
[[ ! -e $scratch/rebuild-failed-loose/marker ]] ||
  fail "a failed rebuild records no marker without strict shell options"
pass "a failed rebuild leaves the migration pending without strict shell options"

# A refused write leaves the drop-in unwritten, and the migration must not
# report success over it.
rm -rf "$scratch/write-failed"
status=0
TEST_SUDO_STATUS=1 run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/write-failed" || status=$?
(( status != 0 )) || fail "a refused write fails the migration"
[[ ! -e $scratch/write-failed/marker ]] || fail "a refused write records no marker"
pass "a refused write leaves the migration pending"

# A case that needs the rebuild to succeed, after the failure cases: a failure
# knob that leaked into it would make the rebuild fail and this case with it.
rm -rf "$scratch/after-failures"
mkdir -p "$scratch/after-failures/limine-entry-tool.d"
printf '%s\n' 'KERNEL_CMDLINE[default]+=" i915.enable_dc=0 i915.enable_fbc=0"' \
  >"$scratch/after-failures/limine-entry-tool.d/$config_name"
run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/after-failures"
grep -q '^limine-mkinitcpio' "$CALL_LOG" ||
  fail "a rebuild still succeeds after the failure cases"
[[ -f $scratch/after-failures/marker ]] || fail "a rebuild after the failure cases records the marker"
pass "a rebuild still succeeds after the failure cases"

# The marker stops another user's run from repeating the machine-wide rebuild.
run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/migrated"
! grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "the migration rebuilds only once"
pass "the migration rebuilds only once"

rm -rf "$scratch/other"
run_migration "XPS 13 9350" "XPS 13 9350" "$scratch/other"
[[ ! -e $scratch/other ]] || fail "the migration leaves other machines alone"
pass "the migration leaves other machines alone"

# A machine with no Limine cannot rebuild its boot entries, so the migration
# has nothing to do and must not leave a drop-in behind claiming otherwise.
rm -rf "$scratch/no-limine"
TEST_LIMINE_PRESENT=0 run_migration "20W1S7PB00" "ThinkPad T14 Gen 2i" "$scratch/no-limine"
[[ ! -e $scratch/no-limine ]] || fail "a machine without Limine is left alone"
pass "a machine without Limine is left alone"
