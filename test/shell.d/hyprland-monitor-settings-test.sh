#!/bin/bash

# Each monitor's mode, position and scale, saved by the physical monitor, are
# applied whatever connector it turns up on. Runs default/hypr/monitor-settings.lua
# against a fake hl that records what the module asks of it.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/state/omarchy/monitors"
settings="$tmpdir/state/omarchy/monitors/settings"

cat >"$tmpdir/fake.lua" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

applied, env, handlers, monitors, identities = {}, {}, {}, {}, {}

hl = {
  get_monitors = function() return monitors end,
  monitor = function(spec) applied[#applied + 1] = spec end,
  env = function(name, value) env[name] = value end,
  on = function(name, handler) handlers[name] = handler end,
}

o = { workspaces = { identities = function() return identities end } }

function plug(name, identity, fields)
  fields.name = name
  monitors[#monitors + 1] = fields
  identities[name] = identity
end

function load_module()
  applied, env = {}, {}
  package.loaded["default.hypr.monitor-settings"] = nil
  return require("default.hypr.monitor-settings")
end

function check(condition, message)
  if not condition then error(message, 2) end
end
LUA

run_lua() {
  ROOT="$ROOT" XDG_STATE_HOME="$tmpdir/state" lua -e "dofile('$tmpdir/fake.lua')" - <<<"$1"
}

# The Pro Display was set on DP-1 and comes back on DP-2 through a dock. It
# gets its settings there, and only the ones chosen: the laptop, with only a
# scale saved, keeps whatever mode and position monitors.lua gives it.
printf '%s\t%s\t%s\t%s\n' \
  "5120x2880@60" "0x0" "2" "Apple Computer Inc ProDisplayXDR 0x0A110A08" \
  "" "" "1.6" "LG Display 0x0804" >"$settings"
run_lua '
plug("DP-2", "Apple Computer Inc ProDisplayXDR 0x0A110A08", { width = 5120, height = 2880, refresh_rate = 60, scale = 2, x = 0, y = 0 })
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 1.6, x = 2560, y = 0 })
load_module()
check(#applied == 2, "applies every saved monitor while the config loads, got " .. #applied)
check(applied[1].output == "DP-2" and applied[1].mode == "5120x2880@60" and applied[1].position == "0x0" and applied[1].scale == 2,
  "applies the monitor'"'"'s settings on its new connector")
check(applied[2].output == "eDP-1" and applied[2].scale == 1.6 and applied[2].mode == nil and applied[2].position == nil,
  "applies only the settings chosen")
' || fail "monitor settings follow the monitor and set only what was chosen"
pass "monitor settings follow the monitor and set only what was chosen"

# Plugged in again, a monitor already running as saved is left alone; one that
# isn't gets its settings.
run_lua '
plug("DP-2", "Apple Computer Inc ProDisplayXDR 0x0A110A08", { width = 5120, height = 2880, refresh_rate = 60, scale = 2, x = 0, y = 0 })
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 2, x = 2560, y = 0 })
load_module()
applied = {}
handlers["monitor.added"]({ name = "DP-2" })
check(#applied == 0, "leaves a monitor already running as saved alone")
handlers["monitor.added"]({ name = "eDP-1" })
check(#applied == 1 and applied[1].output == "eDP-1" and applied[1].scale == 1.6, "applies a returning monitor'"'"'s settings")
' || fail "monitor settings reapply only what differs when a monitor arrives"
pass "monitor settings reapply only what differs when a monitor arrives"

# GDK_SCALE follows the lowest scale, saved or running, rounded to a whole
# number and never below 1.
run_lua '
plug("DP-2", "Apple Computer Inc ProDisplayXDR 0x0A110A08", { width = 5120, height = 2880, refresh_rate = 60, scale = 2, x = 0, y = 0 })
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 1.6, x = 2560, y = 0 })
load_module()
check(env.GDK_SCALE == "2", "rounds the lowest scale, 1.6, to 2, got " .. tostring(env.GDK_SCALE))
' || fail "monitor settings set GDK_SCALE from the lowest scale"
printf '%s\t%s\t%s\t%s\n' "" "" "1.25" "LG Display 0x0804" >"$settings"
run_lua '
plug("DP-2", "Apple Computer Inc ProDisplayXDR 0x0A110A08", { width = 5120, height = 2880, refresh_rate = 60, scale = 2, x = 0, y = 0 })
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 1.25, x = 2560, y = 0 })
load_module()
check(env.GDK_SCALE == "1", "rounds 1.25 down to 1, got " .. tostring(env.GDK_SCALE))
' || fail "monitor settings round GDK_SCALE down"
pass "monitor settings set GDK_SCALE from the lowest scale"

