#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# First-boot setup's Home step: a machine installed for a later owner (or
# factory reset) offers that owner an existing home of theirs on another
# drive, as the ISO's Home step does. It never offers to erase a disk on a
# first power-on, and a drive the last reset kept is not offered to the next
# owner. Adopting creates the account with the home's own ids instead of
# useradd -m. The functions run as omarchy-provision-owner defines them, with
# the system commands recorded instead of run.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

source "$ROOT/install/provisioning/home-drive.sh"
export PATH="$ROOT/bin:$PATH"
for function in install_authorized_keys home_restore_passphrase home_step_rows home_step_hints home_scan home_choice_restore \
  home_form home_step create_user adopt_home; do
  sed -n "/^$function() {/,/^}/p" "$ROOT/bin/omarchy-provision-owner"
done >"$tmp/functions.sh"
grep -q '^create_user() {' "$tmp/functions.sh" || fail "omarchy-provision-owner defines create_user"
source "$tmp/functions.sh"

row() { local IFS=$'\t'; printf '%s\n' "$*"; }
SCAN=$(
  row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 1395864371200 /dev/vdb 0 "" ""
  row adoptable home /dev/vdc1 ext4 kept-by-reset "" "" 1000 1000 4096 /dev/vdc 0 "" ""
  row erasable disk /dev/nvme1n1 "" "" "" "" "" "" "" /dev/nvme1n1 0 "" ""
)
PROVISIONING_DIR=$tmp/provisioning
mkdir -p "$PROVISIONING_DIR"
printf 'kept-by-reset\n' >"$PROVISIONING_DIR/ignored-home-drives"

rows=$(home_step_rows "$SCAN" kim)
[[ $(sed -n 1p <<<"$rows") == $'Existing home for kim on /dev/vdb1 (xfs, 1.3T)\tadopt:1' ]] ||
  fail "an existing home of the owner comes first" "$rows"
! grep -q 'fresh:\|erases' <<<"$rows" || fail "first boot never offers to erase a disk" "$rows"
[[ $(sed -n 3p <<<"$rows" | cut -f2) == disk ]] || fail "home on the system disk stays a choice" "$rows"
pass "first boot offers the owner's existing home and never an erase"

hints=$(home_step_hints "$(row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 4096 /dev/vdb 0 sam ""
  row refused home /dev/vdd1 ext4 u4 "" "" 999 999 4096 /dev/vdd 0 "" uid-below-1000)" kim)
[[ $hints == $'Also on this drive: sam (left untouched)\nHome for kim on /dev/vdd1 can\'t be used: it belongs to a system account' ]] ||
  fail "first boot names the other homes and why a home cannot be used" "$hints"
hints=$(home_step_hints "$(row refused home /dev/vdd1 ext4 u4 "" "" 1000 1000 4096 /dev/vdd 0 "" duplicate-uuid)" kim)
[[ $hints == *"another drive has the same ID"* ]] || fail "a home on a cloned drive is explained, not called a non-folder" "$hints"
pass "first boot explains other homes and refused ones"

[[ -z $(home_step_rows "$(row erasable disk /dev/nvme1n1 "" "" "" "" "" "" "" /dev/nvme1n1 0 "" "")" kim) ]] ||
  fail "with no existing home there is nothing to ask"
pass "with no existing home first boot asks nothing"

CALLS=$tmp/calls
cryptsetup() {
  echo "cryptsetup $*" >>"$CALLS"
  if [[ $1 == status ]]; then
    [[ -n ${ALREADY_OPEN:-} ]] || return 4
    echo "  device:  ${OPEN_DEVICE:-/dev/vdb1}"
    return 0
  fi
  cat >/dev/null 2>&1 || true
}
blkid() { [[ "$*" == "-o value -s UUID /dev/vdb1" ]] && echo l1; [[ "$*" == "-o value -s UUID /dev/vdc1" ]] && echo other; return 0; }
for cmd in useradd groupadd usermod chpasswd mount umount vgchange setpriv systemctl browser_policy_setup_dir; do
  eval "$cmd() { echo \"$cmd \$*\" >>\"\$CALLS\"; cat >/dev/null 2>&1 || true; }"
