#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1795716272.sh"
stubs="$test_tmp/stubs"
calls="$test_tmp/calls"
mkdir -p "$stubs"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

stub systemctl "echo \"systemctl \$*\" >>\"$calls\"; [[ ! -e $test_tmp/no-user-manager ]] || exit 1; [[ \$* != *is-active* || \$* == *default.target* ]]"
# oo7-installed holds the installed oo7 version; pacman -T accepts 0.7.3 and up.
# gnome-keyring-removed stands for its removal, shared by every user like the real one.
stub sudo "echo \"sudo \$*\" >>\"$calls\"
case \$* in
'pacman -S '*) [[ ! -e $test_tmp/pacman-fails ]] && echo 0.7.3 >$test_tmp/oo7-installed ;;
'pacman -R '*) [[ ! -e $test_tmp/remove-fails ]] && touch $test_tmp/gnome-keyring-removed ;;
esac"
stub omarchy-pkg-present "[[ \$1 == gnome-keyring && ! -e $test_tmp/gnome-keyring-removed ]]"
stub pacman "[[ \$1 == -T && \$2 == 'oo7>=0.7.3' && -e $test_tmp/oo7-installed ]] && (( \$(vercmp \$(<$test_tmp/oo7-installed) 0.7.3) >= 0 ))"
stub systemd-creds "echo \"systemd-creds \$*\" >>\"$calls\"; cat >\"\${@: -1}\""
# A keyring holding UNREPAIRABLE is refused wherever it's tried; repair-fails stands
# for a read or write error on the real keyrings, which a copy doesn't hit.
# MULTILINE is what the repair rewrites.
stub omarchy-keyring-repair "echo \"omarchy-keyring-repair\" >>\"$calls\"
dir=\${OMARCHY_KEYRING_DIR:-\$HOME/.local/share/keyrings}
[[ -n \${OMARCHY_KEYRING_DIR:-} || ! -e $test_tmp/repair-fails ]] || exit 1
! grep -qs UNREPAIRABLE \"\$dir\"/*.keyring || exit 1
sed -i 's/MULTILINE/repaired/' \"\$dir\"/*.keyring 2>/dev/null || true"
cp "$ROOT/bin/omarchy-keyring-seal" "$stubs/"
# Re-keying asks for passwords in a terminal, so the migration runs here without it.
stub omarchy-keyring-rekey "echo \"omarchy-keyring-rekey\" >>\"$calls\""

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
# oo7 goes in before gnome-keyring goes, so org.freedesktop.secrets stays provided.
install_line=$(grep -nF 'sudo pacman -S --noconfirm --needed oo7>=0.7.3 gcr' "$calls" | cut -d: -f1)
remove_line=$(grep -nF 'sudo pacman -R --noconfirm gnome-keyring' "$calls" | cut -d: -f1)
[[ -n $install_line && -n $remove_line ]] || fail "oo7 is installed and gnome-keyring removed"
(( install_line < remove_line )) || fail "oo7 is installed before gnome-keyring is removed"
seal_line=$(grep -n 'systemd-creds encrypt' "$calls" | cut -d: -f1)
grep -q 'enable oo7-daemon.service' "$calls" || fail "oo7 is enabled"
start_line=$(grep -n 'start oo7-daemon.service' "$calls" | cut -d: -f1)
(( seal_line < start_line )) || fail "the credential is sealed before the daemon starts"
pass "migration swaps the packages and seals the credential before starting oo7"

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

# A login keyring next to another chosen default doesn't take its place: the chosen
# one becomes login, and the old login keyring moves to a free name.
home=$(new_home has-login)
seed_keyring "$home"
keyrings="$home/.local/share/keyrings"
echo "chosen" >>"$keyrings/Default_keyring.keyring"
echo "pam" >"$keyrings/login.keyring"
echo "taken" >"$keyrings/previous_login.keyring"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with a login keyring"
grep -q 'chosen' "$keyrings/login.keyring" || fail "the chosen default becomes login"
[[ $(<"$keyrings/previous_login_2.keyring") == "pam" ]] || fail "the old login keyring moves to a free name"
[[ $(<"$keyrings/previous_login.keyring") == "taken" ]] || fail "an existing keyring isn't overwritten"
pass "migration keeps the chosen default ahead of an existing login keyring"

# A user whose chosen default is already login keeps it as it is.
home=$(new_home login-default)
mkdir -p "$home/.local/share/keyrings"
echo "login" >"$home/.local/share/keyrings/default"
echo "existing" >"$home/.local/share/keyrings/login.keyring"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with login as the default"
[[ $(<"$home/.local/share/keyrings/login.keyring") == "existing" ]] || fail "a login default stays in place"
[[ -z $(compgen -G "$home/.local/share/keyrings/previous_login*") ]] || fail "a login default isn't moved aside"
pass "migration keeps a login keyring that is already the default"

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

# A repair that fails on the keyrings themselves, not their content, stops the
# migration before anything changes.
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

# Without the repair command, which comes with the keyring repair change, nothing changes.
mv "$stubs/omarchy-keyring-repair" "$test_tmp/omarchy-keyring-repair"
home=$(new_home no-repair)
seed_keyring "$home"
: >"$calls"
if run_migration "$home" >/dev/null 2>&1; then
  fail "a missing repair command fails the migration"
