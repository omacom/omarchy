#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Factory reset on a machine whose home is on another drive. A reset makes the
# machine nobody's, so the owner is asked whether that drive is erased (the
# default) or kept. Erase is done by a service that runs at every boot until
# the drive has shown up, first before first-boot setup; Keep disconnects it, takes its keyfile's key slot back, and hides it
# from the next owner's first-boot setup. The functions run as the reset and
# its finish step define them, with system commands recorded.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

source "$ROOT/install/provisioning/home-drive.sh"
{
  for function in separate_home_drive home_drive_ids home_part_of home_shares_filesystem home_subvolume_alone home_fstab_subvolume home_fstab_subdir home_erase_scope \
    home_drive_describe home_drive_erase_sources install_home_drive_erase stage_home_drive release_home_drive_key; do
    sed -n "/^$function() {/,/^}/p" "$ROOT/bin/omarchy-system-factory-reset"
  done
  sed -n '/^refuse_erase() {/,/^}/p; /^erase_pending_home_drive() {/,/^}/p' "$ROOT/bin/omarchy-system-factory-reset-erase-home"
} >"$tmp/functions.sh"
source "$tmp/functions.sh"
grep -q '^home_drive_describe() {' "$tmp/functions.sh" || fail "factory reset describes the home drive before asking"
export PATH="$ROOT/bin:$PATH" OMARCHY_PATH=$ROOT
_hd_swaps() { :; }

CALLS=$tmp/calls
: >"$CALLS"
log() { :; }
LOG_FILE=$tmp/reset.log
PROVISIONING_DIR=/var/lib/omarchy/provisioning
next=$tmp/next
mkdir -p "$next/etc"

# findmnt and lsblk as on a machine with root on nvme0n1 and an encrypted home
# on nvme1n1.
findmnt() {
  case "$*" in
    "-no SOURCE /") echo "/dev/mapper/root[/@]" ;;
    "-no SOURCE /home") echo "${HOME_SOURCE-/dev/mapper/home}" ;;
    *) return 1 ;;
  esac
}
lsblk() {
  case "$*" in
    "-nsrpo NAME,TYPE /dev/mapper/root") printf '/dev/mapper/root crypt\n/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/mapper/home") printf '/dev/mapper/home crypt\n/dev/nvme1n1p1 part\n/dev/nvme1n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/mapper/root[/@home]") printf '/dev/mapper/root crypt\n/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-no PKNAME /dev/disk/by-uuid/l1") echo nvme1n1 ;;
    *) return 1 ;;
  esac
}
blkid() {
  case "$*" in
    "-o value -s UUID /dev/nvme1n1p1") echo l1 ;;
    "-o value -s PTUUID /dev/nvme1n1") echo pt1 ;;
    "-t UUID=l1 -o device") [[ -n ${PRESENT:-} ]] && echo /dev/nvme1n1p1 ;;
    "-t PTUUID=pt1 -o device") [[ -n ${PRESENT:-} ]] && echo /dev/nvme1n1 ;;
    "-t UUID=w1 -o device") echo /dev/sdb ;;
  esac
  return 0
}
udevadm() { :; }
cryptsetup() { echo "cryptsetup $*" >>"$CALLS"; }
home_drive_erase() { echo "erase $*" >>"$CALLS"; }

[[ $(separate_home_drive) == /dev/nvme1n1 ]] || fail "a home on another disk is found" "$(separate_home_drive)"
[[ $(HOME_SOURCE="/dev/mapper/home[/home]" separate_home_drive) == /dev/nvme1n1 ]] || fail "a home mounted from a folder of another disk is found"
HOME_SOURCE="/dev/mapper/root[/@home]"
! separate_home_drive >/dev/null || fail "the image's own @home is not a separate drive"
HOME_SOURCE=""
! separate_home_drive >/dev/null || fail "no /home mount is not a separate drive"
unset HOME_SOURCE
pass "a home on another drive is told apart from the image's own @home"

# A home drive that is not plugged in at reset time: fstab and crypttab still
# name it, so the reset still asks, and stages it by those uuids.
sys=$tmp/sys
mkdir -p "$sys/etc"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h1 /home xfs defaults,nofail 0 2\n' >"$sys/etc/fstab"
printf 'home UUID=l1 /etc/cryptsetup-keys.d/home.key luks,nofail\n' >"$sys/etc/crypttab"
[[ $(home_drive_ids "$sys") == $'UUID=l1\nUUID=h1' ]] || fail "the home drive is named by its crypttab and fstab uuids" "$(home_drive_ids "$sys")"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=r /home btrfs rw,subvol=/@home 0 0\n' >"$sys/etc/fstab"
: >"$sys/etc/crypttab"
[[ -z $(home_drive_ids "$sys") ]] || fail "the image's own @home is not a home drive"
pass "a home drive is known from fstab and crypttab even when it is not connected"