done
getent() {
  [[ ${1:-} == group && -n ${GROUP_EXISTS:-} ]] && return 0
  [[ ${1:-} == passwd && -n ${USER_EXISTS:-} ]] && return 0
  return 2
}
# First boot mounted the image's own @home before setup ran.
mountpoint() { [[ $* == "-q /home" ]]; }
user_groups() { echo wheel,video; }
encrypted_install() { return 0; }
home_drive_mount_entries() { echo "mount-entries $*" >>"$CALLS"; }
BROWSER_POLICY_MANAGED_DIRS=()
OMARCHY_PATH=$ROOT
username=kim password=pw

: >"$CALLS"
home_row=$(sed -n 1p <<<"$SCAN") home_password=""
create_user </dev/null 2>/dev/null || true
grep -q '^mount-entries / u1 xfs   true' "$CALLS" || fail "the home drive goes into fstab" "$(cat "$CALLS")"

grep -qx 'mount /home' "$CALLS" || fail "the home drive is mounted before the account is made" "$(cat "$CALLS")"
unmounted_at=$(grep -n '^umount /home$' "$CALLS" | cut -d: -f1)
mounted_at=$(grep -n '^mount /home$' "$CALLS" | cut -d: -f1)
[[ -n $unmounted_at ]] && ((unmounted_at < mounted_at)) ||
  fail "the image's @home is unmounted first, so the drive is not stacked on it" "$(cat "$CALLS")"
grep -qx 'groupadd -g 1000 kim' "$CALLS" || fail "the home's group is created with its gid" "$(cat "$CALLS")"
grep -qx 'useradd -M -u 1000 -g 1000 -G wheel,video -s /bin/bash kim' "$CALLS" ||
  fail "the account takes the home's ids without a copied skel" "$(cat "$CALLS")"
! grep -q 'useradd -m' "$CALLS" || fail "an adopted home is never re-created"
grep -q '^setpriv --reuid=1000 --regid=1000 --clear-groups bash' "$CALLS" || fail "Omarchy's defaults are merged in as the owner" "$(cat "$CALLS")"
pass "adopting at first boot mounts the home and creates the account with its ids"

: >"$CALLS"
home_row=""
create_user </dev/null 2>/dev/null || true
grep -q '^useradd -m ' "$CALLS" || fail "without a home drive the account is made as before" "$(cat "$CALLS")"
pass "without a home drive first boot creates the account as before"

# A retry after a first attempt that failed part way: the home's LUKS is open
# and its group exists. Setup goes on from there instead of failing on them.
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 l1 "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
home_drive_luks_passphrase() { echo pw; }
ALREADY_OPEN=1 GROUP_EXISTS=1 create_user </dev/null 2>/dev/null || true
! grep -q '^cryptsetup open' "$CALLS" || fail "an already open home is not opened again" "$(cat "$CALLS")"
! grep -q '^groupadd' "$CALLS" || fail "an existing group is not created again" "$(cat "$CALLS")"
grep -q '^useradd -M -u 1000' "$CALLS" || fail "the retry still creates the account" "$(cat "$CALLS")"
pass "a retried first boot reuses the open home and the existing group"

# The scan checks the ids against this system's own accounts, not only the
# static rules.
home_drive_scan() { echo "passwd=$HOME_DRIVE_PASSWD group=$HOME_DRIVE_GROUP ignore=$HOME_DRIVE_IGNORE"; }
[[ $(home_scan kim pw /dev/vda) == "passwd=/etc/passwd group=/etc/group ignore=kept-by-reset " ]] ||
  fail "first boot scans against this system's accounts and skips drives the reset kept" "$(home_scan kim pw /dev/vda)"
pass "first boot checks ids against this system and never opens a drive the reset kept"

# A home that opens with a passphrase typed for it, not the owner's password:
# that one is what opens it now and goes into the key slot.
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 l1 "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=typed
home_drive_luks_passphrase() { [[ $2 == $'pw\ntyped' ]] && echo typed; }
create_user </dev/null 2>/dev/null || true
grep -qx 'mount-entries / u1 xfs  l1 true  typed' "$CALLS" || fail "the passphrase that opens the home is the one used" "$(cat "$CALLS")"
pass "the passphrase that actually opens the home is used"

# A home inside another system's root (dir home): said so in the menu, and
# its dir goes into fstab so only that folder is mounted at /home.
rows=$(home_step_rows "$(row adoptable home /dev/vdj1 ext4 u9 "" "" 1000 1000 4096 /dev/vdj 0 "" "" home
  row adoptable home /dev/vdk1 btrfs b9 "" @ 1000 1000 4096 /dev/vdk 0 "" "" home)" kim)
