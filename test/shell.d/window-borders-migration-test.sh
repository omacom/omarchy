#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

migration="$ROOT/migrations/1793833200.sh"
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/hyprctl"
chmod +x "$stub_bin/hyprctl"

test_home="$test_tmp/home"
toggles_dir="$test_home/.local/state/omarchy/toggles/hypr"
mkdir -p "$toggles_dir"

gaps_file="$toggles_dir/window-no-gaps.lua"
borders_file="$toggles_dir/window-no-borders.lua"

# Seed with older window-no-gaps.lua that contained border_size = 0
cat >"$gaps_file" <<'LUA'
-- Remove all window gaps and borders.
hl.config({
  general = {
    gaps_out = 0,
    gaps_in = 0,
    border_size = 0,
  },

  decoration = {
    rounding = 0,
  },
})
LUA

run_migration() {
  (
    env -i \
      HOME="$test_home" \
      XDG_STATE_HOME="$test_home/.local/state" \
      OMARCHY_PATH="$ROOT" \
      PATH="$stub_bin:$ROOT/bin:/usr/bin" \
      bash -euo pipefail "$migration"
  )
}

run_migration >/dev/null 2>&1

! grep -q "border_size" "$gaps_file" || fail "migration strips border_size from saved window-no-gaps.lua"
pass "migration strips border_size from saved window-no-gaps.lua"

[[ -f $borders_file ]] || fail "migration carries over border suppression as window-no-borders.lua"
pass "migration carries over border suppression as window-no-borders.lua"

# User turns borders back on
rm -f "$borders_file"

# Run migration again to verify idempotency
run_migration >/dev/null 2>&1

[[ ! -f $borders_file ]] || fail "migration is idempotent and does not recreate window-no-borders.lua"
pass "migration is idempotent and preserves user choice to turn borders back on"
