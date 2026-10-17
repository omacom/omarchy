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
(( $# == 1 )) && [[ $1 == "omarchy-nvim" ]] || exit 2
[[ $OMARCHY_TEST_NVIM_INSTALLED == "1" ]]
SH
cat >"$mock_bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

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

# Package files left behind after removal must not opt a user back in.
reset_config
printf -- '-- mine\n' >"$config/$transparency"
printf -- '-- my config\n' >"$config/init.lua"
cp -a "$config" "$test_dir/custom-config"
run_migration 0 || fail "an absent package is skipped even with leftover package files"
diff -r "$test_dir/custom-config" "$config" || fail "an absent package preserves the entire custom config"
pass "an absent package is skipped even with leftover package files"

mv "$package" "$test_dir/saved-package"
run_migration 0 || fail "an absent package does not require package files"
diff -r "$test_dir/custom-config" "$config" || fail "an absent package preserves the entire custom config"
pass "an absent package without package files preserves custom config"

# Exercise the real runner with only this migration and a later sentinel.
runner_root="$test_dir/runner"
state="$test_dir/migration-state"
mkdir -p "$runner_root/migrations"
cp "$test_dir/migration.sh" "$runner_root/migrations/1791723398.sh"
cat >"$runner_root/migrations/1791723399.sh" <<'SH'
touch "$HOME/later-migration-ran"
SH

run_migrate() {
  HOME="$test_dir" PATH="$mock_bin:$PATH" OMARCHY_TEST_NVIM_INSTALLED="$1" \
    OMARCHY_PATH="$runner_root" OMARCHY_MIGRATION_STATE="$state" \
    bash "$ROOT/bin/omarchy-migrate" >"$test_dir/runner.out" 2>&1
}

run_migrate 0 || fail "the runner continues when omarchy-nvim is absent"
[[ -f $state/1791723398.sh && -f $state/1791723399.sh && -f $test_dir/later-migration-ran ]] ||
  fail "the runner marks the skipped migration complete and executes the next migration"
diff -r "$test_dir/custom-config" "$config" || fail "the runner preserves custom config when the package is absent"
pass "the runner marks the skipped migration complete and executes the next migration"

rm -rf "$state"
rm -f "$test_dir/later-migration-ran"
reset_config
if run_migrate 1; then
  fail "the runner stops when the installed package is missing files"
fi
[[ ! -e $state/1791723398.sh && ! -e $state/1791723399.sh && ! -e $test_dir/later-migration-ran ]] ||
  fail "a failed migration stays pending and blocks the next migration"
cmp -s "$config/$transparency" "$test_dir/shipped.lua" && [[ ! -e $config/$lualine ]] ||
  fail "a failed package check preserves the config"
pass "a failed migration stays pending and blocks the next migration"

mv "$test_dir/saved-package" "$package"
run_migrate 1 || fail "the runner retries after package files are restored"
[[ -f $state/1791723398.sh && -f $state/1791723399.sh && -f $test_dir/later-migration-ran ]] ||
  fail "a successful retry completes both migrations"
cmp -s "$config/$transparency" "$package/$transparency" && cmp -s "$config/$lualine" "$package/$lualine" ||
  fail "a successful retry installs the package files"
pass "the runner retries successfully after package files are restored"