# What Erase erases is decided when the owner is asked, and the question says
# it: the whole disk when it holds only the home, only the home's partition
# when the disk holds others too, and nothing when the home is a btrfs
# subvolume beside other data or on a disk the system needs.
PARTS=1
FSTYPE=xfs
SUBVOLS=""
findmnt() {
  case "$*" in
    "-no SOURCE /") echo "/dev/mapper/root[/@]" ;;
    "-no SOURCE /home") echo "${HOME_SOURCE-/dev/mapper/home}" ;;
    "-no SOURCE /boot") echo "${BOOT_SOURCE:-/dev/nvme0n1p1}" ;;
    "-no FSTYPE /home") echo "$FSTYPE" ;;
    "-no FSROOT /home") echo "${FSROOT:-/}" ;;
    *) return 1 ;;
  esac
}
lsblk() {
  case "$*" in
    "-nsrpo NAME,TYPE /dev/mapper/root") printf '/dev/mapper/root crypt\n/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/nvme0n1p1") printf '/dev/nvme0n1p1 part\n/dev/nvme0n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/nvme1n1p2") printf '/dev/nvme1n1p2 part\n/dev/nvme1n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/mapper/home") printf '/dev/mapper/home crypt\n/dev/nvme1n1p1 part\n/dev/nvme1n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/nvme1n1p1") printf '/dev/nvme1n1p1 part\n/dev/nvme1n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/sdb") echo "/dev/sdb disk" ;;
    "-ndo TYPE /dev/nvme1n1p1") echo part ;;
    "-ndo TYPE /dev/sdb") echo disk ;;
    "-ndpo PKNAME /dev/nvme1n1p1") echo /dev/nvme1n1 ;;
    "-nrpo TYPE /dev/nvme1n1") echo disk; for ((i = 0; i < PARTS; i++)); do echo part; done; echo crypt ;;
    "-nrpo TYPE /dev/sdb") echo disk ;;
    "-ndo SIZE /dev/nvme1n1" | "-ndo SIZE /dev/nvme1n1p1") echo 1.8T ;;
  esac
  return 0
}
blkid() {
  case "$*" in
    "-o value -s UUID /dev/nvme1n1p1") echo l1 ;;
    "-o value -s UUID /dev/sdb") echo w1 ;;
    "-o value -s PTUUID /dev/nvme1n1") echo pt1 ;;
    "-t UUID=l1 -o device") [[ -n ${PRESENT:-} ]] && echo /dev/nvme1n1p1 ;;
  esac
  return 0
}
btrfs() {
  case "$*" in
    "inspect-internal rootid /home") echo 257 ;;
    "subvolume list -p /home") printf '%s' "$SUBVOLS" ;;
  esac
}
df() { printf 'Used\n12G\n'; }
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\n' >"$sys/etc/fstab"

home_drive_disk=/dev/nvme1n1 home_drive_ids=""
home_drive_describe "$sys"
[[ $home_erase_target == disk && $home_erase_uuid == l1 && $home_erase_ptuuid == pt1 ]] ||
  fail "a disk holding only the home is erased whole" "$home_erase_target $home_erase_uuid $home_erase_ptuuid"
[[ $home_erase_label == "Erase the whole disk /dev/nvme1n1 (12G used)" ]] || fail "the question says the whole disk goes" "$home_erase_label"
PARTS=2
home_drive_describe "$sys"
[[ $home_erase_target == part && $home_erase_uuid == l1 && -z $home_erase_ptuuid ]] ||
  fail "a disk with other partitions loses only the home's" "$home_erase_target $home_erase_uuid"
[[ $home_erase_label == "Erase the home partition /dev/nvme1n1p1 (12G used)" ]] || fail "the question says only the partition goes" "$home_erase_label"
PARTS=1
pass "Erase takes the whole disk only when it holds nothing but the home"

