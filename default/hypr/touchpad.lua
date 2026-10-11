-- Touchpad settings managed by Setup > Config > Touchpad (omarchy-setup-touchpad).
--
-- The tool stores what the user changed in ~/.config/omarchy/touchpad.json.
-- The file is data, never Lua: every key is checked against the schema below
-- and anything unknown or out of range is dropped.
--
-- The file is the source of truth for whatever it sets. apply() runs from
-- default/hypr/toggles.lua, after ~/.config/hypr/input.lua, so a value saved
-- here beats the same option set by hand there; keys absent from the file keep
-- whatever input.lua or Omarchy's defaults chose. watch() runs before the
-- user's files so gestures they add can be replaced by gestures saved here.
--
-- apply() runs at config load and again through `hyprctl eval` whenever the tool
-- saves, so it must be safe to repeat in one Lua state: gestures and window
-- rules it added earlier are removed before the new set goes in.

local paths = require("default.hypr.paths")
local json = require("default.hypr.json")

local M = {}

-- Hardcoded to ~/.config like the shell and the sibling bash tools, which all
-- write there regardless of XDG_CONFIG_HOME.
M.path = paths.home .. "/.config/omarchy/touchpad.json"

-- Where connected input devices are listed. Read as a plain file, since asking
-- Hyprland through hyprctl from inside its own config load would deadlock.
M.input_devices_path = "/proc/bus/input/devices"

local function boolean()
  return { type = "boolean" }
end

local function number(min, max)
  return { type = "number", min = min, max = max }
end

local function integer(min, max)
  return { type = "integer", min = min, max = max }
end

local function enum(...)
  local values = {}
  for _, value in ipairs({ ... }) do
    values[value] = true
  end
  return { type = "enum", values = values }
end

-- Options Hyprland accepts under input.touchpad, and per device.
M.touchpad_schema = {
  natural_scroll = boolean(),
  scroll_factor = number(0.05, 5),
  tap_to_click = boolean(),
  tap_button_map = enum("lrm", "lmr"),
  clickfinger_behavior = boolean(),
  middle_button_emulation = boolean(),
  disable_while_typing = boolean(),
  tap_and_drag = boolean(),
  drag_lock = integer(0, 2),
  drag_3fg = integer(0, 2),
  flip_x = boolean(),
  flip_y = boolean(),
}

-- Options that only exist globally under input, where they would also change
-- every mouse. They are applied per touchpad device instead.
M.pointer_schema = {
  sensitivity = number(-1, 1),
  accel_profile = enum("adaptive", "flat"),
  left_handed = boolean(),
  scroll_method = enum("2fg", "edge", "on_button_down", "no_scroll"),
}

M.gesture_settings_schema = {
  workspace_swipe_distance = integer(50, 2000),
  workspace_swipe_invert = boolean(),
  workspace_swipe_create_new = boolean(),
  workspace_swipe_forever = boolean(),
  workspace_swipe_cancel_ratio = number(0, 1),
  workspace_swipe_min_speed_to_force = integer(0, 200),
  workspace_swipe_direction_lock = boolean(),
}

M.directions = {
  swipe = true,
  horizontal = true,
  vertical = true,
  left = true,
  right = true,
  up = true,
  down = true,
  pinch = true,
  pinchin = true,
  pinchout = true,
}

M.modifiers = { SUPER = true, ALT = true, CTRL = true, SHIFT = true }

local function dispatch(dispatcher)
  return function()
    hl.dispatch(dispatcher)
  end
end

local function command(cmd)
  return function()
    hl.dispatch(hl.dsp.exec_cmd(cmd))
  end
end

