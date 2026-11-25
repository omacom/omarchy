#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Reverting the switch on an ESP that another installation already boots
# through systemd-boot gives that installation back its loader, its
# loader.conf and its boot entry, and takes away only what the switch made.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-boot-switch" >"$test_tmp/functions"

machine=$(head -c 8 /etc/machine-id)

run() {
  bash -c '
    set -euo pipefail
    source "$1/functions"
    STORE=$1/store ESP=$1/esp LOADER_PATH="\\EFI\\systemd\\systemd-bootx64.efi" LOADER_LABEL="Omarchy Boot"
    mkdir -p "$STORE"
    eval "$2"
  ' _ "$test_tmp" "$1"
}

new_esp() {
  rm -rf "$test_tmp/esp" "$test_tmp/store"
  mkdir -p "$test_tmp/esp/EFI/Linux"
}

# Another installation's systemd-boot, there before the switch.
new_esp
mkdir -p "$test_tmp/esp/EFI/systemd" "$test_tmp/esp/loader"
printf 'theirs\n' >"$test_tmp/esp/EFI/systemd/systemd-bootx64.efi"
printf 'default theirs\n' >"$test_tmp/esp/loader/loader.conf"
printf 'theirs\n' >"$test_tmp/esp/EFI/Linux/other-os.efi"
run 'backup_esp
  printf "ours\n" >"$ESP/EFI/systemd/systemd-bootx64.efi"
  printf "default omarchy\n" >"$ESP/loader/loader.conf"
  printf "ours\n" >"$ESP/EFI/Linux/omarchy-'"$machine"'-linux-omarchy-abc.efi"
  # A second staging, after a failed trial, must not back up the switch'"'"'s own files.
  backup_esp
  restore_esp' || fail "the revert restores the ESP"
[[ $(<"$test_tmp/esp/EFI/systemd/systemd-bootx64.efi") == theirs ]] || fail "the other installation's loader comes back"
[[ $(<"$test_tmp/esp/loader/loader.conf") == "default theirs" ]] || fail "the other installation's loader.conf comes back"
[[ ! -e $test_tmp/esp/EFI/Linux/omarchy-$machine-linux-omarchy-abc.efi ]] || fail "this machine's boot images go"
[[ -f $test_tmp/esp/EFI/Linux/other-os.efi ]] || fail "the other installation's boot image stays"
pass "a revert gives another installation back its systemd-boot files"

# Nothing there before: the revert leaves no systemd-boot behind.
new_esp
run 'backup_esp
  mkdir -p "$ESP/EFI/systemd" "$ESP/loader"
  printf "ours\n" >"$ESP/EFI/systemd/systemd-bootx64.efi"
  printf "default omarchy\n" >"$ESP/loader/loader.conf"
  restore_esp' || fail "the revert cleans a fresh ESP"
[[ ! -e $test_tmp/esp/EFI/systemd && ! -e $test_tmp/esp/loader/loader.conf ]] || fail "systemd-boot's files leave an ESP that had none"
pass "a revert takes systemd-boot off an ESP that had none"

# The boot entry: one the firmware already had is reused and not marked as
# the switch's, so revert leaves it; one the switch creates is marked.
new_esp
run 'boot_entry_for() { echo 0004; }
  efibootmgr() { echo "efibootmgr must not run" >&2; return 1; }
  [[ $(loader_entry) == 0004 ]]
  [[ -z $(state_get loader_entry_created) ]]' || fail "an existing entry is reused without being marked"
pass "a boot entry another installation made isn't marked for deletion"

new_esp
run 'created=$1/created
  boot_entry_for() { [[ -f $created ]] && echo 0007 || true; }
  findmnt() { echo /dev/nvme0n1p1; }
  lsblk() { case $2 in PKNAME) echo nvme0n1 ;; PARTN) echo 1 ;; esac; }
  efibootmgr() { touch "$created"; }
  [[ $(loader_entry) == 0007 ]]
  [[ $(state_get loader_entry_created) == 1 ]]' || fail "a created entry is marked"
pass "a boot entry the switch creates is marked as its own"