FSTYPE=btrfs FSROOT=/@home
# The filesystem's top level, as mounting it shows it.
top_level=$tmp/top-level
mkdir -p "$top_level/@home/kim"
mount() { cp -a "$top_level/." "${!#}"; }
umount() { find "$1" -mindepth 1 -delete; }
# As btrfs prints them: a nested subvolume's path is relative to its parent.
SUBVOLS=$'ID 257 gen 9 parent 5 top level 5 path @home\nID 258 gen 9 parent 257 top level 257 path .snapshots\nID 259 gen 9 parent 258 top level 258 path .snapshots/1/snapshot\n'
home_drive_describe "$sys"
[[ $home_erase_target == disk ]] || fail "a btrfs home with only its own subvolumes can be erased" "$home_erase_target $home_erase_why"
SUBVOLS+=$'ID 260 gen 9 parent 5 top level 5 path @data\n'
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "a btrfs home beside other subvolumes is never erased" "$home_erase_target $home_erase_why"
# Plain files and folders outside the home subvolume do not show under /home,
# and Erase would take them with the partition.
SUBVOLS=$'ID 257 gen 9 parent 5 top level 5 path @home\n'
mkdir "$top_level/backups"
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "a btrfs home beside plain folders at the top level is never erased" "$home_erase_target $home_erase_why"
rmdir "$top_level/backups"
mount() { return 1; }
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "a top level that cannot be looked at counts as shared" "$home_erase_target $home_erase_why"
unset -f mount umount
FSTYPE=xfs SUBVOLS="" FSROOT=""
BOOT_SOURCE=/dev/nvme1n1p2
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == protected ]] || fail "a home on a disk the system needs is never erased" "$home_erase_target $home_erase_why"
unset BOOT_SOURCE
pass "a home sharing its filesystem, or on a disk the system needs, is only kept"

# Not mounted at reset time (a locked drive whose boot gave up waiting): when
# it is there, the question names it rather than calling it not connected.
home_drive_disk="" home_drive_ids=$'UUID=l1\nUUID=h1'
PRESENT=1 home_drive_describe "$sys"
[[ $home_drive_name == /dev/nvme1n1 && $home_erase_target == disk && $home_erase_uuid == l1 ]] ||
  fail "a home drive that is there but not mounted is named" "$home_drive_name $home_erase_target $home_erase_uuid"
[[ $home_erase_label == *"/dev/nvme1n1"* ]] || fail "its erase names it too" "$home_erase_label"
home_drive_describe "$sys"
[[ $home_drive_name == "your home drive (not connected)" && $home_erase_target == part && $home_erase_uuid == l1 ]] ||
  fail "a drive that is not there is erased by its uuid when it is connected" "$home_drive_name $home_erase_target $home_erase_uuid"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h1 /home btrfs rw,subvol=@home 0 0\n' >"$sys/etc/fstab"
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == unchecked ]] ||
  fail "a btrfs subvolume home that cannot be looked into is not erased blind" "$home_erase_target $home_erase_why"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\n' >"$sys/etc/fstab"
pass "a home drive that is not mounted is named when it is there, and erased only when that is safe"

# A home that is a folder inside another system's root (mounted with
# X-mount.subdir=home): erasing its partition would erase that system, so it
# is only kept, mounted or not, there or not.
home_drive_disk=/dev/nvme1n1 home_drive_ids=""
FSTYPE=ext4 FSROOT=/home home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "a mounted folder of another system's root is never erased" "$home_erase_target $home_erase_why"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h1 /home btrfs defaults,nofail,subvol=@,X-mount.subdir=home 0 0\n' >"$sys/etc/fstab"
FSTYPE=btrfs SUBVOLS=$'ID 257 gen 9 parent 5 top level 5 path @\n' home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "a btrfs root subvolume's home folder is never erased" "$home_erase_target $home_erase_why"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h1 /home ext4 defaults,nofail,X-mount.subdir=home 0 2\n' >"$sys/etc/fstab"
home_drive_disk="" home_drive_ids=$'UUID=l1\nUUID=h1'
PRESENT=1 home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared && $home_drive_name == /dev/nvme1n1p1 ]] ||
  fail "a folder of another system's root is not erased when it is there but not mounted" "$home_drive_name $home_erase_target $home_erase_why"
home_drive_describe "$sys"
[[ -z $home_erase_target && $home_erase_why == shared ]] || fail "nor when it is not connected" "$home_erase_target $home_erase_why"
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\n' >"$sys/etc/fstab"
pass "a home inside another system's root is only ever kept"

