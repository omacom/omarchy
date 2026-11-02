#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The initramfs cryptsetup wrapper, run by busybox ash as the initramfs runs it,
# in front of a fake real cryptsetup: a Plymouth unlock records which slot
# opened the disk, a failed one records nothing and keeps its status, and every
# other call goes straight through.

busybox=/usr/lib/initcpio/busybox
[[ -x $busybox ]] || { skip "mkinitcpio's busybox is not installed"; exit 0; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/real" <<'SH'
#!/bin/sh
echo "$*" >>"$TEST_TMP/calls"
case "$*" in
  "luksUUID /dev/nvme0n1p2") echo uuid-root ;;
  *--verbose*open*)
    password=$(cat)
    [ "$password" = "kidpass" ] || { echo "No key available with this passphrase." >&2; exit 2; }
    echo "No usable token is available."
    echo "Key slot 3 unlocked."
    echo "Command successful."
    echo "Something else cryptsetup said."
    ;;
esac
SH
chmod +x "$tmp/real"
wrapper=$ROOT/etc/initcpio/omarchy-luks-slot/cryptsetup

unlock() {
  rm -f "$tmp/calls" "$tmp/run/luks-slot"
  printf '%s' "$1" | TEST_TMP=$tmp CRYPTSETUP_REAL=$tmp/real LUKS_SLOT_RECORD=$tmp/run/luks-slot \
    "$busybox" ash "$wrapper" open --type luks --key-file=- /dev/nvme0n1p2 root '>/dev/null' >"$tmp/stdout" 2>"$tmp/stderr"
}

unlock kidpass || fail "a right password unlocks"
[[ $(cat "$tmp/run/luks-slot") == "uuid-root 3" ]] || fail "the unlock records the disk and the slot that opened it" "$(cat "$tmp/run/luks-slot" 2>/dev/null)"
grep -q 'open --type luks --key-file=- /dev/nvme0n1p2 root >/dev/null' "$tmp/calls" || fail "the real cryptsetup gets the hook's arguments untouched, quiet included" "$(cat "$tmp/calls")"
[[ $(grep -c -- 'open' "$tmp/calls") == 1 ]] || fail "the unlock runs once"
grep -q 'Something else cryptsetup said' "$tmp/stdout" && ! grep -q 'Key slot\|Command successful' "$tmp/stdout" || fail "what cryptsetup would have said reaches the screen, without what verbose adds"
pass "a Plymouth unlock runs cryptsetup once and records which slot opened the disk"

status=0
unlock wrongpass || status=$?
(( status == 2 )) || fail "a wrong password keeps cryptsetup's status" "status $status"
[[ ! -e $tmp/run/luks-slot ]] || fail "a failed unlock records nothing"
grep -q 'No key available' "$tmp/stderr" || fail "the failure still reaches the screen"
pass "a wrong password fails exactly as it would have, and records nothing"

rm -f "$tmp/calls"
TEST_TMP=$tmp CRYPTSETUP_REAL=$tmp/real LUKS_SLOT_RECORD=$tmp/run/luks-slot "$busybox" ash "$wrapper" isLuks /dev/nvme0n1p2
[[ $(cat "$tmp/calls") == "isLuks /dev/nvme0n1p2" ]] || fail "other calls pass straight through" "$(cat "$tmp/calls")"
[[ ! -e $tmp/run/luks-slot ]] || fail "other calls record nothing"
pass "every other cryptsetup call passes straight through"

# The console prompt, when Plymouth is not running: cryptsetup asks on its own,
# with no --key-file, and the unlock is recorded all the same.
rm -f "$tmp/run/luks-slot"
printf 'kidpass' | TEST_TMP=$tmp CRYPTSETUP_REAL=$tmp/real LUKS_SLOT_RECORD=$tmp/run/luks-slot \
  "$busybox" ash "$wrapper" open --type luks /dev/nvme0n1p2 root >/dev/null 2>&1 || fail "a console unlock unlocks"
[[ $(cat "$tmp/run/luks-slot") == "uuid-root 3" ]] || fail "a console unlock records the slot too"
pass "an unlock at the console prompt, without Plymouth, is recorded too"

# Nowhere to keep the record, the unlock still goes through untouched.
printf 'kidpass' | TEST_TMP=$tmp CRYPTSETUP_REAL=$tmp/real LUKS_SLOT_RECORD=/proc/no-such-dir/luks-slot \
  "$busybox" ash "$wrapper" open --type luks --key-file=- /dev/nvme0n1p2 root >/dev/null 2>&1 || fail "an unlock with nowhere to record still unlocks"
pass "an unlock with nowhere to keep the record goes straight through"

"$busybox" ash -n "$wrapper" || fail "the wrapper parses under busybox ash"
pass "the wrapper parses under the initramfs shell"

# The hook follows encrypt only once Setup > Users exists, added last, after
# a drop-in from before the baseline that sets HOOKS whole.
hooks_for() {
  OMARCHY_USERS_DIR=$1 PATH="$tmp/nohw:$PATH" bash -uc "
    FILES=()
    source '$ROOT/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf'
    HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
    source '$ROOT/etc/mkinitcpio.conf.d/zz-omarchy-luks-slot.conf'
    echo \"\${HOOKS[*]}\"
  "
}
mkdir -p "$tmp/nohw" "$tmp/users"
printf '#!/bin/bash\necho x86\n' >"$tmp/nohw/omarchy-hw-platform"
chmod +x "$tmp/nohw/omarchy-hw-platform"
[[ $(hooks_for "$tmp/absent") != *omarchy-luks-slot* ]] || fail "a machine with one person never carries the wrapper"
[[ $(hooks_for "$tmp/users") == *" encrypt omarchy-luks-slot filesystems "* ]] || fail "with people added, the hook follows encrypt" "$(hooks_for "$tmp/users")"
pass "the hook follows encrypt only once Setup > Users has added someone"
