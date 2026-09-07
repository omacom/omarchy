#!/bin/bash

set -euo pipefail

# The migration hands an existing Hermes Desktop install the Omarchy skin. It
# is exercised here with the package probe and the skin hook stubbed, so a
# migration that reached a Hermes Omarchy did not install, or that marked a
# failed hand-over done, shows up in what it ran.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788619462.sh"
[[ -f $migration ]] || fail "Hermes skin migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH

cat >"$mock_bin/omarchy-theme-set-hermes" <<'SH'
#!/bin/bash
echo "omarchy-theme-set-hermes $*" >>"$OMARCHY_TEST_CALLS"
[[ ${OMARCHY_TEST_HOOK_FAILS:-0} == 0 ]]
SH

chmod +x "$mock_bin"/*

run_migration() {
  : >"$calls"
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-1}" \
    OMARCHY_TEST_HOOK_FAILS="${OMARCHY_TEST_HOOK_FAILS:-0}" \
    OMARCHY_TEST_CALLS="$calls" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_tmp/home" \
    OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

OMARCHY_TEST_DESKTOP_INSTALLED=0 run_migration || fail "migration exits clean without Hermes Desktop"
[[ ! -s $calls ]] || fail "a machine without Hermes Desktop is left alone" "$(cat "$calls")"
pass "migration only applies where Omarchy installed Hermes Desktop"

run_migration || fail "migration exits clean with Hermes Desktop installed"
[[ $(cat "$calls") == "omarchy-theme-set-hermes --activate" ]] ||
  fail "the skin is rendered, published and activated through the hook's deliberate form" "$(cat "$calls")"
pass "migration hands the skin over through the hook"

if OMARCHY_TEST_HOOK_FAILS=1 run_migration; then
  fail "a hand-over that failed on Omarchy's side stays pending"
fi
pass "migration stays pending when the hand-over fails"