# Staged as the marker the erase worker reads.
PROVISIONING_DIR=/var/lib/omarchy/provisioning
unit_src=$next/usr/share/omarchy/install/provisioning
mkdir -p "$unit_src"
printf '[Unit]\n' >"$unit_src/omarchy-factory-reset-erase-home.service"
rm -rf "$next/var" "$next/etc/systemd"
home_drive_choice=erase home_erase_target=disk home_erase_uuid=l1 home_erase_ptuuid=pt1
(set -e; stage_home_drive "$next") || fail "an erase is staged"
[[ $(cat "$next$PROVISIONING_DIR/erase-home-drive") == $'TARGET=disk\nUUID=l1\nPTUUID=pt1' ]] ||
  fail "a whole-disk erase is staged by the home's uuid and its disk's partition table" "$(cat "$next$PROVISIONING_DIR/erase-home-drive")"
[[ -L $next/etc/systemd/system/multi-user.target.wants/omarchy-factory-reset-erase-home.service ]] ||
  fail "an erase arms the boot service that carries it out"
[[ ! -e $next$PROVISIONING_DIR/ignored-home-drives ]] || fail "an erased drive is not hidden, it is gone"
rm -rf "$next/var"
home_drive_choice=erase home_erase_target=part home_erase_uuid=l1 home_erase_ptuuid=""
stage_home_drive "$next"
[[ $(cat "$next$PROVISIONING_DIR/erase-home-drive") == $'TARGET=part\nUUID=l1' ]] ||
  fail "a partition erase is staged by the partition's uuid" "$(cat "$next$PROVISIONING_DIR/erase-home-drive")"
pass "Erase is staged for the next boot, saying what goes"

# Keep hides the drive from the next owner's first boot. The keyfile's key
# slot on it is taken back only once the reset is committed: until then the
# old root, which still has the keyfile, may be what boots again.
rm -rf "$next/var"
: >"$CALLS"
mkdir -p "$tmp/keys" "$tmp/running/etc"
: >"$tmp/keys/home.key"
printf 'home UUID=l1 /etc/cryptsetup-keys.d/home.key luks,nofail\n' >"$tmp/running/etc/crypttab"
home_drive_choice=keep home_drive_disk=/dev/nvme1n1 home_drive_ids=$'UUID=l1\nUUID=h1' home_erase_uuid=l1
HOME_DRIVE_KEYFILE=$tmp/keys/home.key stage_home_drive "$next"
[[ $(sort "$next$PROVISIONING_DIR/ignored-home-drives") == $'h1\nl1' ]] || fail "a kept drive is hidden from the next owner's first boot" "$(cat "$next$PROVISIONING_DIR/ignored-home-drives")"
[[ ! -e $next$PROVISIONING_DIR/erase-home-drive ]] || fail "a kept drive is not erased"
! grep -q luksRemoveKey "$CALLS" || fail "staging the reset leaves the keyfile's key slot alone" "$(cat "$CALLS")"
HOME_DRIVE_KEYFILE=$tmp/keys/home.key release_home_drive_key "$tmp/running"
grep -qx "cryptsetup luksRemoveKey /dev/disk/by-uuid/l1 $tmp/keys/home.key" "$CALLS" ||
  fail "a committed reset takes back the keyfile's key slot" "$(cat "$CALLS")"
pass "Keep hides the drive, and takes its key slot back only once the reset is committed"

# A machine installed before this feature: its factory snapshot has neither
# the erase service nor its helpers. The reset brings them from the running
# system, so the erase it promises happens.
old=$tmp/old-next
mkdir -p "$old/etc"
PROVISIONING_DIR=/var/lib/omarchy/provisioning
home_drive_choice=erase home_erase_target=part home_erase_uuid=l1 home_erase_ptuuid=""
(set -e; OMARCHY_PATH=$ROOT stage_home_drive "$old") || fail "an erase is staged on a snapshot from before this feature"
unit=$old/etc/systemd/system/omarchy-factory-reset-erase-home.service
[[ -f $unit && -L $old/etc/systemd/system/multi-user.target.wants/omarchy-factory-reset-erase-home.service ]] ||
  fail "the erase service is installed and enabled from the running system"
grep -qx 'ExecStart=/usr/local/sbin/omarchy-factory-reset-erase-home' "$unit" || fail "the service runs the worker the reset installed" "$(cat "$unit")"
[[ -x $old/usr/local/sbin/omarchy-factory-reset-erase-home && -f $old/usr/local/lib/omarchy/home-drive.sh ]] ||
  fail "the worker and its helpers come along"
