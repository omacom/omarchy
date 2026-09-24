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

mkdir -p "$test_dir/packaged/shell/plugins/omacom.elsewhen"
migration="$ROOT/migrations/1790042972.sh"
sed "s|/usr/share/omarchy|$test_dir/packaged|g" "$migration" >"$test_dir/migration.sh"

plugin="$test_dir/home/.config/omarchy/plugins/omacom.elsewhen"
run_migration() {
  : >"$CALL_LOG"
  HOME="$test_dir/home" OMARCHY_PATH="${1:-$test_dir/packaged}" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$test_dir/migration.sh" >"$test_dir/output" 2>&1
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
[[ $(readlink "$plugin") == "$test_dir/packaged/shell/plugins/omacom.elsewhen" ]] || fail "dev checkout links the packaged plugin"
pass "dev checkout discovers Elsewhen through a user plugin link"
run_migration "$ROOT"
[[ $(readlink "$plugin") == "$test_dir/packaged/shell/plugins/omacom.elsewhen" ]] || fail "dev link survives a rerun"
pass "dev link is idempotent"
rm "$plugin"

mkdir -p "$plugin"
printf 'local work\n' >"$plugin/notes"
run_migration "$ROOT"
[[ ! -L $plugin && $(cat "$plugin/notes") == "local work" ]] || fail "existing checkout is preserved"
pass "existing checkout and local files are preserved"

rm "$plugin/notes"
rmdir "$plugin"
ln -s "$test_dir/custom-plugin" "$plugin"
run_migration "$ROOT"
[[ $(readlink "$plugin") == "$test_dir/custom-plugin" ]] || fail "existing symlink is preserved"
pass "existing symlink is preserved, including a missing target"

# An earlier revision, and a symlink once shipped under config/, pointed every
# install at the package's old path.
for tree in "$ROOT" "$test_dir/packaged"; do
  ln -sfn "$test_dir/packaged/plugins/omacom.elsewhen" "$plugin"
  run_migration "$tree"
  [[ $(readlink "$plugin") == "$test_dir/packaged/shell/plugins/omacom.elsewhen" ]] ||
    fail "a stranded link to the package's old path is re-pointed (OMARCHY_PATH=$tree)" "$(readlink "$plugin")"
done
pass "a stranded link to the package's old path is re-pointed on every install"
rm "$plugin"

if env TEST_PUT_RESULT=unknown HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$test_dir/migration.sh" >"$test_dir/output" 2>&1; then
  fail "an unknown widget must leave the migration pending"
fi
pass "an unknown widget leaves the migration pending"

# An update with no shell to ask, from a TTY or with the shell down, still
# finishes: the package and link land, the placement is skipped, and the update
# restarts the shell afterwards.
rm "$plugin"
: >"$CALL_LOG"
if ! env SHELL_ABSENT=1 OMARCHY_SHELL_ABSENT_ATTEMPTS=1 HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$test_dir/migration.sh" >"$test_dir/output" 2>&1; then
  fail "an absent shell must not fail the migration" "$(cat "$test_dir/output")"
fi
grep -q "omacom.elsewhen was not put on the bar" "$test_dir/output" || fail "an absent shell is reported" "$(cat "$test_dir/output")"
[[ $(readlink "$plugin") == "$test_dir/packaged/shell/plugins/omacom.elsewhen" ]] || fail "the package and plugin link land without a shell"
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "the rescan is best-effort and the put is still asked" "$(cat "$CALL_LOG")"
pass "an absent shell leaves the update running with the package and link in place"

# The first run of this migration was under 1789581661.sh, before the re-point
# existed; that marker must not stop the renamed file from running there.
state="$test_dir/state"
mkdir -p "$state"
touch "$state/1789581661.sh"
OMARCHY_MIGRATION_STATE="$state" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-migrate" --pending >"$test_dir/pending" || true
grep -qx "$(basename "$migration")" "$test_dir/pending" || fail "the old marker must not satisfy the renamed migration" "$(cat "$test_dir/pending")"
pass "a machine that applied the migration under its old name runs it again"