[[ $(sed -n 1p <<<"$rows") == $'Existing home for kim inside the system on /dev/vdj1 (ext4, 4.0K)\tadopt:1' ]] ||
  fail "a home inside another system says so" "$rows"
[[ $(sed -n 2p <<<"$rows" | cut -f1) == "Existing home for kim inside the system on /dev/vdk1 (btrfs @, 4.0K)" ]] ||
  fail "a home inside a btrfs root subvolume names the subvolume" "$rows"
: >"$CALLS"
home_row=$(row adoptable home /dev/vdj1 ext4 u9 "" "" 1000 1000 4096 /dev/vdj 0 "" "" home) home_password=""
create_user </dev/null 2>/dev/null || true
grep -qx 'mount-entries / u9 ext4   true home ' "$CALLS" || fail "the home's dir goes into fstab before the passphrase" "$(cat "$CALLS")"
grep -qx 'mount /home' "$CALLS" || fail "the home inside a system is mounted from fstab" "$(cat "$CALLS")"
pass "a home inside another system is labelled as such and mounted by its folder"

# An unrelated encrypted drive must not become what Enter picks: the system
# disk comes before drives to unlock, as in the installer.
rows=$(home_step_rows "$(row locked home /dev/vdc1 crypto_LUKS "" l9 "" "" "" "" /dev/vdc 0 "" wrong-passphrase)" kim)
[[ $(sed -n 1p <<<"$rows" | cut -f2) == disk && $(sed -n 2p <<<"$rows" | cut -f2) == locked:1 ]] ||
  fail "the system disk is the default when only a locked drive is found" "$rows"
pass "a locked drive never becomes the default"

# A retry after the account was made on the adopted home: the scan now refuses
# the account's own uid, so the choice made the first time is what counts.
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
create_user </dev/null 2>/dev/null || true
[[ $(cat "$PROVISIONING_DIR/setup-home") == "$home_row" ]] || fail "the adopted home is remembered for a retry"
home_row=""
home_choice_restore || fail "a retry finds the remembered choice"
[[ $home_row == "$(cat "$PROVISIONING_DIR/setup-home")" ]] || fail "a retry restores the adopted home"
rm -f "$PROVISIONING_DIR/setup-home"
home_row=""
! home_choice_restore || fail "a first attempt has nothing to restore"
pass "a retried first boot keeps the adopted home"

# A mapping left open by a different drive is never taken for the home.
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 l1 "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
if (ALREADY_OPEN=1 OPEN_DEVICE=/dev/vdc1 adopt_home </dev/null 2>/dev/null); then
  fail "a mapping of another drive stops setup"
fi
! grep -q '^mount /home' "$CALLS" || fail "nothing is mounted from another drive's mapping"
pass "an open mapping of another drive is never mounted as home"

# A retry after the account was made but before Omarchy's defaults were merged
# in: the mount and the merge happen again; both are safe to repeat.
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
USER_EXISTS=1 GROUP_EXISTS=1 create_user </dev/null 2>/dev/null || true
grep -q '^usermod ' "$CALLS" || fail "the existing account is refreshed" "$(cat "$CALLS")"
grep -qx 'mount /home' "$CALLS" || fail "a retry mounts the home again" "$(cat "$CALLS")"
grep -q '^setpriv --reuid=1000 --regid=1000 --clear-groups bash' "$CALLS" || fail "a retry finishes the merge" "$(cat "$CALLS")"
pass "a retry after the account exists still mounts and merges the home"

# A retry restores the saved choice without the Home step, so a drive with a
# passphrase of its own is asked for again (never saved) when the owner's
# password does not open it and nothing has it open.
gum() { echo "gum $*" >>"$CALLS"; echo typed-again; }
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 l1 "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
home_drive_luks_passphrase() { return 1; }
home_restore_passphrase
[[ $home_password == typed-again ]] || fail "the drive's passphrase is asked for again on a retry"
: >"$CALLS"
home_password=""
home_drive_luks_passphrase() { echo pw; }
home_restore_passphrase
[[ -z $home_password ]] && ! grep -q '^gum' "$CALLS" || fail "no prompt when the owner's password opens the drive"
: >"$CALLS"
home_drive_luks_passphrase() { return 1; }
ALREADY_OPEN=1 home_restore_passphrase
! grep -q '^gum' "$CALLS" || fail "no prompt when the drive is already open"
unset -f gum
pass "a retry asks for a drive's own passphrase only when it is needed"

