#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

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

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf 'installer:%s\n' "$1" >"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch-log"
PATH="$mock_bin:$PATH" OMARCHY_TEST_1PASSWORD=1 OMARCHY_TEST_BITWARDEN=1 OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-password-manager"
grep -Fxq '1password' "$launch_log" ||
  fail "password manager dispatcher prefers 1Password when both are installed"
pass "password manager dispatcher prefers 1Password when both are installed"

PATH="$mock_bin:$PATH" OMARCHY_TEST_1PASSWORD=0 OMARCHY_TEST_BITWARDEN=1 OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-password-manager"
grep -Fxq 'bitwarden' "$launch_log" ||
  fail "password manager dispatcher launches Bitwarden when only it is installed"
pass "password manager dispatcher launches Bitwarden when only it is installed"

PATH="$mock_bin:$PATH" OMARCHY_TEST_1PASSWORD=0 OMARCHY_TEST_BITWARDEN=0 OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-password-manager"
grep -Fxq 'installer:omarchy-install-service-1password' "$launch_log" ||
  fail "password manager dispatcher starts the 1Password installer when no manager is installed"
pass "password manager dispatcher starts the 1Password installer when no manager is installed"

grep -Fq '{ omarchy = "password-manager" }' "$ROOT/default/hypr/bindings/applications.lua" ||
  fail "Passwords keybinding uses the password manager dispatcher"
pass "Passwords keybinding uses the password manager dispatcher"
