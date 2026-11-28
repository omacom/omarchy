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

# On Apple Silicon the built-in panel and Apple's wide-gamut displays map sRGB
# into their own gamut, whatever port they're on and whenever they're plugged
# in; every other monitor gets Hyprland's default sRGB. A rule's own cm wins.
# rule_for picks a monitor's rule the way Hyprland does: a call merges into the
# output's existing rule, and the latest rule naming the port or matching the
# description wins, else the latest rule for every monitor.
wide_gamut='
o.shell_quote = function(value) return value end
o.shell_succeeds = function() return apple end
package.loaded["default.hypr.wide-gamut"] = nil
require("default.hypr.wide-gamut")
function rule_for(name, description)
  local rules = {}
  for _, call in ipairs(applied) do
    local output, merged = call.output or "", {}
    for i, rule in ipairs(rules) do
      if rule.output == output then merged = table.remove(rules, i) break end
    end
    for key, value in pairs(call) do merged[key] = value end
    merged.output = output
    rules[#rules + 1] = merged
  end
  for i = #rules, 1, -1 do
    local desc = rules[i].output:match("^desc:(.+)$")
    if rules[i].output == name or (desc and description:sub(1, #desc) == desc) then return rules[i] end
  end
  for i = #rules, 1, -1 do
    if rules[i].output == "" then return rules[i] end
  end
end
xdr = "Apple Computer Inc ProDisplayXDR 0x0A110A08"
studio = "Apple Computer Inc StudioDisplay 0x1114"
lg = "LG Electronics LG HDR 4K 209NTUWDD710"
plug("eDP-1", "", { description = "Apple Computer Inc Apple Panel 9201b950" })
'
run_lua "apple = true $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
-- Plugged in after the rules loaded, on any port.
check(rule_for("eDP-1", "").cm == "edid", "gives the built-in panel EDID color")
check(rule_for("DP-1", xdr).cm == "edid" and rule_for("DP-1", xdr).scale == "auto", "gives a Pro Display XDR EDID color and the shared settings")
check(rule_for("DP-4", studio).cm == "edid", "gives a Studio Display EDID color")
check(rule_for("DP-2", lg).cm ~= "edid", "leaves another monitor on sRGB")
' || fail "Apple displays get EDID color, other monitors keep sRGB"
pass "Apple displays get EDID color, other monitors keep sRGB"

# The panel'"'"'s port-named rules carry no cm: they get EDID color only on an
# Apple display, and keep a cm chosen in monitors.lua for the description or
# for every monitor. Port rules still beat the copies of a later "" rule.
run_lua "apple = true $wide_gamut"'
plug("DP-2", "", { description = xdr })
plug("DP-3", "", { description = lg })
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "DP-2", scale = 2 })
hl.monitor({ output = "DP-3", scale = 2 })
check(rule_for("DP-2", xdr).cm == "edid" and rule_for("DP-2", xdr).scale == 2, "gives an Apple display'"'"'s port rule EDID color")
check(rule_for("DP-3", lg).cm == "srgb", "leaves another monitor'"'"'s port rule on sRGB")
hl.monitor({ output = "", scale = 1.5 })
check(rule_for("DP-2", xdr).scale == 2, "keeps a port rule ahead of a later rule for every monitor")
check(rule_for("DP-1", studio).scale == 1.5 and rule_for("DP-1", studio).cm == "edid", "copies a later rule for every monitor to the Apple displays")
hl.monitor({ output = "DP-3", scale = 2, cm = "edid" })
check(rule_for("DP-3", lg).cm == "edid", "keeps a color choice of its own")
hl.monitor({ output = "desc:Apple Computer Inc ProDisplayXDR", cm = "dcip3" })
hl.monitor({ output = "DP-2", scale = 2 })
check(rule_for("DP-2", xdr).cm == "dcip3", "keeps the cm chosen for the description, got " .. tostring(rule_for("DP-2", xdr).cm))
hl.monitor({ output = "", cm = "srgb" })
check(rule_for("DP-1", studio).cm == "srgb" and rule_for("eDP-1", "").cm == "srgb", "keeps the cm chosen for every monitor")
hl.monitor({ output = "", scale = 1.5 })
check(rule_for("DP-1", studio).cm == "srgb", "keeps the cm chosen for every monitor through a later shared rule")
' || fail "port rules get EDID color only on Apple displays"
pass "port rules get EDID color only on Apple displays"

# A port rule loaded before its Apple display was plugged in gets EDID color
# once the display arrives.
run_lua "apple = true $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "DP-2", scale = 2 })
check(rule_for("DP-2", xdr).cm == "srgb", "has no display to check before it is plugged in")
plug("DP-2", "", { description = xdr })
handlers["monitor.added"]({ name = "DP-2" })
check(rule_for("DP-2", xdr).cm == "edid" and rule_for("DP-2", xdr).scale == 2, "gives the port rule EDID color once the display arrives")
local count = #applied
handlers["monitor.added"]({ name = "DP-2" })
check(#applied == count, "leaves the rule alone when nothing changed")
-- Swapped for another monitor on the same port: the merged rule must not keep edid.
monitors[#monitors].description = lg
handlers["monitor.added"]({ name = "DP-2" })
check(rule_for("DP-2", lg).cm == "srgb" and rule_for("DP-2", lg).scale == 2, "puts the port back on sRGB for another monitor")
' || fail "port rules wait for their monitor"
pass "port rules wait for their monitor"

# Description rules get EDID color for the monitors they match, connected now
# or plugged in later.
run_lua "apple = true $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "desc:Apple Computer Inc Apple Panel", scale = 2 })
check(rule_for("eDP-1", "Apple Computer Inc Apple Panel 9201b950").cm == "edid" and rule_for("eDP-1", "Apple Computer Inc Apple Panel 9201b950").scale == 2,
  "gives a description rule for the built-in panel EDID color")
hl.monitor({ output = "desc:LG Electronics", scale = 1 })
check(rule_for("DP-3", lg).cm == "srgb", "leaves a description rule for another monitor on sRGB")
hl.monitor({ output = "desc:Apple Computer Inc", scale = 2 })
plug("DP-2", "", { description = xdr })
handlers["monitor.added"]({ name = "DP-2" })
check(rule_for("DP-2", xdr).cm == "edid", "gives a broad description rule EDID color once an XDR arrives")
' || fail "description rules get EDID color on Apple displays"
pass "description rules get EDID color on Apple displays"

# A description rule that matches no connected display gets EDID color once an
# Apple display it matches arrives (DP-5 has no rule of its own). A port rule
# with its own cm still wins over a description rule loaded before it.
run_lua "apple = true $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "desc:Apple Computer Inc Pro", scale = 2 })
hl.monitor({ output = "DP-2", scale = 1.5, cm = "srgb" })
plug("DP-2", "", { description = xdr })
handlers["monitor.added"]({ name = "DP-2" })
check(rule_for("DP-2", xdr).cm == "srgb" and rule_for("DP-2", xdr).scale == 1.5, "keeps a later port rule ahead of a rechecked description rule")
check(rule_for("DP-5", xdr).cm == "edid", "gives a rechecked description rule EDID color")
hl.monitor({ output = "desc:Apple Computer Inc ProDisplayXDR", cm = "srgb" })
plug("DP-4", "", { description = studio })
hl.monitor({ output = "desc:Apple Computer Inc", scale = 2 })
check(rule_for("DP-4", studio).cm == "edid", "keeps one display'"'"'s cm off a broader description rule")
' || fail "description rules are rechecked on hotplug and yield to port rules"
pass "description rules are rechecked on hotplug and yield to port rules"

# The replay keeps every field of a port rule, as Hyprland merges them.
run_lua "apple = true $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "eDP-1", mode = "3456x2234@120" })
hl.monitor({ output = "eDP-1", scale = 2 })
hl.monitor({ output = "", mode = "preferred", scale = 1.5 })
local rule = rule_for("eDP-1", "Apple Computer Inc Apple Panel 9201b950")
check(rule.mode == "3456x2234@120" and rule.scale == 2 and rule.cm == "edid", "keeps an earlier mode through a later rule for every monitor")
' || fail "replayed port rules keep every field"
pass "replayed port rules keep every field"

run_lua "apple = false $wide_gamut"'
hl.monitor({ output = "", mode = "preferred", scale = "auto" })
hl.monitor({ output = "DP-2", scale = 2 })
check(#applied == 2 and applied[1].cm == nil and applied[2].cm == nil, "changes no rule off Apple Silicon")
' || fail "monitors keep sRGB off Apple Silicon"
pass "monitors keep sRGB off Apple Silicon"
