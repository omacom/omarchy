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
local events, recovery, reveal, command, commands, imported = {}, nil, nil, nil, {}, false
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
    assert(options.type == "oneshot")
    if options.timeout == 15000 then
      recovery = callback
    else
      assert(options.timeout > 500, "outlast the compositor's 500ms cursor visibility check")
      reveal = callback
    end
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
local state_file = os.getenv("XDG_RUNTIME_DIR") .. "/omarchy-startup-cursor-test-instance-a.state"
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
assert(config.invisible and not command:match("my%-hyprcursor"), "stay hidden until the compositor has applied the hide")
assert(env.OMARCHY_STARTUP_CURSOR_SESSION == "test-instance-a", "a reload before the cursor is shown must still find the reveal pending")
assert(env.OMARCHY_STARTUP_CURSOR == "test-instance-a:pending" and io.open(state_file, "r"), "the pending phase and snapshot must survive the redraw delay")
local interrupted_reveal = reveal
omarchy_startup_cursor_restore(true)
assert(reveal == interrupted_reveal, "duplicate completion must not reschedule the redraw")
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
dofile(os.getenv("ROOT") .. "/default/hypr/startup-cursor.lua")
events["config.reloaded"]()
interrupted_reveal()
assert(omarchy_startup_cursor_pending and config.invisible and io.open(state_file, "r"), "an old reveal callback must not finish a fresh Lua-state recovery")
recovery()
omarchy_startup_cursor_restore(true)
reveal()
assert(env.OMARCHY_STARTUP_CURSOR == "test-instance-a:done", "mark startup done only after the delayed reveal")
assert(not config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme)
assert(env.OMARCHY_STARTUP_CURSOR_SESSION == "", "a shown cursor ends the startup reveal")
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
reveal()
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
capture:write("xcursor=cursor-a\npath=/icons-a\nsize=24\ninvisible=false\nenable_hyprcursor=true\nsync_gsettings_theme=true\nhyprcursor=\n")
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
local other_file = os.getenv("XDG_RUNTIME_DIR") .. "/omarchy-startup-cursor-test-instance-b.state"
assert(io.open(other_file, "r") and io.open(state_file, "r"), "two startups must keep separate captures")
omarchy_startup_cursor_restore(true)
reveal()
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
reveal()

-- A leftover capture in a healthy session (e.g. from a crash before the
-- reveal) must never hide the pointer of a later reload.
local stale = io.open(state_file, "w")
stale:write("xcursor=my-xcursor\npath=/my/icons\nsize=24\ninvisible=false\nenable_hyprcursor=true\nsync_gsettings_theme=true\nhyprcursor=\n")
stale:close()
omarchy_startup_cursor_pending = nil
monitors = { {} }
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and not config.invisible, "installing the fix in a running compositor must leave its cursor alone")
assert(not io.open(state_file, "r"), "a healthy reload must drop a stale capture")

-- An exported empty path is valid. Losing this snapshot would recapture
-- invisible=true from the temporary startup config and never show the pointer.
env.XCURSOR_PATH, env.XCURSOR_THEME = "", "empty-path-theme"
env.OMARCHY_STARTUP_CURSOR = "previous-instance:done"
config.invisible, config.enable_hyprcursor, config.sync_gsettings_theme = false, true, true
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = {}
events["config.reloaded"]()
assert(config.invisible, "startup must initially hide the pointer")
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = { {} }
events["config.reloaded"]()
assert(omarchy_startup_cursor.path == "" and not omarchy_startup_cursor.config.invisible,
  "empty paths must preserve the original visible cursor settings across reload")
omarchy_startup_cursor_restore(true)
reveal()
assert(not config.invisible and config.enable_hyprcursor and config.sync_gsettings_theme,
  "the resumed empty-path reveal must restore visibility and original settings")
assert(not io.open(state_file, "r"), "empty-path recovery must clean up its snapshot")

-- Snapshot content is data, never a Lua program, even in a pending session.
local malicious = assert(io.open(state_file, "w"))
malicious:write("_G.snapshot_executed = true; return { xcursor = 'injected', path = '/injected', size = 24 }\n")
malicious:close()
env.OMARCHY_STARTUP_CURSOR = "test-instance-a:pending"
env.XCURSOR_THEME, env.XCURSOR_PATH = "safe-theme", "/safe/icons"
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
events["config.reloaded"]()
assert(not snapshot_executed and omarchy_startup_cursor.xcursor == "safe-theme", "executable or invalid snapshots must fall back without executing their content")
omarchy_startup_cursor_restore(true)
reveal()

-- Escaped separators and percent signs round-trip without splitting records.
env.XCURSOR_THEME, env.XCURSOR_PATH = "theme%=value", "/icons%\nwith\rnewlines=here"
env.OMARCHY_STARTUP_CURSOR = "old-session:done"
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = {}
events["config.reloaded"]()
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = { {} }
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "theme%=value" and omarchy_startup_cursor.path == "/icons%\nwith\rnewlines=here", "snapshot escaping must preserve cursor strings exactly across reloads")
omarchy_startup_cursor_restore(true)
reveal()

for _, invalid in ipairs({ "xcursor=bad%escape", "xcursor=injected\nxcursor=duplicate" }) do
  local file = assert(io.open(state_file, "w"))
  file:write(invalid .. "\npath=/injected\nsize=24\ninvisible=false\nenable_hyprcursor=true\nsync_gsettings_theme=true\n")
  file:close()
  env.XCURSOR_THEME, env.XCURSOR_PATH = "safe-theme", "/safe/icons"
  env.OMARCHY_STARTUP_CURSOR = "test-instance-a:pending"
  omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
  events["config.reloaded"]()
  assert(omarchy_startup_cursor.xcursor == "safe-theme", "malformed escapes and duplicate fields must invalidate the snapshot")
  omarchy_startup_cursor_restore(true)
  reveal()
end

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
reveal()
assert(not config.invisible and config.sync_gsettings_theme)
assert(orphan(nil) == "custom-cursor", "recover a nonblank user GSettings theme when no snapshot survives")
omarchy_startup_cursor_restore(true)
reveal()
gsettings = "'omarchy-startup'\n"
assert(orphan(nil) == "default", "a destroyed user preference must fall back to the default alias, never the blank theme")
omarchy_startup_cursor_restore(true)
reveal()
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
monitors = {}
env.XCURSOR_THEME, env.XCURSOR_PATH = "next-theme", "/next/icons"
env.OMARCHY_STARTUP_CURSOR_PATH = "/stale/icons"
env.OMARCHY_STARTUP_CURSOR_SESSION = "old-session"
env.OMARCHY_STARTUP_CURSOR = "old-session:done"
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "next-theme" and omarchy_startup_cursor.path == "/next/icons", "a new session must honor changed cursor settings instead of inherited snapshots")
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
env.XCURSOR_THEME, env.OMARCHY_STARTUP_CURSOR_SESSION, gsettings = "", "old-session", "'custom-cursor'\n"
env.OMARCHY_STARTUP_CURSOR = "old-session:done"
events["config.reloaded"]()
assert(omarchy_startup_cursor.xcursor == "default", "an ordinary boot without a cursor theme keeps the default alias instead of adopting GSettings")
io.popen = popen
LUA
lua "$lua_test"
pass "the first compositor frame starts blank and the reveal restores user cursor settings"
