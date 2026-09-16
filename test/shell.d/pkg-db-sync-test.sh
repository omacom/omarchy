#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The ISO installs offline and post-install/pacman.sh then repoints pacman at
# the Omarchy mirrors, so a freshly installed machine has no database for the
# repositories it is configured to install from. Every package helper has to
# close that gap before it reaches for a package that only exists in one of
# them.
grep -q 'omarchy-pkg-db-sync' "$ROOT/bin/omarchy-pkg-add" ||
  fail "installing an Arch package syncs repositories that have never been synced"
grep -q 'omarchy-pkg-db-sync' "$ROOT/bin/omarchy-pkg-aur-add" ||
  fail "installing an AUR package syncs repositories that have never been synced"

pass "the package helpers sync unsynced repositories before installing"

grep -q 'omarchy-pkg-db-sync' "$ROOT/install/post-install/pacman.sh" ||
  fail "the installer syncs the mirrors it just configured"

pass "a fresh install leaves the configured repositories synced"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
sync_dir="$test_tmp/db/sync"
mkdir -p "$mock_bin" "$sync_dir"

cat >"$mock_bin/pacman-conf" <<'SH'
#!/bin/bash
case "$1" in
  DBPath) printf '%s/\n' "$OMARCHY_DB_TEST_DBPATH" ;;
  --repo-list) printf '%s\n' core extra multilib omarchy ;;
  *) exit 2 ;;
esac
SH
cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
printf 'pacman\t%s\n' "$*" >>"$OMARCHY_DB_TEST_LOG"
exit "${OMARCHY_DB_TEST_SYNC_STATUS:-0}"
SH
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo\t%s\n' "$*" >>"$OMARCHY_DB_TEST_LOG"
exec "$@"
SH
chmod +x "$mock_bin"/*

log="$test_tmp/actions.log"
export OMARCHY_DB_TEST_LOG="$log"
export OMARCHY_DB_TEST_DBPATH="$test_tmp/db"

run_db_sync() {
  PATH="$mock_bin:$PATH" bash "$ROOT/bin/omarchy-pkg-db-sync"
}

# A machine straight off the ISO: the offline repository it installed from is
# gone from pacman.conf and nothing has replaced it.
: >"$log"
printf 'offline\n' >"$sync_dir/offline.db"
run_db_sync || fail "the sync runs on a machine that has never synced"
grep -qxF $'pacman\t-Sy --noconfirm' "$log" ||
  fail "a repository without a database is downloaded"

pass "a machine installed from the offline repository syncs on first use"

# Once every configured repository has one, syncing again is somebody else's
# job -- omarchy update owns the -Syu that keeps them current.
: >"$log"
for repo in core extra multilib omarchy; do
  printf '%s\n' "$repo" >"$sync_dir/$repo.db"
done
run_db_sync || fail "the sync succeeds when every repository has a database"
[[ ! -s $log ]] || fail "a fully synced machine downloads nothing"

pass "an already synced machine is left alone"

# Offline, the sync cannot succeed. The install behind it still has to run so
# the user hears about the package they asked for, not the database.
: >"$log"
rm -f "$sync_dir/extra.db"
OMARCHY_DB_TEST_SYNC_STATUS=1 run_db_sync ||
  fail "a failed sync does not abort the install that follows it"
grep -qxF $'pacman\t-Sy --noconfirm' "$log" ||
  fail "the sync was attempted before giving up on it"

pass "a sync that cannot reach the mirrors does not swallow the install"