# A drive the last reset was told to erase, not erased yet because it was not
# connected: it is never offered for adoption, or the next boot would erase
# the home just adopted.
printf 'UUID=pending1\nPTUUID=pt9\n' >"$PROVISIONING_DIR/erase-home-drive"
[[ $(home_scan kim pw /dev/vda) == *"ignore="*"pending1"* ]] || fail "a drive waiting to be erased is never offered" "$(home_scan kim pw /dev/vda)"
rm -f "$PROVISIONING_DIR/erase-home-drive"
pass "a drive waiting to be erased is never offered for adoption"

# SSH keys staged for the owner: an adopted home may sit in the shared users
# group with no group named after the user, may already authorize keys of its
# own, and is the user's own, so a link in it is never written through.
keys_home=$tmp/keys-home
mkdir -p "$keys_home/kim/.ssh" "$tmp/etc-target"
printf 'ssh-ed25519 OWN kim@laptop\n' >"$keys_home/kim/.ssh/authorized_keys"
printf 'ssh-ed25519 NEW kim@host' >"$PROVISIONING_DIR/authorized_keys"
chown() { echo "chown $*" >>"$CALLS"; }
: >"$CALLS"
HOME_ROOT=$keys_home install_authorized_keys
[[ $(cat "$keys_home/kim/.ssh/authorized_keys") == $'ssh-ed25519 OWN kim@laptop\nssh-ed25519 NEW kim@host' ]] ||
  fail "staged keys are added to the ones the home already authorizes" "$(cat "$keys_home/kim/.ssh/authorized_keys")"
grep -qx "chown -R kim: $keys_home/kim/.ssh" "$CALLS" || fail "the keys get the user's login group, whatever it is called" "$(cat "$CALLS")"
printf 'root:x:0:0\n' >"$tmp/etc-target/passwd"
rm "$keys_home/kim/.ssh/authorized_keys"
ln -s "$tmp/etc-target/passwd" "$keys_home/kim/.ssh/authorized_keys"
HOME_ROOT=$keys_home install_authorized_keys 2>/dev/null || true
[[ $(cat "$tmp/etc-target/passwd") == "root:x:0:0" ]] || fail "a linked authorized_keys is never written through"
unset -f chown
rm -f "$PROVISIONING_DIR/authorized_keys"
pass "staged SSH keys are added safely to an adopted home"

# Run as setup runs them, under set -e: what kills a step there is what a
# caller's "|| true" would hide. Never inside || or if, which would turn
# set -e off again; the status is left in $strict.
strict() {
  set +e
  (set -e; "$@" </dev/null 2>"$tmp/strict.err")
  strict=$?
  set -e
}

# A home whose mapping is already open (a retry) needs no passphrase, and the
# drive is addressed by its LUKS uuid: a USB drive's device name can change
# between the scan and setup, or across a reboot.
: >"$CALLS"
home_row=$(row adoptable home /dev/sdz1 xfs u1 l1 "" 1000 1000 4096 /dev/sdz 0 "" "") home_password=""
home_drive_luks_passphrase() { echo "lookup $1" >>"$CALLS"; return 1; }
ALREADY_OPEN=1 strict adopt_home
((strict == 0)) || fail "an open home needs no passphrase" "$(cat "$tmp/strict.err") $(cat "$CALLS")"
grep -qx 'mount /home' "$CALLS" || fail "the open home is mounted" "$(cat "$CALLS")"
: >"$CALLS"
home_drive_luks_passphrase() { [[ $1 == /dev/disk/by-uuid/l1 ]] && echo pw; }
strict adopt_home
((strict == 0)) || fail "a home is opened by its LUKS uuid" "$(cat "$tmp/strict.err") $(cat "$CALLS")"
grep -qx 'cryptsetup open --key-file=- /dev/disk/by-uuid/l1 home' "$CALLS" || fail "the LUKS volume is opened by uuid" "$(cat "$CALLS")"
grep -qx 'mount-entries / u1 xfs  l1 true  pw' "$CALLS" || fail "the passphrase found for the uuid is used" "$(cat "$CALLS")"
: >"$CALLS"
home_drive_luks_passphrase() { return 1; }
strict adopt_home
((strict != 0)) || fail "a home nothing opens stops setup"
! grep -q '^mount /home' "$CALLS" || fail "nothing is mounted when the home cannot be opened" "$(cat "$CALLS")"
pass "an adopted LUKS home is opened by its uuid, and an open one needs no passphrase"

