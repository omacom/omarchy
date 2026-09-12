#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fstab_post_install="$ROOT/install/post-install/fstab.sh"
all_post_install="$ROOT/install/post-install/all.sh"

[[ -f $fstab_post_install ]] || fail "fstab.sh exists in install/post-install/"
grep -F 'run_logged "$OMARCHY_INSTALL/post-install/fstab.sh"' "$all_post_install" >/dev/null || fail "all.sh invokes fstab.sh"
pass "post-install orchestrates fstab.sh"

# Test fstab transformation on mock fstab
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mock_fstab="$tmp_dir/fstab"
cat << 'MOCK' > "$mock_fstab"
# <file system> <dir> <type> <options> <dump> <pass>
UUID=1111-2222	/	btrfs	rw,relatime,compress=zstd:3,subvol=/@	0 0
UUID=1111-2222	/home	btrfs	rw,relatime,compress=zstd:3,subvol=/@home	0 0
UUID=3333-4444	/boot	vfat	rw,relatime,fmask=0077,dmask=0077	0 2
/swap/swapfile	none	swap	defaults,pri=0	0 0
MOCK

sed -i '/[[:space:]]btrfs[[:space:]]/s/\brelatime\b/noatime/g' "$mock_fstab"

grep -F 'UUID=1111-2222	/	btrfs	rw,noatime,compress=zstd:3,subvol=/@	0 0' "$mock_fstab" >/dev/null || fail "root btrfs mount updated to noatime"
pass "root btrfs mount updated to noatime"

grep -F 'UUID=1111-2222	/home	btrfs	rw,noatime,compress=zstd:3,subvol=/@home	0 0' "$mock_fstab" >/dev/null || fail "home btrfs mount updated to noatime"
pass "home btrfs mount updated to noatime"

grep -F 'UUID=3333-4444	/boot	vfat	rw,relatime,fmask=0077,dmask=0077	0 2' "$mock_fstab" >/dev/null || fail "vfat boot mount remains unchanged"
pass "non-btrfs mounts remain untouched"
