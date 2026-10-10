#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

# The restore persists its capture here so a reload that wipes Lua state can
# pick it back up. Keep it hermetic: never touch the session runtime dir.
export XDG_RUNTIME_DIR
XDG_RUNTIME_DIR="$(mktemp -d)"
lua_test="$(mktemp)"
trap 'rm -rf "$XDG_RUNTIME_DIR" "$lua_test"' EXIT

# NOTE: lua 5.5 exits 0 on errors in programs read from stdin, which would
# mask every assertion below. Run the program from a file so failures fail.
cat >"$lua_test" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local events, recovery, command, commands = {}, nil, nil, {}
local config = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true }
local env = { OMARCHY_PATH = os.getenv("ROOT"), HYPRLAND_INSTANCE_SIGNATURE = "test-instance-a", XCURSOR_THEME = "my-xcursor", HYPRCURSOR_THEME = "my-hyprcursor", XCURSOR_PATH = "/my/icons" }
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
    table.insert(commands, value)
  end,
}
o = { shell_quote = function(value) return "'" .. value .. "'" end, launch = function(value) return value end }

require("default.hypr.autostart")
assert(not config.invisible, "loading the module must wait for user configuration")
events["config.reloaded"]()
assert(config.invisible and not config.enable_hyprcursor and not config.sync_gsettings_theme)
assert(env.XCURSOR_THEME == "omarchy-startup" and env.XCURSOR_PATH:match("/default/hypr/cursors:/my/icons$"))
assert(omarchy_startup_cursor_pending, "the first compositor frame must use the blank cursor")
local state_file = os.getenv("XDG_RUNTIME_DIR") .. "/omarchy-startup-cursor-test-instance-a.lua"
assert(io.open(state_file, "r"), "the capture must survive a reload that wipes Lua state")

-- A reload while the restore is pending (e.g. monitor-watch recovering a
-- still-waking display) wipes Lua state but keeps compositor config and
-- environment. Fresh state must pick the restore back up from the capture
-- instead of stranding the blank theme.
omarchy_startup_cursor_pending = nil
omarchy_startup_cursor = nil
monitors = { {} }
events["config.reloaded"]()
assert(omarchy_startup_cursor_pending, "a wiped pending restore must resume while the blank theme is still set")
assert(omarchy_startup_cursor.xcursor == "my-xcursor", "the resumed restore must use the captured theme, not the blank one")
assert(config.invisible and not config.sync_gsettings_theme, "resuming must re-hide the compositor cursor until the reveal")
monitors = {}

events["hyprland.start"]()
assert(env.XCURSOR_THEME == "my-xcursor" and env.XCURSOR_PATH == "/my/icons", "applications must inherit the user's cursor")
assert(config.invisible, "starting applications must not reveal the cursor")

local previous_recovery = recovery
omarchy_startup_cursor_pending = nil
omarchy_startup_cursor = nil
monitors = { {} }
events["config.reloaded"]()
assert(omarchy_startup_cursor_pending and omarchy_startup_cursor.xcursor == "my-xcursor", "a fresh Lua state after application startup must recover the pending reveal")
assert(recovery ~= previous_recovery and config.invisible, "a config reload must retain startup hiding and rearm recovery")
recovery()
assert(command:match("setcursor 'my%-xcursor'"), "restore the Xcursor fallback before revealing the pointer")
assert(config.invisible, "wait for the normal theme before restoring visibility")
omarchy_startup_cursor_restore(true)
assert(not config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme)
assert(command:match("setcursor 'my%-hyprcursor'"), "restore the user's Hyprcursor theme")
assert(not io.open(state_file, "r"), "a revealed cursor must drop its capture so later reloads stay untouched")
assert(commands[#commands - 1]:match("xsetroot %-cursor_name left_ptr"), "restore the X11/XWayland root cursor after a Lua-state reload")
local previous_command = command
previous_recovery()
assert(command == previous_command, "recovery must not change a revealed cursor")
events["config.reloaded"]()
assert(not config.invisible and env.XCURSOR_THEME == "my-xcursor", "ordinary config reloads must not hide the cursor")

-- Without a Hyprcursor theme (plain Xcursor session) the reveal must still
-- run setcursor with the captured theme so GSettings re-syncs off the blank
-- one instead of persisting it.
omarchy_startup_cursor_pending = true
omarchy_startup_cursor = {
  config = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true },
  hyprcursor = nil,
  size = 24,
  path = "/my/icons",
  xcursor = "my-xcursor",
}
command = nil
omarchy_startup_cursor_restore(true)
assert(not config.invisible and config.sync_gsettings_theme)
assert(command:match("setcursor 'my%-xcursor'"), "restore the Xcursor fallback when the Hyprcursor theme is unset")
assert(not io.open(state_file, "r"), "the fallback reveal must drop its capture too")

-- A fresh state after reveal stays done, even with all monitors unplugged.
omarchy_startup_cursor_pending = nil
omarchy_startup_cursor = nil
monitors = {}
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and not config.invisible, "a completed startup must not restart on a monitorless reload")

-- An independent compositor must not overwrite or remove A's capture.
local capture = assert(io.open(state_file, "w"))
capture:write("return { xcursor = 'cursor-a', path = '/icons-a', size = 24 }\n")
capture:close()
env.HYPRLAND_INSTANCE_SIGNATURE = "test-instance-b"
env.OMARCHY_STARTUP_CURSOR = "test-instance-a:pending"
package.loaded["default.hypr.startup-cursor"] = nil
require("default.hypr.startup-cursor")
omarchy_startup_cursor_pending = nil
monitors = { {} }
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and io.open(state_file, "r"), "a healthy compositor B must leave A's capture alone")
omarchy_startup_cursor_pending = nil
monitors = {}
events["config.reloaded"]()
local other_file = os.getenv("XDG_RUNTIME_DIR") .. "/omarchy-startup-cursor-test-instance-b.lua"
assert(io.open(other_file, "r") and io.open(state_file, "r"), "two startups must keep separate captures")
omarchy_startup_cursor_restore(true)
assert(not io.open(other_file, "r") and io.open(state_file, "r"), "revealing B must not remove A's capture")
env.HYPRLAND_INSTANCE_SIGNATURE = "test-instance-a"
env.OMARCHY_STARTUP_CURSOR = "test-instance-a:pending"
package.loaded["default.hypr.startup-cursor"] = nil
require("default.hypr.startup-cursor")
omarchy_startup_cursor_pending = nil
monitors = { {} }
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "cursor-a" and omarchy_startup_cursor.path == "/icons-a", "A must recover its own cursor after B reveals")
omarchy_startup_cursor_restore(true)

-- A leftover capture in a healthy session (e.g. from a crash before the
-- reveal) must never hide the pointer of a later reload.
local stale = io.open(state_file, "w")
stale:write("return { xcursor = 'my-xcursor', path = '/my/icons', size = 24 }\n")
stale:close()
omarchy_startup_cursor_pending = nil
monitors = { {} }
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and not config.invisible, "installing the fix in a running compositor must leave its cursor alone")
assert(not io.open(state_file, "r"), "a healthy reload must drop a stale capture")
LUA
lua "$lua_test"
pass "the first compositor frame starts blank and the reveal restores user cursor settings"
