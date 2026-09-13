#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-intel-no-hwp"
apply="$ROOT/bin/omarchy-powerprofiles-intel-no-hwp-apply"
leaf="$ROOT/install/hardware/intel/cpu-profile-limits.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "cpu-profile-limits" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/intel/cpu-profile-limits.sh' "$all" ||
  fail "the CPU profile limits run during hardware setup"
pass "the CPU profile limits run during hardware setup"

[[ -n $migration ]] || fail "a migration enables the limits on existing installs"
pass "a migration enables the limits on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-intel" <<'SH'
#!/bin/bash
[[ ${TEST_IS_INTEL:-1} == 1 ]]
SH

cat >"$test_tmp/bin/logger" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$test_tmp/bin"/*

# --- detector -------------------------------------------------------------

make_cpuinfo() {
  local flags="$1"
  printf 'vendor_id\t: GenuineIntel\nflags\t\t: %s\n' "$flags" >"$test_tmp/cpuinfo"
}

make_cpu_root() {
  local root="$test_tmp/cpu"
  rm -rf "$root"
  mkdir -p "$root/intel_pstate" "$root/cpu0/cpufreq" "$root/cpu1/cpufreq"
  printf '0\n' >"$root/intel_pstate/no_turbo"
  printf '%s\n' "${1:-4000000}" >"$root/cpu0/cpufreq/cpuinfo_max_freq"
  printf '%s\n' "${2:-2800000}" >"$root/cpu0/cpufreq/scaling_max_freq"
  printf '%s\n' "${2:-2800000}" >"$root/cpu1/cpufreq/scaling_max_freq"
  echo "$root"
}

run_detector() {
  PATH="$test_tmp/bin:$PATH" \
    TEST_IS_INTEL="${1:-1}" \
    OMARCHY_CPUINFO="$test_tmp/cpuinfo" \
    OMARCHY_CPU_ROOT="${2:-$(make_cpu_root)}" \
    bash "$detector"
}

make_cpuinfo "fpu vme de pse tsc msr"
run_detector || fail "the detector matches an Intel CPU without HWP"
pass "the detector matches an Intel CPU without HWP"

make_cpuinfo "fpu vme de hwp hwp_notify hwp_act_window"
run_detector && fail "the detector rejects a CPU with HWP"
pass "the detector rejects a CPU with HWP"

make_cpuinfo "fpu vme de pse tsc msr"
run_detector 0 && fail "the detector rejects a non-Intel CPU"
pass "the detector rejects a non-Intel CPU"

run_detector 1 "$test_tmp/missing" && fail "the detector rejects a CPU without intel_pstate"
pass "the detector rejects a CPU without intel_pstate"

# --- apply ----------------------------------------------------------------

run_apply() {
  local root="$1" profile="$2"
  PATH="$test_tmp/bin:$PATH" OMARCHY_CPU_ROOT="$root" bash "$apply" "$profile"
}

root=$(make_cpu_root 4000000 2800000)
run_apply "$root" performance || fail "performance applies cleanly"
[[ $(<"$root/intel_pstate/no_turbo") == 0 ]] || fail "performance re-enables turbo"
[[ $(<"$root/cpu0/cpufreq/scaling_max_freq") == 4000000 ]] || fail "performance uses full turbo"
pass "performance uses full turbo"

root=$(make_cpu_root 4000000 2800000)
run_apply "$root" balanced || fail "balanced applies cleanly"
[[ $(<"$root/intel_pstate/no_turbo") == 0 ]] || fail "balanced keeps turbo enabled"
[[ $(<"$root/cpu0/cpufreq/scaling_max_freq") == 3400000 ]] ||
  fail "balanced caps midway between base and turbo"
pass "balanced caps midway between base and turbo"

root=$(make_cpu_root 4000000 2800000)
run_apply "$root" power-saver || fail "power-saver applies cleanly"
[[ $(<"$root/intel_pstate/no_turbo") == 1 ]] || fail "power-saver disables turbo"
pass "power-saver disables turbo"

# Every core must be capped, not just cpu0.
root=$(make_cpu_root 4000000 2800000)
run_apply "$root" balanced
[[ $(<"$root/cpu1/cpufreq/scaling_max_freq") == 3400000 ]] ||
  fail "the cap applies to every core"
pass "the cap applies to every core"

# A different SKU must derive its own frequencies rather than reuse constants.
root=$(make_cpu_root 3600000 2400000)
run_apply "$root" balanced
[[ $(<"$root/cpu0/cpufreq/scaling_max_freq") == 3000000 ]] ||
  fail "the frequencies derive from the CPU rather than a model table"
pass "the frequencies derive from the CPU rather than a model table"

root=$(make_cpu_root 4000000 2800000)
run_apply "$root" nonsense 2>/dev/null && fail "an unknown profile fails"
pass "an unknown profile fails"

root=$(make_cpu_root 4000000 2800000)
chmod -w "$root/intel_pstate/no_turbo"
run_apply "$root" balanced || fail "a read-only pstate is a no-op rather than an error"
pass "a read-only pstate is a no-op rather than an error"
chmod +w "$root/intel_pstate/no_turbo"

# --- leaf -----------------------------------------------------------------
#
# Grep-only coverage caught none of the ordering bugs this branch shipped
# with: a watch unit that cycled against multi-user.target through the real
# power-profiles-daemon.service unit, and a "resume" unit that was never
# actually a post-resume hook. Actually run the leaf against a faked root and
# inspect what it generates, then hand the real generated unit to
# `systemd-analyze verify` together with the real target units, the same way
# the original cycle was found and confirmed fixed by hand.

