#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The entries that make a home on another drive come up at boot, and their
# removal: fstab replaces the image's @home line, an encrypted home gets a
# crypttab line, and on an encrypted root a keyfile so boot asks for one
# passphrase. Factory reset removes them all, and erases a home drive when the
# owner says so: LUKS headers first, then signatures, then a discard.

source "$ROOT/install/provisioning/home-drive.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
LOG=$tmp/ops.log

new_root() {
  rm -rf "$tmp/root"
  mkdir -p "$tmp/root/etc"
  printf '# /dev/mapper/root\nUUID=r / btrfs rw,noatime,compress=zstd,subvol=/@ 0 0\nUUID=r /home btrfs rw,noatime,compress=zstd,subvol=/@home 0 0\n' >"$tmp/root/etc/fstab"
  : >"$LOG"
}
_hd_luks_add_key() { echo "add-key $1 $2 $3" >>"$LOG"; [[ -z ${ADD_KEY_FAILS:-} ]]; }
_hd_luks_test_key() { [[ -n ${KEY_ENROLLED:-} ]]; }

new_root
home_drive_mount_entries "$tmp/root" u1 xfs "" "" false "" ""
! grep -q 'subvol=/@home' "$tmp/root/etc/fstab" || fail "the image's @home line is replaced" "$(cat "$tmp/root/etc/fstab")"
grep -qx 'UUID=u1 /home xfs defaults,nofail,x-systemd.device-timeout=10s 0 2' "$tmp/root/etc/fstab" || fail "an XFS home is mounted by uuid with nofail" "$(cat "$tmp/root/etc/fstab")"
grep -q ' / btrfs ' "$tmp/root/etc/fstab" || fail "the root line stays"
[[ ! -e $tmp/root/etc/crypttab ]] || fail "an unencrypted home writes no crypttab"
pass "an unencrypted home replaces the @home line in fstab"

new_root
home_drive_mount_entries "$tmp/root" u2 btrfs @home "" false "" ""
grep -qx 'UUID=u2 /home btrfs defaults,nofail,x-systemd.device-timeout=10s,noatime,compress=zstd,subvol=@home 0 0' "$tmp/root/etc/fstab" || fail "a btrfs home mounts its subvolume" "$(cat "$tmp/root/etc/fstab")"
pass "a btrfs home is mounted like the root (noatime, zstd) with its subvolume and no fsck pass"

new_root
home_drive_mount_entries "$tmp/root" u3 xfs "" l3 true "" secret
grep -qx 'home UUID=l3 /etc/cryptsetup-keys.d/home.key luks,x-systemd.device-timeout=10s' "$tmp/root/etc/crypttab" || fail "an encrypted home on an encrypted root unlocks with a keyfile" "$(cat "$tmp/root/etc/crypttab")"
key=$tmp/root/etc/cryptsetup-keys.d/home.key
[[ $(stat -c %a "$key") == 400 && $(stat -c %s "$key") == 64 ]] || fail "the keyfile is 64 bytes, readable by its owner only"
grep -qx "add-key /dev/disk/by-uuid/l3 secret $key" "$LOG" || fail "the keyfile is added to the home's LUKS" "$(cat "$LOG")"
grep -qx '/dev/mapper/home /home xfs defaults,nofail 0 2' "$tmp/root/etc/fstab" || fail "fstab mounts the opened mapping, with no time limit of its own" "$(cat "$tmp/root/etc/fstab")"
pass "an encrypted home on an encrypted root gets crypttab, a keyfile and a key slot"

new_root
home_drive_mount_entries "$tmp/root" u4 xfs "" l4 false "" secret
# Not nofail: boot waits at the prompt, and the wait for the opened mapping
# has no limit, so the passphrase can take as long as it takes. A drive that
# is missing holds boot up for the ten seconds only.
grep -qx 'home UUID=l4 none luks,x-systemd.device-timeout=10s' "$tmp/root/etc/crypttab" || fail "an encrypted home on an unencrypted root asks at boot, before login" "$(cat "$tmp/root/etc/crypttab")"
[[ ! -e $tmp/root/etc/cryptsetup-keys.d/home.key ]] || fail "no keyfile lands on an unencrypted root"
[[ ! -s $LOG ]] || fail "no key slot is added for an unencrypted root"
grep -qx '/dev/mapper/home /home xfs defaults,nofail 0 2' "$tmp/root/etc/fstab" || fail "the mount waits for the passphrase, not ten seconds" "$(cat "$tmp/root/etc/fstab")"
pass "an encrypted home on an unencrypted root keeps its passphrase prompt"

