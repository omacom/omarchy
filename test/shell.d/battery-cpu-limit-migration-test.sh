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
  chmod -R u+w "$root" 2>/dev/null || true
  rm -rf "$root"
  mkdir -p "$root/class/powercap/intel-rapl:0" "$root/class/power_supply/ADP1" "$root/class/power_supply/BAT0" "$root/devices/system/cpu/intel_pstate"
  printf '0' >"$root/devices/system/cpu/intel_pstate/no_turbo"
  printf '100' >"$root/devices/system/cpu/intel_pstate/max_perf_pct"
  # Writable limits at the firmware defaults of a MacBookPro16,1, plus the
  # read-only hardware ceiling the helper must never target.
  printf '100000000' >"$root/class/powercap/intel-rapl:0/constraint_0_power_limit_uw"
  printf '125000000' >"$root/class/powercap/intel-rapl:0/constraint_1_power_limit_uw"
  printf '45000000' >"$root/class/powercap/intel-rapl:0/constraint_0_max_power_uw"
  printf '0' >"$root/class/powercap/intel-rapl:0/constraint_1_max_power_uw"
  chmod a-w "$root/class/powercap/intel-rapl:0/constraint_0_max_power_uw" "$root/class/powercap/intel-rapl:0/constraint_1_max_power_uw"
  printf 'Mains' >"$root/class/power_supply/ADP1/type"
  printf '%s' "$online" >"$root/class/power_supply/ADP1/online"
  printf 'Battery' >"$root/class/power_supply/BAT0/type"
}

run_helper() {
  OMARCHY_SYSFS_ROOT="$sysfs" OMARCHY_BATTERY_CPU_STATE_DIR="$state_dir" bash "$helper" "$@"
}

test_tmp=$(mktemp -d)
trap 'chmod -R u+w "$test_tmp"; rm -rf "$test_tmp"' EXIT
sysfs="$test_tmp/sys"
state_dir="$test_tmp/state"
rapl="$sysfs/class/powercap/intel-rapl:0"

reset_sysfs() {
  chmod -R u+w "$sysfs" 2>/dev/null || true
  rm -rf "$sysfs" "$state_dir"
}

make_sysfs "$sysfs" 0
run_helper 0 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 1 ]] ||
  fail "battery state disables turbo"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 50 ]] ||
  fail "battery state caps max performance at 50%"
[[ $(cat "$rapl/constraint_0_power_limit_uw") == 25000000 ]] ||
  fail "battery state caps PL1 at 25W"
[[ $(cat "$rapl/constraint_1_power_limit_uw") == 35000000 ]] ||
  fail "battery state caps PL2 at 35W"
[[ $(cat "$rapl/constraint_0_max_power_uw") == 45000000 && $(cat "$rapl/constraint_1_max_power_uw") == 0 ]] ||
  fail "battery state wrote the read-only RAPL ceiling instead of the limit"
[[ $(cat "$state_dir/no-turbo") == 0 ]] ||
  fail "first cap saves the live AC no-turbo default"
[[ $(cat "$state_dir/max-pct") == 100 ]] ||
  fail "first cap saves the live AC max-perf-pct default"
[[ $(cat "$state_dir/pl1") == 100000000 ]] ||
  fail "first cap saves the live AC PL1 limit, not the ceiling"
[[ $(cat "$state_dir/pl2") == 125000000 ]] ||
  fail "first cap saves the live AC PL2 limit"
pass "battery state caps turbo, frequency, PL1, and PL2 and saves AC defaults"

run_helper 1 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "AC state restores no-turbo"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 100 ]] ||
  fail "AC state restores max-perf-pct"
[[ $(cat "$rapl/constraint_0_power_limit_uw") == 100000000 ]] ||
  fail "AC state restores PL1"
[[ $(cat "$rapl/constraint_1_power_limit_uw") == 125000000 ]] ||
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

reset_sysfs
mkdir -p "$sysfs/class/power_supply/ADP1"
printf 'Mains' >"$sysfs/class/power_supply/ADP1/type"
run_helper 0 >/dev/null
pass "helper stays inert without Intel pstate"

reset_sysfs
make_sysfs "$sysfs" 0
rm "$sysfs/devices/system/cpu/intel_pstate/no_turbo"
run_helper 0 >/dev/null || fail "helper fails where intel_pstate lacks no_turbo"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 100 ]] ||
  fail "helper capped a machine whose intel_pstate lacks no_turbo"
pass "helper stays inert without the intel_pstate knobs"

reset_sysfs
make_sysfs "$sysfs" 0
rm -rf "$sysfs/class/power_supply/BAT0"
run_helper 0 >/dev/null
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "helper capped a machine with no battery"
pass "helper stays inert without a battery"

if run_helper 2 >/dev/null 2>&1; then fail "helper rejects states other than 0/1"; fi
pass "helper rejects invalid states"

reset_sysfs
make_sysfs "$sysfs" 0
chmod a-w "$rapl/constraint_0_power_limit_uw" "$rapl/constraint_1_power_limit_uw"
run_helper 0 >/dev/null 2>"$test_tmp/stderr" || fail "BIOS-locked RAPL aborts the whole cap"
grep -Fq 'PL1 not writable' "$test_tmp/stderr" || fail "BIOS-locked RAPL warns loudly"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 1 ]] ||
  fail "BIOS-locked RAPL skips the turbo cap"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 50 ]] ||
  fail "BIOS-locked RAPL skips the frequency cap"
