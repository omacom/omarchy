#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-acer-predator-v4"
leaf="$ROOT/install/hardware/acer/enable-predator-v4.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1790579560.sh"

grep -q 'acer/enable-predator-v4.sh' "$all" ||
  fail "the predator_v4 quirk runs during hardware setup"
pass "the predator_v4 quirk runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/etc/modprobe.d/acer-wmi.conf"
mkdir -p "$stub_bin" "$test_tmp/dmi"

# The detector reads DMI from absolute paths, so run a copy pointed at fixtures.
sed -e "s|/sys/class/dmi/id/|$test_tmp/dmi/|g" "$detector" >"$stub_bin/omarchy-hw-acer-predator-v4"

installed_kernel=7.2.5-arch1-1
mkdir -p "$test_tmp/modules/$installed_kernel"

# Like the real one, it resolves against the running kernel unless -k names one.
cat >"$stub_bin/modinfo" <<'SH'
#!/bin/bash

kernel=$RUNNING_KERNEL
[[ $1 == "-k" ]] && kernel=$2
[[ -d $TEST_MODULES/$kernel ]] || { echo "modinfo: ERROR: Module alias acer_wmi not found." >&2; exit 1; }
(( ${NO_PREDATOR_V4:-0} == 1 )) || echo 'predator_v4:Enable features for predator laptops that use predator sense v4 (bool)'
echo 'ec_raw_mode:Enable EC raw mode (bool)'
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

# Stubbed rather than run: the real one would write the running user's state.
cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

set_dmi() {
  printf '%s\n' "$1" >"$test_tmp/dmi/sys_vendor"
  printf '%s\n' "$2" >"$test_tmp/dmi/product_name"
}

run_leaf() {
  local script="$test_tmp/leaf.sh"
  sed -e "s|/etc/modprobe.d|$test_tmp/etc/modprobe.d|g" -e "s|/usr/lib/modules|$test_tmp/modules|g" "$leaf" >"$script"

  PATH="$stub_bin:$PATH" TEST_MODULES="$test_tmp/modules" RUNNING_KERNEL="${RUNNING_KERNEL:-$installed_kernel}" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null >/dev/null
}

run_migration() {
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" OMARCHY_ACER_WMI_CONF="$conf" \
    TEST_MODULES="$test_tmp/modules" RUNNING_KERNEL="$installed_kernel" \
    bash -euo pipefail "$migration" >/dev/null
}

# The machine this was written for: the kernel does not list it, and without
# the option its Turbo key does nothing.
set_dmi "Acer" "Nitro ANV14-61"
rm -rf "${test_tmp:?}/etc"
run_leaf
grep -qx 'options acer_wmi predator_v4=1' "$conf" 2>/dev/null ||
  fail "the Nitro ANV14-61 gets predator_v4" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "the Nitro ANV14-61 gets predator_v4"

# The installer runs under arch-chroot, where the running kernel is the live
# ISO's and /usr/lib/modules holds only the target's.
rm -rf "${test_tmp:?}/etc"
RUNNING_KERNEL=7.1.9-arch1-1 run_leaf
grep -qx 'options acer_wmi predator_v4=1' "$conf" 2>/dev/null ||
  fail "an install whose live kernel differs from the target's gets predator_v4" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "an install whose live kernel differs from the target's gets predator_v4"

# acer-wmi already quirks these, and forcing the option would replace their
# quirks with fewer ones: the AN515-58 would lose fan PWM, the PH16-72 its Turbo.
for model in "Nitro AN515-58" "Predator PH315-53" "Predator PHN16-71" "Predator PH16-71" \
  "Predator PH16-72" "Predator PHN16-72" "Predator PH18-71" "Predator PT14-51"; do
  set_dmi "Acer" "$model"
  rm -rf "${test_tmp:?}/etc"
  run_leaf
  [[ ! -e $conf ]] || fail "models the kernel already quirks are left alone" "$model"
done
pass "models the kernel already quirks are left alone"

# An unlisted Nitro may not implement the v4 WMI calls, and a failed probe takes
# rfkill and backlight setup down with it.
set_dmi "Acer" "Nitro ANV15-51"
rm -rf "${test_tmp:?}/etc"
run_leaf
[[ ! -e $conf ]] || fail "other Acer laptops are left alone"
pass "other Acer laptops are left alone"

set_dmi "LENOVO" "Nitro ANV14-61"
rm -rf "${test_tmp:?}/etc"
run_leaf
[[ ! -e $conf ]] || fail "a non-Acer machine with the same product name is left alone"
pass "a non-Acer machine with the same product name is left alone"

set_dmi "Acer" "Nitro ANV14-61"
rm -rf "${test_tmp:?}/etc"
NO_PREDATOR_V4=1 run_leaf
[[ ! -e $conf ]] || fail "a kernel without the option is left alone"
pass "a kernel without the option is left alone"

# Someone who turned the option off, or commented it out, made that choice.
for existing in 'options acer_wmi predator_v4=0' '#options acer_wmi predator_v4=1'; do
  mkdir -p "$(dirname "$conf")"
  printf '%s\n' "$existing" >"$conf"
  run_leaf
  [[ $(cat "$conf") == "$existing" ]] || fail "the installer keeps an existing predator_v4 choice" "$(cat "$conf")"
  run_migration
  [[ $(cat "$conf") == "$existing" ]] || fail "the migration keeps an existing predator_v4 choice" "$(cat "$conf")"
  [[ ! -s $calls ]] || fail "the migration escalates nothing when the choice is made" "$(cat "$calls")"
done
pass "an existing predator_v4 line, set or commented out, is kept"

# Installs that predate the quirk never ran the leaf.
rm -rf "${test_tmp:?}/etc"
run_migration
grep -qx 'options acer_wmi predator_v4=1' "$conf" 2>/dev/null ||
  fail "the migration fixes an install that never got the quirk" "$(ls -R "$test_tmp/etc" 2>&1)"
# The option only reaches the driver when acer_wmi next loads.
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that applies it" "$(cat "$calls")"
pass "the migration fixes an install that never got the quirk"

run_migration
(( $(grep -c 'predator_v4' "$conf") == 1 )) || fail "the migration is idempotent" "$(cat "$conf")"
[[ ! -s $calls ]] || fail "a fixed install is left untouched" "$(cat "$calls")"
pass "the migration is idempotent"

# Written without a trailing newline, the way a hand-edited config often is.
printf '%s' 'options acer_wmi ec_raw_mode=1' >"$conf"
run_migration
grep -qx 'options acer_wmi ec_raw_mode=1' "$conf" ||
  fail "the migration keeps other options in the config" "$(cat "$conf")"
grep -qx 'options acer_wmi predator_v4=1' "$conf" ||
  fail "the migration appends to a config without a trailing newline" "$(cat "$conf")"
pass "the migration appends to a config that holds other options"

set_dmi "Acer" "Nitro AN515-58"
rm -rf "${test_tmp:?}/etc"
run_migration
[[ ! -e $conf ]] || fail "the migration skips models the kernel already quirks" "$(cat "$conf")"
[[ ! -s $calls ]] || fail "the migration escalates nothing on other models" "$(cat "$calls")"
pass "the migration skips models the kernel already quirks"
