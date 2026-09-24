#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The migration hands the mise-era stub to the installer's --migrate, which is
# exercised in hermes-cli-test.sh; here the installer is a logger, so this
# stays about what the migration files do and never reaches a live Hermes.

migration="$ROOT/migrations/1790012162.sh"
superseded="$ROOT/migrations/1787760281.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
exit "${OMARCHY_TEST_INSTALLER_STATUS:-0}"
SH
chmod +x "$mock_bin"/*

run_migration() {
  : >"$test_tmp/calls"
  OMARCHY_TEST_CALLS="$test_tmp/calls" \
    HOME="$test_tmp/home" \
    PATH="$mock_bin:$PATH" \
    bash -euo pipefail "$1" >/dev/null 2>&1
}

for file in "$migration" "$superseded"; do
  [[ $(stat -c %a "$file") == "644" ]] || fail "migration is a plain 0644 file" "$file"
  ! grep -q '^#!' "$file" || fail "migration has no shebang" "$file"
done
pass "the Hermes migrations are plain sourced scripts"

run_migration "$migration" || fail "the migration succeeds"
[[ $(cat "$test_tmp/calls") == "--migrate" ]] || fail "the migration hands the stub to the installer's --migrate"
pass "the migration retires the mise Hermes through the installer"

# A replacement that could not finish is a migration that has not finished.
OMARCHY_TEST_INSTALLER_STATUS=1 run_migration "$migration" && fail "an installer failure leaves the migration pending"
pass "the migration stays pending when the installer fails"

# The wrapper migration this one supersedes must not write the stub back for a
# late updater, who runs both in order.
run_migration "$superseded" || fail "the superseded wrapper migration succeeds"
[[ ! -s $test_tmp/calls ]] || fail "the superseded wrapper migration no longer installs anything"
pass "the superseded wrapper migration does nothing"
