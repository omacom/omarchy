#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A grep that always matches stands in for readable DMI files, which an empty
# pattern matches, so the test does not depend on the host exposing any.
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/grep"
chmod +x "$mock_bin/grep"

# A missing pattern used to make the greps match every readable DMI file,
# turning a forgotten argument into a hardware "yes" for any caller.
if PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hw-match" 2>/dev/null; then
  fail "hw-match refuses a missing pattern"
fi
pass "hw-match refuses a missing pattern"

if PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hw-match" "" 2>/dev/null; then
  fail "hw-match refuses an empty pattern"
fi
pass "hw-match refuses an empty pattern"

# The error should say what was missing.
usage=$("$ROOT/bin/omarchy-hw-match" 2>&1 >/dev/null || true)
[[ $usage == *"Usage: omarchy-hw-match <pattern>"* ]] ||
  fail "hw-match usage names the missing pattern" "actual: $usage"
pass "hw-match usage names the missing pattern"
