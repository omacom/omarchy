#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/db/sync"
export OMARCHY_DB_TEST_DBPATH="$test_tmp/db"
export OMARCHY_DB_TEST_LOG="$test_tmp/actions.log"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/pacman-conf" <<'SH'
#!/bin/bash
[[ ${DB_CONFIG_FAIL:-} != "$1" ]] || exit 1
printf 'config %s\n' "$1" >>"$OMARCHY_DB_TEST_LOG"
case "$1" in
  DBPath) echo "$OMARCHY_DB_TEST_DBPATH" ;;
  --repo-list) printf '%s\n' ${DB_REPOS:-core extra} ;;
  *) exit 2 ;;
esac
SH
cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
printf 'pacman %s\n' "$*" >>"$OMARCHY_DB_TEST_LOG"
if [[ $1 == "-Slq" ]]; then
  echo example
fi
SH
cat >"$test_tmp/bin/yay" <<'SH'
#!/bin/bash
printf 'yay %s\n' "$*" >>"$OMARCHY_DB_TEST_LOG"
if [[ $1 == "-Slqa" ]]; then
  echo example
fi
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
# Exercise the missing-package path; package presence has its own tests.
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/omarchy-pkg-missing"
printf '#!/bin/bash\ncat\n' >"$test_tmp/bin/fzf"
printf '#!/bin/bash\n:\n' >"$test_tmp/bin/omarchy-sudo-keepalive"
printf '#!/bin/bash\nexit "$1"\n' >"$test_tmp/bin/omarchy-show-done"
printf '#!/bin/bash\n:\n' >"$test_tmp/bin/updatedb"
chmod +x "$test_tmp/bin"/*

# Run the real callers and the real guard. Missing databases must stop even
# listing packages, and no standalone sync may precede an install.
for caller in add aur-add install aur-install; do
  : >"$OMARCHY_DB_TEST_LOG"
  if bash "$ROOT/bin/omarchy-pkg-$caller" example >"$test_tmp/output" 2>&1; then
    fail "$caller rejects missing databases"
  fi
  grep -q 'omarchy update' "$test_tmp/output" || fail "$caller explains recovery"
  if grep -Eq '^(pacman|yay) ' "$OMARCHY_DB_TEST_LOG"; then
    fail "$caller stops before package operations when databases are missing"
  fi
  pass "$caller requires a system update before listing or installing"
done

# Fully synced machines retain all four installation paths. Check the order
# from executed commands rather than searching their source.
touch "$test_tmp/db/sync/core.db" "$test_tmp/db/sync/extra.db"
for caller in add aur-add install aur-install; do
  : >"$OMARCHY_DB_TEST_LOG"
  bash "$ROOT/bin/omarchy-pkg-$caller" example >"$test_tmp/output" 2>&1 || fail "$caller installs with databases present"
  [[ $(head -2 "$OMARCHY_DB_TEST_LOG") == $'config DBPath\nconfig --repo-list' ]] || fail "$caller checks before package operations"
  grep -Eq '^(pacman|yay) -S ' "$OMARCHY_DB_TEST_LOG" || fail "$caller reaches installation"
  if grep -Eq '^(pacman|yay) -Sy' "$OMARCHY_DB_TEST_LOG"; then
    fail "$caller must not refresh databases independently"
  fi
  pass "$caller checks databases before listing or installing"
done

rm "$test_tmp/db/sync/extra.db"
if omarchy-pkg-require-dbs >"$test_tmp/output" 2>&1; then
  fail "a newly configured repository requires an update too"
fi
pass "one missing repository blocks installation"

# The installer's offline repository remains usable without a network.
touch "$test_tmp/db/sync/offline.db"
DB_REPOS=offline omarchy-pkg-require-dbs || fail "the ISO's existing offline database is sufficient"
pass "offline installation can use its bundled repository"

for query in DBPath --repo-list; do
  if DB_CONFIG_FAIL="$query" omarchy-pkg-require-dbs; then
    fail "a failed $query lookup must not permit installation"
  fi
done
pass "configuration lookup errors stop installation"
