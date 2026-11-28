#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Destination selection against fake drives. The installation sits on a
# 128 GB disk with 70 GiB of data, so a 64 GB drive is too small even though
# the source disk is larger, and a 256 GB drive is offered. The current disk
# and zram must never reach the selector; a zero-byte drive is listed as too
# small so an empty card reader is visible.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin"

cat >"$tmp/bin/lsblk" <<'SH'
#!/bin/bash
case "$*" in
  "-bdpno NAME,SIZE,TYPE")
    printf '%s\n' \
      '/dev/sda 128035676160 disk' \
      '/dev/sdb 64000000000 disk' \
      '/dev/sdc 0 disk' \
      '/dev/sdd 256060514304 disk' \
      '/dev/zram0 8065646592 disk'
    ;;
  "-s -n -r -p -o NAME,TYPE /dev/mapper/root")
    printf '%s\n' '/dev/mapper/root crypt' '/dev/sda2 part' '/dev/sda disk'
    ;;
  "-bpP -o NAME,SIZE,TYPE,FSTYPE,FSUSED /dev/sda")
    printf '%s\n' \
      'NAME="/dev/sda" SIZE="128035676160" TYPE="disk" FSTYPE="" FSUSED=""' \
      'NAME="/dev/sda1" SIZE="2147483648" TYPE="part" FSTYPE="vfat" FSUSED="209715200"' \
      'NAME="/dev/sda2" SIZE="125885743104" TYPE="part" FSTYPE="crypto_LUKS" FSUSED=""' \
      'NAME="/dev/mapper/root" SIZE="125868965888" TYPE="crypt" FSTYPE="btrfs" FSUSED="75161927680"'
    ;;
  "-bdno SIZE /dev/sda") echo 128035676160 ;;
  "-bdno SIZE /dev/sdb") echo 64000000000 ;;
  "-bdno SIZE /dev/sdd") echo 256060514304 ;;
  *)
    echo "unexpected lsblk call: $*" >&2
    exit 99
    ;;
esac
SH

cat >"$tmp/bin/findmnt" <<'SH'
#!/bin/bash
case "$*" in
  "-no SOURCE /") echo '/dev/mapper/root[/@]' ;;
  "-no SOURCE /boot") echo '/dev/sda1' ;;
  *) exit 1 ;;
esac
SH

chmod +x "$tmp/bin/lsblk" "$tmp/bin/findmnt"
export PATH="$tmp/bin:$PATH"

source "$ROOT/bin/omarchy-drive-migrate-progress"

[[ $(disk_for_source /dev/mapper/root) == "/dev/sda" ]] ||
  fail "the physical disk below the LUKS and partition layers is found"

mapfile -t source_disks < <(current_installation_disks)
[[ ${source_disks[*]-} == "/dev/sda" ]] ||
  fail "the installation disk is collected once even with a separate /boot" "${source_disks[*]-}"

used=$(required_bytes /dev/sda)
[[ $used == 77309411328 ]] ||
  fail "used bytes come from the filesystems, with a 1 GiB floor for the ESP" "$used"

reserve=$(migration_reserve "$used")
[[ $reserve == $((used / 20)) && $reserve -ge 1073741824 ]] ||
  fail "the reserve is five percent of the data, with a 1 GiB floor" "$reserve"

[[ $(migration_reserve 1000) == 1073741824 ]] ||
  fail "a nearly empty installation still reserves 1 GiB"

required=$((used + reserve))
classify_destination_disks "$required" "${source_disks[@]}"
[[ ${eligible[*]-} == "/dev/sdd" ]] ||
  fail "only the drive that can hold the data is offered" "${eligible[*]-}"
[[ ${too_small[*]-} == "/dev/sdb /dev/sdc" ]] ||
  fail "drives smaller than the data in use, including a zero-byte one, are flagged as too small" "${too_small[*]-}"
[[ " ${eligible[*]-} " != *" /dev/sda "* ]] ||
  fail "the current installation disk is never offered"
[[ " ${eligible[*]-} " != *" /dev/sdc "* ]] ||
  fail "a zero-byte drive is never offered"
[[ " ${eligible[*]-} " != *" /dev/zram0 "* && " ${too_small[*]-} " != *" /dev/zram0 "* ]] ||
  fail "non-physical disks such as zram are left out entirely"

# The production entrypoint inlines the same detection helpers; make sure a
# regression there is caught too.
source "$ROOT/bin/omarchy-drive-migrate"
[[ $(current_installation_disks) == "/dev/sda" ]] ||
  fail "the production entrypoint detects the installation disk" "$(current_installation_disks)"

pass "drive migration selects a destination from the data actually in use"


# Pure helpers of the clone script: destination partition naming, subvolume
# parsing and the kernel cmdline rewrite that makes the new disk bootable.
source "$ROOT/bin/omarchy-drive-migrate-clone"

[[ $(partition_device /dev/nvme0n1 1) == "/dev/nvme0n1p1" ]] ||
  fail "nvme destination partitions carry the p suffix"

[[ $(partition_device /dev/sda 2) == "/dev/sda2" ]] ||
  fail "scsi destination partitions have no p suffix"

[[ $(subvol_from_source "/dev/mapper/root[/@home]") == "@home" ]] ||
  fail "the subvolume name is parsed out of the findmnt source"

if subvol_from_source "/dev/sda2" 2>/dev/null; then
  fail "a source without a subvolume suffix is rejected"
fi

cmdline="cryptdevice=PARTUUID=11111111-1111-1111-1111-111111111111:root root=/dev/mapper/root rw"
expected="cryptdevice=PARTUUID=22222222-2222-2222-2222-222222222222:root root=/dev/mapper/root rw"
[[ $(rewrite_cmdline "$cmdline" "PARTUUID=22222222-2222-2222-2222-222222222222") == "$expected" ]] ||
  fail "cryptdevice is rewritten while the mapper name is kept"

plain_cmdline="root=UUID=33333333-3333-3333-3333-333333333333 rw"
[[ $(rewrite_cmdline "$plain_cmdline" "PARTUUID=44444444-4444-4444-4444-444444444444") == "root=PARTUUID=44444444-4444-4444-4444-444444444444 rw" ]] ||
  fail "a plain root= UUID moves to the new partition"

pass "drive migration names destination partitions and rewrites boot device references"
