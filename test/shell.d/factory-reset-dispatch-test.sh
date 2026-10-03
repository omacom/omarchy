#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Factory reset's boot step through the real omarchy-lifecycle-dispatch. On an
# x86 fixture the generic Limine UKI path runs and the boot-package entrypoints
# on disk never do. On an Apple fixture a fake boot package owns the factory
# root's boot chain: it prepares and verifies it before the throwaway slot is
# added, gets the key on standard input after the switch, and rolls back when
# the reset fails before the switch. Subvolumes are directories, and
# cryptsetup is a slot-table fake.
require_platform_fixtures "factory reset through lifecycle dispatch"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fake_platform "$tmp/x86" generic
fake_platform "$tmp/apple" apple-silicon

# Load the production functions without self-elevation or the reset entrypoint.
awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-system-factory-reset" >"$tmp/functions"

# The fake boot package: each entrypoint records its call, reset-commit its
# standard input, and reset-verify fails on request.
lifecycle=$tmp/lifecycle
mac_boot=$lifecycle/usr/lib/omarchy/mac-boot
mkdir -p "$mac_boot"
for operation in reset-prepare reset-verify reset-commit reset-rollback; do
  cat >"$mac_boot/$operation" <<SH
#!/bin/bash
echo "$operation\${*:+ \$*}" >>"$tmp/calls"
[[ $operation != reset-commit ]] || cat >"$tmp/committed-key"
[[ ! -e $tmp/$operation-fail ]] || { echo "$operation: the fixture refuses" >&2; exit 1; }
SH
done
chmod 755 "$mac_boot"/*
chmod -R go-w "$lifecycle"

cat >"$tmp/reset" <<'SH'
#!/bin/bash
set -euo pipefail
source "$TMP/functions"
TOP_MNT=$TMP/top
NEXT_NAME=@omarchy-reset-next
PROVISIONING_DIR=/var/lib/omarchy/provisioning
LOG_FILE=$TMP/reset.log
DISPATCH=${TEST_DISPATCH:-$ROOT/bin/omarchy-lifecycle-dispatch}
RESET_BOOT=""
RESET_BOOT_ERROR=""
swap_done=0

gum() {
  if [[ $1 == "input" ]]; then
    printf '%s\n' "$CURRENT"
  elif [[ $1 == "style" ]]; then
    printf '%s\n' "${!#}" >>"$TMP/screen"
  fi
}
encrypted_install() { [[ -n $DEVICE ]]; }
luks_device() { echo "$DEVICE"; }
scrub_factory_accounts() { :; }
sanitize_factory_baseline() { :; }
install_provisioning_units() { :; }
systemd-id128() { printf '%032d\n' 7; }
sync() { :; }
mountpoint() { return 0; }
mount() { echo "mount $*" >>"$TMP/calls"; }
umount() { :; }
chroot() { echo "chroot ${*:2}" >>"$TMP/calls"; }
reset_limine_config() { echo "limine menu reset" >>"$TMP/calls"; }
verify_limine_hashes() { :; }

btrfs() {
  case "$1 $2" in
    "subvolume snapshot") cp -a "$3" "$4" ;;
    "subvolume delete") rm -rf "${!#}" ;;
    "subvolume show") return 1 ;;
  esac
}

mv() {
  if [[ -e $TMP/switch-fail && $1 == "$TOP_MNT/@" ]]; then
    echo "mv: the fixture refuses the switch" >&2
    return 1
  fi
  if [[ -e $TMP/activate-fail && $1 == "$TOP_MNT/$NEXT_NAME" ]]; then
    echo "mv: the fixture refuses the activation" >&2
    return 1
  fi
  if [[ -e $TMP/restore-fail && $1 == "$TOP_MNT"/@omarchy-old-* ]]; then
    echo "mv: the fixture refuses the restore" >&2
    return 1
  fi
  command mv "$@"
}

# "<slot> <key>" per line.
cryptsetup() {
  local op=$1 key_file="" slot material next
  local -a args=()
  shift
  while (( $# )); do
    case $1 in
      --key-file) key_file=$2; shift 2 ;;
      --token-type) shift 2 ;;
      -*) shift ;;
      *) args+=("$1"); shift ;;
    esac
  done
  echo "cryptsetup $op" >>"$TMP/calls"
  case $op in
    open)
      material=$(cat "$key_file")
      if [[ -e $TMP/lookup-fail-once && $material != "$CURRENT" ]]; then
        rm "$TMP/lookup-fail-once"
        return 2
      fi
      slot=$(awk -v m="$material" '$2 == m { print $1; exit }' "$TMP/slots")
      [[ -n $slot ]] || return 2
      echo "Key slot $slot unlocked."
      ;;
    luksAddKey)
      material=$(cat "$key_file")
      awk -v m="$material" '$2 == m { found = 1 } END { exit !found }' "$TMP/slots" || return 2
      for (( next = 0; next < 32; next++ )); do
        awk '{ print $1 }' "$TMP/slots" | grep -qx "$next" || break
      done
      printf '%s %s\n' "$next" "$(cat "${args[1]}")" >>"$TMP/slots"
      ;;
    luksDump)
      echo "Keyslots:"
      awk '{ printf "  %s: luks2\n", $1 }' "$TMP/slots"
      ;;
    luksKillSlot)
      slot=${args[1]}
      awk -v s="$slot" '$1 != s' "$TMP/slots" >"$TMP/slots.next"
      command mv -f "$TMP/slots.next" "$TMP/slots"
      ;;
    *) return 1 ;;
  esac
}

case $MODE in
  owner) reset_boot_owner && echo "$RESET_BOOT" ;;
  reset)
    trap cleanup EXIT
    stage_full_reset
    ;;
esac
SH

current_password=owner-password
device=$tmp/luks-device

# A top-level Btrfs volume: the running root and a factory baseline whose ESP
# the generic path mounts from its fstab.
fixture() {
  rm -rf "$tmp/top" "$tmp/calls" "$tmp/screen" "$tmp/reset.log" "$tmp/committed-key" "$tmp"/*-fail
  mkdir -p "$tmp/top/@" "$tmp/top/@factory/etc" "$tmp/top/@factory/usr/bin" \
    "$tmp/top/@factory/usr/share/omarchy/install/provisioning" "$tmp/top/@factory/boot"
  touch "$tmp/top/@/old-system" "$tmp/top/@factory/factory-system" "$tmp/esp" \
    "$tmp/top/@factory/usr/share/omarchy/install/provisioning/omarchy-provision-owner.service"
  printf '#!/bin/bash\n' >"$tmp/top/@factory/usr/bin/omarchy-provision-owner"
  chmod +x "$tmp/top/@factory/usr/bin/omarchy-provision-owner"
  printf '%s /boot vfat defaults 0 2\n' "$tmp/esp" >"$tmp/top/@factory/etc/fstab"
  : >"$device"
  printf '0 %s\n' "$current_password" >"$tmp/slots"
  : >"$tmp/reset.log"
}

run() {
  local mode=$1 platform=$2
  TMP=$tmp ROOT=$ROOT MODE=$mode CURRENT=$current_password DEVICE=${DEVICE-$device} TEST_DISPATCH=${TEST_DISPATCH:-} \
    OMARCHY_PROC_ROOT="$tmp/$platform/proc" OMARCHY_LIFECYCLE_ROOT=$lifecycle PATH="$tmp/$platform/bin:$PATH" \
    bash "$tmp/reset" >"$tmp/out" 2>&1
}

activated() {
  [[ -e $tmp/top/@/factory-system && -f $tmp/top/@/var/lib/omarchy/provisioning/pending ]] &&
    compgen -G "$tmp/top/@omarchy-old-*/old-system" >/dev/null
}

