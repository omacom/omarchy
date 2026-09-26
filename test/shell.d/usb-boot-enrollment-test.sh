#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$ROOT/bin/omarchy-usb-authorization-boot"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
usb_authorization_secure_boot_enabled() { return 0; }
usb_authorization_limine_settings() { printf 'x64 %s\n' "${ENROLLMENT:-yes}"; }

# Real PE enrollment always runs. An optional isolated sbctl configuration also
# exercises real signatures; default runs track signed content without host keys.
sbctl() {
  if [[ $1 == sign && ${SIGN_FAIL:-0} == 1 ]]; then
    return 1
  fi
  if [[ -n ${USB_TEST_SBCTL_CONFIG:-} ]]; then
    /usr/bin/sbctl --config "$USB_TEST_SBCTL_CONFIG" "$@"
  elif [[ $1 == sign ]]; then
    sha256sum "${!#}" | cut -d ' ' -f1 >>"$scratch/signed"
  elif [[ $1 == verify ]]; then
    local digest signed=0
    digest=$(sha256sum "${!#}")
    if grep -qx "${digest%% *}" "$scratch/signed"; then signed=1; fi
    jq -n --arg file "${!#}" --argjson signed "$signed" '[{file_name: $file, is_signed: $signed}]'
  fi
}

fixture() {
  case_dir=$(mktemp -d "$scratch/case.XXXXXXXX")
  boot_path="$case_dir/boot"
  cache="$case_dir/cache"
  limine_conf="$boot_path/limine.conf"
  limine_defaults="$case_dir/defaults"
  drop_in="$case_dir/dropins/usb-authorization.conf"
  image="$boot_path/EFI/limine/limine_x64.efi"
  mkdir -p "${image%/*}" "$cache/lss" "${drop_in%/*}"
  printf 'initial menu\n' >"$limine_conf"
  printf 'initial kernel\n' >"$boot_path/kernel.efi"
  printf 'initial snapshot\n' >"$cache/lss/snapshots.json"
  printf 'initial defaults\n' >"$limine_defaults"
  : >"$scratch/signed"
  cp /usr/share/limine/BOOTX64.EFI "$image"
  if [[ ${ENROLLMENT:-yes} == yes ]]; then
    digest=$(b2sum "$limine_conf")
    limine enroll-config "$image" "${digest%% *}" --quiet
  fi
  sbctl sign "$image" >/dev/null
  cp "$image" "$case_dir/original.efi"
  usb_authorization_verify_bootloader "$limine_conf" "$boot_path"
}

# Matches the installed wrapper: restore unsigned binary, enroll, attempt sign,
# then mask failure with a successful final sync. No real ESP is ever touched.
limine-enroll-config() {
  cp /usr/share/limine/BOOTX64.EFI "$image"
  if [[ ${ENROLLMENT:-yes} == yes && ${SKIP_ENROLLMENT:-0} != 1 ]]; then
    local digest
    digest=$(b2sum "$limine_conf")
    limine enroll-config "$image" "${digest%% *}" --quiet || return 1
  fi
  sbctl sign "$image" || true
  sync -f "$image"
}