fi
mv "$test_tmp/omarchy-keyring-repair" "$stubs/omarchy-keyring-repair"
! grep -q 'sudo pacman' "$calls" || fail "a missing repair command doesn't touch packages"
grep -q 'enable --now gnome-keyring-daemon.socket' "$calls" || fail "a missing repair command restores gnome-keyring"
[[ -f $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "a missing repair command leaves the keyring alone"
pass "migration stays pending without the repair command"

# The repair runs before the swap.
home=$(new_home repair-order)
seed_keyring "$home"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs after a repair"
repair_line=$(grep -n 'omarchy-keyring-repair' "$calls" | cut -d: -f1)
swap_line=$(grep -n 'sudo pacman' "$calls" | head -1 | cut -d: -f1)
(( repair_line < swap_line )) || fail "the repair runs before the package swap"
pass "migration repairs the keyring before the package swap"

# The backup holds the keyring as it was before the repair.
home=$(new_home backup-before-repair)
seed_keyring "$home"
echo "MULTILINE" >>"$home/.local/share/keyrings/Default_keyring.keyring"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with a repairable secret"
grep -q 'repaired' "$home/.local/share/keyrings/login.keyring" || fail "the keyring is repaired"
grep -q 'MULTILINE' "$home/.local/share/keyrings.pre-oo7/Default_keyring.keyring" || fail "the backup predates the repair"
pass "migration backs up the keyring before repairing it"

# A keyring the repair refuses moves into the backup, and the migration finishes
# without it instead of staying pending and holding back every later migration.
home=$(new_home unrepairable)
seed_keyring "$home"
keyrings=$home/.local/share/keyrings
printf '[keyring]\nUNREPAIRABLE\n' >"$keyrings/Other.keyring"
echo "MULTILINE" >>"$keyrings/Default_keyring.keyring"
: >"$calls"
output=$(run_migration "$home" 2>&1) || fail "migration finishes despite an unrepairable keyring"
[[ ! -e $keyrings/Other.keyring ]] || fail "the unrepairable keyring leaves oo7's way"
grep -q 'UNREPAIRABLE' "$home/.local/share/keyrings.pre-oo7/Other.keyring.unrepairable" || fail "the unrepairable keyring is kept in the backup"
[[ $output == *"Other.keyring can't be repaired safely"* ]] || fail "the user is told which keyring was moved"
grep -q 'repaired' "$keyrings/login.keyring" || fail "the other keyrings are still repaired and moved"
grep -q 'enable oo7-daemon.service' "$calls" || fail "oo7 is enabled"
! grep -q 'enable --now gnome-keyring-daemon.socket' "$calls" || fail "gnome-keyring isn't restored"
pass "migration sets an unrepairable keyring aside and finishes"

# If the default keyring is the unrepairable one, oo7 starts with a new login keyring.
home=$(new_home unrepairable-default)
seed_keyring "$home"
echo "UNREPAIRABLE" >>"$home/.local/share/keyrings/Default_keyring.keyring"
run_migration "$home" >/dev/null 2>&1 || fail "migration finishes despite an unrepairable default keyring"
[[ ! -e $home/.local/share/keyrings/login.keyring ]] || fail "nothing is renamed to login"
[[ -f $home/.local/share/keyrings.pre-oo7/Default_keyring.keyring.unrepairable ]] || fail "the default keyring is kept in the backup"
[[ -s $home/.config/credstore.encrypted/oo7.keyring-encryption-password ]] || fail "the credential is sealed"
pass "migration sets an unrepairable default keyring aside"

# An oo7 older than 0.7.3 can lose an unconverted keyring, so it's upgraded in the swap.
echo 0.7.2 >"$test_tmp/oo7-installed"
home=$(new_home old-oo7)
seed_keyring "$home"
: >"$calls"
run_migration "$home" >/dev/null 2>&1 || fail "migration runs with an older oo7"
grep -qF 'sudo pacman -S --noconfirm --needed oo7>=0.7.3 gcr' "$calls" || fail "an older oo7 is upgraded"
[[ $(<"$test_tmp/oo7-installed") == 0.7.3 ]] || fail "oo7 is at 0.7.3 after the swap"
pass "migration upgrades an oo7 older than 0.7.3"

# If gnome-keyring can't be removed (another package needs it by name), oo7 stays
# installed but disabled, and gnome-keyring keeps serving until the next attempt.
rm -f "$test_tmp/gnome-keyring-removed"
touch "$test_tmp/remove-fails"
home=$(new_home failed-removal)
seed_keyring "$home"
: >"$calls"
if run_migration "$home" >/dev/null 2>&1; then
  fail "a failed gnome-keyring removal fails the migration"
fi
grep -q 'enable --now gnome-keyring-daemon.socket' "$calls" || fail "a failed removal restores gnome-keyring"
! grep -q 'oo7-daemon' "$calls" || fail "a failed removal leaves oo7-daemon alone"
[[ -f $home/.local/share/keyrings/Default_keyring.keyring ]] || fail "a failed removal leaves the keyring alone"
rm -f "$test_tmp/remove-fails"
pass "migration leaves oo7 idle if gnome-keyring can't be removed"

# If the package swap fails, the migration stays pending and the old keyring comes back.
rm -f "$test_tmp/oo7-installed" "$test_tmp/gnome-keyring-removed"
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
