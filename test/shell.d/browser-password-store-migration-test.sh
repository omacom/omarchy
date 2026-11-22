#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1784508556.sh"

# Runs the migration with HOME at $1 and its combined output in $2; $3, when set,
# goes ahead of PATH (stubbed commands). Echoes the exit status.
run_migration() {
  local test_home="$1" output="$2" extra_path="${3:-}" status=0
  (
    cd "$test_home"
    env -i \
      HOME="$test_home" \
      PATH="${extra_path:+$extra_path:}$ROOT/bin:/usr/bin" \
      bash -euo pipefail "$migration"
  ) >"$output" 2>&1 || status=$?
  echo "$status"
}

new_profile_fixture() {
  local profile="$1"
  printf 'saved logins' >"$profile/Login Data"
  printf 'wal' >"$profile/Login Data-wal"
  printf 'journal' >"$profile/Login Data-journal"
  printf 'saved cookies' >"$profile/Cookies"
}

# A brave install that already fell back to the basic store: an unpinned flags
# conf next to two profiles holding logins and cookies.
home=$test_tmp/unpinned
data="$home/.config/BraveSoftware/Brave-Browser"
mkdir -p "$data/Default" "$data/Profile 1"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$home/.config/brave-flags.conf"
new_profile_fixture "$data/Default"
new_profile_fixture "$data/Profile 1"

status=$(run_migration "$home" "$test_tmp/unpinned.log")
(( status == 0 )) || fail "migration pins a browser that has profile data" "$(cat "$test_tmp/unpinned.log")"

conf="$home/.config/brave-flags.conf"
[[ $(grep -c -- '--password-store=gnome-libsecret' "$conf") == "1" ]] || fail "migration appends the pin once" "$(cat "$conf")"
grep -qF -- '--enable-features=WaylandWindowDecorations' "$conf" || fail "migration keeps the conf's existing flags"

backup_root="$home/.local/state/omarchy/migration-backups"
backups=("$backup_root"/*)
if (( ${#backups[@]} != 1 )) || [[ ! -d ${backups[0]} ]]; then
  fail "migration creates one backup directory" "found: ${backups[*]}"
fi
backup=${backups[0]}
for profile in "Default" "Profile 1"; do
  for file in "Login Data" "Login Data-wal" "Login Data-journal" "Cookies"; do
    [[ -f "$backup/$profile/$file" ]] || fail "migration backs up $profile/$file" "missing from $backup"
  done
done
[[ $(cat "$backup/Default/Login Data") == "saved logins" ]] || fail "backup preserves the database contents"
pass "migration backs up every profile's logins and cookies before pinning"

grep -qF "$backup" "$test_tmp/unpinned.log" || fail "warning names the backup path" "$(cat "$test_tmp/unpinned.log")"
grep -q "undecryptable" "$test_tmp/unpinned.log" || fail "warning names the password-loss risk" "$(cat "$test_tmp/unpinned.log")"
pass "migration warns about the risk and the backup path"

# A conf that is already pinned must not be pinned twice nor backed up again.
status=$(run_migration "$home" "$test_tmp/pinned.log")
(( status == 0 )) || fail "migration completes for an already-pinned browser" "$(cat "$test_tmp/pinned.log")"
[[ $(grep -c -- '--password-store=gnome-libsecret' "$conf") == "1" ]] || fail "already-pinned conf is not pinned twice" "$(cat "$conf")"
backups=("$backup_root"/*)
if (( ${#backups[@]} != 1 )) || [[ ${backups[0]} != "$backup" ]]; then
  fail "already-pinned conf triggers no new backup" "found: ${backups[*]}"
fi
pass "already-pinned conf neither re-pins nor backs up again"

# No profile data at all: nothing to back up, so the pin lands as before.
home=$test_tmp/no-profiles
mkdir -p "$home/.config"
printf '%s\n' '--ozone-platform-hint=auto' >"$home/.config/chromium-flags.conf"

status=$(run_migration "$home" "$test_tmp/no-profiles.log")
(( status == 0 )) || fail "migration pins a browser with no profile data" "$(cat "$test_tmp/no-profiles.log")"
grep -q -- '--password-store=gnome-libsecret' "$home/.config/chromium-flags.conf" || fail "migration pins the empty browser"
[[ ! -e "$home/.local/state/omarchy/migration-backups" ]] || fail "no backup is made without profile data"
pass "a browser with no profile data is pinned without a backup"

# A backup that cannot be made defers the whole migration (exit 75) instead of
# pinning with nothing to restore from.
home=$test_tmp/failed-backup
mkdir -p "$home/.config/BraveSoftware/Brave-Browser/Default" "$test_tmp/bin"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$home/.config/brave-flags.conf"
new_profile_fixture "$home/.config/BraveSoftware/Brave-Browser/Default"
printf '#!/bin/bash\nexit 1\n' >"$test_tmp/bin/cp"
chmod +x "$test_tmp/bin/cp"

status=$(run_migration "$home" "$test_tmp/failed-backup.log" "$test_tmp/bin")
(( status == 75 )) || fail "a failed backup defers the migration with exit 75" "$(cat "$test_tmp/failed-backup.log")"
if grep -qF -- '--password-store=' "$home/.config/brave-flags.conf"; then
  fail "a failed backup leaves the conf unpinned" "$(cat "$home/.config/brave-flags.conf")"
fi
grep -q "Could not back up" "$test_tmp/failed-backup.log" || fail "a deferred run explains the deferral" "$(cat "$test_tmp/failed-backup.log")"
pass "a failed backup defers the migration instead of pinning"
