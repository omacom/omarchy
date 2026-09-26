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
if [[ $1 == "${TEST_CMD_MISSING:-}" ]]; then
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
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
exit "${TEST_MKINITCPIO_STATUS:-0}"
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

run_detector "Aspire Go 15" || fail "the detector matches Acer Aspire Go 15"
pass "the detector matches Acer Aspire Go 15"

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
grep -q 'atkbd\.reset' "$drop_in_file" || fail "the drop-in contains atkbd.reset"
grep -q 'acpi_osi=Linux' "$drop_in_file" || fail "the drop-in contains acpi_osi=Linux"
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
    OMARCHY_RUNNING_CMDLINE="$running_cmdline_file" \
    bash -euo pipefail "$migration" >/dev/null
}

# 1. Migration on unconfigured machine: drop-in created, limine-update run, reboot-required set
rm -f "$drop_in_file"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 rw\n' >"$running_cmdline_file"
run_migration || fail "the migration executes on matching hardware"
[[ -f $drop_in_file ]] || fail "migration created drop-in"
grep -q '^limine-update$' "$call_log" || fail "migration executed limine-update"
grep -q 'state set reboot-required' "$call_log" || fail "migration requested reboot"
pass "the migration creates drop-in, rebuilds boot config, and requests reboot"

# 2. Migration on already-running quirk machine: rebuilds drop-in but does not need reboot
rm -f "$drop_in_file"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 i8042.reset atkbd.reset acpi_osi=Linux rw\n' >"$running_cmdline_file"
run_migration || fail "the migration executes when quirks already running"
grep -q '^limine-update$' "$call_log" || fail "migration executed limine-update"
grep -q 'state set reboot-required' "$call_log" && fail "migration skipped reboot request when quirks already active"
pass "the migration skips reboot request when quirks are already active in cmdline"

# 3. Migration fallback to limine-mkinitcpio when limine-update is not present
rm -f "$drop_in_file"
printf 'BOOT_IMAGE=/vmlinuz-linux root=/dev/sda1 rw\n' >"$running_cmdline_file"
run_migration "Aspire AG15-42P" "Acer" "limine-update" || fail "the migration falls back to limine-mkinitcpio"
grep -q '^limine-mkinitcpio$' "$call_log" || fail "migration executed limine-mkinitcpio fallback"
pass "the migration falls back to limine-mkinitcpio when limine-update is absent"

# 4. Migration fails and avoids marking reboot-required if bootloader rebuild fails
rm -f "$drop_in_file"
run_migration "Aspire AG15-42P" "Acer" "" "1" && fail "the migration must fail when limine-update fails"
grep -q 'state set reboot-required' "$call_log" && fail "failing rebuild must not mark reboot-required"
pass "the migration fails and avoids marking reboot-required when bootloader rebuild fails"

# 5. Migration idempotent: drop-in already present -> no rebuild needed
printf 'KERNEL_CMDLINE[default]+=" i8042.reset atkbd.reset acpi_osi=Linux"\n' >"$drop_in_file"
: >"$call_log"
run_migration || fail "the migration succeeds on already configured machine"
grep -q '^limine-update$' "$call_log" && fail "migration skipped rebuild when drop-in was already up to date"
pass "the migration is idempotent and skips rebuild when drop-in is already present"

# 6. Migration on other hardware
: >"$call_log"
run_migration "ThinkPad X1" "Lenovo" || fail "the migration runs cleanly on other hardware"
[[ -s $call_log ]] && fail "the migration does nothing on other hardware"
pass "the migration no-ops on other hardware"
