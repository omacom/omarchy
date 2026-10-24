#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

config="$test_dir/.config/nvim"
package="$test_dir/package"
transparency="plugin/after/transparency.lua"
lualine="lua/plugins/lualine-transparent.lua"

mock_bin="$test_dir/bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $OMARCHY_TEST_NVIM_INSTALLED == 1 ]]
SH
chmod +x "$mock_bin/omarchy-pkg-present"

mkdir -p "$package/plugin/after" "$package/lua/plugins"
printf -- '-- new transparency\n' >"$package/$transparency"
printf -- '-- lualine\n' >"$package/$lualine"
printf -- '-- shipped transparency\n' >"$test_dir/shipped.lua"

# The real package and shipped files live outside this repo, so the migration
# reads a stand-in package and knows the stand-in shipped file by its hash.
shipped_hash=$(sha256sum <"$test_dir/shipped.lua" | cut -c1-64)
sed -e "s@/usr/share/omarchy-nvim/config@$package@" \
  -e "s@6e31b917f13e16514ac94ff9270d47f24e76509a3e559ca85116a5aa2d61306a@$shipped_hash@" \
  "$ROOT/migrations/1791723398.sh" >"$test_dir/migration.sh"

run_migration() {
  HOME="$test_dir" PATH="$mock_bin:$PATH" OMARCHY_TEST_NVIM_INSTALLED="${1:-1}" \
    bash -euo pipefail "$test_dir/migration.sh" >/dev/null 2>&1
}

reset_config() {
  rm -rf "$config"
  mkdir -p "$config/plugin/after" "$config/lua/plugins"
  cp "$test_dir/shipped.lua" "$config/$transparency"
}

reset_config
run_migration
run_migration
cmp -s "$config/$transparency" "$package/$transparency" && cmp -s "$config/$lualine" "$package/$lualine" ||
  fail "a shipped config takes the package's transparency file and lualine spec"
[[ -z $(find "$config" -name '*.new.*') ]] || fail "no staged files are left behind"
pass "a shipped config takes the package's transparency file and lualine spec"

reset_config
printf -- '-- mine\n' >"$config/$transparency"
printf -- '-- my lualine\n' >"$config/$lualine"
run_migration
[[ $(<"$config/$transparency") == "-- mine" && $(<"$config/$lualine") == "-- my lualine" ]] ||
  fail "files the user changed or added are kept"
pass "files the user changed or added are kept"

reset_config
mkdir -p "$test_dir/dotfiles"
mv "$config/plugin" "$test_dir/dotfiles/plugin"
ln -s "$test_dir/dotfiles/plugin" "$config/plugin"
run_migration
cmp -s "$config/$transparency" "$test_dir/shipped.lua" && [[ ! -e $config/$lualine ]] ||
  fail "a config a dotfile manager links in is left alone"
pass "a config a dotfile manager links in is left alone"

# An older package leaves the migration pending to run again after the update.
reset_config
mv "$package/$lualine" "$test_dir/lualine.lua"
if run_migration; then
  fail "an older package leaves the migration pending"
fi
mv "$test_dir/lualine.lua" "$package/$lualine"
pass "an older package leaves the migration pending"

reset_config
chmod a-w "$config/plugin/after"
if run_migration; then
  chmod u+w "$config/plugin/after"
  fail "a write that fails leaves the migration pending"
fi
chmod u+w "$config/plugin/after"
cmp -s "$config/$transparency" "$test_dir/shipped.lua" || fail "a write that fails leaves the file as it was"
pass "a write that fails leaves the migration pending and the file as it was"

rm -rf "$config"
run_migration
[[ ! -e $config ]] || fail "a missing Neovim config is not created"
pass "a missing Neovim config is not created"

# A custom config without omarchy-nvim is the user's own, so the migration
# neither needs the package's files nor touches the config.
reset_config
printf -- '-- mine\n' >"$config/$transparency"
cp -a "$config" "$test_dir/custom-config"
rm -rf "$package"
run_migration 0 || fail "a config without omarchy-nvim does not block the migration"
diff -r "$test_dir/custom-config" "$config" >/dev/null || fail "a config without omarchy-nvim is left alone"
pass "a config without omarchy-nvim is left alone"
