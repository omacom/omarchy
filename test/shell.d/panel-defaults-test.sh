#!/bin/bash

# A built-in panel its platform package names in displays.conf with a panel
# line gets those settings in every rule for it, and nothing else changes.
# Runs default/hypr/panel-defaults.lua, rewritten to read a fixture in place of
# /usr/share/omarchy-platform/displays.conf, against a fake hl that records the
# rules it is given.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/default/hypr"
displays_conf="$tmpdir/displays.conf"
sed "s|/usr/share/omarchy-platform/displays.conf|$displays_conf|" \
  "$ROOT/default/hypr/panel-defaults.lua" >"$tmpdir/default/hypr/panel-defaults.lua"
grep -Fq "$displays_conf" "$tmpdir/default/hypr/panel-defaults.lua" || fail "the module reads the platform's displays.conf"

cat >"$tmpdir/fake.lua" <<'LUA'
package.path = os.getenv("TMPROOT") .. "/?.lua;" .. os.getenv("ROOT") .. "/?.lua;" .. package.path

applied, handlers, monitors = {}, {}, {}

hl = {
  get_monitors = function() return monitors end,
  monitor = function(spec) applied[#applied + 1] = spec end,
  on = function(name, handler) handlers[name] = handler end,
}

function plug(name, fields)
  fields.name = name
  monitors[#monitors + 1] = fields
end

function load_module()
  package.loaded["default.hypr.panel-defaults"] = nil
  require("default.hypr.panel-defaults")
end

-- The rules given for a port, in order.
function for_output(name)
  local found = {}
  for _, spec in ipairs(applied) do
    if spec.output == name then found[#found + 1] = spec end
  end
  return found
end

function last_for(name)
  local found = for_output(name)
  return found[#found]
end

function check(condition, message)
  if not condition then error(message, 2) end
end
LUA

run_lua() {
  ROOT="$ROOT" TMPROOT="$tmpdir" lua -e "dofile('$tmpdir/fake.lua')" - <<<"$1"
}

panel='
plug("eDP-1", { width = 3024, height = 1964, description = "Apple Computer Inc J604" })
plug("DP-1", { width = 3840, height = 2160, description = "Dell Inc. DELL U2723QE" })
'

cat >"$displays_conf" <<'CONF'
# The Retina panel; Apple Silicon has no GPU backlight
backlight-prefer apple-panel-bl
# The 14-inch MacBook Pro panel: 10 bits per channel, Display P3
panel eDP 3024x1964 bitdepth=10 cm=dp3
CONF

# Omarchy's catch-all reaches the panel as a rule of its own with the settings,
# and the catch-all itself, which also covers external monitors, has none.
run_lua "$panel"'
load_module()
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
check(applied[1].output == "" and applied[1].bitdepth == nil and applied[1].cm == nil, "leaves the catch-all without the settings")
local own = last_for("eDP-1")
check(own and own.bitdepth == 10 and own.cm == "dp3", "gives the panel 10 bits and Display P3")
check(own.mode == "preferred" and own.position == "auto" and own.scale == "auto", "keeps the catch-all'"'"'s mode, position and scale")
check(#for_output("DP-1") == 0, "gives an external monitor no rule")
' || fail "the catch-all gives the named panel its settings"
pass "the catch-all gives the named panel its settings"

# A rule naming the panel, from monitors.lua, the display panel or a command's
# hyprctl eval, keeps the settings; one naming an external monitor gets none.
run_lua "$panel"'
load_module()
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "eDP-1", mode = "3024x1964@120", position = "auto", scale = 2 })
hl.monitor({ output = "DP-1", scale = 1.5 })
local own = last_for("eDP-1")
check(own.bitdepth == 10 and own.cm == "dp3" and own.scale == 2 and own.mode == "3024x1964@120", "a scale change keeps 10 bits and Display P3")
check(last_for("DP-1").bitdepth == nil and last_for("DP-1").cm == nil, "an external monitor gets neither")
' || fail "rules naming the panel keep its settings"
pass "rules naming the panel keep its settings"

# A setting chosen in monitors.lua wins: for the port, for the monitor's
# description or for every monitor, later rules without one keep it, and the
# other setting still comes from the platform.
run_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "eDP-1", scale = 2, bitdepth = 8 })
hl.monitor({ output = "eDP-1", scale = 1.6 })
check(last_for("eDP-1").bitdepth == 8, "keeps 8 chosen for the port, got " .. tostring(last_for("eDP-1").bitdepth))
check(last_for("eDP-1").cm == "dp3", "still gives Display P3")
' || fail "a depth chosen for the port wins"
run_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "desc:Apple Computer Inc J604", cm = "srgb" })
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").cm == "srgb", "keeps srgb chosen for the description, got " .. tostring(last_for("eDP-1").cm))
check(last_for("eDP-1").bitdepth == 10, "still gives 10 bits")
' || fail "a color preset chosen for the description wins"
run_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "", scale = "auto", bitdepth = 8, cm = "srgb" })
check(last_for("eDP-1").bitdepth == 8 and last_for("eDP-1").cm == "srgb", "follows the settings chosen for every monitor")
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").bitdepth == 8 and last_for("eDP-1").cm == "srgb", "keeps the settings chosen for every monitor")
' || fail "settings chosen for every monitor win"
pass "settings chosen in monitors.lua win, each on its own"

