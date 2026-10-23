#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-acer-aspire-go-15"
leaf="$ROOT/install/hardware/acer/fix-aspire-keyboard.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-aspire-keyboard.sh" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/acer/fix-aspire-keyboard.sh' "$all" ||
  fail "the Acer keyboard workaround runs during hardware setup"
pass "the Acer keyboard workaround runs during hardware setup"

[[ -n $migration ]] || fail "a migration enables the workaround on existing installs"
pass "a migration enables the workaround on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
if [[ " ${TEST_CMD_MISSING:-} " == *" $1 "* ]]; then
  exit 1
fi
command -v "$1" >/dev/null 2>&1
SH

cat >"$test_tmp/bin/limine-update" <<'SH'
#!/bin/bash
printf 'limine-update\n' >>"$CALL_LOG"
exit "${TEST_UPDATE_STATUS:-0}"
SH

cat >"$test_tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
if [[ " ${TEST_CMD_MISSING:-} " == *" limine-mkinitcpio "* ]]; then
  exit 127
else
  printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
  exit "${TEST_MKINITCPIO_STATUS:-0}"
fi
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

vendor_file="$test_tmp/sys_vendor"
call_log="$test_tmp/calls.log"

run_detector() {
  printf '%s\n' "${2-Acer}" >"$vendor_file"
  PATH="$test_tmp/bin:$PATH" \
    TEST_PRODUCT_NAME="${1-Aspire AG15-42P}" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    bash "$detector"
}

run_detector || fail "the detector matches Acer Aspire AG15-42P"
pass "the detector matches Acer Aspire AG15-42P"

run_detector "Aspire Go 15" && fail "the detector rejects other Aspire Go 15 models"
pass "the detector rejects other Aspire Go 15 models"

run_detector "Aspire AG15-42P" "Dell" && fail "the detector rejects non-Acer vendor"
pass "the detector rejects non-Acer vendor"

run_detector "Swift SF314" "Acer" && fail "the detector rejects other Acer models"
pass "the detector rejects other Acer models"

run_detector "Aspire AG15-42P" "ACER" || fail "the detector matches case-insensitively"
pass "the detector matches case-insensitively"

PATH="$test_tmp/bin:$PATH" \
  TEST_PRODUCT_NAME="Aspire AG15-42P" \
  OMARCHY_DMI_SYS_VENDOR="$test_tmp/nonexistent" \
  bash "$detector" && fail "the detector fails closed when vendor attribute is missing"
pass "the detector fails closed when vendor attribute is missing"

# Leaf execution test
drop_in_file="$test_tmp/etc/limine-entry-tool.d/acer-aspire-keyboard.conf"

