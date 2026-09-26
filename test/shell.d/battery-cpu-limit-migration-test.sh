#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-battery-cpu-limit"
leaf="$ROOT/install/hardware/intel/battery-cpu-limit.sh"
migration="$ROOT/migrations/1790406600.sh"

grep -Fq '# omarchy:summary=' "$helper" ||
  fail "battery cpu-limit helper documents its summary"
grep -Fq 'omarchy:hidden=true' "$helper" ||
  fail "battery cpu-limit helper stays out of the default command listing"
pass "battery cpu-limit helper declares valid command metadata"

grep -Fq 'hardware/intel/battery-cpu-limit.sh' "$ROOT/install/hardware/all.sh" ||
  fail "fresh installs run the battery cpu-limit hardware leaf"
pass "fresh installs wire the battery cpu-limit hardware leaf"

grep -Fq 'install/hardware/intel/battery-cpu-limit.sh' "$migration" ||
  fail "the migration shares the install leaf instead of duplicating it"
pass "the migration reuses the install leaf"

# --- helper against a fake sysfs ---

make_sysfs() {
  local root=$1 online=${2:-0}
  mkdir -p "$root/class/powercap/intel-rapl:0" "$root/class/power_supply/ADP1" "$root/class/power_supply/BAT0" "$root/devices/system/cpu/intel_pstate"
  printf '0' >"$root/devices/system/cpu/intel_pstate/no_turbo"
  printf '100' >"$root/devices/system/cpu/intel_pstate/max_perf_pct"
  printf '45000000' >"$root/class/powercap/intel-rapl:0/constraint_0_max_power_uw"
  printf '0' >"$root/class/powercap/intel-rapl:0/constraint_1_max_power_uw"
  printf 'Mains' >"$root/class/power_supply/ADP1/type"
  printf '%s' "$online" >"$root/class/power_supply/ADP1/online"
  printf 'Battery' >"$root/class/power_supply/BAT0/type"
}

run_helper() {
  OMARCHY_SYSFS_ROOT="$sysfs" OMARCHY_BATTERY_CPU_STATE_DIR="$state_dir" bash "$helper" "$@"
}

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
sysfs="$test_tmp/sys"
state_dir="$test_tmp/state"

make_sysfs "$sysfs" 0
run_helper 0 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 1 ]] ||
  fail "battery state disables turbo"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 50 ]] ||
  fail "battery state caps max performance at 50%"
[[ $(cat "$sysfs/class/powercap/intel-rapl:0/constraint_0_max_power_uw") == 25000000 ]] ||
  fail "battery state caps PL1 at 25W"
[[ $(cat "$sysfs/class/powercap/intel-rapl:0/constraint_1_max_power_uw") == 35000000 ]] ||
  fail "battery state caps PL2 at 35W"
[[ $(cat "$state_dir/no-turbo") == 0 ]] ||
  fail "first cap saves the live AC no-turbo default"
[[ $(cat "$state_dir/max-pct") == 100 ]] ||
  fail "first cap saves the live AC max-perf-pct default"
[[ $(cat "$state_dir/pl1") == 45000000 ]] ||
  fail "first cap saves the live AC PL1 default"
pass "battery state caps turbo, frequency, PL1, and PL2 and saves AC defaults"

run_helper 1 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "AC state restores no-turbo"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 100 ]] ||
  fail "AC state restores max-perf-pct"
[[ $(cat "$sysfs/class/powercap/intel-rapl:0/constraint_0_max_power_uw") == 45000000 ]] ||
  fail "AC state restores PL1"
[[ $(cat "$sysfs/class/powercap/intel-rapl:0/constraint_1_max_power_uw") == 0 ]] ||
  fail "AC state restores PL2"
pass "AC state restores the saved policy"

run_helper >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 1 ]] ||
  fail "arg-less run re-reads the discharging state"
make_sysfs "$sysfs" 1
run_helper >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "arg-less run re-reads the charging state"
pass "arg-less runs follow the power-supply state"

rm -rf "$sysfs" "$state_dir"
mkdir -p "$sysfs/class/power_supply/ADP1"
printf 'Mains' >"$sysfs/class/power_supply/ADP1/type"
run_helper 0 >/dev/null
pass "helper stays inert without Intel pstate"

rm -rf "$sysfs"
make_sysfs "$sysfs" 0
rm -rf "$sysfs/class/power_supply/BAT0"
run_helper 0 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "helper capped a machine with no battery"
pass "helper stays inert without a battery"

if run_helper 2 >/dev/null 2>&1; then fail "helper rejects states other than 0/1"; fi
pass "helper rejects invalid states"

rm -rf "$sysfs" "$state_dir"
make_sysfs "$sysfs" 0
chmod a-w "$sysfs/class/powercap/intel-rapl:0/constraint_0_max_power_uw" "$sysfs/class/powercap/intel-rapl:0/constraint_1_max_power_uw"
run_helper 0 >/dev/null 2>"$test_tmp/stderr" || fail "read-only RAPL aborts the whole cap"
grep -Fq 'PL1 not writable' "$test_tmp/stderr" || fail "read-only RAPL warns loudly"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 1 ]] ||
  fail "read-only RAPL skips the turbo and frequency cap"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 50 ]] ||
  fail "read-only RAPL skips the frequency cap"
