#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# home_drive_scan through the layers a home sits under on other distributions:
# LUKS (opened with the user's password, else offered as locked; read through
# its mapping when something already opened it), and btrfs home subvolumes as Omarchy/Arch
# (@home), Fedora (home) and openSUSE (@/home) lay them out. Whatever the scan
# opens it closes again, and a filesystem that is already mounted is read where
# it is rather than mounted a second time. LVM is not offered yet: a home on a
# logical volume gets no row, and the scan activates nothing.

source "$ROOT/install/provisioning/home-drive.sh"
eval "$(declare -f _hd_mountpoint | sed '1s/_hd_mountpoint/real_hd_mountpoint/')"
eval "$(declare -f _hd_mount_fsroot | sed '1s/_hd_mount_fsroot/real_hd_mount_fsroot/')"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME_DRIVE_SCAN_DIR=$tmp/scan
LOG=$tmp/ops.log
: >"$LOG"

LSBLK=$'NAME="/dev/vda" TYPE="disk" SIZE="68719476736" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="crypto_LUKS" UUID="l-vdb1" PKNAME="/dev/vdb"
NAME="/dev/vdc" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdc1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="LVM2_member" UUID="pv-vdc1" PKNAME="/dev/vdc"
NAME="/dev/vdd" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdd1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="btrfs" UUID="b-vdd1" PKNAME="/dev/vdd"
NAME="/dev/vde" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vde1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="btrfs" UUID="b-vde1" PKNAME="/dev/vde"
NAME="/dev/vdf" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdf1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="btrfs" UUID="b-vdf1" PKNAME="/dev/vdf"
NAME="/dev/vdg" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdg1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="ext4" UUID="e-vdg1" PKNAME="/dev/vdg"
NAME="/dev/vdk" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdk1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="btrfs" UUID="b-vdk1" PKNAME="/dev/vdk"'

home_tree() { mkdir -p "$1/kim"; }
home_tree "$tmp/fs/luks-xfs"
home_tree "$tmp/fs/lvm-ext4"
home_tree "$tmp/fs/omarchy-btrfs/@home"
mkdir -p "$tmp/fs/omarchy-btrfs/@" "$tmp/fs/omarchy-btrfs/@log"
home_tree "$tmp/fs/fedora-btrfs/home"
mkdir -p "$tmp/fs/fedora-btrfs/root"
home_tree "$tmp/fs/suse-btrfs/@/home"
home_tree "$tmp/fs/already-mounted"
# Ubuntu on btrfs without a home subvolume: home/kim inside the root
# subvolume @, and a snapper snapshot of @ that holds a copy of it.
home_tree "$tmp/fs/ubuntu-btrfs/@/home"
mkdir -p "$tmp/fs/ubuntu-btrfs/@/home/sam" "$tmp/fs/ubuntu-btrfs/@/etc"
home_tree "$tmp/fs/ubuntu-btrfs/@/.snapshots/1/snapshot/home"

declare -A FIXTURE=(
  [/dev/mapper/omarchy-home-scan-1]=$tmp/fs/luks-xfs
  [/dev/vg/home]=$tmp/fs/lvm-ext4
  [/dev/vdd1]=$tmp/fs/omarchy-btrfs
  [/dev/vde1]=$tmp/fs/fedora-btrfs
  [/dev/vdf1]=$tmp/fs/suse-btrfs
  [/dev/vdk1]=$tmp/fs/ubuntu-btrfs
)
declare -A PROBE=(
  [/dev/mapper/omarchy-home-scan-1]="xfs x-inner"
  [/dev/vg/home]="ext4 e-lv"
  [/dev/vg/swap]="swap s-lv"
)
declare -A SUBVOLS=(
  [$tmp/fs/omarchy-btrfs]=$'@\n@home\n@log'
  [$tmp/fs/fedora-btrfs]=$'root\nhome'
  [$tmp/fs/suse-btrfs]=$'@\n@/home'
  [$tmp/fs/ubuntu-btrfs]=$'@\n@/.snapshots\n@/.snapshots/1/snapshot'
)
declare -A MOUNTED=([/dev/vdg1]=$tmp/fs/already-mounted)

