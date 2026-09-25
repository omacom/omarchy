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
[[ $2 != "rescanPlugins" ]] || exit "${SCAN_STATUS:-0}"
printf '%s\n' "${TEST_PUT_RESULT:-ok}"
SH
cat >"$test_dir/bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
echo 'migration must leave the restart to omarchy update' >&2
exit 1
SH
chmod +x "$test_dir/bin/"*

plugin="$test_dir/home/.config/omarchy/plugins/omacom.elsewhen"
run_migration() {
  : >"$CALL_LOG"
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1789581661.sh" >"$test_dir/output" 2>&1
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

expected=$'package elsewhen\nshell rescanPlugins\nshell putBarWidget omacom.elsewhen {"before":"omarchy.clock"}'
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "install, scan and placement run in order" "$(cat "$CALL_LOG")"
pass "real bar helper enables and places before the clock without restarting during reload"

run_migration
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "migration can be rerun"
[[ ! -e $plugin && ! -L $plugin ]] || fail "rerunning the migration does not create a user plugin link"
pass "migration can be rerun without a user plugin link"

mkdir -p "$plugin"
printf 'local work\n' >"$plugin/notes"
run_migration
[[ ! -L $plugin && $(cat "$plugin/notes") == "local work" ]] || fail "existing checkout is preserved"
pass "existing checkout and local files are preserved"

rm "$plugin/notes"
rmdir "$plugin"
ln -s "$test_dir/custom-plugin" "$plugin"
run_migration
[[ $(readlink "$plugin") == "$test_dir/custom-plugin" ]] || fail "existing symlink is preserved"
pass "existing symlink is preserved, including a missing target"

for failure in 'SCAN_STATUS=1' 'TEST_PUT_RESULT=unknown'; do
  if env "$failure" HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1789581661.sh" >"$test_dir/output" 2>&1; then
    fail "$failure must leave the migration pending"
  fi
  pass "$failure leaves the migration pending"
done
