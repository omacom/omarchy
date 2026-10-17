#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'add:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
[[ $* != "bitwarden-cli" || $OMARCHY_TEST_CLI_FAILS != "true" ]]
SH

cat >"$mock_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
true
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
[[ -n $OMARCHY_TEST_NODEJS ]] && echo "$OMARCHY_TEST_NODEJS"
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

run_installer() {
  : >"$test_tmp/log"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$test_tmp/log" OMARCHY_TEST_CLI_FAILS="$1" OMARCHY_TEST_NODEJS="$2" \
    bash "$ROOT/bin/omarchy-install-service-bitwarden" >"$test_tmp/out" 2>&1 || return 1

  # The launch is backgrounded, so give it a moment to land in the log.
  for _ in {1..50}; do
    grep -q '^launch:' "$test_tmp/log" && return 0
    sleep 0.02
  done
  return 1
}

run_installer true nodejs || fail "Bitwarden installer survives a CLI install failure" "$(cat "$test_tmp/out")"
grep -Fxq 'add:bitwarden' "$test_tmp/log" && grep -Fxq 'launch:uwsm-app -- gtk-launch bitwarden' "$test_tmp/log" ||
  fail "Bitwarden installer installs and launches the desktop app when the CLI fails" "$(cat "$test_tmp/log")"
pass "Bitwarden installer installs and launches the desktop app when the CLI fails"
grep -q 'conflicts with the installed nodejs' "$test_tmp/out" ||
  fail "Bitwarden installer explains the conflict when nodejs is installed" "$(cat "$test_tmp/out")"
pass "Bitwarden installer explains the conflict when nodejs is installed"

run_installer true nodejs-lts-jod || fail "Bitwarden installer survives a CLI failure beside an LTS Node" "$(cat "$test_tmp/out")"
grep -q 'could not be installed' "$test_tmp/out" && ! grep -q 'conflicts with' "$test_tmp/out" ||
  fail "Bitwarden installer blames Node only when nodejs itself is installed" "$(cat "$test_tmp/out")"
pass "Bitwarden installer blames Node only when nodejs itself is installed"

run_installer false "" || fail "Bitwarden installer succeeds without a conflict" "$(cat "$test_tmp/out")"
grep -Fxq 'add:bitwarden-cli' "$test_tmp/log" && ! grep -q 'could not be installed' "$test_tmp/out" ||
  fail "Bitwarden installer installs the CLI when nothing conflicts" "$(cat "$test_tmp/out")"
pass "Bitwarden installer installs the CLI when nothing conflicts"
