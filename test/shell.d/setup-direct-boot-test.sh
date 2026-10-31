#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
  choose)
    if [[ -n ${STUB_GUM_CHOOSE:-} ]]; then
      echo "$STUB_GUM_CHOOSE"
      exit 0
    fi
    shift
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --header*|--selected*)
          shift 2 2>/dev/null || shift 1
          ;;
        --*)
          shift
          ;;
        *)
          echo "$1"
          exit 0
          ;;
      esac
    done
    head -n 1
    ;;
  confirm)
    [[ ${STUB_GUM_CONFIRM:-1} == 1 ]]
    ;;
  *)
    exit 0
    ;;
esac
STUB

cat >"$stub_bin/efibootmgr" <<'STUB'
#!/bin/bash
printf 'efibootmgr %s\n' "$*" >>"${CALL_LOG:?}"
if [[ "$*" == *"--create"* ]] && [[ ${STUB_EFIBOOTMGR_FAIL_CREATE:-0} == 1 ]]; then
  echo "efibootmgr: Could not prepare Boot variable: No space left on device" >&2
  exit 1
fi
if [[ -n ${STUB_EFIBOOTMGR_ENTRIES:-} ]]; then
  printf '%b\n' "$STUB_EFIBOOTMGR_ENTRIES"
else
  printf 'BootCurrent: 0000\nBootOrder: 0000\nBoot0000* EFI Hard Drive\tHD(1,GPT,...)\n'
fi
STUB

cat >"$stub_bin/findmnt" <<'STUB'
#!/bin/bash
echo "/dev/nvme0n1p1"
STUB

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'STUB'
#!/bin/bash
exit ${STUB_HW_APPLE:-1}
STUB

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${CALL_LOG:?}"
case "$1" in
  find)
    shift
    if [[ -d "${FAKE_BOOT_DIR:-}" ]]; then
      /usr/bin/find "$FAKE_BOOT_DIR" "${@:2}"
    else
      exit 0
    fi
    ;;
  efibootmgr)
    shift
    efibootmgr "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
STUB