untouched() {
  [[ -e $tmp/top/@/old-system && ! -e $tmp/top/@omarchy-reset-next ]] && [[ $(cat "$tmp/slots") == "0 $current_password" ]]
}

# x86: the generic Limine UKI path, with boot-package entrypoints on disk that
# would record themselves if they ran.
fixture
run owner x86 && [[ $(cat "$tmp/out") == "generic" ]] || fail "x86: the reset boot step is generic" "$(cat "$tmp/out")"
run reset x86 || fail "x86: an encrypted reset stages" "$(cat "$tmp/out" "$tmp/reset.log")"
activated || fail "x86: the factory root is activated"
grep -qx 'chroot /usr/bin/limine-update' "$tmp/calls" || fail "x86: limine-update rebuilds the factory root's UKI" "$(cat "$tmp/calls")"
[[ -f $tmp/top/@/etc/omarchy/provisioning.key && -f $tmp/top/@/etc/limine-entry-tool.d/99-omarchy-provisioning-unlock.conf &&
  -f $tmp/top/@/etc/mkinitcpio.conf.d/99-omarchy-provisioning-key.conf ]] || fail "x86: the UKI carries the reset's auto-unlock"
[[ $(awk 'NR == 2 { print $2 }' "$tmp/slots") == "$(cat "$tmp/top/@/var/lib/omarchy/provisioning/luks-key")" ]] ||
  fail "x86: the throwaway slot opens with the staged key" "$(cat "$tmp/slots")"
