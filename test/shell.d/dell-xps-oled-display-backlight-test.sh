#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/dell-xps-oled-display-backlight.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "dell-xps-oled-display-backlight" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/dell-xps-oled-display-backlight.sh' "$all" ||
  fail "the Dell XPS OLED backlight fix runs during hardware setup"
pass "the Dell XPS OLED backlight fix runs during hardware setup"

[[ -n $migration ]] || fail "a migration enables the fix on existing installs"
pass "a migration enables the fix on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/rebuild-bin"

cat >"$test_tmp/bin/omarchy-hw-dell-xps-oled" <<'SH'
#!/bin/bash
[[ ${TEST_XPS_OLED:-0} == 1 ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/rebuild-bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
SH

# Models a machine without limine-mkinitcpio. The helper is stubbed rather than
# the command dropped from PATH: the real tool sits in /usr/bin on a developer
# machine, and the mock sudo would run it as the test user. The failing stub
# stays as a tripwire, so a fall-through shows up in the call log instead.
mkdir -p "$test_tmp/no-limine-bin"
cat >"$test_tmp/no-limine-bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 != "limine-mkinitcpio" ]]
SH
cat >"$test_tmp/no-limine-bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
exit 1
SH

mkdir -p "$test_tmp/failing-rebuild-bin"
cat >"$test_tmp/failing-rebuild-bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
exit 1
SH

chmod +x "$test_tmp/bin"/* "$test_tmp/rebuild-bin"/* "$test_tmp/no-limine-bin"/* "$test_tmp/failing-rebuild-bin"/*

drop_in="$test_tmp/limine-entry-tool.d/dell-xps-oled-display-backlight.conf"
call_log="$test_tmp/calls.log"
expected_param='KERNEL_CMDLINE[default]+=" xe.enable_dpcd_backlight=1"'

# Sourced the way run_logged runs it.
run_leaf() {
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    TEST_XPS_OLED="${1-1}" \
    OMARCHY_DELL_XPS_OLED_BACKLIGHT_CONF="$drop_in" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf writes the Limine drop-in on a Dell XPS OLED"
grep -Fxq "$expected_param" "$drop_in" ||
  fail "the leaf writes the Limine drop-in on a Dell XPS OLED" "$(cat "$drop_in" 2>&1)"
pass "the leaf writes the Limine drop-in on a Dell XPS OLED"

run_leaf || fail "the leaf is idempotent"
(( $(grep -c 'enable_dpcd_backlight' "$drop_in") == 1 )) ||
  fail "the leaf is idempotent" "$(cat "$drop_in")"
pass "rerunning the leaf leaves one copy of the parameter"

rm -rf "$test_tmp/limine-entry-tool.d"
run_leaf 0 || fail "the leaf no-ops on other hardware"
[[ ! -e $drop_in ]] || fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"

run_migration() {
  : >"$call_log"
  PATH="$test_tmp/bin:${2-$test_tmp/rebuild-bin}:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_XPS_OLED="${1-1}" \
    OMARCHY_DELL_XPS_OLED_BACKLIGHT_CONF="$drop_in" \
    OMARCHY_DELL_XPS_OLED_BACKLIGHT_MARKER="$marker" \
    OMARCHY_DELL_XPS_OLED_RUNNING_CMDLINE="$running_cmdline" \
    bash -euo pipefail "$migration" >/dev/null
}

marker="$test_tmp/var/lib/omarchy/migrations/1788886195"
running_cmdline="$test_tmp/cmdline"
printf 'root=UUID=abc rw quiet\n' >"$running_cmdline"

run_migration || fail "the migration applies the fix, rebuilds the boot image, and asks for a reboot"
grep -Fxq "$expected_param" "$drop_in" ||
  fail "the migration writes the Limine drop-in"
grep -Fxq 'limine-mkinitcpio' "$call_log" ||
  fail "the migration rebuilds the boot image" "$(cat "$call_log")"
grep -Fxq 'state set reboot-required' "$call_log" ||
  fail "the migration asks for a reboot" "$(cat "$call_log")"
[[ -e $marker ]] || fail "the migration records the machine-wide rebuild"
pass "the migration applies the fix, rebuilds the boot image, and asks for a reboot"

run_migration || fail "a second user's migration before the reboot asks for one without rebuilding"
! grep -Fxq 'limine-mkinitcpio' "$call_log" ||
  fail "a second user's migration before the reboot does not rebuild again" "$(cat "$call_log")"
grep -Fxq 'state set reboot-required' "$call_log" ||
  fail "a second user's migration before the reboot asks that user to reboot" "$(cat "$call_log")"
pass "a second user's migration before the reboot asks for one without rebuilding"

printf 'root=UUID=abc rw quiet xe.enable_dpcd_backlight=1\n' >"$running_cmdline"
run_migration || fail "a user's migration after the reboot no-ops"
[[ ! -s $call_log ]] || fail "a user's migration after the reboot no-ops" "$(cat "$call_log")"
pass "a user's migration after the reboot neither rebuilds nor asks for another"

# Booted with the parameter typed in at the boot menu, so nothing persistent carries it yet.
rm -rf "$test_tmp/limine-entry-tool.d" "$marker"
run_migration || fail "a machine booted with the parameter by hand still gets the drop-in"
grep -Fxq "$expected_param" "$drop_in" ||
  fail "a machine booted with the parameter by hand still gets the drop-in"
grep -Fxq 'limine-mkinitcpio' "$call_log" ||
  fail "a machine booted with the parameter by hand still rebuilds the boot image" "$(cat "$call_log")"
[[ -e $marker ]] || fail "a machine booted with the parameter by hand records the rebuild"
! grep -q 'reboot-required' "$call_log" ||
  fail "a machine already booted with the parameter is not asked to reboot" "$(cat "$call_log")"
pass "a machine booted with the parameter by hand still gets the drop-in, without a reboot prompt"
printf 'root=UUID=abc rw quiet\n' >"$running_cmdline"

rm -rf "$test_tmp/limine-entry-tool.d" "$marker"
if run_migration 1 "$test_tmp/failing-rebuild-bin"; then
  fail "a failed rebuild stops the migration"
fi
[[ ! -e $marker ]] || fail "a failed rebuild leaves no marker, so the migration retries"
! grep -q 'reboot-required' "$call_log" || fail "a failed rebuild does not ask for a reboot" "$(cat "$call_log")"
pass "a failed rebuild leaves the migration pending for a retry"

rm -rf "$test_tmp/limine-entry-tool.d"
run_migration 0 || fail "the migration no-ops on other hardware"
[[ ! -e $drop_in && ! -s $call_log ]] || fail "the migration no-ops on other hardware" "$(cat "$call_log")"
pass "the migration no-ops on other hardware"

# A drop-in under /etc/limine-entry-tool.d does nothing without the tool that
# reads it, so the migration must skip cleanly rather than fail and block the
# queue behind a missing rebuild command.
run_migration 1 "$test_tmp/no-limine-bin" || fail "the migration skips when limine-mkinitcpio is missing"
[[ ! -e $drop_in && ! -s $call_log ]] ||
  fail "the migration skips when limine-mkinitcpio is missing" "$(cat "$call_log")"
pass "the migration skips cleanly without limine-mkinitcpio"
