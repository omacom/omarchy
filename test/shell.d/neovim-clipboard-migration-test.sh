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
cat >"$test_home/bin/pacman" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$test_home/bin/pacman"
cp "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" "$provider"

if ! env HOME="$test_home" PATH="$test_home/bin:$PATH" bash -euo pipefail "$test_home/migration.sh" >"$test_home/output"; then
  fail "uninstalled omarchy-nvim completes the migration"
fi
cmp "$provider" "$SHELL_TEST_DIR/fixtures/neovim-clipboard/june.lua" || fail "uninstalled omarchy-nvim leaves the provider unchanged"
grep -q 'omarchy-nvim is not installed' "$test_home/output" || fail "uninstalled omarchy-nvim explains the skip"
pass "uninstalled omarchy-nvim skips the repair without blocking later migrations"
