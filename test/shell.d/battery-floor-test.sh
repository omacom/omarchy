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

# Functional: the post-resume decision table, with every helper stubbed.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

# Each helper exits per its STUB_* switch so the matrix below drives the hook
# without touching real sysfs, and sleep is instant.
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
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin"/*

# The hook names system tools by absolute /usr/bin path (repo convention),
# which PATH stubs cannot intercept, so exercise a copy with that prefix
# redirected into the sandbox. The omarchy-* helpers stay bare names and
# resolve through PATH as on a real machine.
sandboxed_hook="$test_tmp/battery-floor"
sed "s|/usr/bin/|$stub_bin/|g" "$hook" >"$sandboxed_hook"
chmod +x "$sandboxed_hook"

run_hook() {
  : >"$calls"
  CALLS="$calls" PATH="$stub_bin:$PATH" "$sandboxed_hook" "$@" >/dev/null 2>&1
}

# No battery anywhere: fully inert, pre and post.
STUB_OMARCHY_BATTERY_PRESENT=0 run_hook pre suspend
[[ ! -s $calls ]] || fail "hook without a battery arms nothing" "$(cat "$calls")"
STUB_OMARCHY_BATTERY_PRESENT=0 run_hook post suspend
[[ ! -s $calls ]] || fail "hook without a battery decides nothing" "$(cat "$calls")"
pass "the hook is inert without a battery"

export STUB_OMARCHY_BATTERY_PRESENT=1

# Pre suspend arms the self-wake; pre hibernate leaves hibernate alone.
run_hook pre suspend
grep -Fq $'rtcwake\t-m no -s 1200' "$calls" ||
  fail "pre suspend arms a 20min RTC self-wake" "$(cat "$calls")"
pass "pre suspend arms a 20min RTC self-wake"

run_hook pre hibernate
[[ ! -s $calls ]] || fail "pre hibernate leaves hibernate alone" "$(cat "$calls")"
pass "pre hibernate leaves hibernate alone"

# Lid open on resume: somebody woke it, do nothing.
export STUB_OMARCHY_HW_LAPTOP_CLOSED=0
run_hook post suspend
[[ ! -s $calls ]] || fail "an opened lid wakes normally" "$(cat "$calls")"
pass "an opened lid wakes normally"

# Docked with the lid shut: clamshell session still in use, do nothing.
export STUB_OMARCHY_HW_LAPTOP_CLOSED=1 STUB_OMARCHY_HW_EXTERNAL_MONITORS=1
run_hook post suspend
[[ ! -s $calls ]] || fail "a docked lid stays awake" "$(cat "$calls")"
pass "a docked lid stays awake"

export STUB_OMARCHY_HW_EXTERNAL_MONITORS=0

# Lid shut on AC: back to sleep; the next pre rearms the alarm.
export STUB_OMARCHY_POWER_PRESENT=1
run_hook post suspend
grep -Fxq $'systemctl\tsuspend' "$calls" ||
  fail "a lid-shut resume on AC suspends again" "$(cat "$calls")"
pass "a lid-shut resume on AC suspends again"

# Lid shut on battery: the floor.
export STUB_OMARCHY_POWER_PRESENT=0
run_hook post suspend
grep -Fxq $'systemctl\tpoweroff' "$calls" ||
  fail "a lid-shut resume on battery powers off" "$(cat "$calls")"
pass "a lid-shut resume on battery powers off"
