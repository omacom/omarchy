#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791722809.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

config="$test_dir/.config/herdr/config.toml"
mkdir -p "${config%/*}" "$test_dir/bin"

# Reloading herdr would reach the developer's own server.
printf '#!/bin/bash\necho restart >>"$TEST_LOG"\n' >"$test_dir/bin/omarchy-restart-herdr"
chmod +x "$test_dir/bin/omarchy-restart-herdr"

run_migration() {
  : >"$test_dir/log"
  HOME="$test_dir" PATH="$test_dir/bin:$PATH" TEST_LOG="$test_dir/log" bash -euo pipefail "$migration" >/dev/null
}

cp "$ROOT/config/herdr/config.toml" "$test_dir/shipped.toml"
sed -i '/^# The tab bar sits/,/^surface_dim = "black"$/c\# The active tab is drawn as panel_bg text on an accent background\npanel_bg = "black"' "$test_dir/shipped.toml"
cp "$test_dir/shipped.toml" "$config"

run_migration
grep -qx 'panel_bg = "reset"' "$config" && (( $(grep -c '^surface_dim' "$config") == 1 )) ||
  fail "the shipped black tab bar takes the terminal background" "$(cat "$config")"
grep -qx restart "$test_dir/log" || fail "herdr reloads after the change"
run_migration
[[ ! -s $test_dir/log ]] || fail "a second run changes nothing"
pass "the shipped black tab bar takes the terminal background, once"

# A surface_dim of the user's own, indented or not, is kept as the only one.
{ cat "$test_dir/shipped.toml"; printf '  surface_dim = "white"\n'; } >"$config"
cp "$config" "$test_dir/custom.toml"
run_migration
cmp -s "$config" "$test_dir/custom.toml" || fail "an indented surface_dim of the user's own is kept, with no second one"
pass "a surface_dim of the user's own is kept, with no second one"

# A config a dotfile manager links in is left for it to manage.
mkdir -p "$test_dir/dotfiles"
cp "$test_dir/shipped.toml" "$test_dir/dotfiles/config.toml"
rm "$config"
ln -s "$test_dir/dotfiles/config.toml" "$config"
run_migration
[[ -L $config ]] && cmp -s "$test_dir/dotfiles/config.toml" "$test_dir/shipped.toml" ||
  fail "a linked herdr config is left linked and unchanged"
pass "a linked herdr config is left alone"