-- Gesture actions by the name the tool stores. Native actions follow the
-- finger continuously; the rest fire once when the swipe completes.
M.actions = {
  workspace = { action = "workspace" },
  move = { action = "move" },
  resize = { action = "resize" },
  special = { action = "special", workspace_name = "scratchpad" },
  close = { action = "close" },
  fullscreen = { action = "fullscreen" },
  maximize = { action = "fullscreen", mode = "maximize" },
  float = { action = "float" },
  zoom = { action = "cursorZoom", zoom_level = 2, mode = "live" },
  scroll_move = { action = "scroll_move" },
  focus_left = { fn = function() return dispatch(hl.dsp.focus({ direction = "l" })) end },
  focus_right = { fn = function() return dispatch(hl.dsp.focus({ direction = "r" })) end },
  focus_up = { fn = function() return dispatch(hl.dsp.focus({ direction = "u" })) end },
  focus_down = { fn = function() return dispatch(hl.dsp.focus({ direction = "d" })) end },
  workspace_next = { fn = function() return dispatch(hl.dsp.focus({ workspace = "e+1" })) end },
  workspace_previous = { fn = function() return dispatch(hl.dsp.focus({ workspace = "e-1" })) end },
  menu = { fn = function() return command("omarchy-menu toggle root") end },
  notifications = { fn = function() return command("omarchy-shell notifications showHistory") end },
}

-- Omarchy's default per-app touchpad scroll speeds. A saved "apps" list
-- replaces these entirely, so removing a row in the tool removes the rule.
M.default_apps = {
  { match = "(Alacritty|kitty)", scroll = 1.5 },
  -- foot only applies its scrollback multiplier to wheel clicks, not precise touchpad scrolling.
  { match = "foot", scroll = 2.0 },
  { match = "com.mitchellh.ghostty", scroll = 0.2 },
}

local function valid_text(value, limit)
  return type(value) == "string" and value ~= "" and #value <= limit and not value:find("%c")
end

local function check(spec, value)
  if spec.type == "boolean" then
    return type(value) == "boolean"
  elseif spec.type == "number" then
    return type(value) == "number" and value == value and value >= spec.min and value <= spec.max
  elseif spec.type == "integer" then
    return type(value) == "number" and value == math.floor(value) and value >= spec.min and value <= spec.max
  elseif spec.type == "enum" then
    return type(value) == "string" and spec.values[value] == true
  end

  return false
end

local function pick(source, ...)
  local result = {}
  if type(source) ~= "table" or json.is_array(source) then
    return result
  end

  for _, schema in ipairs({ ... }) do
    for key, spec in pairs(schema) do
      local value = source[key]
      if value ~= nil and check(spec, value) then
        if spec.type == "integer" then
          value = math.tointeger(value)
        end
        result[key] = value
      end
    end
  end

  return result
end

local function sorted_keys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function gesture_spec(binding)
  if type(binding) ~= "table" or json.is_array(binding) then
    return nil
  end

  local fingers = binding.fingers
  if type(fingers) ~= "number" or fingers ~= math.floor(fingers) or fingers < 2 or fingers > 5 then
    return nil
  end

  if not M.directions[binding.direction] then
    return nil
  end

  local action = M.actions[binding.action]
  if not action then
    return nil
  end

  local spec = { fingers = math.tointeger(fingers), direction = binding.direction }

  if binding.mods ~= nil and binding.mods ~= "" then
    if not M.modifiers[binding.mods] then
      return nil
    end
    spec.mods = binding.mods
  end

  if type(binding.scale) == "number" and binding.scale >= 0.1 and binding.scale <= 10 then
    spec.scale = binding.scale
  end

  if action.fn then
    spec.action = action.fn()
  else
    for key, value in pairs(action) do
      spec[key] = value
    end
  end

  if binding.action == "special" and valid_text(binding.workspace_name, 64) and binding.workspace_name:match("^[%w_%-]+$") then
    spec.workspace_name = binding.workspace_name
  end

  return spec
end