# The adopted home is remembered for a retry only once the account exists on
# it: a failed adoption lets the retry offer the Home step again.
rm -f "$PROVISIONING_DIR/setup-home"
: >"$CALLS"
home_row=$(row adoptable home /dev/vdb1 xfs u1 "" "" 1000 1000 4096 /dev/vdb 0 "" "") home_password=""
useradd() { echo "useradd $*" >>"$CALLS"; return 1; }
strict create_user
((strict != 0)) || fail "a failed useradd stops setup"
[[ ! -e $PROVISIONING_DIR/setup-home ]] || fail "a home the account was not created on is not remembered"
useradd() { echo "useradd $*" >>"$CALLS"; }
pass "a home is remembered only once the account exists on it"

# A merge that could not copy every default (3) is a warning, as a failed
# user finalization is; any other failure still stops setup.
log_step() { echo "log $*" >>"$CALLS"; }
FINALIZE_WARNING_FLAG=$tmp/finalize-warning
setpriv() { echo "setpriv $*" >>"$CALLS"; return "${MERGE_STATUS:-0}"; }
: >"$CALLS"
# (The steps after the passwords write to /etc, so how far setup got is told
# by chpasswd having run.)
MERGE_STATUS=3 strict create_user
grep -q '^chpasswd' "$CALLS" || fail "a partial merge does not stop setup" "$(cat "$CALLS")"
[[ -e $FINALIZE_WARNING_FLAG ]] || fail "a partial merge warns at the end"
rm -f "$FINALIZE_WARNING_FLAG"
: >"$CALLS"
MERGE_STATUS=1 strict create_user
((strict != 0)) || fail "a failed merge stops setup"
! grep -q '^chpasswd' "$CALLS" || fail "nothing after a failed merge runs" "$(cat "$CALLS")"
setpriv() { echo "setpriv $*" >>"$CALLS"; }
pass "a partial merge is a warning, a failed one stops setup"

# A drive waiting for a whole-disk erase: every partition of that disk is
# left alone, not only the one the marker names.
blkid_saved=$(declare -f blkid)
blkid() { [[ "$*" == "-t UUID=pending1 -o device" ]] && echo /dev/vdz2; return 0; }
lsblk() {
  case "$*" in
    "-ndo TYPE /dev/vdz2") echo part ;;
    "-ndpo PKNAME /dev/vdz2") echo /dev/vdz ;;
    "-nro UUID /dev/vdz") printf '\npending1\nsibling9\n' ;;
  esac
  return 0
}
printf 'TARGET=disk\nUUID=pending1\nPTUUID=pt9\n' >"$PROVISIONING_DIR/erase-home-drive"
[[ $(home_scan kim pw /dev/vda) == *"sibling9"* ]] || fail "every partition of a disk waiting to be erased is ignored" "$(home_scan kim pw /dev/vda)"
printf 'TARGET=part\nUUID=pending1\n' >"$PROVISIONING_DIR/erase-home-drive"
[[ $(home_scan kim pw /dev/vda) != *"sibling9"* ]] || fail "a partition erase leaves the rest of its disk offered"
rm -f "$PROVISIONING_DIR/erase-home-drive"
eval "$blkid_saved"
unset -f lsblk
pass "a disk waiting to be erased whole is left alone entirely"

