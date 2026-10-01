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
cat >"$test_tmp/bin/omarchy-update-pacman" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$test_tmp/bin/omarchy-update-system-pkgs-when-conflicted" <<'STUB'
#!/bin/bash
echo conflict-handler >>"$TEST_LOG"
exit 0
STUB
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
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
  grep -q -- '^-Syu ' "$TEST_LOG" || fail "valid records still upgrade"
done
pass "valid records allow upgrades, including packages that own no files"

mkdir -p "$TEST_DATABASE/local/another-package-2.0-3"
: >"$TEST_DATABASE/local/another-package-2.0-3/desc"
: >"$record/desc"
if "$ROOT/bin/omarchy-update-verify-package-database" >"$test_tmp/output" 2>&1; then
  fail "multiple damaged records block the update"
fi
for package in example another-package; do
  grep -Fq "sudo pacman -S --dbonly -- $package" "$test_tmp/output" || fail "every damaged package has a database repair command"
  grep -Fxq "  sudo pacman -S -- $package" "$test_tmp/output" || fail "every damaged package has a reinstall command"
done
grep -Fq 'omarchy-record-backups' "$test_tmp/output" || fail "repair guidance keeps a backup outside the local database"
[[ -d $record && -d $TEST_DATABASE/local/another-package-2.0-3 ]] || fail "verification performs no repair automatically"
pass "one check identifies every damaged record and prints recoverable repair steps"

for inaccessible in local record desc files; do
  printf '%%NAME%%\nexample\n\n%%REASON%%\n1\n' >"$record/desc"
  : >"$record/files"
  case "$inaccessible" in
    local) blocked="$TEST_DATABASE/local"; mode=600 ;;
    record) blocked="$record"; mode=600 ;;
    desc|files) blocked="$record/$inaccessible"; mode=000 ;;
  esac
  chmod "$mode" "$blocked"
  status=0
  "$ROOT/bin/omarchy-update-verify-package-database" >"$test_tmp/output" 2>&1 || status=$?
  chmod u+rwx "$blocked"
  (( status != 0 )) || fail "inaccessible $inaccessible cannot pass verification"
  grep -q 'Cannot' "$test_tmp/output" || fail "inaccessible records explain the permissions failure"
done
pass "unreadable and nontraversable records stop verification"

printf '%%NAME%%\nexample\n\n%%REASON%%\n1\n' >"$record/desc"
rm "$record/files"
if "$ROOT/bin/omarchy-update-verify-package-database" >"$test_tmp/output" 2>&1; then
  fail "dependency with a damaged record blocks verification"
fi
grep -Fxq '  sudo pacman -D --asdeps -- example' "$test_tmp/output" || fail "repair restores a known dependency reason"
grep -q 'install reason is missing' "$test_tmp/output" || fail "lost metadata is reported without guessing the install reason"
pass "repair guidance restores known dependency reasons and reports missing metadata"
