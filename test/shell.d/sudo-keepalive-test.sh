#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Cancelling sudo's password prompt makes `sudo -v` exit 1 rather than die of the signal.
printf '#!/bin/bash\nif [[ $1 == "-v" ]]; then exit "$TEST_SUDO_STATUS"; fi\n' >"$test_tmp/sudo"
chmod +x "$test_tmp/sudo"

source_keepalive() {
  TEST_SUDO_STATUS=$1 PATH="$test_tmp:$ROOT/bin:$PATH" bash -c 'source omarchy-sudo-keepalive; echo continued' >"$test_tmp/out" 2>&1
}

if source_keepalive 1 || [[ -s $test_tmp/out ]]; then
  fail "a cancelled sudo prompt stops the script that sourced the keepalive"
fi
pass "a cancelled sudo prompt stops the script that sourced the keepalive"

source_keepalive 0 && [[ $(<"$test_tmp/out") == "continued" ]] || fail "an authorized sudo lets the script go on"
pass "an authorized sudo lets the script go on"
