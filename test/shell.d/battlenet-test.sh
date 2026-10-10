#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/bin/omarchy-install-gaming-battlenet"

[[ ! -f $ROOT/applications/battlenet.desktop ]] || fail "Battle.net launcher is not part of default application refresh"
[[ -f $ROOT/default/applications/battlenet.desktop ]] || fail "Battle.net launcher template is available to the installer"
grep -F '$OMARCHY_PATH/default/applications/battlenet.desktop' "$install_script" >/dev/null ||
  fail "Battle.net installer installs the launcher from the installer-only template"

pass "Battle.net launcher is only installed by the Battle.net installer"

require_command lua

# The launcher used to be a fixed 1280x800 float. On a scale-2 2256x1504 panel
# that is 1128x752 logical, so centering puts the window at -76,-24 and the
# client's fullscreen request fights the close bind. The rule has to stay inside
# the monitor there and stay 1280x800 on a 1080p display.
ROOT="$ROOT" lua <<'LUA' || fail "Battle.net launcher is sized to the monitor"
local seen = {}

o = {
  window = function(match, rules)
    table.insert(seen, { match = match, rules = rules })
  end,
}

dofile(os.getenv("ROOT") .. "/default/hypr/apps/battlenet.lua")

local function find(title)
  for _, item in ipairs(seen) do
    if item.match.title == title then
      return item
    end
  end
  error("no rule for " .. title)
end

local launcher = find("^Battle\\.net$")
assert(launcher.match.class == "^steam_app_battlenet$", "launcher match stays on the Proton class")
assert(launcher.rules.float == true, "launcher stays floating")
assert(launcher.rules.center == true, "launcher stays centered")
assert(launcher.rules.size[1] == "min(1280,monitor_w-48)", "width caps at the monitor")
assert(launcher.rules.size[2] == "min(800,monitor_h-64)", "height caps at the monitor")
assert(launcher.rules.suppress_event == "fullscreen maximize", "fullscreen is ignored and maximize stays suppressed")

local setup = find("^Battle\\.net Setup$")
assert(setup.rules.decorate == false, "setup still drops decorations")
assert(setup.rules.size == nil, "setup is not forced to the launcher size")

local function fit(want, monitor, margin)
  return math.min(want, monitor - margin)
end

-- Surface Laptop 4 at scale 2. The old rule centered at (1128-1280)/2, (752-800)/2.
local width, height = fit(1280, 1128, 48), fit(800, 752, 64)
assert(width == 1080 and height == 688, "scale-2 2256x1504 panel gets 1080x688")
assert((1128 - width) / 2 == 24, "the fitted window starts on-screen")
assert(width < 1128 and height < 752, "the fitted window is smaller than that panel")

assert(fit(1280, 1920, 48) == 1280, "a 1080p monitor keeps the 1280 width")
assert(fit(800, 1080, 64) == 800, "a 1080p monitor keeps the 800 height")
LUA

pass "Battle.net launcher is sized to the monitor"