run_helper 1 >/dev/null 2>&1
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "AC restore fails when RAPL is read-only"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 100 ]] ||
  fail "AC restore fails when RAPL is read-only"
pass "read-only RAPL warns but still caps turbo and frequency"

rm -rf "$sysfs" "$state_dir"
make_sysfs "$sysfs" 0
rm "$sysfs/class/powercap/intel-rapl:0/constraint_0_max_power_uw" "$sysfs/class/powercap/intel-rapl:0/constraint_1_max_power_uw"
run_helper 0 >/dev/null 2>&1 || fail "missing RAPL constraints abort the cap"
[[ $(cat "$state_dir/pl1") == unwritable ]] ||
  fail "missing RAPL constraints are recorded"
[[ $(cat "$state_dir/pl2") == unwritable ]] ||
  fail "missing RAPL constraints are recorded"
run_helper 1 >/dev/null 2>&1 || fail "AC restore fails when RAPL was never readable"
pass "missing RAPL constraints are recorded and skipped"

rm -rf "$sysfs" "$state_dir"
make_sysfs "$sysfs" 0
mkdir -p "$state_dir"
printf '0' >"$state_dir/no-turbo"
printf '1' >"$sysfs/devices/system/cpu/intel_pstate/no_turbo"
run_helper 0 >/dev/null 2>&1
[[ $(cat "$state_dir/no-turbo") == 0 ]] ||
  fail "a later knob re-snapshots an already-saved knob from capped state"
[[ $(cat "$state_dir/max-pct") == 100 ]] ||
  fail "a missing knob is still saved from live state"
pass "already-saved knobs survive later caps"

chmod a-w "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct"
if run_helper 0 >/dev/null 2>&1; then fail "unwritable max-perf-pct passes silently"; fi
pass "helper fails loudly when max-perf-pct cannot be written"

# --- migration end to end with stubs ---

mock_omarchy="$test_tmp/omarchy"
rule_dest="$test_tmp/udev-rules/99-omarchy-battery-cpu-limit.rules"
hook_dest="$test_tmp/system-sleep/battery-cpu-limit"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$mock_omarchy/default/udev" "$mock_omarchy/default/systemd/system-sleep" \
  "$mock_omarchy/install/hardware/intel" "$stub_bin"
cp "$ROOT/default/udev/battery-cpu-limit.rules" "$mock_omarchy/default/udev/"
cp "$ROOT/default/systemd/system-sleep/battery-cpu-limit" "$mock_omarchy/default/systemd/system-sleep/"
sed -e "s|/etc/udev/rules.d/99-omarchy-battery-cpu-limit.rules|$rule_dest|" \
  -e "s|/usr/lib/systemd/system-sleep/battery-cpu-limit|$hook_dest|" \
  "$leaf" >"$mock_omarchy/install/hardware/intel/battery-cpu-limit.sh"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat >"$stub_bin/udevadm" <<SH
#!/bin/bash
printf 'udevadm %s\n' "\$*" >>"$calls"
SH
cat >"$stub_bin/omarchy-hw-intel" <<SH
#!/bin/bash
(( \${INTEL_HARDWARE:-0} == 1 ))
SH
cat >"$stub_bin/omarchy-battery-present" <<SH
#!/bin/bash
(( \${LAPTOP_BATTERY:-0} == 1 ))
SH
chmod +x "$stub_bin/"*

run_migration() {
  : >"$calls"
  rm -f "$rule_dest" "$hook_dest"
  HOME="$test_tmp/home" PATH="$stub_bin:$PATH" OMARCHY_PATH="$mock_omarchy" bash -euo pipefail "$migration" >/dev/null
}

mkdir -p "$test_tmp/home"
INTEL_HARDWARE=1 LAPTOP_BATTERY=1 run_migration
[[ -f $rule_dest ]] || fail "migration publishes the udev rule on Intel laptops"
[[ -f $hook_dest ]] || fail "migration publishes the sleep hook on Intel laptops"
[[ -x $hook_dest ]] || fail "migration publishes an executable sleep hook"
grep -Fq 'omarchy-battery-cpu-limit' "$rule_dest" ||
  fail "published udev rule calls the cpu-limit helper"
grep -Fq 'control --reload-rules' "$calls" ||
  fail "migration reloads udev rules"
grep -Fq 'trigger --subsystem-match=power_supply' "$calls" ||
  fail "migration applies the cap immediately through a power-supply trigger"
pass "migration publishes the cap on Intel laptops with a battery"

: >"$calls"
INTEL_HARDWARE=1 LAPTOP_BATTERY=1 HOME="$test_tmp/home" PATH="$stub_bin:$PATH" OMARCHY_PATH="$mock_omarchy" bash -euo pipefail "$migration" >/dev/null
[[ ! -s $calls ]] || fail "migration repeats privileged work once the machine is repaired"
pass "migration no-ops once the machine is repaired"

INTEL_HARDWARE=0 LAPTOP_BATTERY=1 run_migration
[[ ! -e $rule_dest && ! -e $hook_dest && ! -s $calls ]] ||
  fail "migration touches non-Intel machines"
INTEL_HARDWARE=1 LAPTOP_BATTERY=0 run_migration
[[ ! -e $rule_dest && ! -e $hook_dest && ! -s $calls ]] ||
  fail "migration touches machines without a battery"
pass "migration stays inert where the cap does not apply"
