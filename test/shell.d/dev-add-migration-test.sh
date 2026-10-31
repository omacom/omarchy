#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

now=$(date +%s)
output=$(OMARCHY_PATH="$test_tmp" "$ROOT/bin/omarchy-dev-add-migration" --no-edit)

[[ -f $output ]] || fail "dev add migration creates file"
migration_name=$(basename "$output")
migration_id="${migration_name%.sh}"

(( migration_id >= now && migration_id <= now + 5 )) || fail "dev add migration uses current timestamp instead of git commit time"
pass "dev add migration stamps current timestamp"

mode=$(stat -c '%a' "$output" 2>/dev/null || stat -f '%Lp' "$output" 2>/dev/null)
[[ $mode == "644" ]] || fail "migration permissions are 0644"
pass "migration permissions are 0644"
