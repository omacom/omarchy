#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
sed "s#/tmp/omarchy-update\.log#$test_tmp/update.log#" "$ROOT/bin/omarchy-update-analyze-logs" >"$test_tmp/bin/omarchy-update-analyze-logs"
grep -q "$test_tmp/update.log" "$test_tmp/bin/omarchy-update-analyze-logs" || fail "the analyzer reads the test's log"
printf '#!/bin/bash\nexit 1\n' >"$test_tmp/bin/omarchy-hw-aarch64-apple"
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"

build="(4/9) Updating linux initcpios..."
built="==> Initcpio image generation successful"
broken="==> ERROR: module not found"

warns() { # start byte, then log lines
  local start=$1
  shift
  printf '%s\n' "$@" >"$test_tmp/update.log"
  [[ $(omarchy-update-analyze-logs "$start") == *"Initramfs generation may have failed"* ]]
}

warns 0 "nothing to rebuild" && fail "a log without an initramfs build warns"
warns 0 "$build" "$built" && fail "a successful build warns"
warns 0 "$build" "$broken" || fail "a failed build does not warn"
pass "an initramfs build is judged by its outcome"

warns "" "$build" "$built" "$build" "$broken" && fail "without a start, a success anywhere in the log no longer passes"
warns 999999 "$build" "$broken" || fail "an offset past the end of a replaced log hides its failure"
warns "a[0]" "$build" "$broken" || fail "an offset that is not a number is not read as the start"
pass "without a usable start the whole log is read, as before"

# A channel switch logs its own transactions ahead of the update's.
switch=$(printf '%s\n' "$build" "$built" | wc -c)
warns "$switch" "$build" "$built" "$build" "$broken" || fail "the switch's success hides the update's failed build"
warns "$switch" "$build" "$broken" "$build" "$built" && fail "the switch's failure is blamed on the update"
pass "only the update's own output is read"
