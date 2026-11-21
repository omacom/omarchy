#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

themes="$test_dir/.config/nvim/lua/plugins/all-themes.lua"

run_migration() {
  HOME="$test_dir" bash -euo pipefail "$ROOT/migrations/1791786178.sh" >/dev/null 2>&1
}

write_themes() {
  rm -rf "$test_dir/.config" "$test_dir/dotfiles"
  mkdir -p "$(dirname "$themes")"
  printf 'return {\n\t{\n\t\t"%s",\n\t\tlazy = true,\n\t},\n}\n' "$1" >"$themes"
}

write_themes gthelding/monokai-pro.nvim
run_migration
run_migration
grep -q '"loctvl842/monokai-pro.nvim"' "$themes" && ! grep -q gthelding "$themes" ||
  fail "a shipped spec naming the deleted fork names the maintained repository"
pass "a shipped spec naming the deleted fork names the maintained repository"

write_themes someone/monokai-pro.nvim
run_migration
grep -q '"someone/monokai-pro.nvim"' "$themes" || fail "a spec the user pointed elsewhere is kept"
pass "a spec the user pointed elsewhere is kept"

write_themes gthelding/monokai-pro-nvim
run_migration
grep -q '"gthelding/monokai-pro-nvim"' "$themes" || fail "only the exact shipped spec is rewritten"
pass "only the exact shipped spec is rewritten"

write_themes gthelding/monokai-pro.nvim
chmod a-r "$themes"
if run_migration; then
  chmod u+r "$themes"
  fail "a file that cannot be read leaves the migration pending"
fi
chmod u+r "$themes"
pass "a file that cannot be read leaves the migration pending"

write_themes gthelding/monokai-pro.nvim
mkdir -p "$test_dir/dotfiles"
mv "$themes" "$test_dir/dotfiles/all-themes.lua"
ln -s "$test_dir/dotfiles/all-themes.lua" "$themes"
run_migration
[[ -L $themes ]] && grep -q gthelding "$test_dir/dotfiles/all-themes.lua" ||
  fail "a config a dotfile manager links in is left alone"
pass "a config a dotfile manager links in is left alone"

rm -rf "$test_dir/.config"
run_migration
[[ ! -e $test_dir/.config ]] || fail "a missing Neovim config is not created"
pass "a missing Neovim config is not created"