if (set -e; OMARCHY_PATH=$tmp/nowhere stage_home_drive "$tmp/other-next") 2>/dev/null; then
  fail "a reset that cannot carry out the erase refuses rather than promising it"
fi
pass "the erase is installed from the running system, never silently skipped"

# /home on its own partition of the system disk (set up by hand) is not a home
# drive: the reset never offers to erase it. Erasing it would erase root.
findmnt() { [[ "$*" == "-no SOURCE /" ]] && echo "/dev/nvme0n1p2[/@]"; return 0; }
lsblk() {
  case "$*" in
    "-nsrpo NAME,TYPE /dev/nvme0n1p2") printf '/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/nvme0n1p3") printf '/dev/nvme0n1p3 part\n/dev/nvme0n1 disk\n' ;;
    "-ndo TYPE /dev/nvme0n1p3") echo part ;;
    "-no PKNAME /dev/nvme0n1p3") echo nvme0n1 ;;
  esac
  return 0
}
blkid() { [[ "$*" == "-t UUID=h3 -o device" ]] && echo /dev/nvme0n1p3; return 0; }
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h3 /home xfs defaults 0 2\n' >"$sys/etc/fstab"
: >"$sys/etc/crypttab"
[[ -z $(home_drive_ids "$sys") ]] || fail "a home partition on the system disk is not a home drive" "$(home_drive_ids "$sys")"
[[ $(home_drive_system_disks) == /dev/nvme0n1 ]] || fail "the disk holding / is known" "$(home_drive_system_disks)"
pass "a home partition on the system disk is never treated as a home drive"

# Everything the running system needs is protected, not only the disk of /:
# the ESP (/boot, /efi) and active swap may be on other disks. When / itself
# cannot be traced to a disk, every disk counts as the system's.
findmnt() {
  case "$*" in
    "-no SOURCE /") echo "${ROOT_SOURCE-/dev/nvme0n1p2[/@]}" ;;
    "-no SOURCE /boot") echo /dev/sda1 ;;
    *) return 1 ;;
  esac
}
_hd_swaps() { echo /dev/sdc2; }
lsblk() {
  case "$*" in
    "-nsrpo NAME,TYPE /dev/nvme0n1p2") printf '/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-nsrpo NAME,TYPE /dev/sda1") printf '/dev/sda1 part\n/dev/sda disk\n' ;;
    "-nsrpo NAME,TYPE /dev/sdc2") printf '/dev/sdc2 part\n/dev/sdc disk\n' ;;
    "-nsrpo NAME,TYPE /dev/sdd1") printf '/dev/sdd1 part\n/dev/sdd disk\n' ;;
  esac
  return 0
}
[[ $(home_drive_system_disks | sort) == $'/dev/nvme0n1\n/dev/sda\n/dev/sdc' ]] ||
  fail "the disks of /, the ESP and swap are all protected" "$(home_drive_system_disks)"
ROOT_SOURCE=""
home_drive_system_disks | grep -qx unknown || fail "a root that cannot be traced protects everything" "$(home_drive_system_disks)"
blkid() { [[ "$*" == "-t UUID=h4 -o device" ]] && echo /dev/sdd1; return 0; }
printf 'UUID=r / btrfs rw,subvol=/@ 0 0\nUUID=h4 /home xfs defaults 0 2\n' >"$sys/etc/fstab"
[[ -z $(home_drive_ids "$sys") ]] || fail "with the system disk unknown no drive is taken for a home drive" "$(home_drive_ids "$sys")"
unset ROOT_SOURCE
[[ $(home_drive_ids "$sys") == UUID=h4 ]] || fail "a home on a disk the system does not use is a home drive" "$(home_drive_ids "$sys")"
pass "the ESP and swap disks are protected too, and an unknown root protects everything"

