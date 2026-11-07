#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

lua - <<'LUA' || fail "a cold start hides the pointer without touching Hyprcursor, and the reveal restores it"
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local events, recovery = {}, nil
local defaults = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true }
local config = {}
local env = { HYPRLAND_INSTANCE_SIGNATURE = "test-session", OMARCHY_PATH = os.getenv("ROOT") }
local getenv = os.getenv
os.getenv = function(name)
  if name:match("CURSOR") or name == "HYPRLAND_INSTANCE_SIGNATURE" then return env[name] end
  return env[name] or getenv(name)
end
local monitors = {}
hl = {
  on = function(event, callback) events[event] = callback end,
  get_monitors = function() return monitors end,
  get_config = function(key) return config[key:match("%.(.+)")] end,
  env = function(name, value)
    assert(name == "OMARCHY_STARTUP_CURSOR_SESSION", "only the reveal marker may change the environment, never a cursor theme: " .. name)
    env[name] = value
  end,
  config = function(values)
    for name, value in pairs(values.cursor) do
      assert(name == "invisible", "only cursor.invisible may change; Hyprcursor must load its style when Hyprland starts: " .. name)
      config[name] = value
    end
  end,
  timer = function(callback, options)
    assert(options.timeout == 15000 and options.type == "oneshot")
    recovery = callback
  end,
  exec_cmd = function() end,
}
o = { shell_quote = function(value) return "'" .. value .. "'" end, launch = function(value) return value end }

-- Hyprland reloads the configuration in a fresh Lua state: globals and timers
-- are gone and every option is back to the user's value.
local function reload(user)
  omarchy_startup_cursor_pending, omarchy_startup_cursor_invisible, recovery = nil, nil, nil
  for name, value in pairs(defaults) do config[name] = value end
  for name, value in pairs(user or {}) do config[name] = value end
  dofile(os.getenv("ROOT") .. "/default/hypr/startup-cursor.lua")
  events["config.reloaded"]()
end

require("default.hypr.autostart")
for name, value in pairs(defaults) do config[name] = value end
assert(not config.invisible, "loading the module must wait for user configuration")
events["config.reloaded"]()
assert(config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme, "a cold start hides the pointer and leaves Hyprcursor on")
events["hyprland.start"]()
assert(config.invisible, "starting applications must not reveal the pointer")

monitors = { {} }
reload()
assert(config.invisible and recovery, "a reload before the reveal keeps the pointer hidden and rearms the timeout")
omarchy_startup_cursor_restore()
assert(not config.invisible and env.OMARCHY_STARTUP_CURSOR_SESSION == "", "the reveal shows the pointer and clears the marker")
config.invisible = true
recovery()
assert(config.invisible, "the timeout must not change a revealed pointer")

reload()
assert(not config.invisible and not omarchy_startup_cursor_pending, "an ordinary reload must not hide the pointer")

env.OMARCHY_STARTUP_CURSOR_SESSION = "old-session"
reload()
assert(not config.invisible, "a marker left by another session must not hide the pointer")

monitors = {}
reload({ invisible = true })
assert(config.invisible)
recovery()
assert(config.invisible, "the reveal restores a pointer the user hid themselves as hidden")

reload()
recovery()
assert(not config.invisible, "the timeout reveals the pointer when the shell never does")
LUA
pass "a cold start hides the pointer without touching Hyprcursor, and the reveal restores it"