-- Directions each direction also claims, mirroring Hyprland's shadowing rule.
local covers = {
  swipe = { swipe = true, horizontal = true, vertical = true, left = true, right = true, up = true, down = true },
  horizontal = { horizontal = true, left = true, right = true },
  vertical = { vertical = true, up = true, down = true },
  pinch = { pinch = true, pinchin = true, pinchout = true },
}

local function overlaps(a, b)
  return a == b or (covers[a] and covers[a][b]) or (covers[b] and covers[b][a]) or false
end

-- Hyprland refuses a gesture an earlier one shadows, and reports it as a config
-- error even under pcall, so drop those here, as the window flags them. Two
-- finger swipes are left to scrolling.
local function usable(spec, earlier)
  if spec.fingers == 2 and not covers.pinch[spec.direction] then
    return false
  end

  for _, other in ipairs(earlier) do
    if other.fingers == spec.fingers and (other.mods or "") == (spec.mods or "")
      and overlaps(other.direction, spec.direction) then
      return false
    end
  end

  return true
end

-- Read and validate the settings file. A missing or unreadable file is the
-- same as an empty one: every setting stays on Omarchy's defaults.
function M.read(path)
  local data, err = json.decode_file(path or M.path)
  if err then
    print("Ignoring malformed " .. (path or M.path) .. ": " .. err)
  end
  if type(data) ~= "table" or json.is_array(data) then
    data = {}
  end

  local settings = {
    touchpad = pick(data.touchpad, M.touchpad_schema),
    pointer = pick(data.touchpad, M.pointer_schema),
    devices = {},
    gesture_settings = {},
    gestures = {},
    apps = nil,
  }

  if type(data.devices) == "table" and not json.is_array(data.devices) then
    for _, name in ipairs(sorted_keys(data.devices)) do
      if valid_text(name, 256) then
        settings.devices[#settings.devices + 1] = {
          name = name,
          settings = pick(data.devices[name], M.touchpad_schema, M.pointer_schema),
        }
      end
    end
  end

  local gestures = data.gestures
  if type(gestures) == "table" and not json.is_array(gestures) then
    settings.gesture_settings = pick(gestures.settings, M.gesture_settings_schema)

    if json.is_array(gestures.bindings) then
      for _, binding in ipairs(gestures.bindings) do
        local spec = gesture_spec(binding)
        if spec and usable(spec, settings.gestures) then
          settings.gestures[#settings.gestures + 1] = spec
        end
      end
    end
  end

  if json.is_array(data.apps) then
    settings.apps = {}
    for _, app in ipairs(data.apps) do
      if type(app) == "table" and valid_text(app.match, 200)
        and type(app.scroll) == "number" and app.scroll >= 0.05 and app.scroll <= 10 then
        settings.apps[#settings.apps + 1] = { match = app.match, scroll = app.scroll }
      end
    end
  end

  return settings
end

-- What this Lua state added on the previous apply, so a live re-apply can
-- take it back out before adding the new set.
local applied = { gestures = {}, rules = {} }

-- Gestures other config added, recorded by watch(), so a saved gesture can
-- take over their swipe instead of being refused as shadowed.
local foreign = {}
local real_gesture = nil

local function gesture_api()
  return real_gesture or hl.gesture
end

local function same_gesture(a, b)
  return a.fingers == b.fingers and a.direction == b.direction and (a.mods or "") == (b.mods or "")
end

-- Record every gesture the rest of the config adds after this point. Hyprland
-- has no way to list gestures, and unsetting one that does not exist is
-- reported as a config error, so only exact recorded swipes are ever unset.
function M.watch()
  if real_gesture or type(hl.gesture) ~= "function" then
    return
  end

  real_gesture = hl.gesture
  hl.gesture = function(spec)
    local result = real_gesture(spec)
    if type(spec) == "table" and type(spec.fingers) == "number" and type(spec.direction) == "string" then
      if spec.action == "unset" then
        for i = #foreign, 1, -1 do
          if same_gesture(foreign[i], spec) then
            table.remove(foreign, i)
          end
        end
      else
        foreign[#foreign + 1] = { fingers = spec.fingers, direction = spec.direction, mods = spec.mods }
      end
    end
    return result
  end
end

local function take_over(gesture)
  for i = #foreign, 1, -1 do
    local other = foreign[i]
    if other.fingers == gesture.fingers and (other.mods or "") == (gesture.mods or "")
      and overlaps(other.direction, gesture.direction) then
      pcall(gesture_api(), { fingers = other.fingers, direction = other.direction, mods = other.mods, action = "unset" })
      table.remove(foreign, i)
    end
  end
end

local function remove_previous()
  for _, gesture in ipairs(applied.gestures) do
    pcall(gesture_api(), { fingers = gesture.fingers, direction = gesture.direction, mods = gesture.mods, action = "unset" })
  end

  for _, rule in ipairs(applied.rules) do
    pcall(function() rule:set_enabled(false) end)
  end

  applied = { gestures = {}, rules = {} }
end

local function merge(...)
  local result = {}
  for _, source in ipairs({ ... }) do
    for key, value in pairs(source) do
      result[key] = value
    end
  end
  return result
end

-- Hyprland names a device by its kernel name, lowercased with spaces turned
-- into dashes, and treats it as a touchpad by the same test as
-- omarchy-hw-touchpad. Hyprland has no device-added event, so a pad first
-- plugged in mid-session picks the shared settings up on the next apply.
function M.connected_touchpads(path)
  local names = {}
  local file = io.open(path or M.input_devices_path, "r")
  if not file then
    return names
  end

  for line in file:lines() do
    local name = line:match('^N: Name="(.*)"$')
    if name then
      name = name:lower():gsub(" ", "-")
      if (name:find("touchpad", 1, true) or name:find("trackpad", 1, true)) and valid_text(name, 256) then
        names[#names + 1] = name
      end
    end
  end
  file:close()

  return names
end

-- Saved devices, plus any connected touchpad the file does not name yet, so
-- shared pointer settings reach every pad and not only those seen at a save.
local function devices_with_connected(devices)
  local result = {}
  local known = {}
  for _, device in ipairs(devices) do
    result[#result + 1] = device
    known[device.name] = true
  end

  for _, name in ipairs(M.connected_touchpads()) do
    if not known[name] then
      result[#result + 1] = { name = name, settings = {} }
      known[name] = true
    end
  end

  return result
end

local function report(what, err)
  print("Touchpad settings: could not apply " .. what .. ": " .. tostring(err))
end

function M.apply(path)
  local settings = M.read(path)

  remove_previous()

  local config = {}
  if next(settings.touchpad) then
    config.input = { touchpad = settings.touchpad }
  end
  if next(settings.gesture_settings) then
    config.gestures = settings.gesture_settings
  end
  if next(config) then
    local ok, err = pcall(hl.config, config)
    if not ok then
      report("options", err)
    end
  end

  for _, device in ipairs(devices_with_connected(settings.devices)) do
    local spec = merge(settings.pointer, device.settings)
    if next(spec) then
      spec.name = device.name
      local ok, err = pcall(hl.device, spec)
      if not ok then
        report(device.name, err)
      end
    end
  end

  for _, gesture in ipairs(settings.gestures) do
    take_over(gesture)
    local ok, err = pcall(gesture_api(), gesture)
    if ok then
      applied.gestures[#applied.gestures + 1] = gesture
    else
      report(gesture.fingers .. "-finger " .. gesture.direction .. " gesture", err)
    end
  end

  for _, app in ipairs(settings.apps or M.default_apps) do
    local ok, rule = pcall(hl.window_rule, { match = { class = app.match }, scroll_touchpad = app.scroll })
    if ok then
      applied.rules[#applied.rules + 1] = rule
    else
      report(app.match .. " scroll speed", rule)
    end
  end

  return settings
end

return M
