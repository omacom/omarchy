#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"
export CALL_LOG="$test_dir/calls"

cat >"$test_dir/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$CALL_LOG"
exit "${PACKAGE_STATUS:-0}"
SH
cat >"$test_dir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
quiet=0
if [[ $1 == "-q" ]]; then
  quiet=1
  shift
fi
if [[ ${SHELL_ABSENT:-0} == 1 ]]; then
  (( quiet )) && exit 0
  echo "omarchy-shell is not running" >&2
  exit 1
fi
[[ $2 != "rescanPlugins" ]] || exit 0
printf '%s\n' "${TEST_PUT_RESULT:-ok}"
SH
cat >"$test_dir/bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
echo 'migration must leave the restart to omarchy update' >&2
exit 1
SH
chmod +x "$test_dir/bin/"*

migration="$ROOT/migrations/1790042972.sh"

plugin="$test_dir/home/.config/omarchy/plugins/omacom.elsewhen"
run_migration() {
  : >"$CALL_LOG"
  HOME="$test_dir/home" OMARCHY_PATH="${1:-$test_dir/packaged}" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >"$test_dir/output" 2>&1
}

if PACKAGE_STATUS=1 run_migration; then
  fail "package failure stops the migration"
fi
[[ ! -e $plugin && ! -L $plugin && $(cat "$CALL_LOG") == "package elsewhen" ]] ||
  fail "package failure leaves the plugin and shell untouched"
pass "package failure stops before changing the shell"

run_migration
[[ ! -e $plugin && ! -L $plugin ]] || fail "migration does not create a user plugin link"
[[ ! -e $ROOT/config/omarchy/plugins/omacom.elsewhen && ! -L $ROOT/config/omarchy/plugins/omacom.elsewhen ]] || fail "fresh installs do not ship a user plugin link"
pass "migration and fresh installs rely on the packaged plugin directory"

expected=$'package elsewhen\n-q shell rescanPlugins\nshell putBarWidget omacom.elsewhen {"before":"omarchy.clock"}'
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "install, scan and placement run in order" "$(cat "$CALL_LOG")"
pass "real bar helper enables and places before the clock without restarting during reload"

run_migration
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "migration can be rerun"
[[ ! -e $plugin && ! -L $plugin ]] || fail "rerunning the migration does not create a user plugin link"
pass "migration can be rerun without a user plugin link"

run_migration "$ROOT"
[[ ! -e $plugin && ! -L $plugin ]] || fail "dev migration does not create a user plugin link"
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "dev migration uses the same install, scan and placement"
pass "dev checkout uses the same migration without a user plugin link"

if env TEST_PUT_RESULT=unknown HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/output" 2>&1; then
  fail "an unknown widget must leave the migration pending"
fi
pass "an unknown widget leaves the migration pending"

: >"$CALL_LOG"
if ! env SHELL_ABSENT=1 OMARCHY_SHELL_ABSENT_ATTEMPTS=1 HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" >"$test_dir/output" 2>&1; then
  fail "an absent shell must not fail the migration" "$(cat "$test_dir/output")"
fi
grep -q "omacom.elsewhen was not put on the bar" "$test_dir/output" || fail "an absent shell is reported" "$(cat "$test_dir/output")"
[[ ! -e $plugin && ! -L $plugin ]] || fail "an absent shell does not create a user plugin link"
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "the rescan is best-effort and the put is still asked" "$(cat "$CALL_LOG")"
pass "an absent shell keeps the existing bar helper behavior without a user plugin link"

# The first version of this migration ran as 1789581661.sh; that marker must
# not stop this one from running there.
state="$test_dir/state"
mkdir -p "$state"
touch "$state/1789581661.sh"
OMARCHY_MIGRATION_STATE="$state" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-migrate" --pending >"$test_dir/pending" || true
grep -qx "$(basename "$migration")" "$test_dir/pending" || fail "the old marker must not satisfy the renamed migration" "$(cat "$test_dir/pending")"
pass "a machine that applied the migration under its old name runs it again"