run_helper 1 >/dev/null 2>&1 || fail "AC restore fails when RAPL is BIOS-locked"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/no_turbo") == 0 ]] ||
  fail "AC restore skips no-turbo when RAPL is BIOS-locked"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 100 ]] ||
  fail "AC restore skips max-perf-pct when RAPL is BIOS-locked"
pass "BIOS-locked RAPL warns but still caps turbo and frequency"

reset_sysfs
make_sysfs "$sysfs" 0
rm -f "$rapl/"constraint_*
run_helper 0 >/dev/null 2>"$test_tmp/stderr" || fail "missing RAPL aborts the cap"
grep -Fq 'PL1 not available' "$test_tmp/stderr" || fail "missing RAPL warns"
[[ ! -e $state_dir/pl1 && ! -e $state_dir/pl2 ]] ||
  fail "missing RAPL saves a bogus AC limit"
[[ $(cat "$sysfs/devices/system/cpu/intel_pstate/max_perf_pct") == 50 ]] ||
  fail "missing RAPL skips the frequency cap"
run_helper 1 >/dev/null 2>&1 || fail "AC restore fails without RAPL"
pass "missing RAPL is skipped and never restored"

# Boot on battery: the Mains add event runs before intel_rapl_common registers
# the package zone, then the powercap add event re-runs the helper with no args.
reset_sysfs
make_sysfs "$sysfs" 0
mv "$rapl" "$test_tmp/rapl-late"
run_helper 0 >/dev/null 2>&1 || fail "boot-time cap fails before RAPL registers"
mv "$test_tmp/rapl-late" "$rapl"
run_helper >/dev/null 2>&1 || fail "powercap add re-run fails"
[[ $(cat "$rapl/constraint_0_power_limit_uw") == 25000000 && $(cat "$rapl/constraint_1_power_limit_uw") == 35000000 ]] ||
  fail "late RAPL registration leaves the firmware PL1/PL2 in force"
[[ $(cat "$state_dir/pl1") == 100000000 && $(cat "$state_dir/pl2") == 125000000 ]] ||
  fail "late RAPL registration saves the capped limits as AC defaults"
grep -Fq 'SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", ACTION=="add"' "$ROOT/default/udev/battery-cpu-limit.rules" ||
  fail "udev rule does not re-apply once the RAPL zone registers"
pass "a RAPL zone registered after the Mains event still gets capped"

reset_sysfs
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
dropin_dest="$test_tmp/systemd/thermald.service.d/battery-cpu-limit.conf"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$mock_omarchy/default/udev" "$mock_omarchy/default/systemd/system-sleep" \
  "$mock_omarchy/default/systemd/system/thermald.service.d" \
  "$mock_omarchy/install/hardware/intel" "$stub_bin"
cp "$ROOT/default/udev/battery-cpu-limit.rules" "$mock_omarchy/default/udev/"
cp "$ROOT/default/systemd/system-sleep/battery-cpu-limit" "$mock_omarchy/default/systemd/system-sleep/"
cp "$ROOT/default/systemd/system/thermald.service.d/battery-cpu-limit.conf" "$mock_omarchy/default/systemd/system/thermald.service.d/"
sed -e "s|/etc/udev/rules.d/99-omarchy-battery-cpu-limit.rules|$rule_dest|" \
  -e "s|/usr/lib/systemd/system-sleep/battery-cpu-limit|$hook_dest|" \
  -e "s|/etc/systemd/system/thermald.service.d/battery-cpu-limit.conf|$dropin_dest|" \
  "$leaf" >"$mock_omarchy/install/hardware/intel/battery-cpu-limit.sh"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat >"$stub_bin/udevadm" <<SH
#!/bin/bash
printf 'udevadm %s\n' "\$*" >>"$calls"
SH
cat >"$stub_bin/systemctl" <<SH
#!/bin/bash
printf 'systemctl %s\n' "\$*" >>"$calls"
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
  rm -f "$rule_dest" "$hook_dest" "$dropin_dest"
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

[[ -f $dropin_dest ]] || fail "migration publishes the thermald drop-in"
grep -Fq 'ExecStartPre=-' "$dropin_dest" ||
  fail "thermald drop-in applies the cap before thermald starts without blocking it"
grep -Fq '/usr/bin/omarchy-battery-cpu-limit' "$dropin_dest" ||
  fail "thermald drop-in calls the cpu-limit helper"
grep -Fq 'systemctl daemon-reload' "$calls" ||
  fail "migration reloads systemd for the thermald drop-in"
grep -Fq 'systemctl try-restart thermald.service' "$calls" ||
  fail "migration re-baselines a running thermald on the cap"
pass "migration makes thermald snapshot the capped PL1"

: >"$calls"
INTEL_HARDWARE=1 LAPTOP_BATTERY=1 HOME="$test_tmp/home" PATH="$stub_bin:$PATH" OMARCHY_PATH="$mock_omarchy" bash -euo pipefail "$migration" >/dev/null
[[ ! -s $calls ]] || fail "migration repeats privileged work once the machine is repaired"
pass "migration no-ops once the machine is repaired"

INTEL_HARDWARE=0 LAPTOP_BATTERY=1 run_migration
[[ ! -e $rule_dest && ! -e $hook_dest && ! -e $dropin_dest && ! -s $calls ]] ||
  fail "migration touches non-Intel machines"
INTEL_HARDWARE=1 LAPTOP_BATTERY=0 run_migration
[[ ! -e $rule_dest && ! -e $hook_dest && ! -e $dropin_dest && ! -s $calls ]] ||
  fail "migration touches machines without a battery"
pass "migration stays inert where the cap does not apply"
