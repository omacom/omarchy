#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1788843383.sh"
[[ -f $migration ]] || fail "the clipboard history mode migration exists at $migration"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

run_migration() {
  HOME="$test_dir/home" XDG_STATE_HOME="$test_dir/state" bash -euo pipefail "$migration" >/dev/null
}

run_migration
pass "clipboard mode migration no-ops when history is absent"

mkdir -p "$test_dir/state/omarchy/clipboard-images"
printf '[]\n' >"$test_dir/state/omarchy/clipboard-history.json"
chmod 644 "$test_dir/state/omarchy/clipboard-history.json"
chmod 755 "$test_dir/state/omarchy/clipboard-images"

run_migration
[[ $(stat -c '%a' "$test_dir/state/omarchy/clipboard-history.json") == 600 ]] ||
  fail "clipboard mode migration sets history JSON 0600"
pass "clipboard mode migration sets history JSON 0600"
[[ $(stat -c '%a' "$test_dir/state/omarchy/clipboard-images") == 700 ]] ||
  fail "clipboard mode migration sets images directory 0700"
pass "clipboard mode migration sets images directory 0700"

run_migration
[[ $(stat -c '%a' "$test_dir/state/omarchy/clipboard-history.json") == 600 ]] ||
  fail "clipboard mode migration is idempotent"
pass "clipboard mode migration is idempotent"
