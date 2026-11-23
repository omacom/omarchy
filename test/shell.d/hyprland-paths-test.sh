#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

run_paths() {
  lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local paths = require("default.hypr.paths")
assert(paths.config_home == os.getenv("EXPECTED_CONFIG"), "config_home: " .. paths.config_home)
assert(paths.state_home == os.getenv("EXPECTED_STATE"), "state_home: " .. paths.state_home)
LUA
}

HOME="/home/test-user" OMARCHY_PATH="$ROOT" \
  XDG_CONFIG_HOME= XDG_STATE_HOME= \
  EXPECTED_CONFIG="/home/test-user/.config" EXPECTED_STATE="/home/test-user/.local/state" \
  run_paths
pass "empty XDG path variables fall back to their defaults"

HOME="/home/test-user" OMARCHY_PATH="$ROOT" \
  XDG_CONFIG_HOME="/custom/config" XDG_STATE_HOME="/custom/state" \
  EXPECTED_CONFIG="/custom/config" EXPECTED_STATE="/custom/state" \
  run_paths
pass "set XDG path variables are honored"

# Toggle flags are written to ~/.local/state whatever XDG_STATE_HOME says, so
# Hyprland has to read them from there too, or a diverged XDG_STATE_HOME turns
# every toggle into a no-op that still reports success.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home" "$test_tmp/xdg-state" "$test_tmp/bin"
printf '#!/bin/bash\n' >"$test_tmp/bin/hyprctl"
chmod +x "$test_tmp/bin/hyprctl"

HOME="$test_tmp/home" XDG_STATE_HOME="$test_tmp/xdg-state" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" \
  "$ROOT/bin/omarchy-hyprland-toggle" window-no-gaps on

HOME="$test_tmp/home" XDG_STATE_HOME="$test_tmp/xdg-state" OMARCHY_PATH="$ROOT" lua - <<'LUA'
local configs = {}
hl = {
  config = function(config)
    table.insert(configs, config)
  end,
  device = function() end,
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.toggles")

local loaded = false
for _, config in ipairs(configs) do
  if config.general and config.general.gaps_out == 0 then
    loaded = true
  end
end
assert(loaded, "a flag set by omarchy-hyprland-toggle is loaded on reload")
LUA
pass "toggle flags load from where omarchy-hyprland-toggle writes them, not XDG_STATE_HOME"
