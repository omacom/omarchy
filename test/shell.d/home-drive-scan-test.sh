#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# home_drive_scan against fake disks. lsblk describes the machine, mounting a
# partition links a fixture tree in its place, and ownership comes from a
# table instead of stat, so the test needs neither root nor real filesystems.
# The rows it prints are what the installer's Home step and first-boot setup
# offer, so every rule about what may be adopted or erased is checked here.

source "$ROOT/install/provisioning/home-drive.sh"
eval "$(declare -f _hd_owner | sed '1s/_hd_owner/real_hd_owner/')"
eval "$(declare -f _hd_mount_ro | sed '1s/_hd_mount_ro/real_hd_mount_ro/')"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME_DRIVE_SCAN_DIR=$tmp/scan

# A machine as lsblk -bpPo NAME,TYPE,SIZE,RM,TRAN,FSTYPE,UUID,PKNAME prints it:
# the install target, a second disk with an XFS home, a USB stick with an
# empty ext4 partition, and a blank NVMe.
LSBLK=$'NAME="/dev/vda" TYPE="disk" SIZE="68719476736" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdb1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="xfs" UUID="u-vdb1" PKNAME="/dev/vdb"
NAME="/dev/sdb" TYPE="disk" SIZE="64023257088" RM="1" TRAN="usb" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/sdb1" TYPE="part" SIZE="64022208512" RM="1" TRAN="" FSTYPE="ext4" UUID="u-sdb1" PKNAME="/dev/sdb"
NAME="/dev/nvme2n1" TYPE="disk" SIZE="1000204886016" RM="0" TRAN="nvme" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/zram0" TYPE="disk" SIZE="8589934592" RM="0" TRAN="" FSTYPE="swap" UUID="" PKNAME=""'

declare -A FIXTURE=()
declare -A OWNER=()
MOUNT_LOG=$tmp/mounts.log
: >"$MOUNT_LOG"

mkdir -p "$tmp/fixtures/xfs-home/kim" "$tmp/fixtures/xfs-home/sam" "$tmp/fixtures/xfs-home/lost+found" \
  "$tmp/fixtures/empty" "$tmp/fixtures/usb-home/kim" "$tmp/fixtures/file-home"
: >"$tmp/fixtures/file-home/kim"
FIXTURE[/dev/vdb1]=$tmp/fixtures/xfs-home
FIXTURE[/dev/sdb1]=$tmp/fixtures/empty

