#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/battery-floor"
setup="$ROOT/bin/omarchy-battery-floor-setup"
remove="$ROOT/bin/omarchy-battery-floor-remove"

[[ -f $hook ]] || fail "battery-floor hook source exists" "$hook"
pass "battery-floor hook source exists"

[[ -f $setup ]] || fail "battery-floor setup command exists" "$setup"
pass "battery-floor setup command exists"

[[ -f $remove ]] || fail "battery-floor remove command exists" "$remove"
pass "battery-floor remove command exists"

# The hook decides from helpers, never from hardcoded device names: LID0/ACAD
# style names are one board's; logind-era helpers glob instead.
grep -Fq 'omarchy-hw-laptop-closed' "$hook" ||
  fail "battery floor reads the lid through the laptop helper"
pass "battery floor reads the lid through the laptop helper"

grep -Fq 'omarchy-power-present' "$hook" ||
  fail "battery floor reads AC through the power helper"
pass "battery floor reads AC through the power helper"

grep -Fq 'omarchy-battery-present' "$hook" ||
  fail "battery floor stays inert without a battery"
pass "battery floor stays inert without a battery"

grep -Eq 'LID[0-9]|ACAD|/sys/class/power_supply/AC' "$hook" &&
  fail "battery floor names no lid or charger device directly"
pass "battery floor names no lid or charger device directly"

grep -Fq 'rtcwake' "$hook" ||
  fail "battery floor arms an RTC self-wake"
pass "battery floor arms an RTC self-wake"

grep -Fq 'systemd-run' "$hook" ||
  fail "battery floor defers its decision outside the suspend job"
pass "battery floor defers its decision outside the suspend job"

grep -Fq 'poweroff' "$hook" ||
  fail "battery floor powers off a bagged laptop on battery"
pass "battery floor powers off a bagged laptop on battery"

# Setup is explicit opt-in: powering off is destructive, so it confirms,
# yields to hibernation, and needs a battery.
grep -Fq 'gum confirm' "$setup" ||
  fail "battery-floor setup confirms before installing"
pass "battery-floor setup confirms before installing"

grep -Fq 'omarchy-hibernation-available' "$setup" ||
  fail "battery-floor setup yields to hibernation"
pass "battery-floor setup yields to hibernation"

grep -Fq 'omarchy-battery-present' "$setup" ||
  fail "battery-floor setup needs a battery"
pass "battery-floor setup needs a battery"

grep -Fq '/usr/lib/systemd/system-sleep/battery-floor' "$setup" ||
  fail "battery-floor setup installs the hook where systemd reads it"
pass "battery-floor setup installs the hook where systemd reads it"

grep -Fq '/usr/lib/systemd/system-sleep/battery-floor' "$remove" ||
  fail "battery-floor remove cleans the hook"
pass "battery-floor remove cleans the hook"

bash -n "$hook" || fail "battery-floor hook parses"
pass "battery-floor hook parses"

bash -n "$setup" || fail "battery-floor setup parses"
pass "battery-floor setup parses"

bash -n "$remove" || fail "battery-floor remove parses"
pass "battery-floor remove parses"

# Functional: the deadline logic, the post-resume stand-down table, and the
# deferred act decision, with every helper stubbed.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
floor_dir="$test_tmp/floor"
mkdir -p "$stub_bin" "$floor_dir"
: >"$calls"

# Each helper exits per its STUB_* switch so the matrix below drives the hook
# without touching real sysfs. The date stub plus NOW_OFFSET drives the clock
# so expired and pending deadlines can be tested without waiting.
for helper in omarchy-battery-present omarchy-hw-laptop-closed \
  omarchy-hw-external-monitors omarchy-power-present; do
  switch=$(printf '%s' "$helper" | tr 'a-z-' 'A-Z_')
  cat >"$stub_bin/$helper" <<SH