run_leaf() {
  : >"$call_log"
  printf '%s\n' "${2-Acer}" >"$vendor_file"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    TEST_PRODUCT_NAME="${1-Aspire AG15-42P}" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_ACER_ASPIRE_LIMINE_CONF="$drop_in_file" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf executes on matching hardware"
[[ -f $drop_in_file ]] || fail "the leaf creates the limine drop-in file"
grep -q 'i8042\.reset' "$drop_in_file" || fail "the drop-in contains i8042.reset"
grep -q 'atkbd\.reset' "$drop_in_file" && fail "the drop-in should not contain atkbd.reset"
grep -q 'acpi_osi=Linux' "$drop_in_file" && fail "the drop-in should not contain acpi_osi=Linux"
pass "the leaf creates the limine drop-in configuration"

# Leaf idempotency
run_leaf || fail "the leaf executes again idempotently"
(( $(grep -c 'i8042\.reset' "$drop_in_file") == 1 )) || fail "leaf does not duplicate cmdline lines"
pass "the leaf is idempotent and does not duplicate configuration"

# Leaf on non-matching hardware
rm -f "$drop_in_file"
run_leaf "ThinkPad X1" "Lenovo" || fail "the leaf no-ops on other hardware"
[[ -f $drop_in_file ]] && fail "the leaf does not create drop-in on other hardware"
pass "the leaf no-ops on other hardware"

# Migration execution test
running_cmdline_file="$test_tmp/proc_cmdline"
rebuild_marker="$test_tmp/var/lib/omarchy/migrations/1788707260"

run_migration() {
  : >"$call_log"
  printf '%s\n' "${2-Acer}" >"$vendor_file"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_PRODUCT_NAME="${1-Aspire AG15-42P}" \
    TEST_CMD_MISSING="${3:-}" \
    TEST_UPDATE_STATUS="${4:-0}" \
    TEST_MKINITCPIO_STATUS="${5:-0}" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_ACER_ASPIRE_LIMINE_CONF="$drop_in_file" \
    OMARCHY_ACER_ASPIRE_REBUILD_MARKER="$rebuild_marker" \
    OMARCHY_RUNNING_CMDLINE="$running_cmdline_file" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

# 1. Migration on unconfigured machine: drop-in created, limine-update run, reboot-required set
rm -f "$drop_in_file" "$rebuild_marker"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 rw\n' >"$running_cmdline_file"
run_migration || fail "the migration executes on matching hardware"
[[ -f $drop_in_file ]] || fail "migration created drop-in"
grep -q '^limine-update$' "$call_log" || fail "migration executed limine-update"
[[ -e $rebuild_marker ]] || fail "migration recorded the rebuild"
grep -q 'state set reboot-required' "$call_log" || fail "migration requested reboot"
pass "the migration creates drop-in, rebuilds boot config, and requests reboot"

# 2. Migration on already-running quirk machine: rebuilds drop-in but does not need reboot
rm -f "$drop_in_file" "$rebuild_marker"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 i8042.reset rw\n' >"$running_cmdline_file"
run_migration || fail "the migration executes when quirks already running"
grep -q '^limine-update$' "$call_log" || fail "migration executed limine-update"
grep -q 'state set reboot-required' "$call_log" && fail "migration skipped reboot request when quirks already active"
pass "the migration skips reboot request when quirks are already active in cmdline"

# 3. Migration fallback to limine-mkinitcpio when limine-update is not present
rm -f "$drop_in_file" "$rebuild_marker"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 rw\n' >"$running_cmdline_file"
run_migration "Aspire AG15-42P" "Acer" "limine-update" || fail "the migration falls back to limine-mkinitcpio"
grep -q '^limine-mkinitcpio$' "$call_log" || fail "migration executed limine-mkinitcpio fallback"
pass "the migration falls back to limine-mkinitcpio when limine-update is absent"

# 4. A failed rebuild fails the migration and is retried on the next run
rm -f "$drop_in_file" "$rebuild_marker"
run_migration "Aspire AG15-42P" "Acer" "" "1" && fail "the migration must fail when limine-update fails"
grep -q '^limine-update$' "$call_log" || fail "the failing run reached limine-update"
grep -q 'state set reboot-required' "$call_log" && fail "failing rebuild must not mark reboot-required"
[[ -e $rebuild_marker ]] && fail "failing rebuild must not be recorded"
run_migration || fail "the retried migration succeeds"
grep -q '^limine-update$' "$call_log" || fail "the retried migration rebuilds although the drop-in exists"
grep -q 'state set reboot-required' "$call_log" || fail "the retried migration requests reboot"
pass "the migration fails on a failed rebuild and rebuilds when retried"

# 5. With no Limine rebuild tool the migration fails rather than completing unapplied
rm -f "$drop_in_file" "$rebuild_marker"
run_migration "Aspire AG15-42P" "Acer" "limine-update limine-mkinitcpio" && fail "the migration must fail without a rebuild tool"
[[ -e $rebuild_marker ]] && fail "a missing rebuild tool must not be recorded as a rebuild"
grep -q 'state set reboot-required' "$call_log" && fail "a missing rebuild tool must not mark reboot-required"
pass "the migration fails when no Limine rebuild tool is present"

# 6. Migration idempotent: rebuild already recorded -> no second rebuild
rm -f "$rebuild_marker"
run_migration || fail "the migration succeeds on an unconfigured machine"
run_migration || fail "the migration succeeds on an already configured machine"
grep -q '^limine-update$' "$call_log" && fail "migration skipped rebuild when it was already recorded"
pass "the migration is idempotent and skips rebuild once it is recorded"

# 6b. A user whose migration finds another user's rebuild still gets the reboot request
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 rw\n' >"$running_cmdline_file"
run_migration || fail "the migration succeeds after another user's rebuild"
grep -q '^limine-update$' "$call_log" && fail "the migration does not repeat another user's rebuild"
grep -q 'state set reboot-required' "$call_log" || fail "the migration requests reboot after another user's rebuild"
pass "the migration requests reboot for a user whose rebuild was done by another"

# 7. A drop-in removed after a recorded rebuild is restored and rebuilt, even after a failed attempt
rm -f "$drop_in_file"
run_migration "Aspire AG15-42P" "Acer" "" "1" && fail "the migration fails when the restoring rebuild fails"
[[ -e $rebuild_marker ]] && fail "a failed restoring rebuild clears the old record"
run_migration || fail "the migration restores a removed drop-in"
[[ -f $drop_in_file ]] || fail "the migration rewrote the drop-in"
grep -q '^limine-update$' "$call_log" || fail "the migration rebuilds after restoring the drop-in"
pass "the migration rebuilds when it restores a removed drop-in"

# 8. Migration on other hardware
rm -f "$drop_in_file" "$rebuild_marker"
run_migration "ThinkPad X1" "Lenovo" || fail "the migration runs cleanly on other hardware"
[[ -s $call_log ]] && fail "the migration does nothing on other hardware"
[[ -f $drop_in_file ]] && fail "the migration writes no drop-in on other hardware"
pass "the migration no-ops on other hardware"
