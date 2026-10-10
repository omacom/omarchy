#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
set -euo pipefail

case "${1:-}" in
  1password)
    [[ ${OMARCHY_TEST_1PASSWORD:-0} == "1" ]]
    ;;
  bitwarden-desktop)
    [[ ${OMARCHY_TEST_BITWARDEN:-0} == "1" ]]
    ;;
  *)
    command -v "${1:-}" >/dev/null 2>&1
    ;;
esac
SH

cat >"$mock_bin/omarchy-launch-1password" <<'SH'
#!/bin/bash
printf '1password\n' >"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/omarchy-launch-bitwarden" <<'SH'
#!/bin/bash
printf 'bitwarden\n' >"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

default_file="$test_home/.config/omarchy/defaults/password-manager"
launch_log="$test_tmp/launch-log"

dispatch() {
  env -u OMARCHY_TEST_1PASSWORD -u OMARCHY_TEST_BITWARDEN \
    HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" "$@" \
    OMARCHY_TEST_LOG="$launch_log" \
    bash "$ROOT/bin/omarchy-launch-password-manager"
}

# With nothing chosen the dispatcher follows the hotkey's long-standing order.
dispatch OMARCHY_TEST_1PASSWORD=1 OMARCHY_TEST_BITWARDEN=1
grep -Fxq '1password' "$launch_log" ||
  fail "password manager dispatcher prefers 1Password when both are installed and nothing is chosen"
pass "password manager dispatcher prefers 1Password when both are installed and nothing is chosen"

dispatch OMARCHY_TEST_BITWARDEN=1
grep -Fxq 'bitwarden' "$launch_log" ||
  fail "password manager dispatcher launches Bitwarden when only it is installed"
pass "password manager dispatcher launches Bitwarden when only it is installed"

# Nothing installed means 1Password, whose launcher starts its own installer.
dispatch
grep -Fxq '1password' "$launch_log" ||
  fail "password manager dispatcher falls back to 1Password when no manager is installed"
pass "password manager dispatcher falls back to 1Password when no manager is installed"

# A default chosen under Setup > Defaults > Password Manager wins over
# detection, even when that manager is not the one that is installed.
mkdir -p "$(dirname "$default_file")"
printf 'bitwarden\n' >"$default_file"
dispatch OMARCHY_TEST_1PASSWORD=1 OMARCHY_TEST_BITWARDEN=1
grep -Fxq 'bitwarden' "$launch_log" ||
  fail "password manager dispatcher honors a chosen default over detection"
pass "password manager dispatcher honors a chosen default over detection"

printf '1password\n' >"$default_file"
dispatch OMARCHY_TEST_BITWARDEN=1
grep -Fxq '1password' "$launch_log" ||
  fail "password manager dispatcher stays with a chosen default that is not installed"
pass "password manager dispatcher stays with a chosen default that is not installed"

grep -Fq '{ omarchy = "password-manager" }' "$ROOT/default/hypr/bindings/applications.lua" ||
  fail "Passwords keybinding uses the password manager dispatcher"
pass "Passwords keybinding uses the password manager dispatcher"
