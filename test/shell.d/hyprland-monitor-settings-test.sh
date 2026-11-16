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