_hd_lsblk() { printf '%s\n' "$LSBLK"; }
_hd_owner() {
  if [[ -d $1 && ! -L $1 ]]; then echo "1000 1000"; else echo missing; fi
}
_hd_used() { echo 4096; }
_hd_mountpoint() { printf '%s' "${MOUNTED[$1]:-}"; }
_hd_mount_ro() {
  [[ -n ${FIXTURE[$1]:-} ]] || return 1
  rmdir "$2"
  ln -s "${FIXTURE[$1]}" "$2"
  echo "mount $1" >>"$LOG"
}
_hd_umount() {
  rm "$1"
  mkdir "$1"
  echo "umount" >>"$LOG"
}
_hd_btrfs_subvols() { printf '%s\n' "${SUBVOLS[$(readlink "$1")]:-}"; }
_hd_probe() { printf '%s' "${PROBE[$1]:-}"; }
_hd_luks_open() {
  local device=$1 name=$2 password=$3
  [[ $device == /dev/vdb1 && $password == "pw-ok" ]] || return 1
  [[ $name == omarchy-home-scan-1 ]] || return 1
  echo "luks-open $device" >>"$LOG"
}
_hd_luks_close() { echo "luks-close $1" >>"$LOG"; }
# A scan mount is a link to its fixture, and the machine's other mappings are
# whatever DM_NAMES lists.
_hd_is_mounted() { [[ -L $1 ]]; }
_hd_dm_names() { printf '%s\n' "${DM_NAMES:-}"; }
_hd_luks_test() { [[ $1 == /dev/vdb1 && $2 == pw-ok ]]; }
declare -A MAPPED=()
_hd_luks_mapped() { printf '%s' "${MAPPED[$1]:-}"; }
_hd_lvm_activate() {
  [[ $1 == /dev/vdc1 ]] || return 0
  echo "lvm-activate $1" >>"$LOG"
  printf '%s\n' /dev/vg/home /dev/vg/swap
}
_hd_lvm_deactivate() { echo "lvm-deactivate $1" >>"$LOG"; }

field() { awk -F'\t' -v n="$2" '{ print $n }' <<<"$1"; }
row_for() { grep -P "^[a-z]+\thome\t$1\t" <<<"$2" || true; }

scan=$(home_drive_scan kim pw-ok /dev/vda)

row=$(row_for /dev/vdb1 "$scan")
[[ $(field "$row" 1) == adoptable && $(field "$row" 4) == xfs ]] || fail "a LUKS home that opens with the password is adoptable" "$scan"
[[ $(field "$row" 5) == x-inner && $(field "$row" 6) == l-vdb1 ]] || fail "a LUKS row carries the inner fs uuid and the LUKS uuid" "$row"
pass "a home inside LUKS opened with the user's password is adoptable"

[[ -z $(row_for /dev/vg/home "$scan") ]] || fail "a home on LVM is not offered yet" "$scan"
! grep -q '^lvm-activate' "$LOG" || fail "the scan activates no volume group"
pass "LVM is left alone"

[[ $(field "$(row_for /dev/vdd1 "$scan")" 7) == @home ]] || fail "Omarchy's @home subvolume is found" "$scan"
[[ $(field "$(row_for /dev/vde1 "$scan")" 7) == home ]] || fail "Fedora's home subvolume is found" "$scan"
[[ $(field "$(row_for /dev/vdf1 "$scan")" 7) == @/home ]] || fail "openSUSE's @/home subvolume is found" "$scan"
[[ $(field "$(row_for /dev/vdd1 "$scan")" 1) == adoptable ]] || fail "a subvolume home is adoptable" "$scan"
pass "btrfs home subvolumes are found by their distribution's name"

row=$(row_for /dev/vdk1 "$scan")
[[ $(field "$row" 1) == adoptable && $(field "$row" 7) == @ && $(field "$row" 15) == home ]] ||
  fail "a home inside a btrfs root subvolume is found at home/<user> in it" "$scan"
[[ $(field "$row" 13) == sam ]] || fail "the other folders under its home/ are the other homes" "$row"
(($(grep -c $'\t/dev/vdk1\t' <<<"$scan") == 1)) || fail "a snapshot's copy of the home is not offered" "$scan"
(($(grep -c $'\t/dev/vdf1\t' <<<"$scan") == 1)) && [[ -z $(field "$(row_for /dev/vdf1 "$scan")" 15) ]] ||
  fail "openSUSE's @/home subvolume is offered once, as the subvolume" "$scan"
