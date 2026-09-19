#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-dell-xps13-dx13260-ptl"
leaf="$ROOT/install/hardware/dell-xps13-ptl-display.sh"
firmware_leaf="$ROOT/install/hardware/dell-xps13-ptl-speaker-firmware.sh"
all="$ROOT/install/hardware/all.sh"
packages="$ROOT/install/omarchy-other.packages"
migration=$(grep -l "dell-xps13-ptl-display.sh" "$ROOT"/migrations/*.sh | head -1)

[[ -x $detector ]] || fail "the DX13260 detector exists and is executable"
pass "the DX13260 detector exists and is executable"

grep -q 'run_logged .*hardware/dell-xps13-ptl-display.sh' "$all" ||
  fail "the XPS 13 display fix runs during hardware setup"
pass "the XPS 13 display fix runs during hardware setup"

[[ -n $migration ]] || fail "a migration applies the display fix on existing installs"
pass "a migration applies the display fix on existing installs"

grep -q 'run_logged .*hardware/dell-xps13-ptl-speaker-firmware.sh' "$all" ||
  fail "the XPS 13 speaker firmware aliases are installed during hardware setup"
pass "the XPS 13 speaker firmware aliases are installed during hardware setup"

grep -qx 'dell-xps13-speaker-firmware' "$packages" ||
  fail "the offline mirror carries the XPS 13 speaker firmware aliases"
pass "the offline mirror carries the XPS 13 speaker firmware aliases"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/etc/limine-entry-tool.d"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH
cat >"$test_tmp/bin/omarchy-hw-intel-ptl" <<'SH'
#!/bin/bash
[[ ${TEST_INTEL_PTL:-0} == "1" ]]
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cp "$detector" "$test_tmp/bin/"
chmod +x "$test_tmp"/bin/*

run_leaf() {
  (
    export PATH="$test_tmp/bin:$PATH"
    export TEST_PRODUCT_NAME="$1" TEST_INTEL_PTL="$2"
    export OMARCHY_LIMINE_DROP_IN_DIR="$test_tmp/etc/limine-entry-tool.d"
    export OMARCHY_LIMINE_CONF="$test_tmp/etc/default/limine"
    # shellcheck disable=SC1090
    source "$leaf"
  )
}

drop_in="$test_tmp/etc/limine-entry-tool.d/dell-xps13-dx13260-display.conf"

run_leaf "XPS 9350" 1
[[ ! -e $drop_in ]] || fail "other Dell models are left alone"
pass "other Dell models are left alone"

run_leaf "XPS 13 DX13260" 0
[[ ! -e $drop_in ]] || fail "a non-Panther-Lake DX13260 is left alone"
pass "a non-Panther-Lake DX13260 is left alone"

run_leaf "XPS 13 DX13260" 1
grep -q 'xe.enable_psr2_sel_fetch=0 xe.enable_panel_replay=0' "$drop_in" 2>/dev/null ||
  fail "the matching machine gets the PSR1-only kernel command line"
pass "the matching machine gets the PSR1-only kernel command line"

rm -f "$drop_in"
echo 'KERNEL_CMDLINE[default]+=" xe.enable_psr=0"' >"$test_tmp/etc/limine-entry-tool.d/manual.conf"
run_leaf "XPS 13 DX13260" 1
[[ ! -e $drop_in ]] || fail "an existing manual PSR setting is respected"
pass "an existing manual PSR setting is respected"
rm -f "$test_tmp/etc/limine-entry-tool.d/manual.conf"

mkdir -p "$test_tmp/etc/default"
limine_conf="$test_tmp/etc/default/limine"
echo 'KERNEL_CMDLINE[default]+=" root=/dev/mapper/root xe.enable_psr=0"' >"$limine_conf"
run_leaf "XPS 13 DX13260" 1
[[ ! -e $drop_in ]] || fail "a manual PSR setting in /etc/default/limine is respected"
pass "a manual PSR setting in /etc/default/limine is respected"

echo '# KERNEL_CMDLINE[default]+=" xe.enable_psr=0"' >"$limine_conf"
run_leaf "XPS 13 DX13260" 1
[[ -e $drop_in ]] || fail "a commented-out PSR setting does not suppress the fix"
pass "a commented-out PSR setting does not suppress the fix"
rm -f "$limine_conf"

before=$(md5sum "$drop_in")
run_leaf "XPS 13 DX13260" 1
[[ $before == "$(md5sum "$drop_in")" ]] || fail "re-running the leaf is idempotent"
pass "re-running the leaf is idempotent"

echo 'KERNEL_CMDLINE[default]+=" xe.enable_panel_replay=0"' >"$drop_in"
run_leaf "XPS 13 DX13260" 1
grep -q 'xe.enable_psr2_sel_fetch=0 xe.enable_panel_replay=0' "$drop_in" ||
  fail "a drop-in carrying only one of the two flags is completed"
pass "a drop-in carrying only one of the two flags is completed"

# The migration, run the way omarchy-migrate runs it.
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${TEST_MISSING_COMMAND:-} != "$1" ]] && command -v "$1" >/dev/null
SH
cat >"$test_tmp/bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
[[ ! -e $TEST_PKG_DB/$1 ]]
SH
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "pkg-add $*" >>"$TEST_LOG"
touch "$TEST_PKG_DB/$1"
SH
cat >"$test_tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo rebuild >>"$TEST_LOG"
SH
cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
echo "state $*" >>"$TEST_LOG"
SH
chmod +x "$test_tmp"/bin/*

log="$test_tmp/log"
pkg_db="$test_tmp/pkg-db"
mkdir -p "$pkg_db"
marker="$test_tmp/var/migration-marker"
cmdline="$test_tmp/cmdline"
firmware_pending="$test_tmp/run/firmware-pending"

run_migration() {
  : >"$log"
  PATH="$test_tmp/bin:$PATH" TEST_LOG="$log" TEST_PKG_DB="$pkg_db" OMARCHY_PATH="$ROOT" \
    TEST_PRODUCT_NAME="$1" TEST_INTEL_PTL=1 \
    OMARCHY_LIMINE_DROP_IN_DIR="$test_tmp/etc/limine-entry-tool.d" \
    OMARCHY_LIMINE_CONF="$limine_conf" \
    OMARCHY_RUNNING_CMDLINE="$cmdline" \
    OMARCHY_XPS13_DISPLAY_REBUILD_MARKER="$marker" \
    OMARCHY_XPS13_FIRMWARE_PENDING="${TEST_FIRMWARE_PENDING:-$firmware_pending}" \
    bash -euo pipefail "$migration"
}

run_firmware_leaf() {
  : >"$log"
  (
    export PATH="$test_tmp/bin:$PATH" TEST_LOG="$log" TEST_PKG_DB="$pkg_db"
    export TEST_PRODUCT_NAME="$1" TEST_INTEL_PTL="$2"
    # shellcheck disable=SC1090
    source "$firmware_leaf"
  )
}

run_firmware_leaf "XPS 13 DX13260" 0
[[ ! -s $log ]] || fail "other machines do not get the speaker firmware aliases"
pass "other machines do not get the speaker firmware aliases"

run_firmware_leaf "XPS 13 DX13260" 1
[[ $(<"$log") == "pkg-add dell-xps13-speaker-firmware" ]] ||
  fail "the matching machine gets the speaker firmware aliases"
pass "the matching machine gets the speaker firmware aliases"
rm -f "$pkg_db"/*

rm -f "$drop_in"
echo "quiet splash" >"$cmdline"

run_migration "XPS 9350" >/dev/null
[[ ! -e $drop_in && ! -s $log ]] || fail "the migration leaves other machines alone"
pass "the migration leaves other machines alone"

# The reboot marker comes first: a run that installed the package and then
# failed to record it would retry into a machine that never asks for the reboot.
echo 'KERNEL_CMDLINE[default]+=" xe.enable_psr=0"' >"$limine_conf"
if TEST_FIRMWARE_PENDING="$cmdline/not-a-directory" run_migration "XPS 13 DX13260" &>/dev/null; then
  fail "a migration that cannot record the pending reboot does not complete"
fi
[[ -z $(ls -A "$pkg_db") ]] || fail "a run that cannot record the pending reboot installs nothing"
pass "a run that cannot record the pending reboot installs nothing"

# A manual PSR setting keeps the display repair away; the speakers still need
# their firmware and the reboot that loads it.
echo 'KERNEL_CMDLINE[default]+=" xe.enable_psr=0"' >"$limine_conf"
run_migration "XPS 13 DX13260" >/dev/null
[[ ! -e $drop_in && $(<"$log") == $'pkg-add dell-xps13-speaker-firmware\nstate set reboot-required' ]] ||
  fail "the migration installs the speaker firmware aliases and asks for a reboot"
pass "the migration installs the speaker firmware aliases and asks for a reboot"

run_migration "XPS 13 DX13260" >/dev/null
[[ $(<"$log") == "state set reboot-required" ]] ||
  fail "a second user before the reboot is asked to reboot for the firmware without a reinstall"
pass "a second user before the reboot is asked to reboot for the firmware without a reinstall"

rm -f "$firmware_pending"
run_migration "XPS 13 DX13260" >/dev/null
[[ ! -s $log ]] || fail "a machine rebooted with the firmware installed is left alone"
pass "a machine rebooted with the firmware installed is left alone"
rm -f "$limine_conf"

TEST_MISSING_COMMAND=limine-mkinitcpio run_migration "XPS 13 DX13260" >/dev/null
[[ ! -e $marker && $(<"$log") == "state set reboot-required" ]] ||
  fail "a machine without limine-mkinitcpio records no rebuild"
pass "a machine without limine-mkinitcpio records no rebuild"

run_migration "XPS 13 DX13260" >/dev/null
[[ -e $drop_in && $(<"$log") == $'rebuild\nstate set reboot-required' ]] ||
  fail "the migration writes the drop-in, rebuilds the boot image and asks for a reboot"
pass "the migration writes the drop-in, rebuilds the boot image and asks for a reboot"

run_migration "XPS 13 DX13260" >/dev/null
[[ $(<"$log") == "state set reboot-required" ]] ||
  fail "a second user before the reboot is asked to reboot without a second rebuild"
pass "a second user before the reboot is asked to reboot without a second rebuild"

rm -f "$marker"
echo "quiet xe.enable_panel_replay=0 splash" >"$cmdline"
run_migration "XPS 13 DX13260" >/dev/null
[[ $(<"$log") == $'rebuild\nstate set reboot-required' ]] ||
  fail "a booted command line with only one of the two flags still gets the rebuild"
pass "a booted command line with only one of the two flags still gets the rebuild"

echo "quiet xe.enable_psr2_sel_fetch=0 xe.enable_panel_replay=0 splash" >"$cmdline"
run_migration "XPS 13 DX13260" >/dev/null
[[ ! -s $log ]] || fail "a machine already booted with both flags is left alone"
pass "a machine already booted with both flags is left alone"

rm -f "$drop_in" "$marker"
echo "quiet splash xe.enable_psr=0" >"$cmdline"
echo 'KERNEL_CMDLINE[default]+=" xe.enable_psr=0"' >"$limine_conf"
run_migration "XPS 13 DX13260" >/dev/null
[[ ! -e $drop_in && ! -s $log ]] || fail "the migration leaves a manual PSR setting alone"
pass "the migration leaves a manual PSR setting alone"
