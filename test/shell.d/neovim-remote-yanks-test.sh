#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT
provider="$test_home/.config/nvim/lua/config/remote_clipboard.lua"
mkdir -p "$(dirname "$provider")" "$test_home/bin"
# Redirect only the packaged source path; run the actual migration logic.
sed "s@/usr/share/omarchy-nvim/config/lua/config/remote_clipboard.lua@$test_home/package.lua@" \
  "$ROOT/migrations/1788996284.sh" >"$test_home/migration.sh"
printf '%s\n' '-- corrected packaged provider' >"$test_home/package.lua"
cat >"$test_home/bin/pacman" <<'STUB'
#!/bin/bash
[[ $* == '-Q omarchy-nvim' ]] || exit 1
printf 'omarchy-nvim %s\n' "${TEST_NVIM_VERSION:-2026.9.21-2}"
STUB
chmod +x "$test_home/bin/pacman"
run_migration() {
  env HOME="$test_home" PATH="$test_home/bin:$PATH" bash -euo pipefail "$test_home/migration.sh"
}

run_migration
[[ ! -e $provider ]] || fail "missing provider is left alone"
pass "missing provider is left alone"

for fixture in "$SHELL_TEST_DIR/fixtures/neovim-clipboard/"*.lua; do
  cp "$fixture" "$provider"
  run_migration
  cmp "$provider" "$test_home/package.lua" || fail "known provider is upgraded: $fixture"
  backup=$(ls -t "$provider".bak.* | head -n1)
  cmp "$backup" "$fixture" || fail "known provider is backed up: $fixture"
  [[ $(stat -c %a "$provider") == "644" ]] || fail "provider is mode 0644"
  before=$(ls "$provider".bak.*)
  run_migration
  [[ $(ls "$provider".bak.*) == "$before" ]] || fail "repeat migration does not create backups"
  pass "known provider is backed up and upgraded idempotently: ${fixture##*/}"
done

cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" "$provider"
printf '%s\n' '-- user customization' >>"$provider"
cp "$provider" "$test_home/custom.lua"
run_migration >"$test_home/output"
cmp "$provider" "$test_home/custom.lua" || fail "customized provider is preserved"
grep -q 'Preserving customized' "$test_home/output" || fail "customized provider receives guidance"
printf '%s\n' '-- unrelated provider' >"$provider"
cp "$provider" "$test_home/custom.lua"
run_migration
cmp "$provider" "$test_home/custom.lua" || fail "unrelated provider is preserved"
pass "customized and unrelated providers are preserved"

cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" "$provider"
for TEST_NVIM_VERSION in 2026.8.13-1 2026.8.13-2 2026.9.21-1; do
  export TEST_NVIM_VERSION
  if run_migration; then fail "old package leaves migration pending: $TEST_NVIM_VERSION"; fi
  cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" || fail "old package leaves provider unchanged"
done
unset TEST_NVIM_VERSION
mv "$test_home/package.lua" "$test_home/package.saved"
if run_migration; then fail "missing package source leaves migration pending"; fi
cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" || fail "missing source leaves provider unchanged"
pass "old or missing package cannot mark an unrepaired provider complete"

mv "$test_home/package.saved" "$test_home/package.lua"
# A write that fails after producing partial output must never damage the live
# provider. Exercise the real install destination with a failing replacement.
cat >"$test_home/bin/install" <<'STUB'
#!/bin/bash
printf '%s' '-- truncated replacement' >"${@: -1}"
exit 1
STUB
chmod +x "$test_home/bin/install"
if run_migration; then fail "failed staging write leaves migration pending"; fi
cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" || fail "failed write preserves live provider"
if compgen -G "$provider.new.*" >/dev/null; then fail "failed staging file is cleaned up"; fi
rm "$test_home/bin/install"
run_migration
cmp "$provider" "$test_home/package.lua" || fail "retry repairs the recognized original"
pass "failed write preserves original and retry succeeds"

# Also fail the final rename, after successful staging.
cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" "$provider"
printf '#!/bin/bash\nexit 1\n' >"$test_home/bin/mv"
chmod +x "$test_home/bin/mv"
if run_migration; then fail "failed rename leaves migration pending"; fi
cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" || fail "failed rename preserves original"
if compgen -G "$provider.new.*" >/dev/null; then fail "failed rename staging file is cleaned up"; fi
rm "$test_home/bin/mv"
run_migration
cmp "$provider" "$test_home/package.lua" || fail "retry after rename failure succeeds"
pass "failed rename preserves original and retry succeeds"

cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" "$test_home/dotfile.lua"
rm "$provider"
ln -s "$test_home/dotfile.lua" "$provider"
run_migration >"$test_home/output"
[[ -L $provider ]] || fail "provider symlink is preserved"
cmp "$test_home/dotfile.lua" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" || fail "symlink target is preserved"
grep -q 'symlink-managed' "$test_home/output" || fail "linked provider receives guidance"
rm "$provider"
ln -s "$test_home/absent.lua" "$provider"
run_migration
[[ -L $provider && ! -e $provider ]] || fail "dangling symlink is preserved"
rm "$provider"

mkdir "$test_home/dotfiles"
mv "$test_home/.config/nvim/lua/config" "$test_home/dotfiles/config"
ln -s "$test_home/dotfiles/config" "$test_home/.config/nvim/lua/config"
cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" "$provider"
run_migration
[[ -L $test_home/.config/nvim/lua/config ]] || fail "linked config directory is preserved"
cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/july.lua" || fail "provider in linked directory is preserved"
pass "linked files, dangling links and linked directories are preserved"