! grep -q '^reset-' "$tmp/calls" || fail "x86: no boot-package entrypoint runs" "$(cat "$tmp/calls")"
pass "x86: dispatch is a no-op and the generic Limine UKI path resets the machine"

# A failed activation on the generic path puts the previous root back and
# revokes the throwaway slot. The ESP already holds the factory root's UKI, so
# the screen says to rebuild the boot files rather than claiming nothing changed.
fixture
touch "$tmp/activate-fail"
if run reset x86; then fail "x86: a failed activation fails the reset"; fi
untouched || fail "x86: a failed activation puts the previous root back and revokes the throwaway slot" "$(ls "$tmp/top"; cat "$tmp/slots")"
! grep -q '^reset-' "$tmp/calls" || fail "x86: a failed activation runs no boot-package entrypoint" "$(cat "$tmp/calls")"
grep -q "run 'sudo limine-update' before rebooting" "$tmp/screen" ||
  fail "x86: a failed activation says the boot files need rebuilding" "$(cat "$tmp/screen")"
pass "x86: a failed activation puts the previous root back, revokes the throwaway slot and says to rebuild the boot files"

# Apple: the boot package prepares and verifies the factory root before the
# throwaway slot exists, and gets the key only once the factory root is active.
fixture
run owner apple && [[ $(cat "$tmp/out") == "platform" ]] || fail "apple: the boot package owns the reset boot step" "$(cat "$tmp/out")"
run reset apple || fail "apple: an encrypted reset stages" "$(cat "$tmp/out" "$tmp/reset.log")"
activated || fail "apple: the factory root is activated"
expected="reset-prepare $tmp/top/@omarchy-reset-next $device
reset-verify $tmp/top/@omarchy-reset-next
cryptsetup luksAddKey
reset-commit"
[[ $(grep -v '^cryptsetup \(open\|luksDump\)' "$tmp/calls") == "$expected" ]] ||
  fail "apple: prepare, verify, the throwaway slot, then commit" "$(cat "$tmp/calls")"
staged=$(cat "$tmp/top/@/var/lib/omarchy/provisioning/luks-key")
[[ -n $staged && $(cat "$tmp/committed-key") == "$staged" ]] || fail "apple: reset-commit gets the staged key on standard input"
[[ $(awk 'NR == 2 { print $2 }' "$tmp/slots") == "$staged" ]] || fail "apple: the throwaway slot opens with the staged key" "$(cat "$tmp/slots")"
[[ ! -e $tmp/top/@/etc/omarchy/provisioning.key && ! -e $tmp/top/@/etc/limine-entry-tool.d/99-omarchy-provisioning-unlock.conf ]] ||
  fail "apple: no Limine UKI unlock is written"
! grep -q 'limine' "$tmp/calls" || fail "apple: the Limine UKI path never runs" "$(cat "$tmp/calls")"
! grep -Fq "$staged" "$tmp/reset.log" "$tmp/calls" "$tmp/out" || fail "apple: the throwaway key is never logged"
pass "apple: the boot package prepares and verifies the factory root before the throwaway slot, and gets the key after the switch"

