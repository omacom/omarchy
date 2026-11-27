#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Reverting the switch on an ESP that another installation already boots
# through systemd-boot gives that installation back its loader, its
# loader.conf and its boot entry, and takes away only what the switch made.
# Finishing it takes over only Limine's fallback loader, and a finish that
# can't start leaves the switch revertible.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-boot-switch" >"$test_tmp/functions"

echo 0123456789abcdef0123456789abcdef >"$test_tmp/machine-id"
machine=01234567

run() {
  bash -c '
    set -euo pipefail
    source "$1/functions"
    STORE=$1/store ESP=$1/esp LOADER_PATH="\\EFI\\systemd\\systemd-bootx64.efi" LOADER_LABEL="Omarchy Boot"
    MACHINE_ID_FILE=$1/machine-id FALLBACK=EFI/BOOT/BOOTX64.EFI LOADER_SOURCE=$1/systemd-bootx64.efi
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

# Staging stopped before it backed up the ESP (the command line didn't
# convert): the switch put nothing there, so revert takes nothing away.
new_esp
mkdir -p "$test_tmp/esp/EFI/systemd" "$test_tmp/esp/loader"
printf 'theirs\n' >"$test_tmp/esp/EFI/systemd/systemd-bootx64.efi"
printf 'default theirs\n' >"$test_tmp/esp/loader/loader.conf"
run 'state_set backend limine; restore_esp' || fail "the revert runs before anything was staged"
[[ $(<"$test_tmp/esp/EFI/systemd/systemd-bootx64.efi") == theirs && $(<"$test_tmp/esp/loader/loader.conf") == "default theirs" ]] ||
  fail "another installation's systemd-boot stays when staging stopped early"
pass "a revert after staging stopped early leaves another installation's systemd-boot alone"

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

# A finish that finds no package to install hasn't started: revert still
# works, and the user is told.
new_esp
status=0
run 'state_set phase promoted; finalize' 2>/dev/null || status=$?
((status == 1)) || fail "a finish without the package stops" "exit $status"
[[ -z $(run 'state_get final_step') && $(run 'state_get notice_key') == finishNoPackage ]] ||
  fail "a finish without the package records no step and leaves a notice" "$(cat "$test_tmp/store/state")"
pass "a finish that can't find its package leaves the switch revertible"

# The finish's last step takes over the fallback loader when it is Limine's,
# whatever version that is now, and leaves another system's.
printf 'systemd-boot\n' >"$test_tmp/systemd-bootx64.efi"
finish_esp() {
  new_esp
  mkdir -p "$test_tmp/esp/EFI/BOOT"
  printf '%s\n' "$1" >"$test_tmp/esp/EFI/BOOT/BOOTX64.EFI"
  run 'state_set final_step snapshot
    boot_entry_for() { :; }
    notice() { :; }
    finalize' || fail "the finish's last step runs"
  cat "$test_tmp/esp/EFI/BOOT/BOOTX64.EFI"
}
[[ $(finish_esp 'Limine 10.1 (upgraded since staging)') == systemd-boot ]] || fail "Limine's fallback loader becomes systemd-boot"
[[ $(finish_esp 'Windows Boot Manager') == "Windows Boot Manager" ]] || fail "another system's fallback loader stays"
pass "the finish replaces Limine's fallback loader and only Limine's"

# A trial that came up puts its entry first, also when the boot order has
# nothing else in it.
new_esp
run 'state_set phase trial; state_set loader_entry 0001
  started_by_systemd_boot() { :; }
  boot_current() { echo 0001; }
  live_root() { :; }
  omarchy-boot-sync() { :; }
  efibootmgr() { if [[ ${2:-} == --bootorder ]]; then echo "$3" >"$STORE/order"; else echo "BootOrder: 0001"; fi; }
  confirm' || fail "the trial is confirmed"
[[ $(<"$test_tmp/store/order") == 0001 ]] || fail "the boot order has no empty entry" "$(cat "$test_tmp/store/order")"
pass "promoting the trial sets a boot order without a trailing comma"

[[ $(run 'esp_space_needed 1 100') == $((3 * 100 + 32 * 1024 * 1024)) ]] || fail "one kernel needs room for three images"
[[ $(run 'esp_space_needed 3 100') == $((4 * 100 + 32 * 1024 * 1024)) ]] || fail "each kernel past two needs room for another image"
pass "the ESP space check counts the installed kernels"

[[ -z $(run 'cmdline_values "$1/no-such-file"') ]] || fail "a missing Limine config has no command line"
pass "a missing Limine config reads as no command line"

# The boot store's fstab entry copies the root's, naming @omarchy-boot; a
# subvolid= the root's carries would select the root instead, so it goes.
for root_options in subvolid=256,subvol=/@ rw,subvolid=256,subvol=/@,compress=zstd subvol=@,subvolid=256 rw,subvol=/@; do
  entry=$(run 'store_fstab_entry <<<"UUID=x / btrfs '"$root_options"' 0 0"')
  options=$(awk '{ print $4 }' <<<"$entry")
  [[ $(awk '{ print $2 }' <<<"$entry") == /var/lib/omarchy/boot && ,$options, == *,subvol=/@omarchy-boot,* && $options != *subvolid=* ]] ||
    fail "the store's entry selects @omarchy-boot from root options $root_options" "$entry"
done
pass "the boot store's fstab entry selects @omarchy-boot, never the root's subvolid"