chmod +x "$stub_bin"/*

fake_sys="$test_dir/sys"
mkdir -p "$fake_sys/firmware/efi"
mkdir -p "$fake_sys/class/dmi/id"
echo "Generic PC" >"$fake_sys/class/dmi/id/bios_vendor"

fake_boot="$test_dir/boot/EFI/Linux"
mkdir -p "$fake_boot"

run_direct_boot() {
  local scenario="$1"
  : >"$test_dir/$scenario.calls"

  CALL_LOG="$test_dir/$scenario.calls" \
    FAKE_BOOT_DIR="$fake_boot" \
    TEST_DIR="$test_dir" \
    OMARCHY_SYS_ROOT="${OMARCHY_SYS_ROOT:-$fake_sys}" \
    OMARCHY_PATH="$ROOT" \
    STUB_HW_APPLE="${STUB_HW_APPLE:-1}" \
    STUB_GUM_CHOOSE="${STUB_GUM_CHOOSE:-}" \
    STUB_GUM_CONFIRM="${STUB_GUM_CONFIRM:-1}" \
    STUB_EFIBOOTMGR_FAIL_CREATE="${STUB_EFIBOOTMGR_FAIL_CREATE:-0}" \
    STUB_EFIBOOTMGR_ENTRIES="${STUB_EFIBOOTMGR_ENTRIES:-}" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-setup-direct-boot"
}

# Test 1: Error when no UKIs found
if run_direct_boot no_uki >"$test_dir/no_uki.out" 2>&1; then
  fail "direct boot setup must fail when no UKI files are found"
fi
grep -q "No Omarchy UKI found" "$test_dir/no_uki.out" || fail "reports missing UKI error"
pass "direct boot setup errors when no UKIs exist"

# Test 1b: Error when only non-Omarchy EFI files exist
touch "$fake_boot/custom_loader.efi"
if run_direct_boot non_omarchy_efi >"$test_dir/non_omarchy_efi.out" 2>&1; then
  fail "direct boot setup must fail when only non-Omarchy EFI files exist"
fi
grep -q "No Omarchy UKI found" "$test_dir/non_omarchy_efi.out" || fail "reports missing UKI error for non-Omarchy EFI"
rm -f "$fake_boot/custom_loader.efi"
pass "direct boot setup ignores non-Omarchy EFI files"

# Test 2: Single kernel UKI auto-selected and created
touch "$fake_boot/omarchy_linux.efi"
output=$(run_direct_boot single_kernel)
grep -q "Creating EFI boot entry for omarchy_linux.efi" <<<"$output" || fail "creates EFI boot entry for single kernel"
grep -q "efibootmgr --create --disk /dev/nvme0n1 --part 1 --label Omarchy --loader \\\\EFI\\\\Linux\\\\omarchy_linux.efi" "$test_dir/single_kernel.calls" || fail "calls efibootmgr create correctly"
pass "direct boot setup configures entry for single kernel"

# Test 3: Multiple kernels available, user selects cachyos kernel
touch "$fake_boot/omarchy_linux-cachyos-bore.efi"
touch "$fake_boot/omarchy_linux-lts.efi"

STUB_GUM_CHOOSE="linux-cachyos-bore (omarchy_linux-cachyos-bore.efi)" output=$(run_direct_boot multi_kernel)
grep -q "Creating EFI boot entry for omarchy_linux-cachyos-bore.efi" <<<"$output" || fail "creates EFI boot entry for chosen cachyos kernel"
grep -q "efibootmgr --create --disk /dev/nvme0n1 --part 1 --label Omarchy --loader \\\\EFI\\\\Linux\\\\omarchy_linux-cachyos-bore.efi" "$test_dir/multi_kernel.calls" || fail "calls efibootmgr create with selected kernel UKI"
pass "direct boot setup allows choosing specific kernel among multiple installed kernels"

# Test 4: Existing entry - Disable direct boot
disable_action="$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" directBoot.disableAction)"
STUB_EFIBOOTMGR_ENTRIES="Boot0005* Omarchy\tHD(1,GPT,...)" STUB_GUM_CHOOSE="$disable_action" output=$(run_direct_boot disable_existing)
grep -q "Removing EFI boot entry 0005" <<<"$output" || fail "removes EFI boot entry when disabling"
grep -q "efibootmgr --bootnum 0005 --delete-bootnum" "$test_dir/disable_existing.calls" || fail "calls efibootmgr delete-bootnum"
pass "direct boot setup disables existing direct boot entry"

# Test 5: Existing entry - Change kernel
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
  choose)
    state_file="${TEST_DIR:-/tmp}/gum_choose_state"
    if [[ ! -f $state_file ]]; then
      echo 1 >"$state_file"
      OMARCHY_PATH="$OMARCHY_PATH" "$OMARCHY_PATH/bin/omarchy-i18n" directBoot.changeKernel
    else
      echo "linux-lts (omarchy_linux-lts.efi)"
    fi
    ;;
  confirm)
    [[ ${STUB_GUM_CONFIRM:-1} == 1 ]]
    ;;
  *)
    exit 0
    ;;
esac
STUB
chmod +x "$stub_bin/gum"

STUB_EFIBOOTMGR_ENTRIES="Boot0005* Omarchy\tHD(1,GPT,...)" output=$(run_direct_boot change_kernel)
grep -q "Creating EFI boot entry for omarchy_linux-lts.efi" <<<"$output" || fail "creates new entry for changed kernel"
grep -q "Removing existing EFI boot entry 0005" <<<"$output" || fail "removes old entry when changing kernel"
grep -q "efibootmgr --bootnum 0005 --delete-bootnum" "$test_dir/change_kernel.calls" || fail "deletes old bootnum"
grep -q "efibootmgr --create --disk /dev/nvme0n1 --part 1 --label Omarchy --loader \\\\EFI\\\\Linux\\\\omarchy_linux-lts.efi" "$test_dir/change_kernel.calls" || fail "creates new entry"

# Verify that replacement is created before the old entry is removed
calls=$(cat "$test_dir/change_kernel.calls")
create_pos=$(grep -n "efibootmgr.*--create" <<<"$calls" | head -n 1 | cut -d: -f1)
delete_pos=$(grep -n "efibootmgr.*--delete-bootnum" <<<"$calls" | head -n 1 | cut -d: -f1)
if (( create_pos >= delete_pos )); then
  fail "expected efibootmgr --create before efibootmgr --delete-bootnum"
fi
pass "direct boot setup creates replacement before deleting existing entry"

# Test 6: Failure creating replacement leaves existing direct boot entry intact
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
  choose)
    state_file="${TEST_DIR:-/tmp}/gum_choose_state_fail"
    if [[ ! -f $state_file ]]; then
      echo 1 >"$state_file"
      OMARCHY_PATH="$OMARCHY_PATH" "$OMARCHY_PATH/bin/omarchy-i18n" directBoot.changeKernel
    else
      echo "linux-lts (omarchy_linux-lts.efi)"
    fi
    ;;
  confirm)
    [[ ${STUB_GUM_CONFIRM:-1} == 1 ]]
    ;;
  *)
    exit 0
    ;;
esac
STUB
chmod +x "$stub_bin/gum"

if STUB_EFIBOOTMGR_ENTRIES="Boot0005* Omarchy\tHD(1,GPT,...)" STUB_EFIBOOTMGR_FAIL_CREATE=1 run_direct_boot create_fail >"$test_dir/create_fail.out" 2>&1; then
  fail "direct boot setup must fail when efibootmgr --create fails"
fi
grep -q "Error: Failed to create EFI boot entry" "$test_dir/create_fail.out" || fail "reports creation failure"
if grep -q "delete-bootnum" "$test_dir/create_fail.calls"; then
  fail "must not delete existing boot entry if creating replacement fails"
fi
pass "direct boot setup preserves existing entry when replacement creation fails"

# Test 7: Hardware/firmware rejection cases
# 7a: Non-UEFI host
empty_sys="$test_dir/non_uefi_sys"
mkdir -p "$empty_sys"
if OMARCHY_SYS_ROOT="$empty_sys" run_direct_boot non_uefi >"$test_dir/non_uefi.out" 2>&1; then
  fail "must fail when system is not booted in UEFI mode"
fi
grep -q "Error: System is not booted in UEFI mode" "$test_dir/non_uefi.out" || fail "reports non-UEFI error"
pass "direct boot setup rejects non-UEFI systems"

# 7b: American Megatrends BIOS vendor
ami_sys="$test_dir/ami_sys"
mkdir -p "$ami_sys/firmware/efi" "$ami_sys/class/dmi/id"
echo "American Megatrends Inc." >"$ami_sys/class/dmi/id/bios_vendor"
if OMARCHY_SYS_ROOT="$ami_sys" run_direct_boot ami_firmware >"$test_dir/ami.out" 2>&1; then
  fail "must fail on American Megatrends firmware"
fi
grep -q "American Megatrends firmware may not safely support custom EFI entries" "$test_dir/ami.out" || fail "reports AMI firmware error"
pass "direct boot setup rejects American Megatrends firmware"

# 7c: Apple firmware
apple_sys="$test_dir/apple_sys"
mkdir -p "$apple_sys/firmware/efi" "$apple_sys/class/dmi/id"
echo "Apple Inc." >"$apple_sys/class/dmi/id/bios_vendor"
if OMARCHY_SYS_ROOT="$apple_sys" run_direct_boot apple_firmware >"$test_dir/apple.out" 2>&1; then
  fail "must fail on Apple firmware"
fi
grep -q "Apple firmware uses its own boot manager" "$test_dir/apple.out" || fail "reports Apple firmware error"
pass "direct boot setup rejects Apple firmware"

# 7d: Apple Silicon
if STUB_HW_APPLE=0 run_direct_boot apple_silicon >"$test_dir/apple_silicon.out" 2>&1; then
  fail "must fail on Apple Silicon"
fi
grep -q "Direct boot is not supported on Apple Silicon" "$test_dir/apple_silicon.out" || fail "reports Apple Silicon error"
pass "direct boot setup rejects Apple Silicon"

# Test 8: Menu choices and headers use omarchy-i18n
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
  choose)
    printf 'gum choose args: %s\n' "$*" >>"${CALL_LOG:?}"
    echo "$STUB_GUM_CHOOSE"
    ;;
  confirm)
    [[ ${STUB_GUM_CONFIRM:-1} == 1 ]]
    ;;
  *)
    exit 0
    ;;
esac
STUB
chmod +x "$stub_bin/gum"

change_expected="$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" directBoot.changeKernel)"
disable_expected="$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" directBoot.disableAction)"
header_expected="$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" directBoot.currentlyEnabled "0005")"

STUB_EFIBOOTMGR_ENTRIES="Boot0005* Omarchy\tHD(1,GPT,...)" STUB_GUM_CHOOSE="$disable_expected" output=$(run_direct_boot i18n_menu)
grep -q "gum choose args:.*$change_expected.*$disable_expected.*--header $header_expected" "$test_dir/i18n_menu.calls" || fail "gum choose action menu uses i18n labels and header"
grep -q "Removing EFI boot entry 0005" <<<"$output" || fail "action matching i18n label executes disable"
pass "direct boot setup action menu and header use i18n translations"