new_root
home_drive_mount_entries "$tmp/root" u5 xfs "" l5 true "" secret
home_drive_mount_entries "$tmp/root" u5 xfs "" l5 true "" secret
(($(grep -c ' /home ' "$tmp/root/etc/fstab") == 1)) || fail "writing the entries twice leaves one fstab line"
(($(grep -c '^home ' "$tmp/root/etc/crypttab") == 1)) || fail "writing the entries twice leaves one crypttab line"
pass "writing the entries again replaces them"

removed=$(home_drive_unmount_entries "$tmp/root")
[[ $removed == l5 ]] || fail "removing the entries names the LUKS volume whose key slot goes too" "$removed"
! grep -q ' /home ' "$tmp/root/etc/fstab" || fail "the home line is gone from fstab"
! grep -q '^home ' "$tmp/root/etc/crypttab" || fail "the home line is gone from crypttab"
[[ ! -e $tmp/root/etc/cryptsetup-keys.d/home.key ]] || fail "the keyfile is gone"
grep -q ' / btrfs ' "$tmp/root/etc/fstab" || fail "other fstab lines stay"
pass "the entries can be removed again"

LSBLK=$'NAME="/dev/vdb" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb1" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="crypto_LUKS" UUID="l" PKNAME="/dev/vdb"
NAME="/dev/vdb2" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="xfs" UUID="x" PKNAME="/dev/vdb"
NAME="/dev/vdc1" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="xfs" UUID="y" PKNAME="/dev/vdc"'
_hd_lsblk() { printf '%s\n' "$LSBLK"; }
_hd_cryptsetup() { echo "cryptsetup $*" >>"$LOG"; }
_hd_wipefs() { echo "wipefs $*" >>"$LOG"; }
_hd_blkdiscard() { echo "blkdiscard $*" >>"$LOG"; }
_hd_discard_supported() { return 0; }

: >"$LOG"
home_drive_erase /dev/vdb
expected=$'cryptsetup erase --batch-mode /dev/vdb1\nwipefs -a /dev/vdb1\nwipefs -a /dev/vdb2\nwipefs -a /dev/vdb\nblkdiscard -f /dev/vdb'
[[ $(cat "$LOG") == "$expected" ]] || fail "erasing crypto-erases LUKS, wipes every signature, then discards" "$(cat "$LOG")"
pass "erasing a home drive destroys LUKS headers, signatures and, where it can, the data"

LSBLK=$'NAME="/dev/sdc" TYPE="disk" SIZE="34359738368" RM="0" TRAN="sata" FSTYPE="crypto_LUKS" UUID="w" PKNAME=""'
: >"$LOG"
home_drive_erase /dev/sdc
[[ $(cat "$LOG") == $'cryptsetup erase --batch-mode /dev/sdc\nwipefs -a /dev/sdc\nblkdiscard -f /dev/sdc' ]] ||
  fail "LUKS straight on the disk is crypto-erased too" "$(cat "$LOG")"
pass "a disk that is LUKS without partitions is crypto-erased"

# Factory reset returns the baseline to the image's own layout: the home line
# comes back as the @home subvolume of the root filesystem, spelled like the
# root line genfstab wrote, so a reset machine mounts the image's home again.
new_root
printf 'UUID=r / btrfs rw,noatime,compress=zstd:3,space_cache=v2,subvolid=256,subvol=/@ 0 0\n' >"$tmp/root/etc/fstab"
home_drive_mount_entries "$tmp/root" u6 xfs "" l6 true "" secret
home_drive_unmount_entries "$tmp/root" >/dev/null
home_drive_restore_home_subvolume "$tmp/root"
grep -qx 'UUID=r /home btrfs rw,noatime,compress=zstd:3,space_cache=v2,subvol=/@home 0 0' "$tmp/root/etc/fstab" ||
  fail "the image's @home line is back" "$(cat "$tmp/root/etc/fstab")"