# After a save, GDK_SCALE follows without any monitor being touched: the command
# that saved has already applied the change in its own order.
printf '%s\t%s\t%s\t%s\n' "1920x1200@60" "0x0" "1" "LG Display 0x0804" >"$settings"
run_lua '
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 2, x = 0, y = 0 })
load_module()
applied, env = {}, {}
o.monitor_settings.update_gdk_scale()
check(#applied == 0, "touches no monitor")
check(env.GDK_SCALE == "1", "sets GDK_SCALE from the saved scale, got " .. tostring(env.GDK_SCALE))
' || fail "monitor settings update GDK_SCALE without touching monitors"
pass "monitor settings update GDK_SCALE without touching monitors"

# A saved rotation goes with the rest, and a monitor already turned that way
# isn't turned again when it arrives.
printf '%s\t%s\t%s\t%s\t%s\n' "" "0x0" "1.5" "1" "Dell Inc. DELL U2723QE" >"$settings"
run_lua '
plug("DP-3", "Dell Inc. DELL U2723QE", { width = 3840, height = 2160, refresh_rate = 60, scale = 1.5, x = 0, y = 0, transform = 1 })
load_module()
check(#applied == 1 and applied[1].transform == 1, "applies the saved rotation")
applied = {}
handlers["monitor.added"]({ name = "DP-3" })
check(#applied == 0, "leaves a monitor already turned as saved alone")
' || fail "monitor settings apply a saved rotation"
pass "monitor settings apply a saved rotation"

# Switched off in monitors.lua, the saved settings are left alone entirely.
printf '%s\t%s\t%s\t%s\n' "1920x1200@60" "0x0" "1" "LG Display 0x0804" >"$settings"
run_lua '
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 2, x = 0, y = 0 })
omarchy_monitor_panel_settings = false
load_module()
handlers["monitor.added"]({ name = "eDP-1" })
o.monitor_settings.update_gdk_scale()
check(#applied == 0 and env.GDK_SCALE == nil, "applies nothing with the panel'"'"'s choices off")
' || fail "monitor settings stay out of the way when switched off in monitors.lua"
pass "monitor settings stay out of the way when switched off in monitors.lua"

# Until something is saved, monitors.lua alone decides, GDK_SCALE included.
rm -f "$settings"
run_lua '
plug("eDP-1", "LG Display 0x0804", { width = 2880, height = 1800, refresh_rate = 120, scale = 2, x = 0, y = 0 })
load_module()
check(#applied == 0 and env.GDK_SCALE == nil, "applies nothing without saved settings")
' || fail "monitor settings leave monitors.lua alone until something is saved"
pass "monitor settings leave monitors.lua alone until something is saved"

# On Apple Silicon every monitor rule maps sRGB into the display's own gamut,
# the panel's port-named rules included, since a rule without cm puts the
# display back on sRGB. A color choice of a rule's own wins, and nothing changes
# on a PC, where the display does the mapping itself.
wide_gamut_rules='
o.shell_quote = function(value) return value end
o.shell_succeeds = function() return apple end
package.loaded["default.hypr.wide-gamut"] = nil
require("default.hypr.wide-gamut")
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "DP-2", scale = 2 })
hl.monitor({ output = "DP-3", scale = 2, cm = "srgb" })
'
run_lua "apple = true $wide_gamut_rules"'
check(applied[1].cm == "edid" and applied[2].cm == "edid" and applied[2].scale == 2, "gives every rule EDID color")
check(applied[3].cm == "srgb", "keeps a color choice of its own")
' || fail "monitors get EDID color on Apple Silicon"
# The panel'"'"'s port-named rules, loading after monitors.lua, keep a cm chosen
# there for the monitor'"'"'s description or for every monitor.
run_lua '
apple = true
plug("DP-2", "", { description = "Apple Computer Inc ProDisplayXDR 0x0A110A08" })
plug("DP-3", "", { description = "Dell Inc. DELL U2723QE" })
o.shell_quote = function(value) return value end
o.shell_succeeds = function() return apple end
require("default.hypr.wide-gamut")
hl.monitor({ output = "", cm = "srgb" })
hl.monitor({ output = "desc:Apple Computer Inc ProDisplayXDR", cm = "dcip3" })
hl.monitor({ output = "DP-2", scale = 2 })
hl.monitor({ output = "DP-3", scale = 2 })
check(applied[3].cm == "dcip3", "keeps the cm chosen for the monitor'"'"'s description, got " .. tostring(applied[3].cm))
check(applied[4].cm == "srgb", "keeps the cm chosen for every monitor, got " .. tostring(applied[4].cm))
' || fail "port rules keep a cm chosen in monitors.lua"
run_lua "apple = false $wide_gamut_rules"'
check(applied[1].cm == nil and applied[2].cm == nil, "changes no rule off Apple Silicon")
' || fail "monitors keep sRGB off Apple Silicon"
pass "monitors get EDID color only on Apple Silicon"

# A built-in panel its platform package names in displays.conf with a panel
# line gets those settings in every rule for it, and nothing else changes.
# Runs default/hypr/panel-defaults.lua, rewritten to read a fixture in place of
# /usr/share/omarchy-platform/displays.conf, against a fake hl of its own.
panel_tmp="$tmpdir/panel"

mkdir -p "$panel_tmp/default/hypr"
displays_conf="$panel_tmp/displays.conf"
sed "s|/usr/share/omarchy-platform/displays.conf|$displays_conf|" \
  "$ROOT/default/hypr/panel-defaults.lua" >"$panel_tmp/default/hypr/panel-defaults.lua"
grep -Fq "$displays_conf" "$panel_tmp/default/hypr/panel-defaults.lua" || fail "the module reads the platform's displays.conf"

cat >"$panel_tmp/fake.lua" <<'LUA'
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

run_panel_lua() {
  ROOT="$ROOT" TMPROOT="$panel_tmp" lua -e "dofile('$panel_tmp/fake.lua')" - <<<"$1"
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
run_panel_lua "$panel"'
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
run_panel_lua "$panel"'
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
run_panel_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "eDP-1", scale = 2, bitdepth = 8 })
hl.monitor({ output = "eDP-1", scale = 1.6 })
check(last_for("eDP-1").bitdepth == 8, "keeps 8 chosen for the port, got " .. tostring(last_for("eDP-1").bitdepth))
check(last_for("eDP-1").cm == "dp3", "still gives Display P3")
' || fail "a depth chosen for the port wins"
run_panel_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "desc:Apple Computer Inc J604", cm = "srgb" })
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").cm == "srgb", "keeps srgb chosen for the description, got " .. tostring(last_for("eDP-1").cm))
check(last_for("eDP-1").bitdepth == 10, "still gives 10 bits")
' || fail "a color preset chosen for the description wins"
run_panel_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "", scale = "auto", bitdepth = 8, cm = "srgb" })
check(last_for("eDP-1").bitdepth == 8 and last_for("eDP-1").cm == "srgb", "follows the settings chosen for every monitor")
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").bitdepth == 8 and last_for("eDP-1").cm == "srgb", "keeps the settings chosen for every monitor")
' || fail "settings chosen for every monitor win"
pass "settings chosen in monitors.lua win, each on its own"

