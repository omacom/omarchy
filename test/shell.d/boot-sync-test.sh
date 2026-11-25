#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-boot-sync's sync publishes one boot image per installed kernel and a
# profile per snapshot, from the boot store to the ESP. Run whole here, against
# a store, a btrfs top level and an ESP in directories, with ukify stubbed.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/ukify" <<'SH'
#!/bin/bash
for arg; do
  case $arg in --output=*) out=${arg#--output=} ;; esac
done
[[ " $* " != *" --linux="* ]] || echo "$*" >>"$UKIFY_LOG"
printf 'uki\n' >"$out"
SH
chmod +x "$test_tmp/bin/ukify"

ns=01234567
file_of() { echo "omarchy-$ns-$1.efi"; }

# An image in the store: name, pkgbase, kernel version.
add_image() {
  mkdir -p "$test_tmp/store/images/$1"
  printf 'k\n' >"$test_tmp/store/images/$1/vmlinuz"
  printf 'i\n' >"$test_tmp/store/images/$1/initramfs.img"
  printf 'PKGBASE=%s\nKVER=%s\nCMDLINE=root=UUID=1 rootflags=subvol=@ rw\n' "$2" "$3" >"$test_tmp/store/images/$1/manifest"
}

# A kernel installed in a root.
install_kernel() {
  mkdir -p "$1/usr/lib/modules/$3"
  echo "$2" >"$1/usr/lib/modules/$3/pkgbase"
}

# A snapshot of a root, pinned to an image.
add_snapshot() {
  mkdir -p "$1/.snapshots/$2/snapshot"
  echo "$3" >"$1/.snapshots/$2/omarchy-boot-image"
  printf '<snapshot><description>test</description><date>2026-11-01 10:00:00</date></snapshot>\n' >"$1/.snapshots/$2/info.xml"
}

new_machine() {
  rm -rf "$test_tmp/store" "$test_tmp/top" "$test_tmp/esp" "$test_tmp/next" "$test_tmp/ukify.log"
  mkdir -p "$test_tmp/store/current" "$test_tmp/esp"
  echo "${ns}89abcdef0123456789abcdef" >"$test_tmp/machine-id"
  : >"$test_tmp/store/state"
  add_image live linux-omarchy 7.2
  ln -s ../images/live "$test_tmp/store/current/linux-omarchy"
  install_kernel "$test_tmp/top/@" linux-omarchy 7.2
}

sync_boot() {
  env PATH="$test_tmp/bin:$PATH" UKIFY_LOG="$test_tmp/ukify.log" OMARCHY_BOOT_TEST=1 \
    OMARCHY_BOOT_STORE="$test_tmp/store" OMARCHY_BOOT_ESP="$test_tmp/esp" OMARCHY_BOOT_TOP="$test_tmp/top" \
    OMARCHY_BOOT_LOCK="$test_tmp/lock" OMARCHY_BOOT_MACHINE_ID="$test_tmp/machine-id" \
    OMARCHY_BOOT_UKI_CONFIG="$test_tmp/uki.conf" \
    "$@" bash "$ROOT/bin/omarchy-boot-sync" sync >>"$test_tmp/sync.log" 2>&1 ||
    fail "the sync runs" "$(cat "$test_tmp/sync.log")"
}

builds() { [[ -f $test_tmp/ukify.log ]] && wc -l <"$test_tmp/ukify.log" || echo 0; }

# A kernel removed while the switch was on trial (no removal hook ran) is
# still the preferred kernel and still has a current image. The sync drops
# both instead of pointing loader.conf at an image it no longer publishes.
new_machine
add_image lts linux-lts 6.6
ln -s ../images/lts "$test_tmp/store/current/linux-lts"
echo preferred=linux-lts >"$test_tmp/store/state"
sync_boot
[[ ! -e $test_tmp/store/current/linux-lts ]] || fail "a kernel that isn't installed loses its current image"
[[ $(<"$test_tmp/esp/loader/loader.conf") == "default $(file_of live)" && -s $test_tmp/esp/EFI/Linux/$(file_of live) ]] ||
  fail "loader.conf points at a published image of an installed kernel" "$(cat "$test_tmp/esp/loader/loader.conf"; ls "$test_tmp/esp/EFI/Linux")"
[[ ! -d $test_tmp/store/images/lts ]] || fail "the removed kernel's unpinned image goes"
pass "a kernel that is no longer installed leaves the default and the store"

# A root that shows no kernels is a mount gone wrong: nothing is dropped.
new_machine
rm -rf "$test_tmp/top/@/usr/lib/modules"
sync_boot
[[ -L $test_tmp/store/current/linux-omarchy ]] || fail "a root without kernels drops no current image"
pass "a root that shows no kernels keeps every current image"

# A pending restore of a snapshot on another image: the restored root's entry
# is that image's second profile while the snapshot is listed on it, and its
# first once the snapshot is gone. The journal follows.
new_machine
add_image old linux-omarchy 7.1
add_snapshot "$test_tmp/top/@" 12 old
mkdir -p "$test_tmp/store/restore"
printf 'TX=1\nSTATE=pending\nSOURCE=12\nIMAGE=old\nPREVIOUS_IMAGE=live\nONESHOT=stale\n' >"$test_tmp/store/restore/journal"
sync_boot
[[ $(sed -n 's/^ONESHOT=//p' "$test_tmp/store/restore/journal") == "$(file_of old)@omarchy-restored" ]] ||
  fail "the journal names the restored root's entry" "$(cat "$test_tmp/store/restore/journal" "$test_tmp/store/entries")"
rm -rf "$test_tmp/top/@/.snapshots/12"
sync_boot
[[ $(sed -n 's/^ONESHOT=//p' "$test_tmp/store/restore/journal") == "$(file_of old)" ]] ||
  fail "the journal follows the restored root's entry when the image's profiles change" "$(cat "$test_tmp/store/restore/journal" "$test_tmp/store/entries")"
pass "a pending restore's journal names the restored root's entry as last published"

# A factory reset publishes the root it builds: the old owner's snapshots,
# still in @ while it runs, are not that root's.
new_machine
add_snapshot "$test_tmp/top/@" 5 live
install_kernel "$test_tmp/next" linux-omarchy 7.2
add_snapshot "$test_tmp/next" 3 live
sync_boot OMARCHY_BOOT_LIVE_ROOT="$test_tmp/next"
! grep -q '^snapshot-5' "$test_tmp/store/entries" || fail "the old owner's snapshot gets no entry" "$(cat "$test_tmp/store/entries")"
grep -q '^snapshot-3' "$test_tmp/store/entries" || fail "the new root's snapshot gets its entry" "$(cat "$test_tmp/store/entries")"
pass "a sync for another root lists that root's snapshots, not @'s"

# uki.conf and the device trees it names are inputs of the published image.
new_machine
printf 'tree-1\n' >"$test_tmp/laptop.dtb"
printf '[UKI]\nDeviceTree=%s/laptop.dtb\n' "$test_tmp" >"$test_tmp/uki.conf"
sync_boot
[[ $(builds) == 1 ]] || fail "the first sync builds the image" "$(builds)"
sync_boot
[[ $(builds) == 1 ]] || fail "an unchanged image isn't rebuilt" "$(builds)"
printf 'tree-2\n' >"$test_tmp/laptop.dtb"
sync_boot
[[ $(builds) == 2 ]] || fail "a changed device tree rebuilds the image" "$(builds)"
rm -f "$test_tmp/uki.conf"
pass "a published image is rebuilt when a device tree it carries changes"

# Boot images carry no splash: the firmware hands over straight to Plymouth's
# unlock screen. A splash a store kept from before goes.
new_machine
printf 'BM-old-splash\n' >"$test_tmp/store/splash.bmp"
sync_boot
[[ $(builds) == 1 ]] || fail "the sync builds the image" "$(builds)"
! grep -q -- '--splash' "$test_tmp/ukify.log" || fail "the image is built without a splash" "$(cat "$test_tmp/ukify.log")"
[[ ! -e $test_tmp/store/splash.bmp ]] || fail "an old splash leaves the store"
pass "boot images carry no splash"

# A pending restore keeps the live image it replaces: the commit records it
# as "Before restore".
new_machine
add_image restored linux-omarchy 7.1
mkdir -p "$test_tmp/store/restore"
printf 'TX=1\nSTATE=swapped\nIMAGE=restored\nPREVIOUS_IMAGE=live\n' >"$test_tmp/store/restore/journal"
ln -sfn ../images/restored "$test_tmp/store/current/linux-omarchy"
sync_boot
[[ -d $test_tmp/store/images/live ]] || fail "the image a pending restore replaces is kept"
pass "a pending restore keeps the image it replaces"

# A restore staged, then the live image rebuilt before the reboot: the
# maintenance profile moves to the new image, and the firmware's one-shot boot
# follows it.
new_machine
add_image old linux-omarchy 7.1
add_snapshot "$test_tmp/top/@" 12 old
mkdir -p "$test_tmp/store/restore" "$test_tmp/efivars"
printf 'TX=1\nSTATE=pending\nSOURCE=12\nIMAGE=old\nPREVIOUS_IMAGE=live\n' >"$test_tmp/store/restore/journal"
cat >"$test_tmp/bin/bootctl" <<SH
#!/bin/bash
echo "\$*" >>"$test_tmp/bootctl.log"
SH
chmod +x "$test_tmp/bin/bootctl"
oneshot() { { printf '\7\0\0\0'; printf '%s' "$1" | sed 's/./&\x00/g'; } >"$test_tmp/efivars/LoaderEntryOneShot-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f"; }
oneshot "omarchy-${ns}-old-image.efi@omarchy-restore"
rm -f "$test_tmp/bootctl.log"
sync_boot env OMARCHY_BOOT_EFIVARS="$test_tmp/efivars"
[[ $(<"$test_tmp/bootctl.log") == "set-oneshot $(file_of live)@omarchy-restore" ]] ||
  fail "the one-shot boot follows the maintenance profile" "$(cat "$test_tmp/bootctl.log" 2>/dev/null; cat "$test_tmp/store/entries")"
oneshot "$(file_of live)@omarchy-restore"
rm -f "$test_tmp/bootctl.log"
sync_boot env OMARCHY_BOOT_EFIVARS="$test_tmp/efivars"
[[ ! -e $test_tmp/bootctl.log ]] || fail "a one-shot boot already right is left alone" "$(cat "$test_tmp/bootctl.log")"
oneshot "$(file_of old)@snapshot-12"
sync_boot env OMARCHY_BOOT_EFIVARS="$test_tmp/efivars"
[[ ! -e $test_tmp/bootctl.log ]] || fail "a snapshot boot the user chose stays armed" "$(cat "$test_tmp/bootctl.log")"
rm -f "$test_tmp/bin/bootctl"
pass "a pending restore's maintenance boot follows the rebuilt live image"
