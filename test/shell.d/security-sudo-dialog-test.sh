#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-sudo-dialog-auth"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# PAM execs the helper directly, so -p in the shebang keeps BASH_ENV and
# exported functions out; an ordinary Bash launch (which ran BASH_ENV already)
# with a decoy -p argument must still be refused.
if /usr/bin/bash "$helper" -p >/dev/null 2>"$test_tmp/error"; then
  fail "omarchy-sudo-dialog-auth refuses an ordinary Bash launch"
fi
grep -Fq "Refusing an unsafe Bash startup" "$test_tmp/error" || fail "omarchy-sudo-dialog-auth explains the refusal" "$(cat "$test_tmp/error")"
pass "omarchy-sudo-dialog-auth refuses an ordinary Bash launch with a decoy -p"