home_drive_restore_home_subvolume "$tmp/root"
(($(grep -c ' /home ' "$tmp/root/etc/fstab") == 1)) || fail "restoring twice leaves one home line"
# A root line that names its subvolume by id alone: the home line still
# names @home, or it would mount the filesystem's default subvolume.
new_root
printf 'UUID=r / btrfs rw,noatime,subvolid=256 0 0\n' >"$tmp/root/etc/fstab"
home_drive_restore_home_subvolume "$tmp/root"
grep -qx 'UUID=r /home btrfs rw,noatime,subvol=/@home 0 0' "$tmp/root/etc/fstab" ||
  fail "a root line with only subvolid= still gets an @home line" "$(cat "$tmp/root/etc/fstab")"
pass "the image's @home mount comes back after the home drive's entries go"

# A keyfile from an earlier attempt whose key slot never made it is enrolled
# now, and a failure to enrol one fails the step instead of leaving a boot
# that asks for a second passphrase.
new_root
mkdir -p "$tmp/root/etc/cryptsetup-keys.d"
head -c 64 /dev/urandom >"$tmp/root/etc/cryptsetup-keys.d/home.key"
home_drive_mount_entries "$tmp/root" u7 xfs "" l7 true "" secret
grep -q '^add-key /dev/disk/by-uuid/l7 ' "$LOG" || fail "a keyfile that does not open the drive is enrolled" "$(cat "$LOG")"
new_root
if ADD_KEY_FAILS=1 home_drive_mount_entries "$tmp/root" u8 xfs "" l8 true "" secret 2>/dev/null; then
  fail "a key slot that could not be added fails the step"
fi
new_root
mkdir -p "$tmp/root/etc/cryptsetup-keys.d"
head -c 64 /dev/urandom >"$tmp/root/etc/cryptsetup-keys.d/home.key"
KEY_ENROLLED=1 home_drive_mount_entries "$tmp/root" u9 xfs "" l9 true "" secret
! grep -q '^add-key' "$LOG" || fail "an enrolled keyfile is not added again"
pass "the keyfile is enrolled exactly when it does not open the drive"

# The files keep their modes: Arch ships crypttab readable by root only.
new_root
printf 'home UUID=old none luks\n' >"$tmp/root/etc/crypttab"
chmod 600 "$tmp/root/etc/crypttab"
KEY_ENROLLED=1 home_drive_mount_entries "$tmp/root" u10 xfs "" l10 false "" secret
home_drive_unmount_entries "$tmp/root" >/dev/null
[[ $(stat -c %a "$tmp/root/etc/crypttab") == 600 ]] || fail "crypttab stays readable by root only" "$(stat -c %a "$tmp/root/etc/crypttab")"
pass "fstab and crypttab keep their modes"

# A btrfs home at the top level of its filesystem, not in a subvolume.
new_root
home_drive_mount_entries "$tmp/root" u11 btrfs "" "" false "" ""
grep -qx 'UUID=u11 /home btrfs defaults,nofail,x-systemd.device-timeout=10s,noatime,compress=zstd,subvolid=5 0 0' "$tmp/root/etc/fstab" ||
  fail "a top-level btrfs home mounts the top level, not the default subvolume" "$(cat "$tmp/root/etc/fstab")"
pass "a btrfs home at the top level mounts subvolid=5"

# An erase that did not happen is not reported as done: a failed crypto-erase
# or wipe fails the whole erase. A disk that cannot discard is still erased.
LSBLK=$'NAME="/dev/vdb" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb1" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="crypto_LUKS" UUID="l" PKNAME="/dev/vdb"'
_hd_wipefs() { echo "wipefs $*" >>"$LOG"; [[ -z ${WIPE_FAILS:-} ]]; }
_hd_blkdiscard() { echo "blkdiscard $*" >>"$LOG"; [[ -z ${DISCARD_FAILS:-} ]]; }
if WIPE_FAILS=1 home_drive_erase /dev/vdb 2>/dev/null; then fail "a failed wipe fails the erase"; fi
_hd_cryptsetup() { echo "cryptsetup $*" >>"$LOG"; [[ -z ${CRYPT_FAILS:-} ]]; }
if CRYPT_FAILS=1 home_drive_erase /dev/vdb 2>/dev/null; then fail "a failed crypto-erase fails the erase"; fi
DISCARD_FAILS=1 home_drive_erase /dev/vdb || fail "a disk that cannot discard is still erased"
pass "an erase reports failure unless every required step succeeded"