# A rule naming the panel by its description, with no port rule after it,
# keeps the settings, and a preset chosen in it still wins.
run_panel_lua "$panel"'
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "desc:Apple Computer Inc J604", scale = 2 })
local own = applied[#applied]
check(own.output == "desc:Apple Computer Inc J604" and own.scale == 2, "passes the description rule on")
check(own.bitdepth == 10 and own.cm == "dp3", "gives the description rule 10 bits and Display P3, got " .. tostring(own.bitdepth) .. " " .. tostring(own.cm))
hl.monitor({ output = "desc:Dell Inc. DELL U2723QE", scale = 1.5 })
check(applied[#applied].bitdepth == nil and applied[#applied].cm == nil, "gives a rule for an external monitor by description neither")
hl.monitor({ output = "desc:Apple Computer Inc J604", scale = 2, cm = "srgb" })
check(applied[#applied].cm == "srgb" and applied[#applied].bitdepth == 10, "keeps srgb chosen in the description rule")
' || fail "a description rule for the panel keeps its settings"
pass "a description rule for the panel keeps its settings"

# The panel's own rule from monitors.lua isn't replaced by a later catch-all.
run_panel_lua "$panel"'
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
  run_panel_lua '
plug("eDP-1", { '"$size"' })
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "eDP-1", scale = 2 })
check(last_for("eDP-1").bitdepth == nil and last_for("eDP-1").cm == nil and #for_output("eDP-1") == 1, "leaves another panel alone")
' || fail "an unnamed panel gets nothing ($size)"
done
run_panel_lua '
plug("HDMI-A-1", { width = 3024, height = 1964 })
load_module()
hl.monitor({ output = "", scale = "auto" })
hl.monitor({ output = "HDMI-A-1", scale = 2 })
check(last_for("HDMI-A-1").bitdepth == nil and last_for("HDMI-A-1").cm == nil, "matches the connector too")
' || fail "a monitor on another connector gets nothing"
pass "only the named panel at its mode gets the settings"

# A panel that turns up after the config has loaded gets its rule then, once.
run_panel_lua '
load_module()
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
check(#applied == 1, "no panel yet")
plug("eDP-1", { width = 3024, height = 1964 })
handlers["hyprland.start"]()
handlers["monitor.added"]({ name = "eDP-1" })
check(#for_output("eDP-1") == 1, "one rule for the panel, got " .. #for_output("eDP-1"))
check(last_for("eDP-1").bitdepth == 10 and last_for("eDP-1").cm == "dp3" and last_for("eDP-1").scale == "auto", "the catch-all'"'"'s rule with the settings")
' || fail "a panel arriving later gets its settings"
run_panel_lua '
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
run_panel_lua "$panel"'
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
  run_panel_lua "$panel"'
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
  run_panel_lua "$panel"'
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
