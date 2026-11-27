#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fake_bin="$tmp/bin"
actions="$tmp/actions.log"
mkdir -p "$fake_bin"
: >"$actions"

cat >"$fake_bin/lsblk" <<'SH'
#!/bin/bash
printf '/dev/nvme0n1p1 vfat\n/dev/sdb1 ext4\n/dev/sdc1 vfat\n/dev/sdd1 ext4\n'
SH

cat >"$fake_bin/udisksctl" <<'SH'
#!/bin/bash
if [[ $1 == "mount" ]]; then
  printf 'mount %s\n' "$4" >>"$TEST_ACTIONS"
  exit 0
fi

[[ $1 == "info" && $2 == "-b" ]] || exit 1
case $3 in
  /dev/nvme0n1p1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 true
    IdType:                     vfat
    IdUsage:                    filesystem
    MountPoints:
INFO
    ;;
  /dev/sdb1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 false
    IdType:                     ext4
    IdUsage:                    filesystem
    MountPoints:
INFO
    ;;
  /dev/sdc1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 false
    IdType:                     vfat
    IdUsage:                    filesystem
    MountPoints:        /run/media/user/USB
INFO
    ;;
  /dev/sdd1)
    cat <<'INFO'
    HintIgnore:                 true
    HintSystem:                 false
    IdType:                     ext4
    IdUsage:                    filesystem
    MountPoints:
INFO
    ;;
  /dev/sde1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 false
    IdType:                     crypto_LUKS
    IdUsage:                    crypto
    CleartextDevice:            '/'
INFO
    ;;
  /dev/sdf1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 false
    IdType:                     crypto_LUKS
    IdUsage:                    crypto
    CleartextDevice:            '/org/freedesktop/UDisks2/block_devices/dm_2d2'
INFO
    ;;
  /dev/dm-1)
    cat <<'INFO'
    HintIgnore:                 false
    HintSystem:                 false
    IdType:                     btrfs
    IdUsage:                    filesystem
    MountPoints:
INFO
    ;;
  *)
    exit 1
    ;;
esac
SH

cat >"$fake_bin/omarchy-drive-unlock" <<'SH'
#!/bin/bash
printf 'unlock %s\n' "$1" >>"$TEST_ACTIONS"
SH

cat >"$fake_bin/udevadm" <<'SH'
#!/bin/bash
cat <<'EVENTS'
UDEV  [1.0] add /devices/sde1 (block)
ACTION=add
DEVNAME=/dev/sde1
ID_FS_USAGE=crypto

UDEV  [1.1] change /devices/sde1 (block)
ACTION=change
DEVNAME=/dev/sde1
ID_FS_USAGE=crypto

UDEV  [1.2] add /devices/sdf1 (block)
ACTION=add
DEVNAME=/dev/sdf1
ID_FS_USAGE=crypto

UDEV  [1.3] change /devices/dm-1 (block)
ACTION=change
DEVNAME=/dev/dm-1
ID_FS_USAGE=filesystem

UDEV  [1.4] change /devices/sdb1 (block)
ACTION=change
DEVNAME=/dev/sdb1
ID_FS_USAGE=filesystem

UDEV  [1.5] remove /devices/sde1 (block)
ACTION=remove
DEVNAME=/dev/sde1

UDEV  [1.6] add /devices/sde1 (block)
ACTION=add
DEVNAME=/dev/sde1
ID_FS_USAGE=crypto

EVENTS
SH

chmod +x "$fake_bin/lsblk" "$fake_bin/udisksctl" "$fake_bin/omarchy-drive-unlock" "$fake_bin/udevadm"

PATH="$fake_bin:$PATH" TEST_ACTIONS="$actions" "$ROOT/bin/omarchy-drive-automount"
# Give backgrounded omarchy-drive-unlock calls a moment to flush.
sleep 0.1

actual=$(sort "$actions")
expected=$(printf '%s\n' \
  "mount /dev/dm-1" \
  "mount /dev/sdb1" \
  "unlock /dev/sde1" \
  "unlock /dev/sde1" | sort)

[[ $actual == "$expected" ]] || fail "automount handles external filesystems, LUKS unlock dedup, re-plug, and skips internal/ignored/mounted drives" "expected:
$expected
actual:
$actual"

pass "automount mounts external filesystems and cleartext volumes, skips internal/ignored/mounted drives, deduplicates LUKS prompts, and re-prompts after removal"
