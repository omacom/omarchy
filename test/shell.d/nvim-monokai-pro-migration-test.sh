#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

plugins="$test_dir/.config/nvim/lua/plugins"
themes="$plugins/all-themes.lua"

run_migration() {
  HOME="$test_dir" bash -euo pipefail "$ROOT/migrations/1791793806.sh" >/dev/null 2>&1
}

write_themes() {
  rm -rf "$test_dir/.config" "$test_dir/dotfiles"
  mkdir -p "$plugins"
  printf '{\n\t"%s",\n\tlazy = true,\n},\n-- mine\n' "$1" >"$themes"
}

write_themes gthelding/monokai-pro.nvim
run_migration
run_migration
[[ $(<"$themes") == $'{\n\t"loctvl842/monokai-pro.nvim",\n\tlazy = true,\n},\n-- mine' ]] ||
  fail "the dead fork is replaced and the rest of the file kept"
pass "the dead fork is replaced and the rest of the file kept"

write_themes someone/monokai-pro.nvim
run_migration
grep -q '"someone/monokai-pro.nvim"' "$themes" || fail "a spec the user pointed elsewhere is kept"
pass "a spec the user pointed elsewhere is kept"

write_themes gthelding/monokai-pro.nvim
mkdir -p "$test_dir/dotfiles"
mv "$plugins" "$test_dir/dotfiles/plugins"
ln -s "$test_dir/dotfiles/plugins" "$plugins"
run_migration
grep -q '"gthelding/monokai-pro.nvim"' "$test_dir/dotfiles/plugins/all-themes.lua" && [[ -L $plugins ]] ||
  fail "a config a dotfile manager links in is left alone"
pass "a config a dotfile manager links in is left alone"

write_themes gthelding/monokai-pro.nvim
mkdir -p "$test_dir/dotfiles"
mv "$themes" "$test_dir/dotfiles/all-themes.lua"
ln -s "$test_dir/dotfiles/all-themes.lua" "$themes"
run_migration
grep -q '"gthelding/monokai-pro.nvim"' "$test_dir/dotfiles/all-themes.lua" && [[ -L $themes ]] ||
  fail "a theme file a dotfile manager links in is left alone"
pass "a theme file a dotfile manager links in is left alone"

write_themes gthelding/monokai-pro.nvim
chmod a-r "$themes"
if run_migration; then
  chmod u+r "$themes"
  fail "a file that cannot be read leaves the migration pending"
fi
chmod u+r "$themes"
pass "a file that cannot be read leaves the migration pending"

rm -rf "$test_dir/.config" "$test_dir/dotfiles"
run_migration
[[ ! -e $test_dir/.config ]] || fail "a missing Neovim config is not created"
pass "a missing Neovim config is not created"