# The erase worker, at boot. The marker names the drive by its uuid alone
# (device names change between boots), says whether its whole disk or only
# its partition goes, and pins a whole disk to its partition table. Root is
# on nvme0n1; the home drive is nvme1n1, its home on p1.
PROVISIONING_DIR=$tmp/finish/provisioning
mkdir -p "$PROVISIONING_DIR"
marker=$PROVISIONING_DIR/erase-home-drive
findmnt() { [[ "$*" == "-no SOURCE /" && -z ${ROOT_UNKNOWN:-} ]] && echo "/dev/nvme0n1p2[/@]"; return 0; }
_hd_swaps() { :; }
lsblk() {
  case "$*" in
    "-nsrpo NAME,TYPE /dev/nvme0n1p2") printf '/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' ;;
    "-ndo TYPE /dev/nvme1n1p1" | "-ndo TYPE /dev/nvme0n1p3") echo part ;;
    "-ndo TYPE /dev/nvme1n1" | "-ndo TYPE /dev/sdb") echo disk ;;
    "-ndpo PKNAME /dev/nvme1n1p1") echo /dev/nvme1n1 ;;
    "-ndpo PKNAME /dev/nvme0n1p3") echo /dev/nvme0n1 ;;
  esac
  return 0
}
blkid() {
  case "$*" in
    "-t UUID=l1 -o device") [[ -n ${ABSENT:-} ]] || echo /dev/nvme1n1p1 ;;
    "-t UUID=w1 -o device") echo /dev/sdb ;;
    "-t UUID=h3 -o device") echo /dev/nvme0n1p3 ;;
    "-t UUID=twin -o device") printf '/dev/nvme1n1p1\n/dev/sdb1\n' ;;
    "-o value -s PTUUID /dev/nvme1n1") echo "${DISK_PTUUID:-pt1}" ;;
  esac
  return 0
}
TREE=""
_hd_lsblk_tree() { printf '%s\n' "$TREE"; }
home_drive_erase() { echo "erase $*" >>"$CALLS"; [[ -z ${ERASE_FAILS:-} ]]; }
# The worker's status: 0 erased, 1 still pending, 2 refused and dropped.
worker() {
  local status=0
  printf '%s\n' "$@" >"$marker"
  : >"$CALLS"
  erase_pending_home_drive 2>"$tmp/worker.err" || status=$?
  echo "$status"
}

[[ $(ABSENT=1 worker TARGET=disk UUID=l1 PTUUID=pt1) == 1 && -f $marker && ! -s $CALLS ]] ||
  fail "a drive that is not there keeps its erase for the next boot" "$(cat "$CALLS")"
[[ $(worker TARGET=disk UUID=l1 PTUUID=pt1) == 0 && $(cat "$CALLS") == "erase /dev/nvme1n1" && ! -e $marker ]] ||
  fail "a whole-disk erase erases the disk of the home's partition, once" "$(cat "$CALLS")"
[[ $(worker TARGET=part UUID=l1) == 0 && $(cat "$CALLS") == "erase /dev/nvme1n1p1" ]] ||
  fail "a partition erase erases only the home's partition" "$(cat "$CALLS")"
[[ $(worker TARGET=disk UUID=w1) == 0 && $(cat "$CALLS") == "erase /dev/sdb" ]] ||
  fail "a home straight on a disk erases that disk" "$(cat "$CALLS")"
[[ $(ERASE_FAILS=1 worker TARGET=disk UUID=l1) == 1 && -f $marker ]] || fail "a failed erase is tried again at the next boot"
pass "the worker erases the disk or the partition the marker names, and keeps trying until it is done"

[[ $(DISK_PTUUID=other worker TARGET=disk UUID=l1 PTUUID=pt1) == 2 && ! -s $CALLS && ! -e $marker ]] ||
  fail "a disk whose partition table is not the one staged is refused" "$(cat "$CALLS")"
[[ $(worker TARGET=disk UUID=twin) == 2 && ! -s $CALLS && ! -e $marker ]] || fail "a uuid on two devices is refused" "$(cat "$CALLS")"
grep -q 'more than one' "$tmp/worker.err" || fail "the refusal says why" "$(cat "$tmp/worker.err")"
TREE=$'NAME="/dev/nvme1n1p1" TYPE="part" PKNAME="/dev/nvme1n1" MOUNTPOINT="/mnt"'
[[ $(worker TARGET=part UUID=l1) == 2 && ! -s $CALLS && ! -e $marker ]] || fail "a drive in use is refused" "$(cat "$CALLS")"
TREE=""
[[ $(worker TARGET=part UUID=h3) == 2 && ! -s $CALLS && ! -e $marker ]] ||
  fail "a marker naming the system disk is refused and dropped, not retried at every boot" "$(cat "$CALLS")"
[[ $(ROOT_UNKNOWN=1 worker TARGET=disk UUID=l1) == 1 && ! -s $CALLS && -f $marker ]] ||
  fail "with the system disk unknown nothing is erased, and the erase waits" "$(cat "$CALLS")"
pass "the worker refuses a changed disk, a cloned uuid, a drive in use and the system disk"
