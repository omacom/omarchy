#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-drive-encryption's menu guards against fake drives, and its fstab and
# crypttab edits on a scratch file. findmnt, swapon and lsblk answer from tables
# written here, so what is checked is which drives each row offers: never the
# system's, never a USB drive, and a drive whose conversion stopped part way
# under the row that started it. Nothing here runs cryptsetup or touches a
# drive.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# The command's functions, without the dispatch at its end.
source <(sed '/^case \${1:-} in$/,$d' "$ROOT/bin/omarchy-drive-encryption")
STATE_DIR=$tmp/state

findmnt() { cat "$tmp/mounts"; }
swapon() { cat "$tmp/swaps"; }
sudo() { "$@"; }

# $tmp/drives holds one device per line in lsblk's tree order: name, type,
# transport, parent, filesystem and UUID, with - for none.
lsblk() {
  case "$1 $2" in
    "-dnrpo NAME,TYPE,TRAN") awk '$2 == "disk" { print $1, $2, ($3 == "-" ? "" : $3) }' "$tmp/drives" ;;
    "-nrpo NAME,UUID") awk '{ print $1, ($6 == "-" ? "" : $6) }' "$tmp/drives" ;;
    "-dnro FSTYPE") awk -v device="$3" '$1 == device && $5 != "-" { print $5 }' "$tmp/drives" ;;
    "-nsrpo NAME,TYPE")
      shift 2
      awk -v devices="$*" '
        { type[$1] = $2; parent[$1] = $4 }
        END {
          n = split(devices, device, " ")
          for (i = 1; i <= n; i++) for (name = device[i]; name in type; name = parent[name]) print name, type[name]
        }' "$tmp/drives"
      ;;
    "-nrpo NAME,TYPE")
      awk -v top="$3" '
        { parent[$1] = $4 }
        { for (name = $1; name != top && name in parent; name = parent[name]); if (name == top) print $1, $2 }' "$tmp/drives"
      ;;
    *)
      echo "unexpected lsblk $*" >&2
      return 98
      ;;
  esac
}

# A desktop: the system on an encrypted NVMe drive, a plain data drive, an
# encrypted one that is open, an encrypted one that is locked, and a USB stick.
desktop() {
  rm -rf "$STATE_DIR"
  cat >"$tmp/drives" <<'EOF'
/dev/nvme0n1 disk nvme - - -
/dev/nvme0n1p1 part - /dev/nvme0n1 vfat boot-fs
/dev/nvme0n1p2 part - /dev/nvme0n1 crypto_LUKS system-luks
/dev/mapper/root crypt - /dev/nvme0n1p2 btrfs root-fs
/dev/sda disk sata - - -
/dev/sda1 part - /dev/sda ext4 plain-fs
/dev/sdb disk sata - - -
/dev/sdb1 part - /dev/sdb crypto_LUKS open-luks
/dev/mapper/luks-open crypt - /dev/sdb1 btrfs open-fs
/dev/sdc disk sata - - -
/dev/sdc1 part - /dev/sdc crypto_LUKS locked-luks
/dev/sdd disk usb - - -
/dev/sdd1 part - /dev/sdd ext4 stick-fs
/dev/zram0 disk - - swap -
EOF
  cat >"$tmp/mounts" <<'EOF'
/ /dev/mapper/root[/@] root-fs
/home /dev/mapper/root[/@home] root-fs
/boot /dev/nvme0n1p1 boot-fs
/mnt/data /dev/sda1 plain-fs
/proc proc
EOF
  echo /dev/zram0 >"$tmp/swaps"
}

# What the guards of Encrypt Drive, Decrypt Drive and Unlock Drive answer: the
# drives each lists, or "hidden" when it fails, which is what hides its row.
rows() {
  local row drives
  local -a answers=()
  for row in plain encrypted locked; do
    if drives=$("list_$row" 2>&1); then
      answers+=("$row=$(paste -sd, - <<<"$drives")")
    else
      answers+=("$row=hidden")
    fi
  done
  echo "${answers[*]}"
}

