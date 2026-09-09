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

chmod +x "$test_tmp/bin"/* "$test_tmp/rebuild-bin"/* "$test_tmp/no-limine-bin"/*

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
    bash -euo pipefail "$migration" >/dev/null
}

run_migration || fail "the migration applies the fix, rebuilds the boot image, and asks for a reboot"
grep -Fxq "$expected_param" "$drop_in" ||
  fail "the migration writes the Limine drop-in"
grep -Fxq 'limine-mkinitcpio' "$call_log" ||
  fail "the migration rebuilds the boot image" "$(cat "$call_log")"
grep -Fxq 'state set reboot-required' "$call_log" ||
  fail "the migration asks for a reboot" "$(cat "$call_log")"
pass "the migration applies the fix, rebuilds the boot image, and asks for a reboot"

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
