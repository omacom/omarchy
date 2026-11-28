#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1789244033.sh"
src="$ROOT/default/nautilus-python/extensions/swipe_navigation.py"
[[ -f $src ]] || fail "swipe_navigation.py is shipped in default nautilus-python extensions"
[[ -f $migration ]] || fail "migration for swipe_navigation.py exists"
pass "extension and migration files exist"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
mkdir -p "$home"

HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null

dst="$home/.local/share/nautilus-python/extensions/swipe_navigation.py"
[[ -f $dst ]] || fail "migration copies swipe_navigation.py into the user extensions dir"
cmp -s "$src" "$dst" || fail "copied extension matches the shipped file"
pass "migration installs the Nautilus swipe extension"

HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null ||
  fail "migration is idempotent"
pass "migration is idempotent"