# The panel's own rule from monitors.lua isn't replaced by a later catch-all.
run_lua "$panel"'
load_module()
hl.monitor({ output = "eDP-1", scale = 2 })
local before = #for_output("eDP-1")
hl.monitor({ output = "", scale = "auto" })
check(#for_output("eDP-1") == before, "adds no rule over the panel'"'"'s own")
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").cm == "dp3" and last_for("eDP-1").scale == 2, "the panel'"'"'s own rule has the settings")
' || fail "the panel's own rule stays in charge"
pass "the panel's own rule stays in charge"

# A panel at another mode, or one the file doesn't name, gets nothing: both
# the width and the height have to match.
for size in 'width = 2880, height = 1864' 'width = 2560, height = 1964' 'width = 3024, height = 1890'; do
  run_lua '
plug("eDP-1", { '"$size"' })
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").bitdepth == nil and last_for("eDP-1").cm == nil and #for_output("eDP-1") == 1, "leaves another panel alone")
' || fail "an unnamed panel gets nothing ($size)"
done
run_lua '
plug("HDMI-A-1", { width = 3024, height = 1964 })
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "HDMI-A-1", scale = 2 })
check(last_for("HDMI-A-1").bitdepth == nil and last_for("HDMI-A-1").cm == nil, "matches the connector too")
' || fail "a monitor on another connector gets nothing"
pass "only the named panel at its mode gets the settings"

# A panel that turns up after the config has loaded gets its rule then, once.
run_lua '
load_module()
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
check(#applied == 1, "no panel yet")
plug("eDP-1", { width = 3024, height = 1964 })
handlers["hyprland.start"]()
handlers["monitor.added"]({ name = "eDP-1" })
check(#for_output("eDP-1") == 1, "one rule for the panel, got " .. #for_output("eDP-1"))
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").cm == "dp3" and last_for("eDP-1").scale == "auto", "the catch-all'"'"'s rule with the settings")
' || fail "a panel arriving later gets its settings"
run_lua '
load_module()
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").bitdepth == nil, "unknown until the panel is there")
plug("eDP-1", { width = 3024, height = 1964 })
handlers["monitor.added"]({ name = "eDP-1" })
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").cm == "dp3" and last_for("eDP-1").scale == 2, "its own rule again, with the settings")
' || fail "a named panel arriving later gets its settings"
pass "a panel arriving later gets its settings"

# A key this Omarchy doesn't know is skipped, and the ones it knows still apply.
printf 'panel eDP 3024x1964 bitdepth=10 sharpness=3\n' >"$displays_conf"
run_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").sharpness == nil and last_for("eDP-1").cm == nil, "applies the known key only")
' || fail "an unknown key is skipped"
pass "an unknown key is skipped"

# Without a well-formed panel line, or without the file, hl.monitor isn't wrapped.
for content in missing 'backlight-prefer apple-panel-bl' 'panel eDP 3024x1964' 'panel eDP 3024x1964 sharpness=3' \
  'panel eDP 3024x1964 bitdepth=12' 'panel eDP 3024x1964 cm=hdr' 'panel eDP 3024x1964 cm=bogus bitdepth=10' \
  'panel eDP 3024x1964 bitdepth' 'panel eDP 3024-1964 bitdepth=10' 'panel ../eDP 3024x1964 bitdepth=10' \
  'panel-bitdepth eDP 3024x1964 10'; do
  if [[ $content == missing ]]; then
    rm -f "$displays_conf"
  else
    printf '%s\n' "$content" >"$displays_conf"
  fi
  run_lua "$panel"'
local original = hl.monitor
load_module()
check(hl.monitor == original, "leaves hl.monitor alone")
' || fail "no well-formed panel line changes nothing ($content)"
done
pass "without a well-formed panel line nothing changes"

# With wide-gamut.lua in front on Apple Silicon, the panel takes the platform's
# preset over wide-gamut's EDID one, external monitors keep wide-gamut's, and
# a preset chosen for the panel still wins.
if [[ -f $ROOT/default/hypr/wide-gamut.lua ]]; then
  printf 'panel eDP 3024x1964 bitdepth=10 cm=dp3\r\n' >"$displays_conf"
  run_lua "$panel"'
o = { shell_quote = function(value) return value end, shell_succeeds = function() return true end }
require("default.hypr.wide-gamut")
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "eDP-1", scale = 2 })
hl.monitor({ output = "DP-1", scale = 1.5 })
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").cm == "dp3", "the panel gets 10 bits and Display P3, got " .. tostring(last_for("eDP-1").cm))
check(last_for("DP-1").cm == "edid" and last_for("DP-1").bitdepth == nil, "an external monitor keeps EDID color")
hl.monitor({ output = "eDP-1", cm = "srgb" })
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").cm == "srgb", "a preset chosen for the panel wins")
' || fail "panel settings compose with wide-gamut"
  pass "panel settings compose with wide-gamut"
fi