# A failed verification adds no credential and rolls the boot state back; the
# previous root keeps booting.
fixture
touch "$tmp/reset-verify-fail"
if run reset apple; then fail "apple: a failed verification fails the reset"; fi
[[ $(grep '^reset-' "$tmp/calls" | cut -d' ' -f1) == $'reset-prepare\nreset-verify\nreset-rollback' ]] ||
  fail "apple: a failed verification rolls back" "$(cat "$tmp/calls")"
! grep -q 'luksAddKey' "$tmp/calls" || fail "apple: a failed verification adds no slot"
untouched || fail "apple: a failed verification leaves the previous root and its slots" "$(cat "$tmp/slots")"
grep -q 'reset-verify: the fixture refuses' "$tmp/screen" || fail "apple: the verification's reason is shown" "$(cat "$tmp/screen")"
pass "apple: a failed verification rolls back, adds no slot and keeps the previous root"

# A failure after the slot was added and before the switch revokes it too.
fixture
touch "$tmp/switch-fail"
if run reset apple; then fail "apple: a failed switch fails the reset"; fi
grep -q 'luksAddKey' "$tmp/calls" && grep -qx 'reset-rollback' "$tmp/calls" && ! grep -q '^reset-commit' "$tmp/calls" ||
  fail "apple: a failed switch rolls back without committing" "$(cat "$tmp/calls")"
untouched || fail "apple: a failed switch revokes the throwaway slot and keeps the previous root" "$(cat "$tmp/slots")"
pass "apple: a failure before the switch revokes the slot it added and rolls the boot state back"

# The old root already moved aside when the factory root cannot take @: the old
# root goes back, and the reset is undone as if it failed before the switch.
fixture
touch "$tmp/activate-fail"
if run reset apple; then fail "apple: a failed activation fails the reset"; fi
grep -qx 'reset-rollback' "$tmp/calls" && ! grep -q '^reset-commit' "$tmp/calls" ||
  fail "apple: a failed activation rolls back without committing" "$(cat "$tmp/calls")"
untouched || fail "apple: a failed activation puts the previous root back at @ and revokes the throwaway slot" "$(ls "$tmp/top"; cat "$tmp/slots")"
! compgen -G "$tmp/top/@omarchy-old-*" >/dev/null || fail "apple: a failed activation leaves no renamed root behind" "$(ls "$tmp/top")"
grep -q 'the current root is back at @' "$tmp/screen" || fail "apple: a failed activation says the current root is back" "$(cat "$tmp/screen")"
pass "apple: a failed activation puts the previous root back, rolls back and revokes the slot"

# When the old root cannot go back either, neither root is at @: both survive
# for recovery, and the screen names the rename that restores the machine.
fixture
touch "$tmp/activate-fail" "$tmp/restore-fail"
if run reset apple; then fail "apple: a failed activation and restore fails the reset"; fi
old=$(compgen -G "$tmp/top/@omarchy-old-*") || fail "apple: the previous root survives under its moved-aside name" "$(ls "$tmp/top")"
[[ -e $old/old-system && -e $tmp/top/@omarchy-reset-next/factory-system && ! -e $tmp/top/@ ]] ||
  fail "apple: a failed restore keeps both roots" "$(ls "$tmp/top")"
grep -qx 'reset-rollback' "$tmp/calls" && [[ $(cat "$tmp/slots") == "0 $current_password" ]] ||
  fail "apple: a failed restore still rolls the boot state back and revokes the slot" "$(cat "$tmp/calls" "$tmp/slots")"
grep -q "rename ${old##*/} to @" "$tmp/screen" || fail "apple: a failed restore names the recovery rename" "$(cat "$tmp/screen")"
pass "apple: a failed activation and restore keeps both roots and names the recovery rename"