grep -q 'omarchy-hw-intel-no-hwp' "$leaf" || fail "the leaf gates on the detector"
grep -q 'omarchy-battery-present' "$leaf" || fail "the leaf gates on a battery"
pass "the leaf gates on the detector and a battery"

sleep_hook="$ROOT/default/systemd/system-sleep/powerprofiles-intel-no-hwp"
[[ -x $sleep_hook ]] || fail "the resume hook exists and is executable"
grep -qE '^\s*if \[\[ \$1 == "post" \]\]; then$' "$sleep_hook" ||
  fail "the resume hook only fires on the post-resume call, not pre-suspend"
pass "the resume hook exists, is executable, and only fires post-resume"

leaf_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp" "$leaf_tmp"' EXIT
mkdir -p "$leaf_tmp/bin" "$leaf_tmp/etc/systemd/system" "$leaf_tmp/usr/lib/systemd/system-sleep"
calls="$leaf_tmp/calls.log"

cat >"$leaf_tmp/bin/omarchy-hw-intel-no-hwp" <<'SH'
#!/bin/bash
[[ ${LEAF_MATCH:-1} == 1 ]]
SH

cat >"$leaf_tmp/bin/omarchy-battery-present" <<'SH'
#!/bin/bash
[[ ${LEAF_BATTERY:-1} == 1 ]]
SH

cat >"$leaf_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
exec "$@"
SH

cat >"$leaf_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

# The real `install -o root -g root` fails for a non-root test user; log the
# call and copy the file, dropping ownership (mode is what the test cares
# about) rather than chowning.
cat >"$leaf_tmp/bin/install" <<'SH'
#!/bin/bash
printf 'install' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

mode=0644
args=("$@")
last=$((${#args[@]} - 1))
src="${args[$((last - 1))]}"
dst="${args[$last]}"

for ((i = 0; i < last - 1; i++)); do
  [[ ${args[$i]} == -m ]] && mode="${args[$((i + 1))]}"
done

cp -f -- "$src" "$dst" && chmod "$mode" -- "$dst"
SH

chmod +x "$leaf_tmp/bin"/*

unit="$leaf_tmp/etc/systemd/system/omarchy-powerprofiles-intel-no-hwp-watch.service"
installed_hook="$leaf_tmp/usr/lib/systemd/system-sleep/powerprofiles-intel-no-hwp"

run_leaf() {
  local script="$leaf_tmp/leaf.sh"
  rm -f "$unit" "$installed_hook"
  : >"$calls"
  sed -e "s|/etc/systemd/system|$leaf_tmp/etc/systemd/system|g" \
    -e "s|/usr/lib/systemd/system-sleep|$leaf_tmp/usr/lib/systemd/system-sleep|g" \
    "$leaf" >"$script"
  LEAF_MATCH="${1:-1}" LEAF_BATTERY="${2:-1}" OMARCHY_PATH="$ROOT" \
    TEST_LOG="$calls" PATH="$leaf_tmp/bin:$PATH" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

run_leaf 0 1 >/dev/null
[[ ! -f $unit ]] || fail "the leaf is a no-op without matching hardware"
pass "the leaf is a no-op without matching hardware"

run_leaf 1 0 >/dev/null
[[ ! -f $unit ]] || fail "the leaf is a no-op without a battery"
pass "the leaf is a no-op without a battery"

run_leaf 1 1 >/dev/null
[[ -f $unit ]] || fail "matching hardware gets the watch unit installed"
grep -qE '^After=dbus\.service$' "$unit" ||
  fail "the generated unit orders after dbus.service"
grep -qE '^(After|Wants)=.*power-profiles-daemon' "$unit" &&
  fail "the generated unit must not order after/want power-profiles-daemon.service directly: the packaged unit is itself After=multi-user.target while this unit is (implicitly) Before=multi-user.target, so that ordering is a cycle systemd breaks by dropping this unit's start job" "$(cat "$unit")"
grep -q $'systemctl\tenable\tomarchy-powerprofiles-intel-no-hwp-watch.service' "$calls" ||
  fail "the watch unit gets enabled" "$(cat "$calls")"
[[ -x $installed_hook ]] || fail "the resume hook is installed and made executable"
cmp -s "$installed_hook" "$sleep_hook" ||
  fail "the installed hook is the repo's copy, not a divergent inline one"
pass "matching hardware installs the watch unit (ordered after dbus, not PPD) and the resume hook"

# Re-running must not fail or duplicate anything -- an existing install
# running the migration, or a fresh install re-running hardware setup.
run_leaf 1 1 >/dev/null
[[ -f $unit && -x $installed_hook ]] || fail "re-running the leaf is idempotent"
pass "re-running the leaf is idempotent"

if command -v systemd-analyze >/dev/null; then
  check_unit="$leaf_tmp/check.service"
  sed 's#^ExecStart=.*#ExecStart=/usr/bin/true#' "$unit" >"$check_unit"

  # Force the real power-profiles-daemon.service and its targets into the
  # graph: verifying the generated unit in isolation resolves referenced
  # units too shallowly to reproduce the cycle this test guards against.
  cycle_output=$(systemd-analyze verify multi-user.target graphical.target \
    power-profiles-daemon.service "$check_unit" 2>&1) || true
  [[ $cycle_output != *"ordering cycle"* ]] ||
    fail "the generated unit has an ordering cycle against the real power-profiles-daemon.service unit" "$cycle_output"
  pass "the generated unit has no ordering cycle against the real power-profiles-daemon.service unit"
else
  pass "systemd-analyze unavailable; skipping the live ordering-cycle check"
fi
