#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791897817.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

config="$test_dir/.config/herdr/config.toml"
mkdir -p "${config%/*}" "$test_dir/bin"

# Reloading herdr would reach the developer's own server.
printf '#!/bin/bash\necho restart >>"$TEST_LOG"\n' >"$test_dir/bin/omarchy-restart-herdr"
chmod +x "$test_dir/bin/omarchy-restart-herdr"

run_migration() {
  : >"$test_dir/log"
  HOME="$test_dir" PATH="$test_dir/bin:$PATH" TEST_LOG="$test_dir/log" bash -euo pipefail "${1:-$migration}" >/dev/null
}

# The config as the glassy tab bar change shipped it, with a black surface_dim.
cp "$ROOT/config/herdr/config.toml" "$test_dir/shipped.toml"
sed 's/^panel_bg = "reset"$/&\nsurface_dim = "black"/' "$test_dir/shipped.toml" >"$test_dir/black.toml"
cp "$test_dir/black.toml" "$config"

run_migration
! grep -q '^surface_dim' "$config" && grep -qx 'panel_bg = "reset"' "$config" ||
  fail "the shipped black surface_dim is removed" "$(cat "$config")"
grep -qx restart "$test_dir/log" || fail "herdr reloads after the change"
run_migration
[[ ! -s $test_dir/log ]] || fail "a second run changes nothing"
pass "the shipped black surface_dim is removed, once"

# A config still on the black tab bar goes through both migrations in order.
sed '/^# The tab bar sits/,/^panel_bg = "reset"$/c\# The active tab is drawn as panel_bg text on an accent background\npanel_bg = "black"' "$test_dir/shipped.toml" >"$config"
run_migration "$ROOT/migrations/1791722809.sh"
run_migration
grep -qx 'panel_bg = "reset"' "$config" && ! grep -q '^surface_dim' "$config" ||
  fail "a black tab bar ends see-through with gray dividers" "$(cat "$config")"
pass "a black tab bar ends see-through with gray dividers"

# A surface_dim of the user's own is kept, black or not.
for own in 'surface_dim = "white"' '  surface_dim = "black"'; do
  sed "s/^panel_bg = \"reset\"$/&\n$own/" "$test_dir/shipped.toml" >"$config"
  cp "$config" "$test_dir/custom.toml"
  run_migration
  cmp -s "$config" "$test_dir/custom.toml" || fail "a surface_dim of the user's own is kept: $own" "$(cat "$config")"
done
pass "a surface_dim of the user's own is kept"

# A config a dotfile manager links in is left for it to manage.
mkdir -p "$test_dir/dotfiles"
cp "$test_dir/black.toml" "$test_dir/dotfiles/config.toml"
rm "$config"
ln -s "$test_dir/dotfiles/config.toml" "$config"
run_migration
[[ -L $config ]] && cmp -s "$test_dir/dotfiles/config.toml" "$test_dir/black.toml" ||
  fail "a linked herdr config is left linked and unchanged"
pass "a linked herdr config is left alone"