expect() {
  local description=$1 actual=$2 expected=$3
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

desktop
expect "each row offers its drives, and never the system's or a USB drive" \
  "$(rows)" "plain=/dev/sda encrypted=/dev/sdb,/dev/sdc locked=/dev/sdc"

sed -i '/\/dev\/sd/d; /luks-open/d' "$tmp/drives"
expect "a machine with only its system drive shows no row" \
  "$(rows)" "plain=hidden encrypted=hidden locked=hidden"

desktop
sed -i 's|^/home .*|/home /dev/sda1 plain-fs|' "$tmp/mounts"
expect "a drive that holds /home is the system's" \
  "$(rows)" "plain=hidden encrypted=/dev/sdb,/dev/sdc locked=/dev/sdc"

desktop
sed -i 's|^/dev/sda1 .*|/dev/sda1 part - /dev/sda btrfs root-fs|' "$tmp/drives"
expect "a drive the root filesystem spans is the system's" \
  "$(rows)" "plain=hidden encrypted=/dev/sdb,/dev/sdc locked=/dev/sdc"

desktop
: >"$tmp/mounts"
expect "no drive is offered when the system's cannot be told" \
  "$(rows)" "plain=hidden encrypted=hidden locked=hidden"

# The marker is named after the LUKS UUID the volume was given.
desktop
mkdir -p "$STATE_DIR"
touch "$STATE_DIR/luks-locked-luks.encrypt"
expect "a drive whose encryption stopped part way stays under Encrypt Drive alone" \
  "$(rows)" "plain=/dev/sda,/dev/sdc encrypted=/dev/sdb locked=hidden"

# A half-decrypted volume carries no signature, and the guards ask whether its
# path is a block device, so a real node stands in for it.
block=$(find /dev -maxdepth 1 -type b ! -name 'sd[a-e]*' ! -name 'nvme0n1*' ! -name zram0 -print -quit 2>/dev/null)
if [[ -z $block ]]; then
  skip "no block device node to stand in for a volume; skipping the interrupted decryption rows"
else
  desktop
  printf '%s\n' "/dev/sde disk sata - - -" "$block part - /dev/sde - -" >>"$tmp/drives"
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$block" luks-old old-fs >"$STATE_DIR/luks-old.state"
  touch "$STATE_DIR/luks-old.header"
  expect "a drive whose decryption stopped part way stays under Decrypt Drive" \
    "$(rows)" "plain=/dev/sda encrypted=/dev/sdb,/dev/sdc,/dev/sde locked=/dev/sdc"

  # The filesystem shows again before the cleanup has run.
  sed -i "s|^$block part .*|$block part - /dev/sde ext4 old-fs|" "$tmp/drives"
  expect "and is not offered for encryption once its filesystem shows again" \
    "$(rows)" "plain=/dev/sda encrypted=/dev/sdb,/dev/sdc,/dev/sde locked=/dev/sdc"

  rm "$STATE_DIR/luks-old.header"
  expect "a decryption state without its saved header is not a decryption" \
    "$(rows)" "plain=/dev/sda,/dev/sde encrypted=/dev/sdb,/dev/sdc locked=/dev/sdc"
fi

fstab=$tmp/fstab
printf '%s\n' \
  '#UUID=aaaa /old ext4 defaults 0 2' \
  'UUID=bede / btrfs rw 0 0' \
  $'/dev/sdb1\t/data\text4\tdefaults\t0 2' \
  'UUID="4460471C60471458" /run/media ntfs3 defaults 0 0' \
  'LABEL=My\040Disk /mnt/my\040disk ext4 defaults 0 2' >"$fstab"
original=$(<"$fstab")

expect "an fstab line is found by device path, by UUID in either case, and by an escaped label" \
  "$(matching_lines "$original" 1 /dev/sdb1) $(matching_lines "$original" 1 UUID=4460471c60471458) $(matching_lines "$original" 1 'LABEL=My\040Disk')" \
  "3 4 5"
expect "a commented-out fstab line does not hold its mountpoint" "$(matching_lines "$original" 2 /old)" ""

comment_etc_lines "$fstab" 5
expect "a disabled fstab line keeps its text behind the comment sign" \
  "$(sed -n 5p "$fstab")" '# LABEL=My\040Disk /mnt/my\040disk ext4 defaults 0 2'
uncomment_etc_lines "$fstab" 'LABEL=My\040Disk /mnt/my\040disk ext4 defaults 0 2'
expect "and comes back exactly as it was" "$(<"$fstab")" "$original"

replace_etc_spec "$fstab" 3 UUID=1111
expect "pointing an fstab line at a UUID leaves the rest of the line alone" \
  "$(sed -n 3p "$fstab")" $'UUID=1111\t/data\text4\tdefaults\t0 2'

append_etc_line "$fstab" 'UUID=2222 /mnt/a\040b ext4 defaults 0 2'
expect "an appended fstab line keeps its escapes" \
  "$(tail -n 1 "$fstab")" 'UUID=2222 /mnt/a\040b ext4 defaults 0 2'

backups=("$fstab".bak.*)
expect "a run backs the file up once, before its first change" \
  "${#backups[@]} $(<"${backups[0]}")" "1 $original"
