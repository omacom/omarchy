#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-apply-trim runs once per machine from the omarchy package's pacman
# hook. The machine is faked: its storage stack is described by files that
# stubs of the tools reading it (findmnt, lsblk, `cryptsetup status`,
# systemd-detect-virt) answer from, and the tools that change it (systemctl,
# fstrim) only log. LUKS2 headers are real files, written by the real
# libcryptsetup, where cryptsetup and python3 are installed.

# As root the command ignores the test's state directory and pinned PATH and
# would change this machine: its LUKS header, its timer.
if (( EUID == 0 )); then
  skip "omarchy-apply-trim tests run as a regular user only; as root they would change this machine"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
stubs=$tmp/bin
machine=$tmp/machine
calls=$tmp/calls
mkdir -p "$stubs"
real_cryptsetup=$(command -v cryptsetup || true)

cat >"$stubs/systemd-detect-virt" <<'EOF'
#!/bin/bash
[[ " $* " == *" --${FAKE_VIRT:-none} "* ]]
EOF
# fstype: the root filesystem's type; members: the devices the mounted root
# filesystem is on, as btrfs reports them.
cat >"$stubs/findmnt" <<'EOF'
#!/bin/bash
case " $* " in
  *" FSTYPE "*) cat "$MACHINE/fstype" ;;
  *" SOURCE "*) echo "$(head -n 1 "$MACHINE/members")[/@]" ;;
esac
EOF
cat >"$stubs/btrfs" <<'EOF'
#!/bin/bash
[[ "$*" == "filesystem show /" ]] || exit 1
echo "Label: none  uuid: fs-uuid"
echo "	Total devices $(wc -l <"$MACHINE/members") FS bytes used 4.00GiB"
n=0
while read -r member; do
  echo "	devid    $((++n)) size 40.00GiB used 6.00GiB path $member"
