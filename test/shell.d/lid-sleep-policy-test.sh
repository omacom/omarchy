#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lid_source="$ROOT/default/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"
sleep_source="$ROOT/default/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf"
setup="$ROOT/bin/omarchy-hibernation-setup"
remove="$ROOT/bin/omarchy-hibernation-remove"
migration="$ROOT/migrations/1789568195.sh"

[[ -f $lid_source ]] || fail "lid-close logind source exists" "$lid_source"
pass "lid-close logind source exists"

[[ -f $sleep_source ]] || fail "suspend-then-hibernate sleep source exists" "$sleep_source"
pass "suspend-then-hibernate sleep source exists"

# Battery lid-close suspends first (lid-open wakes), AC stays in suspend
# (no LID wakeup from S4 on most firmware), docked stays awake for clamshell.
grep -q "^HandleLidSwitch=suspend-then-hibernate$" "$lid_source" ||
  fail "battery lid-close is suspend-then-hibernate"
pass "battery lid-close is suspend-then-hibernate"

grep -q "^HandleLidSwitchExternalPower=suspend$" "$lid_source" ||
  fail "AC lid-close stays in suspend for lid-open wake"
pass "AC lid-close stays in suspend for lid-open wake"

grep -q "^HandleLidSwitchDocked=ignore$" "$lid_source" ||
  fail "docked lid-close is ignored for clamshell mode"
pass "docked lid-close is ignored for clamshell mode"

grep -q "^HibernateDelaySec=20min$" "$sleep_source" ||
  fail "battery hibernate delay is 20min"
pass "battery hibernate delay is 20min"

grep -q "^HibernateOnACPower=no$" "$sleep_source" ||
  fail "manual suspend-then-hibernate stays suspended on AC"
pass "manual suspend-then-hibernate stays suspended on AC"

# Setup installs both policies before the resume marker so failure stays retryable.
grep -Fq 'default/systemd/logind.conf.d/99-omarchy-lid-sleep.conf' "$setup" ||
  fail "hibernation setup installs the lid-close policy"
pass "hibernation setup installs the lid-close policy"

grep -Fq 'default/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf' "$setup" ||
  fail "hibernation setup installs the sleep policy"
pass "hibernation setup installs the sleep policy"

# Remove cleans up both policies.
grep -Fq '/etc/systemd/logind.conf.d/99-omarchy-lid-sleep.conf' "$remove" ||
  fail "hibernation remove cleans the lid-close policy"
pass "hibernation remove cleans the lid-close policy"

grep -Fq '/etc/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf' "$remove" ||
  fail "hibernation remove cleans the sleep policy"
pass "hibernation remove cleans the sleep policy"

bash -n "$setup" || fail "hibernation setup parses"
pass "hibernation setup parses"

bash -n "$remove" || fail "hibernation remove parses"
pass "hibernation remove parses"

# Existing hibernation setups hit setup's "already set up" early exit before
# the new policy install, so a migration backfills both files for them.
[[ -f $migration ]] || fail "lid-close policy migration exists" "$migration"
pass "lid-close policy migration exists"

grep -Fq 'default/systemd/logind.conf.d/99-omarchy-lid-sleep.conf' "$migration" ||
  fail "policy migration installs the lid-close policy"
pass "policy migration installs the lid-close policy"

grep -Fq 'default/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf' "$migration" ||
  fail "policy migration installs the sleep policy"
pass "policy migration installs the sleep policy"

grep -Fq 'omarchy_resume.conf' "$migration" ||
  fail "policy migration only runs where hibernation is already set up"
pass "policy migration only runs where hibernation is already set up"

grep -Fq '99-suspend-then-hibernate.conf' "$migration" ||
  fail "policy migration removes the superseded manual drop-in"
pass "policy migration removes the superseded manual drop-in"

grep -Fq 'systemd-logind' "$migration" ||
  fail "policy migration reloads logind or requests a reboot"
pass "policy migration reloads logind or requests a reboot"

bash -n "$migration" || fail "policy migration parses"
pass "policy migration parses"