pass "a home inside a btrfs root subvolume without a home subvolume is found"

[[ $(field "$(row_for /dev/vdg1 "$scan")" 1) == adoptable ]] || fail "an already mounted home is read where it is" "$scan"
! grep -q 'mount /dev/vdg1' "$LOG" || fail "an already mounted filesystem is not mounted again"
pass "an already mounted filesystem is scanned in place"

opens=$(grep -c '^luks-open' "$LOG")
closes=$(grep -c '^luks-close' "$LOG")
mounts=$(grep -c '^mount' "$LOG")
umounts=$(grep -c '^umount' "$LOG")
((opens == 1 && closes == 1)) || fail "the LUKS volume is closed after the scan" "$(cat "$LOG")"
((mounts == umounts)) || fail "every mount is unmounted" "$(cat "$LOG")"
pass "the scan closes and unmounts everything it opened"

# A retry after an install or first boot that failed part way: the home's LUKS
# is still open. The scan reads it through that mapping, and leaves it open.
: >"$LOG"
MAPPED[/dev/vdb1]=/dev/mapper/omarchy-home-scan-1
row=$(row_for /dev/vdb1 "$(home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == adoptable ]] || fail "an already open LUKS home is read without its passphrase" "$row"
! grep -q '^luks-' "$LOG" || fail "an already open LUKS volume is neither opened again nor closed" "$(cat "$LOG")"
unset 'MAPPED[/dev/vdb1]'
pass "an already open LUKS home is scanned through its mapping"

: >"$LOG"
again=$(home_drive_scan kim pw-ok /dev/vda)
[[ $again == "$scan" ]] || fail "a second scan gives the same rows" "$again"
pass "scanning again gives the same rows"

row=$(row_for /dev/vdb1 "$(home_drive_scan kim pw-bad /dev/vda)")
[[ $(field "$row" 1) == locked && $(field "$row" 14) == wrong-passphrase && $(field "$row" 6) == l-vdb1 ]] ||
  fail "a LUKS partition the password does not open is offered as locked" "$row"
pass "a LUKS partition the password does not open is locked"

# Several passphrases: the user's password and one typed for another drive.
: >"$LOG"
row=$(row_for /dev/vdb1 "$(home_drive_scan kim $'pw-typed\npw-ok' /dev/vda)")
[[ $(field "$row" 1) == adoptable ]] || fail "each passphrase is tried" "$row"
[[ $(home_drive_luks_passphrase /dev/vdb1 $'pw-typed\npw-ok') == pw-ok ]] || fail "the passphrase that opens a drive is named"
pass "every passphrase is tried, and the one that opens a drive is known"

# Drives to leave alone (the last factory reset kept them) are not opened.
: >"$LOG"
row=$(row_for /dev/vdb1 "$(HOME_DRIVE_IGNORE=l-vdb1 home_drive_scan kim pw-ok /dev/vda)")
[[ -z $row ]] || fail "an ignored drive gets no row" "$row"
! grep -q 'luks-open /dev/vdb1' "$LOG" || fail "an ignored drive is not opened"
pass "an ignored drive is neither opened nor offered"

# btrfs already mounted at a subvolume: scanned as that subvolume.
MOUNTED[/dev/vdd1]=$tmp/fs/omarchy-btrfs/@home
FSROOT=/@home
_hd_mount_fsroot() { printf '%s' "$FSROOT"; }
row=$(row_for /dev/vdd1 "$(home_drive_scan kim pw-ok /dev/vda)")
[[ $(field "$row" 1) == adoptable && $(field "$row" 7) == @home ]] || fail "a mounted btrfs subvolume is scanned as that subvolume" "$row"
unset 'MOUNTED[/dev/vdd1]'
pass "an already mounted btrfs subvolume is read as itself"

# btrfs already mounted at its top level: the home subvolumes under it count.
MOUNTED[/dev/vdd1]=$tmp/fs/omarchy-btrfs
FSROOT=/
_hd_btrfs_subvols() { printf '%s\n' "${SUBVOLS[$1]:-}"; }
row=$(row_for /dev/vdd1 "$(home_drive_scan kim pw-ok /dev/vda)")
[[ $(field "$row" 1) == adoptable && $(field "$row" 7) == @home ]] || fail "a top-level btrfs mount is searched for home subvolumes" "$row"
unset 'MOUNTED[/dev/vdd1]'
pass "an already mounted btrfs top level is searched for home subvolumes"

# findmnt writes a space in a mount point as \x20; the scan reads the real
# path.
findmnt() { printf '%s\n' '/run/media/kim/My\x20Disk'; }
[[ $(real_hd_mountpoint /dev/x) == "/run/media/kim/My Disk" ]] || fail "a mount point with a space is decoded" "$(real_hd_mountpoint /dev/x)"
[[ $(real_hd_mount_fsroot /dev/x) == "/run/media/kim/My Disk" ]] || fail "a mount root with a space is decoded" "$(real_hd_mount_fsroot /dev/x)"
unset -f findmnt
pass "mount points with spaces are read as they are"

# A filesystem mounted only as a bind of one of its folders (FSROOT /srv)
# shows that folder, not its top: the scan mounts it itself instead.
mkdir -p "$tmp/fs/bind-sub/kim"
MOUNTED[/dev/vdg1]=$tmp/fs/bind-sub
FIXTURE[/dev/vdg1]=$tmp/fs/already-mounted
FSROOT=/srv
: >"$LOG"
row=$(row_for /dev/vdg1 "$(home_drive_scan kim pw-ok /dev/vda)")
grep -qx 'mount /dev/vdg1' "$LOG" || fail "a bind mount of a folder is not read as the filesystem's top" "$(cat "$LOG")"
[[ $(field "$row" 1) == adoptable ]] || fail "the filesystem is still scanned from its top" "$row"
MOUNTED[/dev/vdg1]=$tmp/fs/already-mounted
unset 'FIXTURE[/dev/vdg1]'
FSROOT=/
pass "a bind mount of a folder is never read as the filesystem's top"

# An interrupted scan (Ctrl+C in the installer, a killed first boot) can
# leave a filesystem mounted under the scan directory or a LUKS volume open.
# The next scan clears them first, and only the scan's own mappings go.
_hd_btrfs_subvols() {
  local path=$1
  [[ -L $path ]] && path=$(readlink "$path")
  printf '%s\n' "${SUBVOLS[$path]:-}"
}
mkdir -p "$HOME_DRIVE_SCAN_DIR"
ln -s "$tmp/fs/luks-xfs" "$HOME_DRIVE_SCAN_DIR/fs.left"
DM_NAMES=$'root\nomarchy-home-scan-7'
: >"$LOG"
home_drive_scan kim pw-ok /dev/vda >/dev/null
grep -qx 'luks-close omarchy-home-scan-7' "$LOG" || fail "a mapping left by an earlier scan is closed" "$(cat "$LOG")"
! grep -qx 'luks-close root' "$LOG" || fail "only the scan's own mappings are closed" "$(cat "$LOG")"
[[ ! -e $HOME_DRIVE_SCAN_DIR/fs.left ]] || fail "a mount left by an earlier scan is unmounted and removed"
DM_NAMES=""
pass "a scan first clears what an interrupted one left behind"

# Interrupted part way through, the scan unmounts what it had mounted before
# it stops. The signal reaches the whole scan, as Ctrl+C does.
_hd_used() {
  local stat
  if [[ $1 == "$HOME_DRIVE_SCAN_DIR"/fs.*/@home && $(readlink -f "$1") == "$(readlink -f "$tmp/fs/omarchy-btrfs/@home")" ]]; then
    read -r -a stat <"/proc/$BASHPID/stat"
    kill -TERM "${stat[3]}" "$SCAN_PID"
  fi
  echo 4096
}
: >"$LOG"
status=0
(SCAN_PID=$BASHPID; home_drive_scan kim pw-ok /dev/vda >/dev/null) || status=$?
((status != 0)) || fail "an interrupted scan stops"
grep -qx 'mount /dev/vdd1' "$LOG" || fail "the scan was interrupted with a filesystem mounted" "$(cat "$LOG")"
[[ -z $(ls -A "$HOME_DRIVE_SCAN_DIR" 2>/dev/null) ]] || fail "an interrupted scan leaves nothing mounted" "$(ls -l "$HOME_DRIVE_SCAN_DIR")"
pass "an interrupted scan unmounts what it mounted"
