-- Exercise only the production cursor module, without private phase assertions.
local root = os.getenv("CURSOR_TEST_SOURCE_ROOT") or os.getenv("ROOT")
local env = { OMARCHY_PATH = root, HYPRLAND_INSTANCE_SIGNATURE = "monitorless-test", XCURSOR_THEME = "Adwaita", XCURSOR_PATH = "/usr/share/icons", XCURSOR_SIZE = "24" }
os.getenv = function(key) return env[key] end
local events, timers, monitors = {}, {}, {}
local config = { invisible = false, enable_hyprcursor = false, sync_gsettings_theme = true }
hl = {
  on = function(event, callback) events[event] = callback end,
  env = function(key, value) env[key] = value end,
  get_monitors = function() return monitors end,
  get_config = function(key) return config[key:match("%.(.+)")] end,
  config = function(values) for key, value in pairs(values.cursor) do config[key] = value end end,
  timer = function(callback, options) timers[options.timeout] = callback end,
  exec_cmd = function() end,
}
o = { shell_quote = function(value) return "'" .. value .. "'" end }
local function load_cursor() dofile(root .. "/default/hypr/startup-cursor.lua") end
load_cursor()
events["config.reloaded"]()
omarchy_startup_cursor_restore(true)
if timers[600] then timers[600]() end
assert(not config.invisible, "initial reveal must complete")
-- A completed compositor can temporarily have no monitors (dock unplug).
-- A configuration reload must not be mistaken for a new compositor boot.
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
timers = {}
load_cursor()
events["config.reloaded"]()
assert(not omarchy_startup_cursor_pending and not config.invisible,
  "a monitorless reload restarted startup hiding after the reveal completed")
-- An inherited marker belongs to the previous compositor, not a new login.
env.HYPRLAND_INSTANCE_SIGNATURE = "another-session"
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
load_cursor()
events["config.reloaded"]()
assert(omarchy_startup_cursor_pending and config.invisible,
  "a new compositor must still hide its startup cursor")
-- Lua loss before completion must still re-arm the existing recovery path.
omarchy_startup_cursor_pending, omarchy_startup_cursor = nil, nil
config.invisible, config.enable_hyprcursor, config.sync_gsettings_theme = false, false, true
load_cursor()
events["config.reloaded"]()
assert(omarchy_startup_cursor_pending and config.invisible and timers[15000],
  "an interrupted reveal must retain recovery after Lua loss")
print("completed monitorless reload preserves visible cursor")
