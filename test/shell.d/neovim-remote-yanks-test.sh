#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT
provider="$test_home/.config/nvim/lua/config/remote_clipboard.lua"
migration="$ROOT/migrations/1788996284.sh"

env HOME="$test_home" bash -euo pipefail "$migration"
[[ ! -e $provider ]] || fail "missing Neovim config is left alone"
pass "missing Neovim config is left alone"

mkdir -p "$(dirname "$provider")"
printf '%s\n' '-- Custom provider' >"$provider"
cp "$provider" "$test_home/before.lua"
env HOME="$test_home" bash -euo pipefail "$migration"
cmp "$provider" "$test_home/before.lua" || fail "custom provider is preserved"
pass "custom provider is preserved"

cat >"$provider" <<'LUA'
local M = {}
function M.setup()
  if not vim.env.SSH_CONNECTION then
    return
  end
  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
  }
end
return M
LUA
env HOME="$test_home" bash -euo pipefail "$migration"
require_command nvim
cat >"$test_home/check.lua" <<'LUA'
vim.env.SSH_CONNECTION = nil
vim.opt.clipboard = ""
dofile(vim.env.TEST_PROVIDER).setup()
assert(vim.o.clipboard == "")
vim.env.SSH_CONNECTION = "test"
dofile(vim.env.TEST_PROVIDER).setup()
assert(vim.o.clipboard == "unnamedplus")
LUA
env NVIM_LOG_FILE="$test_home/nvim.log" TEST_PROVIDER="$provider" nvim --clean -n --headless -i NONE -l "$test_home/check.lua"
pass "clipboard syncing is enabled inside remote provider setup"

cp "$provider" "$test_home/once.lua"
env HOME="$test_home" bash -euo pipefail "$migration"
cmp "$provider" "$test_home/once.lua" || fail "migration is idempotent"
pass "migration is idempotent"