# A home partition on a disk that holds other partitions is erased on its own:
# its LUKS header, its signatures and its blocks, nothing beside it, and
# never a mapping stacked on it.
LSBLK=$'NAME="/dev/vdb" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb1" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="crypto_LUKS" UUID="l" PKNAME="/dev/vdb"
NAME="/dev/mapper/home" TYPE="crypt" SIZE="1000" RM="0" TRAN="" FSTYPE="xfs" UUID="x" PKNAME="/dev/vdb1"
NAME="/dev/vdb2" TYPE="part" SIZE="1000" RM="0" TRAN="" FSTYPE="ext4" UUID="y" PKNAME="/dev/vdb"'
: >"$LOG"
home_drive_erase /dev/vdb1
[[ $(cat "$LOG") == $'cryptsetup erase --batch-mode /dev/vdb1\nwipefs -a /dev/vdb1\nblkdiscard -f /dev/vdb1' ]] ||
  fail "erasing a partition touches that partition only" "$(cat "$LOG")"
pass "a home partition is erased without the partitions beside it"

# In use: mounted, swapped on, or held by something stacked on it (an open
# LUKS mapping). A disk's own partitions are not holders.
TREE=$'NAME="/dev/vdb" TYPE="disk" PKNAME="" MOUNTPOINT=""
NAME="/dev/vdb1" TYPE="part" PKNAME="/dev/vdb" MOUNTPOINT=""'
_hd_lsblk_tree() { printf '%s\n' "$TREE"; }
! home_drive_in_use /dev/vdb || fail "a disk with idle partitions is not in use"
TREE+=$'\nNAME="/dev/vdb2" TYPE="part" PKNAME="/dev/vdb" MOUNTPOINT="/mnt/data"'
home_drive_in_use /dev/vdb || fail "a disk with a mounted partition is in use"
TREE=$'NAME="/dev/vdb1" TYPE="part" PKNAME="/dev/vdb" MOUNTPOINT=""
NAME="/dev/mapper/home" TYPE="crypt" PKNAME="/dev/vdb1" MOUNTPOINT=""'
home_drive_in_use /dev/vdb1 || fail "a partition with an open LUKS mapping is in use"
pass "a drive that is mounted or held open counts as in use"

# A home inside another system's root: only its home folder is mounted at
# /home (libmount's X-mount.subdir), nothing else of that system. The dir
# comes before the passphrase.
new_root
home_drive_mount_entries "$tmp/root" u12 ext4 "" "" false home ""
grep -qx 'UUID=u12 /home ext4 defaults,nofail,x-systemd.device-timeout=10s,X-mount.subdir=home 0 2' "$tmp/root/etc/fstab" ||
  fail "a home inside a system mounts only its home folder" "$(cat "$tmp/root/etc/fstab")"
new_root
home_drive_mount_entries "$tmp/root" u13 btrfs @ l13 true home secret
grep -qx '/dev/mapper/home /home btrfs defaults,nofail,noatime,compress=zstd,subvol=@,X-mount.subdir=home 0 0' "$tmp/root/etc/fstab" ||
  fail "a home inside a btrfs root subvolume mounts that subvolume's home folder" "$(cat "$tmp/root/etc/fstab")"
grep -qx "add-key /dev/disk/by-uuid/l13 secret $tmp/root/etc/cryptsetup-keys.d/home.key" "$LOG" || fail "the passphrase is the argument after dir" "$(cat "$LOG")"
[[ $(home_drive_unmount_entries "$tmp/root") == l13 ]] && ! grep -q ' /home ' "$tmp/root/etc/fstab" ||
  fail "the subdir home line is removed like any other" "$(cat "$tmp/root/etc/fstab")"
pass "a home inside another system mounts only that folder, and is removed like any other"