#!/bin/bash
(( \${STUB_${switch}:-0} == 1 ))
SH
done
cat >"$stub_bin/rtcwake" <<'SH'
#!/bin/bash
printf 'rtcwake\t%s\n' "$*" >>"$CALLS"
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl\t%s\n' "$*" >>"$CALLS"
SH
cat >"$stub_bin/systemd-run" <<'SH'
#!/bin/bash
printf 'systemd-run\t%s\n' "$*" >>"$CALLS"
SH
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/date" <<'SH'
#!/bin/bash
# The absolute real binary: `command date` would resolve back through the
# stub-first PATH into this same script and recurse until the fork limit.
echo $(( $(/usr/bin/date +%s) + ${NOW_OFFSET:-0} ))
SH
chmod +x "$stub_bin"/*

# The hook names system tools by absolute /usr/bin path (repo convention),
# which PATH stubs cannot intercept, so exercise a copy with that prefix
# redirected into the sandbox. The omarchy-* helpers stay bare names and
# resolve through PATH as on a real machine.
sandboxed_hook="$test_tmp/battery-floor"
sed "s|/usr/bin/|$stub_bin/|g" "$hook" >"$sandboxed_hook"
chmod +x "$sandboxed_hook"

deadline_file="$floor_dir/deadline"

run_hook() {
  : >"$calls"
  CALLS="$calls" NOW_OFFSET="${NOW_OFFSET:-0}" \
    OMARCHY_BATTERY_FLOOR_DIR="$floor_dir" \
    PATH="$stub_bin:$PATH" "$sandboxed_hook" "$@" >/dev/null 2>&1
}

# No battery anywhere: fully inert, pre and post.
export STUB_OMARCHY_BATTERY_PRESENT=0
run_hook pre suspend
[[ ! -s $calls && ! -f $deadline_file ]] || fail "hook without a battery arms nothing" "$(cat "$calls")"
run_hook post suspend
[[ ! -s $calls ]] || fail "hook without a battery decides nothing" "$(cat "$calls")"
pass "the hook is inert without a battery"

export STUB_OMARCHY_BATTERY_PRESENT=1

# Pre suspend with the lid shut: records the deadline and arms the self-wake.
export STUB_OMARCHY_HW_LAPTOP_CLOSED=1 STUB_OMARCHY_HW_EXTERNAL_MONITORS=0
run_hook pre suspend
grep -Fq $'rtcwake\t-m no -s 1200' "$calls" ||
  fail "pre suspend with the lid shut arms a 20min RTC self-wake" "$(cat "$calls")"
[[ -s $deadline_file ]] || fail "pre suspend records the floor deadline"
pass "pre suspend with the lid shut arms a 20min RTC self-wake"

# Pre with the lid open: no bag to guard, nothing armed.
rm -f "$deadline_file"
STUB_OMARCHY_HW_LAPTOP_CLOSED=0 run_hook pre suspend
[[ ! -s $calls && ! -f $deadline_file ]] || fail "pre with an open lid arms nothing" "$(cat "$calls")"
pass "pre with an open lid arms nothing"

# Pre with the lid open cancels a countdown a previous lid-shut suspend left.
run_hook pre suspend
STUB_OMARCHY_HW_LAPTOP_CLOSED=0 run_hook pre suspend
grep -Fq $'rtcwake\t-m disable' "$calls" ||
  fail "an open-lid suspend cancels a leftover countdown" "$(cat "$calls")"
[[ ! -f $deadline_file ]] || fail "an open-lid suspend clears the leftover deadline"
pass "an open-lid suspend cancels a leftover countdown"

# Pre hibernate leaves hibernate alone.
rm -f "$deadline_file"
STUB_OMARCHY_HW_LAPTOP_CLOSED=1 run_hook pre hibernate
[[ ! -s $calls ]] || fail "pre hibernate leaves hibernate alone" "$(cat "$calls")"
pass "pre hibernate leaves hibernate alone"

# Post with no deadline: a wake that is not ours (unmanaged suspend, or the
# floor already consumed) changes nothing.
rm -f "$deadline_file"
run_hook post suspend
[[ ! -s $calls ]] || fail "a wake without an armed deadline is ignored" "$(cat "$calls")"
pass "a wake without an armed deadline is ignored"

# Early wake (deadline still pending), lid shut: re-arm the remaining time,
# keep the deadline, decide nothing.
run_hook pre suspend
run_hook post suspend
grep -Eq $'rtcwake\t-m no -s 1[0-9]{2}' "$calls" ||
  fail "an early wake re-arms the remaining countdown" "$(cat "$calls")"
[[ -f $deadline_file ]] || fail "an early wake keeps the deadline"
! grep -q 'systemd-run\|systemctl' "$calls" ||
  fail "an early wake acts before the deadline" "$(cat "$calls")"
pass "an early wake re-arms the remaining countdown"

# Early wake with the lid open: cancel the countdown entirely.
STUB_OMARCHY_HW_LAPTOP_CLOSED=0 run_hook post suspend
grep -Fq $'rtcwake\t-m disable' "$calls" ||
  fail "an early wake with an open lid disarms the alarm" "$(cat "$calls")"
[[ ! -f $deadline_file ]] || fail "an early wake with an open lid clears the deadline"
pass "an early wake with an open lid cancels the countdown"

# Deadline expired: consume it, disarm, and schedule the deferred decision
# without deciding or acting inside the hook itself.
run_hook pre suspend
NOW_OFFSET=1300 run_hook post suspend
grep -Fq $'rtcwake\t-m disable' "$calls" ||
  fail "an expired deadline disarms the alarm" "$(cat "$calls")"
grep -q 'systemd-run' "$calls" ||
  fail "an expired deadline schedules the deferred decision" "$(cat "$calls")"
[[ ! -f $deadline_file ]] || fail "an expired deadline is consumed"
! grep -q $'systemctl\t' "$calls" ||
  fail "the hook never acts inside the suspend job" "$(cat "$calls")"
pass "an expired deadline schedules the deferred decision"

# The deferred decision (the transient unit's phase), lid shut and undocked:
# on AC it suspends again; on battery it is the floor.
export STUB_OMARCHY_HW_LAPTOP_CLOSED=1 STUB_OMARCHY_HW_EXTERNAL_MONITORS=0

export STUB_OMARCHY_POWER_PRESENT=1
run_hook act
grep -Fxq $'systemctl\tsuspend' "$calls" ||
  fail "a lid-shut decision on AC suspends again" "$(cat "$calls")"
pass "a lid-shut decision on AC suspends again"

export STUB_OMARCHY_POWER_PRESENT=0
run_hook act
grep -Fxq $'systemctl\tpoweroff' "$calls" ||
  fail "a lid-shut decision on battery powers off" "$(cat "$calls")"
pass "a lid-shut decision on battery powers off"

# Someone opened the lid while the decision settled: stand down.
STUB_OMARCHY_HW_LAPTOP_CLOSED=0 run_hook act
[[ ! -s $calls ]] || fail "an opened lid during the decision stands down" "$(cat "$calls")"
pass "an opened lid during the decision stands down"

# Docked clamshell: somebody is using it; leave it alone.
export STUB_OMARCHY_HW_LAPTOP_CLOSED=1 STUB_OMARCHY_HW_EXTERNAL_MONITORS=1
run_hook act
[[ ! -s $calls ]] || fail "a docked decision stands down" "$(cat "$calls")"
pass "a docked decision stands down"