_hd_lsblk() { printf '%s\n' "$LSBLK"; }
_hd_mount_ro() {
  local device=$1 dir=$2
  [[ -n ${FIXTURE[$device]:-} ]] || return 1
  rmdir "$dir"
  ln -s "${FIXTURE[$device]}" "$dir"
  printf 'mount %s\n' "$device" >>"$MOUNT_LOG"
}
_hd_umount() {
  rm "$1"
  mkdir "$1"
  printf 'umount\n' >>"$MOUNT_LOG"
}
_hd_owner() {
  local path=$1 name
  name=${path##*/}
  if [[ -L $path || ( -e $path && ! -d $path ) ]]; then
    echo notdir
  elif [[ ! -e $path ]]; then
    echo missing
  else
    echo "${OWNER[$name]:-1000 1000}"
  fi
}
_hd_used() { echo 1395864371200; }
_hd_is_mounted() { [[ -L $1 ]]; }
_hd_dm_names() { :; }

OWNER[kim]="1000 1000"
OWNER[sam]="1001 1001"
OWNER[lost+found]="0 0"

field() { awk -F'\t' -v n="$2" '{ print $n }' <<<"$1"; }
row_for() { grep -P "^[a-z]+\t[a-z]+\t$1\t" <<<"$2" || true; }

scan=$(home_drive_scan kim "" /dev/vda)

row=$(row_for /dev/vdb1 "$scan")
[[ -n $row ]] || fail "the XFS home on vdb1 is found" "$scan"
[[ $(field "$row" 1) == adoptable && $(field "$row" 2) == home ]] || fail "vdb1 is an adoptable home" "$row"
[[ $(field "$row" 4) == xfs && $(field "$row" 5) == u-vdb1 ]] || fail "vdb1 row carries fstype and uuid" "$row"
[[ $(field "$row" 8) == 1000 && $(field "$row" 9) == 1000 ]] || fail "vdb1 row carries the folder's uid and gid" "$row"
[[ $(field "$row" 10) == 1395864371200 ]] || fail "vdb1 row carries the used bytes" "$row"
[[ $(field "$row" 11) == /dev/vdb && $(field "$row" 12) == 0 ]] || fail "vdb1 row names its disk, not removable" "$row"
[[ $(field "$row" 13) == sam ]] || fail "other homes are listed, lost+found and root-owned dirs are not" "$row"
pass "an XFS home on a second disk is adoptable and lists the other homes"

[[ -n $(row_for /dev/nvme2n1 "$scan") && $(field "$(row_for /dev/nvme2n1 "$scan")" 1) == erasable ]] ||
  fail "a blank internal disk is offered for a fresh home" "$scan"
[[ $(field "$(row_for /dev/vdb "$scan")" 1) == erasable ]] || fail "a disk holding a home can still be erased" "$scan"
pass "internal disks other than the target are erasable"

! grep -q '/dev/sdb' <<<"$scan" || fail "a removable disk without a home gets no row" "$scan"
! grep -q '/dev/vda' <<<"$scan" || fail "the install target gets no row" "$scan"
! grep -q 'zram' <<<"$scan" || fail "zram gets no row" "$scan"
pass "removable disks without a home, the target and zram are left out"

FIXTURE[/dev/sdb1]=$tmp/fixtures/usb-home
scan=$(home_drive_scan kim "" /dev/vda)
row=$(row_for /dev/sdb1 "$scan")
[[ $(field "$row" 1) == adoptable && $(field "$row" 12) == 1 ]] || fail "a home on a USB disk is adoptable and marked removable" "$scan"
[[ -z $(row_for /dev/sdb "$scan") ]] || fail "a USB disk is never offered for erasing" "$scan"
pass "a home on a removable disk is adoptable but the disk is never erasable"
FIXTURE[/dev/sdb1]=$tmp/fixtures/empty

OWNER[kim]="999 999"
row=$(row_for /dev/vdb1 "$(home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == uid-below-1000 ]] || fail "a home owned by uid 999 is refused" "$row"
pass "a system uid is refused"

OWNER[kim]="1000 1000"
printf 'root:x:0:0::/root:/bin/bash\ntaken:x:1000:1000::/home/taken:/bin/bash\n' >"$tmp/passwd"
printf 'root:x:0:\nusers:x:100:\n' >"$tmp/group"
row=$(row_for /dev/vdb1 "$(HOME_DRIVE_PASSWD=$tmp/passwd HOME_DRIVE_GROUP=$tmp/group home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == uid-taken ]] || fail "a uid the image already uses is refused" "$row"
pass "a uid taken in the target is refused"

printf 'root:x:0:0::/root:/bin/bash\n' >"$tmp/passwd"
OWNER[kim]="1000 100"
row=$(row_for /dev/vdb1 "$(HOME_DRIVE_PASSWD=$tmp/passwd HOME_DRIVE_GROUP=$tmp/group home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == adoptable && $(field "$row" 9) == 100 ]] || fail "a home in the shared users group is adoptable" "$row"
pass "gid 100 (users) is accepted"

OWNER[kim]="1000 1000"
printf 'root:x:0:\nusers:x:100:\nclash:x:1000:\n' >"$tmp/group"
row=$(row_for /dev/vdb1 "$(HOME_DRIVE_PASSWD=$tmp/passwd HOME_DRIVE_GROUP=$tmp/group home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == gid-taken ]] || fail "a gid the image already uses is refused" "$row"
pass "a gid taken in the target is refused"

OWNER[kim]="1000 50"
row=$(row_for /dev/vdb1 "$(home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == gid-taken ]] || fail "a system gid other than 100 is refused without account files" "$row"
pass "a system gid other than users is refused by the static rule"
OWNER[kim]="1000 1000"

FIXTURE[/dev/vdb1]=$tmp/fixtures/file-home
row=$(row_for /dev/vdb1 "$(home_drive_scan kim "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == not-a-directory ]] || fail "a file named like the user is not a home" "$row"
ln -sfn /etc "$tmp/fixtures/file-home/linked"
row=$(row_for /dev/vdb1 "$(home_drive_scan linked "" /dev/vda)")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == not-a-directory ]] || fail "a symlink named like the user is not a home" "$row"
pass "a file or symlink in place of the home folder is refused"
FIXTURE[/dev/vdb1]=$tmp/fixtures/xfs-home

[[ -z $(row_for /dev/vdb1 "$(home_drive_scan nobody-here "" /dev/vda)") ]] || fail "no row when the user has no folder"
pass "a partition without the user's folder gives no home row"

: >"$MOUNT_LOG"
home_drive_scan kim "" /dev/vda >/dev/null
mounts=$(grep -c '^mount' "$MOUNT_LOG")
umounts=$(grep -c '^umount' "$MOUNT_LOG")
((mounts > 0 && mounts == umounts)) || fail "every scan mount is unmounted" "$(cat "$MOUNT_LOG")"
[[ -z $(ls -A "$HOME_DRIVE_SCAN_DIR" 2>/dev/null) ]] || fail "the scan leaves no mount directories behind"
pass "the scan unmounts everything it mounted and cleans up"

mkdir "$tmp/owner-dir"
: >"$tmp/owner-file"
ln -s "$tmp/owner-dir" "$tmp/owner-link"
[[ $(real_hd_owner "$tmp/owner-dir") == "$(id -u) $(id -g)" ]] || fail "a directory reports its owner"
[[ $(real_hd_owner "$tmp/owner-link") == notdir ]] || fail "a symlink to a directory is not a home"
[[ $(real_hd_owner "$tmp/owner-file") == notdir ]] || fail "a file is not a home"
[[ $(real_hd_owner "$tmp/owner-none") == missing ]] || fail "nothing there is missing"
pass "ownership is read from directories only, never through a symlink"

home_drive_check 1000 1000 "" "" || fail "uid/gid 1000 passes the static rules"
[[ $(home_drive_check 500 1000 "" "") == uid-below-1000 ]] || fail "home_drive_check names the reason"
pass "home_drive_check applies the rules on its own"

# The order the Home step offers the rows in: gum highlights the first, so the
# user's existing home leads, then home on the install disk, then drives to
# unlock (an unrelated encrypted disk must not make Enter ask for a
# passphrase), and disks to erase come last. Refused rows are not choices.
row() { local IFS=$'\t'; printf '%s\n' "$*"; }
scan=$(
  row erasable disk /dev/nvme2n1 "" "" "" "" "" "" "" /dev/nvme2n1 0 "" ""
  row refused home /dev/vdd1 ext4 u4 "" "" 999 999 4096 /dev/vdd 0 "" uid-below-1000
  row locked home /dev/vdc1 crypto_LUKS "" l2 "" "" "" "" /dev/vdc 0 "" wrong-passphrase
  row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 4096 /dev/vdb 0 "" ""
)
[[ $(home_drive_choices "$scan") == $'adopt\t4\ndisk\t0\nlocked\t3\nfresh\t1' ]] ||
  fail "choices lead with the existing home and end with disks to erase" "$(home_drive_choices "$scan")"
[[ $(home_drive_choices "") == $'disk\t0' ]] || fail "with nothing found the install disk is the only choice"
pass "the choices never put an erase first"

# Looking must not write: no journal replay on any filesystem the scan mounts.
mount() { echo "$*"; }
[[ $(real_hd_mount_ro /dev/x /mnt btrfs) == *"ro,rescue=nologreplay,subvolid=5"* ]] || fail "btrfs mounts without replaying its log" "$(real_hd_mount_ro /dev/x /mnt btrfs)"
[[ $(real_hd_mount_ro /dev/x /mnt f2fs) == *"ro,norecovery"* ]] || fail "f2fs mounts without recovery"
[[ $(real_hd_mount_ro /dev/x /mnt xfs) == *"ro,norecovery"* ]] || fail "xfs mounts without recovery"
[[ $(real_hd_mount_ro /dev/x /mnt ext4) == *"ro,noload"* ]] || fail "ext4 mounts without its journal"
unset -f mount
pass "every filesystem is mounted read-only without journal replay"

# A folder name is the user's to choose, newlines and tabs included: one beside
# the home must never turn into a scan row of its own.
mkdir "$tmp/fixtures/xfs-home/"$'x\nadoptable\thome\tfake1\txfs'
scan=$(home_drive_scan kim "" /dev/vda)
[[ -z $(row_for fake1 "$scan") ]] || fail "a folder name cannot inject a scan row" "$scan"
[[ $(field "$(row_for /dev/vdb1 "$scan")" 13) == sam ]] || fail "only names that can be accounts are listed as other homes" "$scan"
rm -r "$tmp/fixtures/xfs-home/"$'x\nadoptable\thome\tfake1\txfs'
pass "a folder name with a newline or tab cannot inject a scan row"

# Disks that are not drives to use: read-only ones (a write-protected card, an
# eMMC boot area) are skipped, and an SD card in a built-in reader is
# removable even though it is not on USB, so it is never offered for erasing.
LSBLK_SAVED=$LSBLK
LSBLK=$'NAME="/dev/vda" TYPE="disk" SIZE="68719476736" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME="" RO="0" HOTPLUG="0"
NAME="/dev/vdh" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME="" RO="1" HOTPLUG="0"
NAME="/dev/mmcblk0boot0" TYPE="disk" SIZE="4194304" RM="0" TRAN="mmc" FSTYPE="" UUID="" PKNAME="" RO="0" HOTPLUG="0"
NAME="/dev/mmcblk1" TYPE="disk" SIZE="64023257088" RM="0" TRAN="mmc" FSTYPE="" UUID="" PKNAME="" RO="0" HOTPLUG="1"
NAME="/dev/mmcblk2" TYPE="disk" SIZE="64023257088" RM="0" TRAN="mmc" FSTYPE="" UUID="" PKNAME="" RO="0" HOTPLUG="0"'
scan=$(home_drive_scan kim "" /dev/vda)
[[ -z $(row_for /dev/vdh "$scan") ]] || fail "a read-only disk gets no row" "$scan"
[[ -z $(row_for /dev/mmcblk0boot0 "$scan") ]] || fail "an eMMC boot area gets no row" "$scan"
[[ -z $(row_for /dev/mmcblk1 "$scan") ]] || fail "an SD card in a hotplug reader is removable and never erasable" "$scan"
[[ $(field "$(row_for /dev/mmcblk2 "$scan")" 1) == erasable ]] || fail "built-in eMMC is still an internal disk" "$scan"
LSBLK=$LSBLK_SAVED
pass "read-only disks and boot areas are skipped, and SD cards count as removable"

# Two devices with one uuid (a cloned disk): fstab could mount either, so a
# home on one of them is refused rather than adopted.
LSBLK_SAVED=$LSBLK
LSBLK+=$'\nNAME="/dev/vdi" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdi1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="xfs" UUID="u-vdb1" PKNAME="/dev/vdi"'
scan=$(home_drive_scan kim "" /dev/vda)
row=$(row_for /dev/vdb1 "$scan")
[[ $(field "$row" 1) == refused && $(field "$row" 14) == duplicate-uuid ]] || fail "a home whose uuid is on two devices is refused" "$scan"
LSBLK=$LSBLK_SAVED
pass "a home whose uuid another device shares is refused"

# An unmount that fails (something still reading the filesystem) is said out
# loud, and the scan's cleanup tries it again rather than leaving it mounted.
eval "$(declare -f _hd_umount | sed '1s/_hd_umount/fake_hd_umount/')"
_hd_umount() {
  if [[ ! -e $tmp/umount-failed ]]; then
    : >"$tmp/umount-failed"
    return 1
  fi
  fake_hd_umount "$1"
}
home_drive_scan kim "" /dev/vda >/dev/null 2>"$tmp/scan.err"
grep -q 'could not unmount' "$tmp/scan.err" || fail "a failed unmount is reported" "$(cat "$tmp/scan.err")"
[[ -z $(ls -A "$HOME_DRIVE_SCAN_DIR" 2>/dev/null) ]] || fail "the cleanup unmounts what would not come off at first" "$(ls -l "$HOME_DRIVE_SCAN_DIR")"
eval "$(declare -f fake_hd_umount | sed '1s/fake_hd_umount/_hd_umount/')"
pass "a failed unmount is reported and retried by the cleanup"

# Every row has a 15th field, dir: empty when the user's folder is at the top
# of its filesystem, as on a drive that is all home.
row=$(row_for /dev/vdb1 "$(home_drive_scan kim "" /dev/vda)")
[[ $(awk -F'\t' '{ print NF }' <<<"$row") == 15 && -z $(field "$row" 15) ]] || fail "a home at the top has an empty dir field" "$row"
pass "a home at the top of its filesystem has no dir"

# Another system's root (Ubuntu, Debian, Mint): one ext4 filesystem with the
# user's folder at home/kim. It is offered with dir home, and the other folders
# under home/ are the other homes. The top of the filesystem holds the system,
# not homes, so it is not looked at for them.
mkdir -p "$tmp/fixtures/ubuntu/home/kim" "$tmp/fixtures/ubuntu/home/sam" "$tmp/fixtures/ubuntu/etc" "$tmp/fixtures/ubuntu/usr" \
  "$tmp/fixtures/ubuntu/root" "$tmp/fixtures/both/kim" "$tmp/fixtures/both/home/kim"
OWNER[home]="0 0"
OWNER[root]="0 0"
LSBLK_SAVED=$LSBLK
LSBLK+=$'\nNAME="/dev/vdj" TYPE="disk" SIZE="34359738368" RM="0" TRAN="virtio" FSTYPE="" UUID="" PKNAME=""
NAME="/dev/vdj1" TYPE="part" SIZE="34358689792" RM="0" TRAN="" FSTYPE="ext4" UUID="u-vdj1" PKNAME="/dev/vdj"'
FIXTURE[/dev/vdj1]=$tmp/fixtures/ubuntu
scan=$(home_drive_scan kim "" /dev/vda)
row=$(row_for /dev/vdj1 "$scan")
[[ $(field "$row" 1) == adoptable && $(field "$row" 4) == ext4 && $(field "$row" 5) == u-vdj1 ]] ||
  fail "a home inside another system's root is adoptable" "$scan"
[[ $(field "$row" 15) == home && -z $(field "$row" 7) ]] || fail "it is found at home/<user>, outside any subvolume" "$row"
[[ $(field "$row" 13) == sam ]] || fail "the other folders under home/ are the other homes" "$row"
(($(grep -c $'\t/dev/vdj1\t' <<<"$scan") == 1)) || fail "the filesystem gives one row" "$scan"
pass "a home inside another system's root filesystem is found at home/<user>"

mv "$tmp/fixtures/ubuntu/home/kim" "$tmp/fixtures/ubuntu/home/kim-real"
ln -s kim-real "$tmp/fixtures/ubuntu/home/kim"
FIXTURE[/dev/vdj1]=$tmp/fixtures/ubuntu
[[ -z $(row_for /dev/vdj1 "$(home_drive_scan kim "" /dev/vda)") ]] || fail "a symlink at home/<user> is not a home" "$(home_drive_scan kim "" /dev/vda)"
rm "$tmp/fixtures/ubuntu/home/kim"
mv "$tmp/fixtures/ubuntu/home/kim-real" "$tmp/fixtures/ubuntu/home/kim"
# home itself a link (to the live system's /home, say) is never followed.
mkdir -p "$tmp/fixtures/linked-home"
ln -s "$tmp/fixtures/ubuntu/home" "$tmp/fixtures/linked-home/home"
FIXTURE[/dev/vdj1]=$tmp/fixtures/linked-home
[[ -z $(row_for /dev/vdj1 "$(home_drive_scan kim "" /dev/vda)") ]] || fail "a home/ that is a link is never followed" "$(home_drive_scan kim "" /dev/vda)"
pass "home/<user> must be a real folder under a real home/"

# Both kim/ at the top and home/kim: the top-level one is the home.
FIXTURE[/dev/vdj1]=$tmp/fixtures/both
scan=$(home_drive_scan kim "" /dev/vda)
(($(grep -c $'\t/dev/vdj1\t' <<<"$scan") == 1)) || fail "one row when both are there" "$scan"
[[ -z $(field "$(row_for /dev/vdj1 "$scan")" 15) ]] || fail "the folder at the top wins over home/<user>" "$scan"
pass "a folder at the top wins over home/<user> on the same filesystem"
LSBLK=$LSBLK_SAVED
unset 'FIXTURE[/dev/vdj1]'
