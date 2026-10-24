#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-update-available" <<'SH'
#!/bin/bash

printf 'available\n' >>"$CALLS"
SH

cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALLS"
SH

chmod +x "$stub_bin/omarchy-update-available" "$stub_bin/omarchy-shell"

# An older omarchy-update, already parsed when the upgrade replaced it, still
# calls this once the packages are in.
PATH="$stub_bin:$PATH" CALLS="$calls" "$ROOT/bin/omarchy-update-status"
[[ $(<"$calls") == "shell -q omarchy.system-update clear" ]] ||
  fail "update status clears the shell indicator without rechecking" "$(<"$calls")"
pass "update status clears the shell indicator without rechecking"