# A slot added but not confirmed is found by its key and revoked all the same.
fixture
touch "$tmp/lookup-fail-once"
if run reset apple; then fail "apple: an unconfirmed throwaway slot fails the reset"; fi
grep -qx 'reset-rollback' "$tmp/calls" && grep -q 'luksKillSlot' "$tmp/calls" || fail "apple: an unconfirmed slot is rolled back and killed" "$(cat "$tmp/calls")"
untouched || fail "apple: an unconfirmed throwaway slot is revoked" "$(cat "$tmp/slots")"
pass "apple: a throwaway slot the reset could not confirm is found by its key and revoked"

# Once the factory root is active nothing rolls back: a failed commit is logged
# and costs the first boot one password prompt.
fixture
touch "$tmp/reset-commit-fail"
run reset apple || fail "apple: a failed commit still completes the reset" "$(cat "$tmp/out")"
activated && ! grep -qx 'reset-rollback' "$tmp/calls" || fail "apple: a failed commit keeps the factory root active" "$(cat "$tmp/calls")"
grep -q 'reset-commit: the fixture refuses' "$tmp/reset.log" || fail "apple: a failed commit is logged" "$(cat "$tmp/reset.log")"
[[ $(wc -l <"$tmp/slots") == 2 ]] || fail "apple: a failed commit keeps the throwaway slot"
pass "apple: a failed commit after the switch is logged and the reset stands"

# An unencrypted Mac still has its boot files rebuilt and verified.
fixture
DEVICE="" run reset apple || fail "apple: an unencrypted reset stages" "$(cat "$tmp/out")"
[[ $(grep '^reset-' "$tmp/calls") == "reset-prepare $tmp/top/@omarchy-reset-next"$'\n'"reset-verify $tmp/top/@omarchy-reset-next"$'\n'"reset-commit" ]] ||
  fail "apple: an unencrypted reset names no LUKS device" "$(cat "$tmp/calls")"
! grep -q '^cryptsetup' "$tmp/calls" || fail "apple: an unencrypted reset touches no key slot"
pass "apple: an unencrypted reset rebuilds and verifies the boot files without a key"

# Without the boot package, or with one that lacks a reset operation, the
# reset stops before anything is asked or changed, naming the package.
fixture
mv "$mac_boot" "$tmp/mac-boot.off"
if run owner apple; then fail "apple without the boot package: the reset refuses"; fi
grep -q 'reset-prepare on apple-silicon needs omarchy-mac-boot' "$tmp/out" || fail "apple without the boot package: the package is named" "$(cat "$tmp/out")"
mkdir -p "$mac_boot"
cp -p "$tmp/mac-boot.off/reset-prepare" "$tmp/mac-boot.off/reset-verify" "$mac_boot/"
chmod -R go-w "$lifecycle"
run owner x86 && [[ $(cat "$tmp/out") == "generic" ]] || fail "x86: a partial boot package on disk is ignored" "$(cat "$tmp/out")"
if run owner apple; then fail "apple with part of the boot package: the reset refuses"; fi
grep -q 'reset-commit on apple-silicon needs omarchy-mac-boot' "$tmp/out" || fail "apple with part of the boot package: the missing operation is named" "$(cat "$tmp/out")"
rm -rf "$mac_boot"
mv "$tmp/mac-boot.off" "$mac_boot"
pass "apple: without the boot package's reset operations, or with only some of them, the reset refuses naming the package"

# A registration that left the reset operations optional and got only some of
# them would mix two boot paths: the reset refuses that too.
mkdir -p "$tmp/half"
cat >"$tmp/half/omarchy-lifecycle-dispatch" <<SH
#!/bin/bash
[[ \$* != "--resolve reset-prepare" ]] || echo /usr/lib/omarchy/mac-boot/reset-prepare
SH
chmod +x "$tmp/half/omarchy-lifecycle-dispatch"
fixture
if TEST_DISPATCH=$tmp/half/omarchy-lifecycle-dispatch run owner apple; then fail "a partial set of reset operations is refused"; fi
grep -q 'implements only some of the factory reset operations' "$tmp/out" || fail "a partial set of reset operations is explained" "$(cat "$tmp/out")"
pass "a boot package implementing only some of the reset operations is refused"
