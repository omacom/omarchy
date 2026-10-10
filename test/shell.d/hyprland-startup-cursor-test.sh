#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

lua - <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local events, recovery, command = {}, nil, nil
local config = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true }
local user_config = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true }
local env = { XCURSOR_THEME = "my-xcursor", HYPRCURSOR_THEME = "my-hyprcursor", XCURSOR_PATH = "/my/icons", HYPRLAND_INSTANCE_SIGNATURE = "first-session" }
local getenv = os.getenv
os.getenv = function(name) return env[name] or getenv(name) end
local monitors = {}
hl = {
  on = function(event, callback) events[event] = callback end,
  get_monitors = function() return monitors end,
  get_config = function(key) return config[key:match("%.(.+)")] end,
  env = function(name, value) env[name] = value end,
  config = function(values)
    for name, value in pairs(values.cursor) do config[name] = value end
  end,
  timer = function(callback, options)
    assert(options.timeout == 15000 and options.type == "oneshot")
    recovery = callback
  end,
  exec_cmd = function(value)
    if value == "omarchy-launch-shell" then
      assert(config.invisible and env.XCURSOR_THEME == "my-xcursor", "hide the compositor cursor while restoring application settings before launch")
    end
    command = value
  end,
}
o = { shell_quote = function(value) return "'" .. value .. "'" end, launch = function(value) return value end }

require("default.hypr.autostart")
assert(not config.invisible, "loading the module must wait for user configuration")
events["config.reloaded"]()
assert(config.invisible and not config.enable_hyprcursor and not config.sync_gsettings_theme)
assert(env.XCURSOR_THEME == "omarchy-startup" and env.XCURSOR_PATH:match("/default/hypr/cursors:/my/icons$"))
assert(omarchy_startup_cursor_pending, "the first compositor frame must use the blank cursor")
events["hyprland.start"]()
assert(env.XCURSOR_THEME == "my-xcursor" and env.XCURSOR_PATH == "/my/icons", "applications must inherit the user's cursor")
assert(config.invisible, "starting applications must not reveal the cursor")

-- Hyprland reloads into a fresh Lua state; only the compositor's environment survives.
local function reload()
  omarchy_startup_cursor_pending, omarchy_startup_cursor, omarchy_startup_cursor_restore = nil, nil, nil
  package.loaded["default.hypr.autostart"], package.loaded["default.hypr.startup-cursor"] = nil, nil
  events = {}
  for name, value in pairs(user_config) do config[name] = value end
  require("default.hypr.autostart")
  events["config.reloaded"]()
end

-- Monitors are up by the time anything can ask for a reload.
monitors = { {} }
local previous_recovery = recovery
reload()
assert(recovery ~= previous_recovery and config.invisible, "a config reload must retain startup hiding and rearm recovery")
assert(omarchy_startup_cursor_pending and env.XCURSOR_THEME == "my-xcursor", "a reload must not hand the blank theme to applications")
recovery()
assert(command:match("setcursor 'my%-xcursor'"), "restore the Xcursor fallback before revealing the pointer")
assert(config.invisible, "wait for the normal theme before restoring visibility")
omarchy_startup_cursor_restore(true)
assert(not config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme)
assert(command:match("setcursor 'my%-hyprcursor'"), "restore the user's Hyprcursor theme")
local previous_command = command
previous_recovery()
assert(command == previous_command, "recovery must not change a revealed cursor")
reload()
assert(not config.invisible and env.XCURSOR_THEME == "my-xcursor", "ordinary config reloads must not hide the cursor")
monitors = {}
reload()
assert(not omarchy_startup_cursor_pending and not config.invisible, "a reload while every monitor is gone must not hide the cursor")

env.HYPRLAND_INSTANCE_SIGNATURE = "second-session"
reload()
assert(omarchy_startup_cursor_pending and config.invisible, "a new compositor must ignore the previous session's startup phase")

env.OMARCHY_STARTUP_CURSOR, env.XCURSOR_THEME, env.XCURSOR_PATH = nil, "my-xcursor", "/my/icons"
monitors = { {} }
reload()
assert(not omarchy_startup_cursor_pending and not config.invisible, "installing the fix in a running compositor must leave its cursor alone")
assert(env.XCURSOR_THEME == "my-xcursor" and env.XCURSOR_PATH == "/my/icons", "installing the fix must leave the application cursor alone")
assert(env.OMARCHY_STARTUP_CURSOR == "second-session:done", "a running compositor is past its startup")
LUA
pass "the first compositor frame starts blank and the reveal restores user cursor settings"
