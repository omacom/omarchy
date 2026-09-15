#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/database/local/example-1.0-1"
export TEST_LOG="$test_tmp/calls" TEST_DATABASE="$test_tmp/database"
cat >"$test_tmp/bin/pacman-conf" <<'STUB'
#!/bin/bash
[[ $1 == "DBPath" ]] || exit 99
printf '%s\n' "$TEST_DATABASE"
STUB
cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
[[ $* == *'pacman -Syu '* ]]
STUB
cat >"$test_tmp/bin/omarchy-update-system-pkgs-when-conflicted" <<'STUB'
#!/bin/bash
echo conflict-handler >>"$TEST_LOG"
exit 0
STUB
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"
record="$TEST_DATABASE/local/example-1.0-1"

for damage in empty-desc missing-desc missing-files; do
  printf '%%NAME%%\nexample\n\n%%VERSION%%\n1.0-1\n' >"$record/desc"
  : >"$record/files"
  case "$damage" in
    empty-desc) : >"$record/desc" ;;
    missing-desc) rm "$record/desc" ;;
    missing-files) rm "$record/files" ;;
  esac
  for interactive in 0 1; do
    : >"$TEST_LOG"
    if OMARCHY_UPDATE_CONFLICT=1 OMARCHY_UPDATE_INTERACTIVE="$interactive" \
      bash "$ROOT/bin/omarchy-update-system-pkgs" >"$test_tmp/output" 2>&1; then
      fail "$damage stops the update"
    fi
    [[ ! -s $TEST_LOG ]] || fail "broken records never reach upgrades or conflict recovery"
    grep -Fq "$record/" "$test_tmp/output" || fail "failure identifies the damaged record"
    grep -q 'reinstall it' "$test_tmp/output" || fail "failure explains the repair needed"
  done
done
pass "empty or missing records stop automatic and interactive upgrades"

printf '%%NAME%%\nexample\n\n%%VERSION%%\n1.0-1\n' >"$record/desc"
: >"$record/files"
for interactive in 0 1; do
  : >"$TEST_LOG"
  OMARCHY_UPDATE_CONFLICT=1 OMARCHY_UPDATE_INTERACTIVE="$interactive" \
    bash "$ROOT/bin/omarchy-update-system-pkgs" >"$test_tmp/output" 2>&1
  grep -q 'pacman -Syu' "$TEST_LOG" || fail "valid records still upgrade"
done
pass "valid records allow upgrades, including packages that own no files"