# An adopted home's .ssh or authorized_keys that is something else than
# setup expects (a file, a folder, a FIFO) is skipped, not failed or hung on.
odd=$tmp/odd-home
mkdir -p "$odd/kim"
printf 'not a folder\n' >"$odd/kim/.ssh"
printf 'ssh-ed25519 NEW kim@host' >"$PROVISIONING_DIR/authorized_keys"
HOME_ROOT=$odd strict install_authorized_keys
((strict == 0)) || fail "a .ssh that is a file does not fail setup" "$(cat "$tmp/strict.err")"
grep -q 'not installing' "$tmp/strict.err" && [[ $(cat "$odd/kim/.ssh") == "not a folder" ]] || fail "it is left as it was, and the skip logged"
rm "$odd/kim/.ssh"
mkdir -p "$odd/kim/.ssh/authorized_keys"
HOME_ROOT=$odd strict install_authorized_keys
((strict == 0)) || fail "an authorized_keys that is a folder does not fail setup" "$(cat "$tmp/strict.err")"
[[ -d $odd/kim/.ssh/authorized_keys && -z $(ls -A "$odd/kim/.ssh/authorized_keys") ]] || fail "the folder is left as it was"
rm -f "$PROVISIONING_DIR/authorized_keys"
pass "an odd .ssh or authorized_keys is skipped with a log line"

# Passphrases typed for several locked drives add up: unlocking a second
# drive keeps the first one open to the scan.
home_drive_system_disks() { echo "${SYSTEM_DISKS:-/dev/vda}"; }
step() { :; }
say() { :; }
notice() { :; }
home_scan() {
  printf '%s' "$2" >"$tmp/scan-passwords"
  row locked home /dev/vdc1 crypto_LUKS "" l9 "" "" "" "" /dev/vdc 0 "" wrong-passphrase
  row locked home /dev/vdd1 crypto_LUKS "" l8 "" "" "" "" /dev/vdd 0 "" wrong-passphrase
}
gum() {
  local n
  case $1 in
    choose)
      n=$(($(cat "$tmp/chooses" 2>/dev/null || echo 0) + 1))
      echo "$n" >"$tmp/chooses"
      sed -n "${n}p" <<<$'locked:1\nlocked:2\ndisk'
      ;;
    input)
      n=$(($(cat "$tmp/inputs" 2>/dev/null || echo 0) + 1))
      echo "$n" >"$tmp/inputs"
      sed -n "${n}p" <<<$'first\nsecond'
      ;;
  esac
}
username=kim password=pw home_password=""
home_form </dev/null
[[ $(cat "$tmp/scan-passwords") == $'pw\nfirst\nsecond' ]] || fail "every passphrase typed is tried again" "$(cat "$tmp/scan-passwords")"
rm -f "$tmp/scan-passwords"
SYSTEM_DISKS=unknown home_form </dev/null
[[ ! -e $tmp/scan-passwords ]] || fail "with the system disk unknown there is no Home step"
unset -f gum
pass "passphrases typed for locked drives add up"

# A retry whose first attempt made the account on the system disk (nothing
# remembered from the Home step): the Home step is not offered again, since
# the account's home is already there.
home_form() { echo "home-form" >>"$CALLS"; }
printf 'kim\n' >"$PROVISIONING_DIR/setup-user"
rm -f "$PROVISIONING_DIR/setup-home"
: >"$CALLS"
home_row=stale
USER_EXISTS=1 home_step
! grep -q home-form "$CALLS" && [[ -z $home_row ]] || fail "an account made on the system disk keeps its home there" "$(cat "$CALLS")"
home_step
grep -q home-form "$CALLS" || fail "a first attempt offers the Home step"
pass "a retry after the account was made on the system disk skips the Home step"

# First-boot setup runs as a system service: no HOME, no OMARCHY_PATH in its
# environment. Its Home step's strings come from omarchy-i18n, a child
# process, which needs both the path and a language file it can do without
# HOME; otherwise every label is empty.
setup_lines=$(grep -E '^export OMARCHY_(PATH|LANGUAGE_FILE)=' "$ROOT/bin/omarchy-provision-owner" || true)
seen=$(env -i PATH="$ROOT/bin:/usr/bin:/bin" bash -c "OMARCHY_PATH=$ROOT"$'\n'"$setup_lines"$'\n''omarchy-i18n homeDrive.systemDisk' 2>&1 || true)
[[ $seen == "On the system disk" ]] || fail "first boot's labels come out of omarchy-i18n without HOME" "$seen"
pass "first boot's labels come out of omarchy-i18n in a service's bare environment"

# The menu is drawn on the console: nothing it runs may print there.
noise=$(home_step_rows "$SCAN" kim 2>&1 >/dev/null)
[[ -z $noise ]] || fail "building the Home menu prints nothing on the console" "$noise"
pass "building the Home menu prints nothing on the console"
