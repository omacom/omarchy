#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

lua - <<'LUA' || fail "the first compositor frame starts blank and the reveal restores user cursor settings"
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local events, recovery, command, imported = {}, nil, nil, false
local config = { invisible = false, enable_hyprcursor = true, sync_gsettings_theme = true }
local env = { XCURSOR_THEME = "my-xcursor", HYPRCURSOR_THEME = "my-hyprcursor", XCURSOR_PATH = "/my/icons", HYPRLAND_INSTANCE_SIGNATURE = "test-session", OMARCHY_PATH = os.getenv("ROOT") }
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
    if value == "dbus-update-activation-environment --systemd XCURSOR_PATH XCURSOR_THEME" then
      assert(env.XCURSOR_THEME ~= "omarchy-startup" and not env.XCURSOR_PATH:match("/default/hypr/cursors"))
      imported = true
    end
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

local previous_recovery = recovery
-- Hyprland reloads the configuration in a fresh Lua state and discards timers.
omarchy_startup_cursor_pending = nil
omarchy_startup_cursor = nil
for name in pairs(config) do config[name] = true end
config.invisible = false
monitors = { {} }
dofile(os.getenv("ROOT") .. "/default/hypr/startup-cursor.lua")
events["config.reloaded"]()
assert(omarchy_startup_cursor_pending and omarchy_startup_cursor.xcursor == "my-xcursor", "a fresh Lua state must retain the pending reveal and the user's cursor")
assert(recovery ~= previous_recovery and config.invisible, "a config reload must retain startup hiding and rearm recovery")
recovery()
assert(command:match("setcursor 'my%-xcursor'"), "restore the Xcursor fallback before revealing the pointer")
assert(config.invisible, "wait for the normal theme before restoring visibility")
omarchy_startup_cursor_restore(true)
assert(not config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme)
assert(command:match("setcursor 'my%-hyprcursor'"), "restore the user's Hyprcursor theme")
local previous_command = command
previous_recovery()
assert(command == previous_command, "recovery must not change a revealed cursor")
events["config.reloaded"]()
assert(not config.invisible and env.XCURSOR_THEME == "my-xcursor", "ordinary config reloads must not hide the cursor")

omarchy_startup_cursor_pending = nil
monitors = { {} }
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and not config.invisible, "installing the fix in a running compositor must leave its cursor alone")

local popen = io.popen
local gsettings = "'custom-cursor'\n"
io.popen = function(value)
  assert(value:match("gsettings get org.gnome.desktop.interface cursor%-theme"))
  return { read = function() return gsettings end, close = function() return true end }
end
local function orphan(theme)
  imported = false
  omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
  env.XCURSOR_THEME = "omarchy-startup"
  env.OMARCHY_STARTUP_CURSOR_THEME = theme
  env.OMARCHY_STARTUP_CURSOR_SESSION = "old-session"
  env.XCURSOR_PATH = "/old/worktree/default/hypr/cursors:/my/icons"
  env.OMARCHY_STARTUP_CURSOR_PATH = nil
  config.invisible, config.enable_hyprcursor, config.sync_gsettings_theme = false, false, true
  dofile(os.getenv("ROOT") .. "/default/hypr/startup-cursor.lua")
  events["config.reloaded"]()
  assert(omarchy_startup_cursor_pending, "an orphan blank theme must be recovered with live monitors")
  assert(env.XCURSOR_THEME ~= "omarchy-startup" and env.XCURSOR_PATH == "/my/icons", "recovery must remove the blank theme and old worktree search path")
  return omarchy_startup_cursor.xcursor
end
assert(orphan("saved-custom") == "saved-custom", "saved settings take precedence over GSettings")
omarchy_startup_cursor_restore()
assert(command:match("setcursor 'saved%-custom'") and imported, "orphan recovery must also repair activation environments")
local stalled = command
command = nil
recovery()
assert(command == stalled, "the timeout must retry an unfinished restore")
local completion = assert(command:match("hyprctl eval '(.*)'$"))
omarchy_startup_cursor.xcursor = "changed-during-restore"
assert(load(completion))()
assert(omarchy_startup_cursor_pending, "a stale completion must not reveal a different cursor after reload")
omarchy_startup_cursor.xcursor = "saved-custom"
local old_size = omarchy_startup_cursor.size
omarchy_startup_cursor.size = old_size + 8
assert(load(completion))()
assert(omarchy_startup_cursor_pending, "a stale completion must not acknowledge a different cursor size")
omarchy_startup_cursor.size = old_size
omarchy_startup_cursor_restore(true)
assert(not config.invisible and config.sync_gsettings_theme)
assert(orphan(nil) == "custom-cursor", "recover a nonblank user GSettings theme when no snapshot survives")
omarchy_startup_cursor_restore(true)
gsettings = "'omarchy-startup'\n"
assert(orphan(nil) == "default", "a destroyed user preference must fall back to the default alias, never the blank theme")
omarchy_startup_cursor_restore(true)
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = {}
env.XCURSOR_THEME, env.XCURSOR_PATH = "next-theme", "/next/icons"
env.OMARCHY_STARTUP_CURSOR_PATH = "/stale/icons"
env.OMARCHY_STARTUP_CURSOR_SESSION = "old-session"
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "next-theme" and omarchy_startup_cursor.path == "/next/icons", "a new session must honor changed cursor settings instead of inherited snapshots")
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
env.XCURSOR_THEME, env.OMARCHY_STARTUP_CURSOR_SESSION, gsettings = "", "old-session", "'custom-cursor'\n"
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "default", "an ordinary boot without a cursor theme keeps the default alias instead of adopting GSettings")
io.popen = popen
LUA
pass "the first compositor frame starts blank and the reveal restores user cursor settings"
