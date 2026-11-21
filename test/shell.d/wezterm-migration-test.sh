#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
mock_bin="$test_dir/bin"
mkdir -p "$test_home/.config/wezterm" "$mock_bin"

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ${WEZTERM_TEST_MISSING:-false} == "true" ]]
SH
chmod +x "$mock_bin/"*

run_migration() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1791536351.sh" >/dev/null
}

printf 'custom settings\n' >"$test_home/.config/wezterm/extra.lua"
run_migration
cmp -s "$ROOT/config/wezterm/wezterm.lua" "$test_home/.config/wezterm/wezterm.lua" ||
  fail "migration supplies the missing config in an existing directory"
[[ $(<"$test_home/.config/wezterm/extra.lua") == "custom settings" ]] ||
  fail "migration preserves other WezTerm files"
cmp -s "$ROOT/applications/org.wezfurlong.wezterm.desktop" \
  "$test_home/.local/share/applications/org.wezfurlong.wezterm.desktop" ||
  fail "migration supplies the command-capable desktop entry"
pass "migration repairs an existing WezTerm directory without replacing other files"

printf 'custom config\n' >"$test_home/.config/wezterm/wezterm.lua"
printf 'custom desktop entry\n' >"$test_home/.local/share/applications/org.wezfurlong.wezterm.desktop"
run_migration
run_migration
[[ $(<"$test_home/.config/wezterm/wezterm.lua") == "custom config" ]] ||
  fail "migration preserves existing WezTerm settings on reruns"
[[ $(<"$test_home/.local/share/applications/org.wezfurlong.wezterm.desktop") == "custom desktop entry" ]] ||
  fail "migration preserves an existing desktop entry"
pass "migration is idempotent and preserves user settings"

rm -rf "$test_home/.config/wezterm"
WEZTERM_TEST_MISSING=true run_migration
[[ ! -e $test_home/.config/wezterm ]] || fail "migration leaves uninstalled WezTerm alone"
run_migration
cmp -s "$ROOT/config/wezterm/wezterm.lua" "$test_home/.config/wezterm/wezterm.lua" ||
  fail "migration creates an absent WezTerm directory"
pass "migration only seeds settings for installed WezTerm"
