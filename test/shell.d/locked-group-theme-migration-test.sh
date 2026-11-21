#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1787545025.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home/.local/state/omarchy/current"
export CALL_LOG="$test_dir/calls"

cat >"$test_dir/bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
echo refresh >>"$CALL_LOG"
SH
chmod +x "$test_dir/bin/omarchy-theme-refresh"

run() {
  : >"$CALL_LOG"
  env HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration" >"$test_dir/output" 2>&1
}

theme_name_path="$test_dir/home/.local/state/omarchy/current/theme.name"

run || fail "no current theme finishes the migration" "$(cat "$test_dir/output")"
pass "no current theme finishes the migration"

echo "nord" >"$theme_name_path"
run || fail "a stock theme refreshes cleanly" "$(cat "$test_dir/output")"
[[ $(cat "$CALL_LOG") == "refresh" ]] || fail "a stock theme is refreshed"
pass "the current stock theme is refreshed"

mkdir -p "$test_dir/home/.config/omarchy/themes/mine"
echo "mine" >"$theme_name_path"
run || fail "a user theme refreshes cleanly" "$(cat "$test_dir/output")"
[[ $(cat "$CALL_LOG") == "refresh" ]] || fail "a user theme is refreshed"
pass "the current user theme is refreshed"

echo "removed" >"$theme_name_path"
run || fail "a removed current theme must not hold later migrations" "$(cat "$test_dir/output")"
[[ ! -s $CALL_LOG ]] || fail "a removed current theme is not refreshed"
pass "a removed current theme leaves the migration queue moving"