# Relocate the outer real flock into scratch. The runner stands in for the
# namespace child and deliberately mutates the same files as rebuild hooks.
transaction=$(declare -f usb_authorization_boot_transaction)
transaction=${transaction//\/run\/lock\/boot-partition.lock/$scratch\/boot.lock}
eval "$transaction"
usb_authorization_run_transaction() {
  if flock --nonblock "$scratch/boot.lock" true; then
    fail "the real boot lock must cover the entire transaction"
  fi
  printf 'changed menu\n' >"$limine_conf"
  printf 'changed kernel\n' >"$boot_path/kernel.efi"
  printf 'changed metadata\n' >"$cache/lss/snapshots.json"
  printf 'new cached backup\n' >"$cache/lss/snapshots.json.old"
  mkdir -p "$boot_path/$(</etc/machine-id)/limine_history"
  printf 'new archived backup\n' >"$boot_path/$(</etc/machine-id)/limine_history/snapshots.json.old"
  printf 'changed defaults\n' >"$limine_defaults"
  printf '%s\n' "$setting" >"$drop_in"
  if [[ ${EARLY_FAILURE:-0} == 1 ]]; then
    cp /usr/share/limine/BOOTX64.EFI "$image"
    return 1
  fi
  if [[ ${UNCHECKED_HOOK:-0} == 1 ]]; then
    limine-enroll-config
  else
    usb_authorization_enroll_config "$limine_conf" "$boot_path"
  fi
}

for failure in SIGN_FAIL SKIP_ENROLLMENT EARLY_FAILURE; do
  fixture
  if (export "$failure=1"; usb_authorization_boot_transaction enable "$cache") >"$case_dir/failure.log" 2>&1; then
    fail "$failure must reject the boot transition"
  fi
  cmp "$image" "$case_dir/original.efi" || fail "$failure must restore the signed bootloader byte-for-byte without signing"
  [[ $(<"$limine_conf") == 'initial menu' ]] || fail "$failure must restore matching menu"
  [[ $(<"$boot_path/kernel.efi") == 'initial kernel' ]] || fail "$failure must restore images referenced by that menu"
  [[ $(<"$cache/lss/snapshots.json") == 'initial snapshot' ]] || fail "$failure must restore cached snapshot metadata"
  [[ ! -e $cache/lss/snapshots.json.old && ! -e $boot_path/$(</etc/machine-id)/limine_history/snapshots.json.old ]] || fail "$failure must remove newly created recovery metadata"
  [[ $(<"$limine_defaults") == 'initial defaults' && ! -e $drop_in ]] || fail "$failure must restore settings including an absent drop-in"
  usb_authorization_verify_bootloader "$limine_conf" "$boot_path"
done
pass "USB boot transitions restore signed Limine, matching menu, images, metadata and settings on failure"

fixture
printf 'original opt-in\n' >"$drop_in"
if (SIGN_FAIL=1 UNCHECKED_HOOK=1 usb_authorization_boot_transaction disable "$cache") >"$case_dir/failure.log" 2>&1; then
  fail "final verification must reject false-success rebuild hooks"
fi
cmp "$image" "$case_dir/original.efi" || fail "false-success hooks must restore original signed Limine"
[[ $(<"$drop_in") == 'original opt-in' ]] || fail "failed disable must preserve an existing drop-in"
pass "USB boot transitions independently verify enrollment after external hooks"

for enrollment in yes no; do
  export ENROLLMENT="$enrollment"
  fixture
  usb_authorization_boot_transaction enable "$cache"
  [[ $(<"$limine_conf") == 'changed menu' && -e $drop_in ]] || fail "successful transition must commit"
  usb_authorization_verify_bootloader "$limine_conf" "$boot_path"
done
pass "USB boot transitions commit verified signing with enrollment enabled or disabled"

# Disposable Lab only: exercise the actual namespace runner and both lock
# inodes, with the installed enrollment/restore functions and real signatures.
if [[ ${USB_TEST_NAMESPACE:-0} == 1 ]]; then
  (( EUID == 0 )) || fail "namespace tests require root in the disposable guest"
  [[ -n ${USB_TEST_SBCTL_CONFIG:-} ]] || fail "namespace tests require isolated signing keys"
  export ENROLLMENT=yes
  for outcome in failure success; do
    fixture
    cp /usr/share/limine/BOOTX64.EFI "$case_dir/limine_x64.efi"
    tar -cf "$case_dir/limine.bak" -C "$case_dir" limine_x64.efi
    lock_inode=$(stat -Lc '%d:%i' /run/lock/boot-partition.lock)
    # Source the shipped functions in both the parent and namespace child.
    sed '/^if \[\[ ${BASH_SOURCE\[0\]} == "\$0" \]\]; then/,$d' "$ROOT/bin/omarchy-usb-authorization-boot" >"$case_dir/helper"
    for variable in scratch case_dir boot_path cache limine_conf limine_defaults drop_in image lock_inode; do
      printf '%s=%q\n' "$variable" "${!variable}" >>"$case_dir/helper"
    done
    declare -f sbctl usb_authorization_limine_settings usb_authorization_secure_boot_enabled >>"$case_dir/helper"
    cat >>"$case_dir/helper" <<'SCRIPT'
usb_authorization_main() {
  [[ $(stat -Lc '%d:%i' /run/lock/boot-partition.lock) != "$lock_inode" ]] || return 1
  exec 9>/run/lock/boot-partition.lock
  flock --nonblock 9 || return 1
  printf 'changed menu\n' >"$limine_conf"
  printf 'changed kernel\n' >"$boot_path/kernel.efi"
  source /usr/lib/limine/limine-common-functions
  LIMINE_DIR_PATH="${image%/*}"
  LIMINE_EFI_FILE=limine_x64.efi
  BINARY_TARGET_PATH="$image"
  BINARY_BACKUP_PATH="$case_dir/limine.bak"
  LIMINE_CONFIG_PATH="$limine_conf"
  ENABLE_ENROLL_LIMINE_CONFIG=yes
  is_sb_installed() { return 0; }
  is_uefi() { return 0; }
  limine-enroll-config() { enroll_config; }
  usb_authorization_enroll_config "$limine_conf" "$boot_path"
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  usb_authorization_boot_transaction "$1" "$cache"
fi
SCRIPT
    if [[ $outcome == failure ]]; then
      if SIGN_FAIL=1 bash "$case_dir/helper" enable >"$case_dir/namespace.log" 2>&1; then
        fail "actual namespace must reject installed wrapper's false success"
      fi
      grep -Fq 'Failed to sign' "$case_dir/namespace.log" || fail "failure must reach the installed enrollment function"
      cmp "$image" "$case_dir/original.efi" || fail "namespace rollback restores original signed bootloader"
      [[ $(<"$limine_conf") == 'initial menu' && $(<"$boot_path/kernel.efi") == 'initial kernel' ]] || fail "namespace rollback restores matching boot files"
    else
      bash "$case_dir/helper" disable >"$case_dir/namespace.log" 2>&1
      [[ $(<"$limine_conf") == 'changed menu' ]] || fail "namespace success commits"
    fi
    usb_authorization_verify_bootloader "$limine_conf" "$boot_path"
    flock --nonblock /run/lock/boot-partition.lock true || fail "outer lock must be released"
  done
  pass "USB real namespace isolates nested locks and recovers installed Limine signing failure"
fi