done <"$MACHINE/members"
EOF
# stack.<device>: the device and everything under it, "NAME TYPE" per line
# (lsblk -s); a device without one cannot be read.
cat >"$stubs/lsblk" <<'EOF'
#!/bin/bash
case " $* " in
  *" -nlpso NAME,TYPE "*) last=${!#}; cat "$MACHINE/stack.${last//\//_}" 2>/dev/null ;;
esac
EOF
# crypt.<mapping>: "TYPE DEVICE LIVE-FLAGS..."; integrity.<header>: that
# header's segment uses authenticated encryption. Everything else is the real
# cryptsetup, on the header files.
cat >"$stubs/cryptsetup" <<EOF
#!/bin/bash
if [[ \$1 == status ]]; then
  read -r type device flags <"\$MACHINE/crypt.\${2//\//_}"
  printf '  type:    %s\n  device:  %s\n  flags:   %s\n' "\$type" "\$device" "\$flags"
  exit 0
fi
if [[ \$1 == luksDump && \$2 == --dump-json-metadata && -e \$MACHINE/integrity.\${3##*/} ]]; then
  echo '{"segments": {"0": {"type": "crypt", "integrity": {"type": "hmac(sha256)"}}}}'
  exit 0
fi
exec $real_cryptsetup "\$@"
EOF
cat >"$stubs/systemctl" <<'EOF'
#!/bin/bash
echo "systemctl $*" >>"$CALLS"
[[ $1 != is-enabled ]] || { echo "${FAKE_TIMER:-disabled}"; exit 1; }
exit "${SYSTEMCTL_STATUS:-0}"
EOF
cat >"$stubs/fstrim" <<'EOF'
#!/bin/bash
echo "fstrim $*" >>"$CALLS"
exit "${FSTRIM_STATUS:-0}"
EOF
chmod +x "$stubs"/*

apply_trim() {
  CALLS=$calls MACHINE=$machine PATH="$stubs:$PATH" OMARCHY_TRIM_STATE_DIR="$tmp/state" \
    "$ROOT/bin/omarchy-apply-trim" "$@"
}

# An unencrypted btrfs root on one partition, no state, nothing called yet.
reset_machine() {
  rm -rf "$tmp/state" "$machine" "$calls"
  mkdir -p "$machine"
  touch "$calls"
  unset FAKE_VIRT FAKE_TIMER SYSTEMCTL_STATUS FSTRIM_STATUS
  echo btrfs >"$machine/fstype"
  echo /dev/nvme0n1p2 >"$machine/members"
  printf '/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' >"$machine/stack._dev_nvme0n1p2"
}

# encrypted_root <TYPE> <backing device> [live flags...]: the root btrfs on
# /dev/mapper/root, over <backing device>.
encrypted_root() {
  local type=$1 device=$2
  shift 2
  echo /dev/mapper/root >"$machine/members"
  printf '/dev/mapper/root crypt\n%s part\n/dev/nvme0n1 disk\n' "$device" >"$machine/stack._dev_mapper_root"
  echo "$type $device $*" >"$machine/crypt._dev_mapper_root"
}

luks2_header() {
  local image=$tmp/$1.img
  rm -f "$image"
  truncate -s 32M "$image"
  printf pw | cryptsetup luksFormat --type luks2 --batch-mode --pbkdf pbkdf2 \
    --pbkdf-force-iterations 1000 --key-file - "$image" >/dev/null
  printf '%s\n' "$image"
}

set_header_flags() { # set_header_flags <image> <flags as a number>
  python3 - "$1" "$2" <<'PY'
import ctypes, sys
lib = ctypes.CDLL("libcryptsetup.so.12")
cd = ctypes.c_void_p()
assert lib.crypt_init(ctypes.byref(cd), sys.argv[1].encode()) == 0
assert lib.crypt_load(cd, b"LUKS2", None) == 0
assert lib.crypt_persistent_flags_set(cd, 0, ctypes.c_uint32(int(sys.argv[2]))) == 0
lib.crypt_free(cd)
PY
}

header_flags() {
  cryptsetup luksDump "$1" | awk '$1 == "Flags:" { $1 = ""; print; exit }' | xargs
}

expect_enabled() {
  grep -qx 'systemctl enable --now --quiet fstrim.timer' "$calls" ||
    fail "$1: fstrim.timer is enabled" "$(cat "$calls")"
  [[ -e $tmp/state/backlog && -e $tmp/state/applied ]] ||
    fail "$1: the backlog trim is queued and the run is recorded"
}

# Without root, and without a test's state directory, it refuses.
if "$ROOT/bin/omarchy-apply-trim" 2>/dev/null; then
  fail "refuses to run without root"
fi
pass "refuses to run without root"

reset_machine
FAKE_VIRT=chroot apply_trim
[[ ! -s $calls && ! -e $tmp/state ]] || fail "changes nothing in a chroot" "$(cat "$calls")"
FAKE_VIRT=container apply_trim
[[ ! -s $calls && ! -e $tmp/state ]] || fail "changes nothing in a container" "$(cat "$calls")"
pass "changes nothing in a chroot or a container (image builds, pacstrap)"

reset_machine
apply_trim
expect_enabled "an unencrypted root"
: >"$calls"
apply_trim
[[ ! -s $calls ]] || fail "a second run changes nothing" "$(cat "$calls")"
pass "an unencrypted root gets the weekly timer and one backlog trim, once"

reset_machine
FAKE_TIMER=masked apply_trim 2>"$tmp/err"
grep -q 'masked; leaving it masked' "$tmp/err" || fail "a masked timer is reported" "$(cat "$tmp/err")"
! grep -q 'systemctl enable' "$calls" || fail "a masked timer is not enabled"
[[ -e $tmp/state/applied ]] || fail "a masked timer does not hold the rest back"
pass "a masked fstrim.timer is its owner's choice and is left masked"

reset_machine
SYSTEMCTL_STATUS=1 apply_trim 2>"$tmp/err" || fail "a timer that cannot be enabled does not fail the update"
grep -q 'could not enable fstrim.timer; trying again' "$tmp/err" || fail "a timer that cannot be enabled is reported" "$(cat "$tmp/err")"
[[ ! -e $tmp/state/applied ]] || fail "a timer that cannot be enabled is tried again on the next update"
pass "a timer that cannot be enabled is reported and tried again on the next update"

reset_machine
encrypted_root LUKS1 /dev/nvme0n1p2
apply_trim 2>"$tmp/err"
grep -q 'LUKS1' "$tmp/err" || fail "a LUKS1 root is reported" "$(cat "$tmp/err")"
expect_enabled "a LUKS1 root"
pass "a LUKS1 root, which has no persistent flags, is reported and still trimmed weekly"

reset_machine
encrypted_root n/a /dev/nvme0n1p2
apply_trim 2>"$tmp/err" || fail "a mapping whose header cannot be read does not fail the update"
grep -q 'cannot tell what kind of dm-crypt mapping' "$tmp/err" || fail "an unreadable mapping is reported" "$(cat "$tmp/err")"
[[ ! -e $tmp/state/applied && ! -s $calls ]] || fail "an unreadable mapping is tried again on the next update"
pass "a mapping whose header libcryptsetup could not read (type n/a) is reported and tried again"

if [[ -z $real_cryptsetup ]] || ! command -v python3 >/dev/null ||
  ! python3 -c 'import ctypes; ctypes.CDLL("libcryptsetup.so.12")' 2>/dev/null; then
  skip "LUKS2 headers: needs cryptsetup, python3 and libcryptsetup.so.12"
  exit 0
fi

reset_machine
image=$(luks2_header plain)
encrypted_root LUKS2 "$image"
[[ $(header_flags "$image") == "(no flags)" ]] || fail "a new header starts without flags"
apply_trim >"$tmp/out"
[[ $(header_flags "$image") == "allow-discards no-read-workqueue" ]] ||
  fail "a LUKS2 root gets allow-discards and no-read-workqueue in its header" "$(header_flags "$image")"
grep -q 'apply from the next boot' "$tmp/out" || fail "says when the flags apply" "$(cat "$tmp/out")"
printf pw | cryptsetup open --test-passphrase --key-file - "$image" ||
  fail "the passphrase still unlocks the header it rewrote"
expect_enabled "a LUKS2 root"
pass "a LUKS2 root gets the installer's persistent flags without the passphrase, and still unlocks"

before=$(sha256sum <"$image")
: >"$calls"
apply_trim
[[ $(sha256sum <"$image") == "$before" && ! -s $calls ]] || fail "a second run leaves the header alone"
pass "a second run leaves the header alone"

reset_machine
image=$(luks2_header cmdline)
encrypted_root LUKS2 "$image" discards
before=$(sha256sum <"$image")
apply_trim
[[ $(sha256sum <"$image") == "$before" ]] || fail "a mapping the cmdline already opens with discards keeps its header"
expect_enabled "a root the cmdline already opens with discards"
pass "a mapping the cmdline or crypttab already opens with discards keeps its header as it is"

reset_machine
image=$(luks2_header already)
set_header_flags "$image" $((1 << 3))
before=$(sha256sum <"$image")
encrypted_root LUKS2 "$image"
apply_trim
[[ $(sha256sum <"$image") == "$before" ]] || fail "a header that already allows discards is not written"
expect_enabled "a root that already allows discards"
pass "a header that already allows discards is not written, and the timer and backlog still apply"

reset_machine
image=$(luks2_header owner)
encrypted_root LUKS2 "$image"
apply_trim >/dev/null
# The owner turns discards off again (cryptsetup refresh --persistent rewrites
# the flags to only those given), then updates once more.
set_header_flags "$image" 0
apply_trim
[[ $(header_flags "$image") == "(no flags)" ]] || fail "an owner's choice to remove the flag stands" "$(header_flags "$image")"
pass "an owner who removes allow-discards afterwards keeps it removed"

# LUKS under LVM, and a btrfs over two LUKS volumes: every mapping under the
# root filesystem gets the flags.
reset_machine
lvm=$(luks2_header lvm)
echo /dev/mapper/vg-root >"$machine/members"
printf '/dev/mapper/vg-root lvm\n/dev/mapper/cryptlvm crypt\n/dev/nvme0n1p2 part\n/dev/nvme0n1 disk\n' >"$machine/stack._dev_mapper_vg-root"
echo "LUKS2 $lvm" >"$machine/crypt._dev_mapper_cryptlvm"
apply_trim >/dev/null
[[ $(header_flags "$lvm") == "allow-discards no-read-workqueue" ]] || fail "LUKS under LVM gets the flags" "$(header_flags "$lvm")"
reset_machine
first=$(luks2_header first) second=$(luks2_header second)
printf '/dev/mapper/a\n/dev/mapper/b\n' >"$machine/members"
printf '/dev/mapper/a crypt\n/dev/nvme0n1p2 part\n' >"$machine/stack._dev_mapper_a"
printf '/dev/mapper/b crypt\n/dev/nvme1n1p1 part\n' >"$machine/stack._dev_mapper_b"
echo "LUKS2 $first" >"$machine/crypt._dev_mapper_a"
echo "LUKS2 $second" >"$machine/crypt._dev_mapper_b"
apply_trim >/dev/null
[[ $(header_flags "$first") == "allow-discards no-read-workqueue" &&
  $(header_flags "$second") == "allow-discards no-read-workqueue" ]] ||
  fail "both LUKS volumes under a two-device btrfs get the flags"
pass "LUKS under LVM, and every LUKS volume under a multi-device btrfs, get the flags"

# An unlocked clone of the root (same filesystem UUID) is not part of the
# mounted filesystem and keeps its header.
reset_machine
image=$(luks2_header root) clone=$(luks2_header clone)
encrypted_root LUKS2 "$image"
printf '/dev/mapper/clone crypt\n/dev/sda2 part\n' >"$machine/stack._dev_mapper_clone"
echo "LUKS2 $clone" >"$machine/crypt._dev_mapper_clone"
before=$(sha256sum <"$clone")
apply_trim >/dev/null
[[ $(header_flags "$image") == "allow-discards no-read-workqueue" && $(sha256sum <"$clone") == "$before" ]] ||
  fail "an unlocked clone of the root keeps its header"
pass "an unlocked clone of the root, with the same filesystem UUID, keeps its header"

reset_machine
image=$(luks2_header partial)
printf '/dev/mapper/root\n/dev/mapper/gone\n' >"$machine/members"
printf '/dev/mapper/root crypt\n%s part\n' "$image" >"$machine/stack._dev_mapper_root"
echo "LUKS2 $image" >"$machine/crypt._dev_mapper_root"
apply_trim 2>"$tmp/err" || fail "a member it cannot read does not fail the update"
[[ ! -e $tmp/state/applied && $(header_flags "$image") == "(no flags)" ]] ||
  fail "a member it cannot read leaves nothing half done and is tried again"
pass "a root member it cannot read leaves every header alone and is tried again on the next update"

# Authenticated encryption cannot discard, and libcryptsetup refuses to open
# such a volume with allow-discards set: never write it there.
reset_machine
image=$(luks2_header integrity)
touch "$machine/integrity.${image##*/}"
encrypted_root LUKS2 "$image"
before=$(sha256sum <"$image")
apply_trim 2>"$tmp/err"
grep -q 'authenticated encryption' "$tmp/err" || fail "an integrity volume is reported" "$(cat "$tmp/err")"
[[ $(sha256sum <"$image") == "$before" ]] || fail "an integrity volume's header is never written"
expect_enabled "a root with authenticated encryption"
pass "a volume with authenticated encryption (dm-integrity) keeps its header, and still gets the weekly timer"

reset_machine
image=$(luks2_header readonly)
chmod 444 "$image"
encrypted_root LUKS2 "$image"
apply_trim 2>"$tmp/err" || fail "a header it cannot write does not fail the update"
grep -q 'could not store allow-discards' "$tmp/err" || fail "a header it cannot write is reported" "$(cat "$tmp/err")"
[[ ! -e $tmp/state/applied && ! -s $calls ]] || fail "a header it cannot write is tried again on the next update"
pass "a header it cannot write is reported, does not fail the update, and is tried again"

# The backlog trim at boot.
reset_machine
apply_trim --backlog
[[ ! -s $calls ]] || fail "nothing queued, nothing trimmed"
mkdir -p "$tmp/state" && touch "$tmp/state/backlog"
FAKE_VIRT=container apply_trim --backlog
FAKE_VIRT=chroot apply_trim --backlog
[[ ! -s $calls && -e $tmp/state/backlog ]] || fail "the backlog trims nothing in a container or a chroot"
grep -qx 'ConditionVirtualization=!container' "$ROOT/default/systemd/system/omarchy-trim-backlog.service" ||
  fail "the backlog unit does not start in a container"
pass "the backlog trims nothing in a container or a chroot, and its unit does not start in a container"
rm -rf "$tmp/state"
image=$(luks2_header backlog)
set_header_flags "$image" $(((1 << 3) | (1 << 24)))
encrypted_root LUKS2 "$image"
mkdir -p "$tmp/state" && touch "$tmp/state/backlog"
apply_trim --backlog >/dev/null
[[ -e $tmp/state/backlog && ! -s $calls ]] || fail "a mapping whose flags wait for the next boot keeps the backlog queued"
encrypted_root LUKS2 "$image" discards no_read_workqueue
FSTRIM_STATUS=1 apply_trim --backlog && fail "a failed trim fails the unit"
[[ -e $tmp/state/backlog ]] || fail "a failed trim stays queued"
: >"$calls"
apply_trim --backlog
grep -qx 'fstrim --listed-in /etc/fstab:/proc/self/mountinfo --verbose --quiet-unsupported' "$calls" ||
  fail "trims every mounted filesystem the way fstrim.service does" "$(cat "$calls")"
[[ ! -e $tmp/state/backlog ]] || fail "a finished trim is dequeued"
pass "the backlog waits for the boot that applies the flags, then trims every filesystem once; a failed trim stays queued"

reset_machine
encrypted_root LUKS1 /dev/nvme0n1p2
mkdir -p "$tmp/state" && touch "$tmp/state/backlog"
apply_trim --backlog >/dev/null
grep -q '^fstrim ' "$calls" && [[ ! -e $tmp/state/backlog ]] ||
  fail "a root that will never pass discards does not hold back the other filesystems' trim"
pass "a root that will never pass discards does not hold back the trim of the other filesystems"
