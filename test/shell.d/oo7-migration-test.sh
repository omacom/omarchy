#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1793743072.sh"
stubs="$test_tmp/stubs"
calls="$test_tmp/calls"
mkdir -p "$stubs"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

stub systemctl "echo \"systemctl \$*\" >>\"$calls\"; [[ ! -e $test_tmp/no-user-manager ]] || exit 1; [[ \$* != *is-active* || \$* == *default.target* ]]"
stub sudo "echo \"sudo \$*\" >>\"$calls\"; [[ ! -e $test_tmp/pacman-fails ]] && touch $test_tmp/oo7-installed"
stub omarchy-pkg-missing "[[ ! -e $test_tmp/oo7-installed ]]"
stub systemd-creds "echo \"systemd-creds \$*\" >>\"$calls\"; cat >\"\${@: -1}\""
stub omarchy-keyring-repair "echo \"omarchy-keyring-repair\" >>\"$calls\"; [[ ! -e $test_tmp/repair-fails ]]"
cp "$ROOT/bin/omarchy-keyring-seal" "$stubs/"

run_migration() {
  (
    cd "$1"
    env -i HOME="$1" PATH="$stubs:/usr/bin" bash -euo pipefail "$migration"
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config/xdg-desktop-portal"
  printf '[preferred]\ndefault=hyprland;gtk\norg.freedesktop.impl.portal.Secret=gnome-keyring\n' \
    >"$test_home/.config/xdg-desktop-portal/hyprland-portals.conf"
  echo "$test_home"
}

seed_keyring() {
  mkdir -p "$1/.local/share/keyrings"
  echo "Default_keyring" >"$1/.local/share/keyrings/default"
  echo "[keyring]" >"$1/.local/share/keyrings/Default_keyring.keyring"
}

# An Omarchy keyring becomes the default collection, and a copy stays behind.
home=$(new_home stock)
seed_keyring "$home"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs"
[[ -f $home/.local/share/keyrings/login.keyring ]] || fail "the default keyring is renamed to login"
[[ ! -e $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "the old name is gone"
[[ -f $home/.local/share/keyrings.pre-oo7/Default_keyring.keyring ]] || fail "the backup keeps the old keyring"
[[ $(stat -c '%a' "$home/.local/share/keyrings.pre-oo7") == "700" ]] || fail "the backup is private"
[[ -s $home/.config/credstore.encrypted/oo7.keyring-encryption-password ]] || fail "the credential is sealed"
grep -q 'Secret=oo7-portal' "$home/.config/xdg-desktop-portal/hyprland-portals.conf" || fail "the portal points at oo7"
pass "migration moves a stock keyring to oo7"

# The swap is one conflict-resolving transaction, before the daemon starts with the credential.
grep -q 'sudo pacman -S --noconfirm --needed --ask 4 oo7 gcr' "$calls" || fail "packages swap in one transaction"
seal_line=$(grep -n 'systemd-creds encrypt' "$calls" | cut -d: -f1)
grep -q 'enable oo7-daemon.service' "$calls" || fail "oo7 is enabled"
start_line=$(grep -n 'start oo7-daemon.service' "$calls" | cut -d: -f1)
(( seal_line < start_line )) || fail "the credential is sealed before the daemon starts"
pass "migration seals the credential before starting oo7"

# A second run changes nothing: no reinstall, no new credential.
credential_before=$(sha256sum "$home/.config/credstore.encrypted/oo7.keyring-encryption-password")
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration is idempotent"
! grep -q 'sudo pacman' "$calls" || fail "a second run doesn't touch packages"
[[ $(sha256sum "$home/.config/credstore.encrypted/oo7.keyring-encryption-password") == "$credential_before" ]] ||
  fail "a second run keeps the credential"
pass "migration is idempotent"

# A second user finds the packages swapped already, and gets their own credential.
home=$(new_home second-user)
seed_keyring "$home"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs for a second user"
! grep -q 'sudo pacman' "$calls" || fail "a second user doesn't touch packages"
[[ -f $home/.local/share/keyrings/login.keyring ]] || fail "a second user's keyring is renamed"
pass "migration handles a second user"

# A user who already has a login keyring keeps it.
home=$(new_home has-login)
seed_keyring "$home"
echo "existing" >"$home/.local/share/keyrings/login.keyring"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with a login keyring"
[[ $(<"$home/.local/share/keyrings/login.keyring") == "existing" ]] || fail "an existing login keyring isn't replaced"
[[ -f $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "the other keyring stays"
pass "migration keeps an existing login keyring"

# A user with no keyring still gets the daemon and the credential.
home=$(new_home no-keyring)
run_migration "$home" >/dev/null 2>&1 || fail "migration runs without a keyring"
[[ ! -e $home/.local/share/keyrings.pre-oo7 ]] || fail "nothing to back up"
[[ -s $home/.config/credstore.encrypted/oo7.keyring-encryption-password ]] || fail "the credential is sealed without a keyring"
pass "migration handles a user without a keyring"

# A custom portal choice is left alone.
home=$(new_home custom-portal)
sed -i 's/Secret=gnome-keyring/Secret=kwallet/' "$home/.config/xdg-desktop-portal/hyprland-portals.conf"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with a custom portal"
grep -q 'Secret=kwallet' "$home/.config/xdg-desktop-portal/hyprland-portals.conf" || fail "a custom portal isn't replaced"
pass "migration keeps a custom portal"

# An update from a TTY has no user manager: the migration still finishes, for the next login.
touch "$test_tmp/no-user-manager"
home=$(new_home tty-update)
seed_keyring "$home"
wants="$home/.config/systemd/user/default.target.wants"
mkdir -p "$wants"
ln -s /usr/lib/systemd/user/gnome-keyring-daemon.socket "$wants/gnome-keyring-daemon.socket"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs without a user manager"
[[ $(readlink "$wants/oo7-daemon.service") == "/usr/lib/systemd/user/oo7-daemon.service" ]] || fail "oo7 is enabled by symlink"
[[ ! -L $wants/gnome-keyring-daemon.socket ]] || fail "the gnome-keyring link is removed"
! grep -q 'start oo7-daemon.service' "$calls" || fail "oo7 waits for the next login"
rm -f "$test_tmp/no-user-manager"
pass "migration handles an update from a TTY"

# The Quattro upgrade reboots into the new session, so it doesn't start the daemon.
home=$(new_home quattro-upgrade)
seed_keyring "$home"
: >"$calls"
(cd "$home" && env -i HOME="$home" PATH="$stubs:/usr/bin" OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 bash -euo pipefail "$migration") >/dev/null 2>&1 ||
  fail "migration runs during the Quattro upgrade"
! grep -q 'start oo7-daemon.service' "$calls" || fail "the Quattro upgrade doesn't start oo7"
pass "migration leaves oo7 for the reboot after the Quattro upgrade"

# A keyring that can't be repaired stops the migration before anything changes.
rm -f "$test_tmp/oo7-installed"
touch "$test_tmp/repair-fails"
home=$(new_home failed-repair)
seed_keyring "$home"
: >"$calls"
if run_migration "$home" >/dev/null 2>&1; then
  fail "a failed repair fails the migration"
fi
! grep -q 'sudo pacman' "$calls" || fail "a failed repair doesn't touch packages"
grep -q 'enable --now gnome-keyring-daemon.socket' "$calls" || fail "a failed repair restores gnome-keyring"
[[ -f $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "a failed repair leaves the keyring alone"
rm -f "$test_tmp/repair-fails"
pass "migration stops before the swap if the repair fails"

# The repair runs before the swap.
home=$(new_home repair-order)
seed_keyring "$home"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs after a repair"
repair_line=$(grep -n 'omarchy-keyring-repair' "$calls" | cut -d: -f1)
swap_line=$(grep -n 'sudo pacman' "$calls" | cut -d: -f1)
(( repair_line < swap_line )) || fail "the repair runs before the package swap"
pass "migration repairs the keyring before the package swap"

# If the package swap fails, the migration stays pending and the old keyring comes back.
rm -f "$test_tmp/oo7-installed"
touch "$test_tmp/pacman-fails"
home=$(new_home failed-swap)
seed_keyring "$home"
: >"$calls"
if run_migration "$home" >/dev/null 2>&1; then
  fail "a failed package swap fails the migration"
fi
grep -q 'enable --now gnome-keyring-daemon.socket' "$calls" || fail "a failed swap restores gnome-keyring"
[[ -f $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "a failed swap leaves the keyring alone"
pass "migration recovers from a failed package swap"
