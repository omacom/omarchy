o.bind("SUPER + SPACE", "Omarchy menu", { menu = "root" })
o.bind("SUPER + ALT + SPACE", "Apps menu", { menu = "apps" })
o.bind("SUPER + CTRL + E", "Emojis", { panel = "omarchy.emojis" })
o.bind("SUPER + CTRL + C", "Capture menu", { menu = "capture" })
o.bind("SUPER + CTRL + O", "Toggle menu", { menu = "toggle" })
o.bind("SUPER + CTRL + H", "Hardware menu", { menu = "hardware" })
o.bind("SUPER + SHIFT + code:201", "Omarchy menu", { menu = "root" })
o.bind("SUPER + ESCAPE", "System menu", { menu = "system" })
o.bind("XF86PowerOff", "Power menu", { menu = "system" }, { locked = true })
o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + ALT + K", "Tmux keybindings", "omarchy-menu-tmux-keybindings")
o.bind("SUPER + CTRL + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")
o.bind("SUPER + CTRL + Q", "Calculator", "omacalc")
o.bind("XF86Calculator", "Calculator", "omacalc")

o.bind_toggle("SUPER + SHIFT + SPACE", "Toggle top bar", "bar")
o.bind("SUPER + CTRL + SPACE", "Background switcher", { menu = "background" })
o.bind("SUPER + SHIFT + CTRL + SPACE", "Theme menu", { menu = "theme" })
o.bind("SUPER + BACKSPACE", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", "omarchy-hyprland-window-gaps-toggle")
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", "omarchy-hyprland-window-single-square-aspect-toggle")
o.bind_toggle("SUPER + CTRL + ALT + F", "Toggle full screen desktop", "fullscreen-desktop")

-- xkbcommon names the comma keysym "comma"; the upper-case "COMMA" does not match.
o.bind("SUPER + comma", "Dismiss last notification", { ipc = "notifications.dismissOne" })
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", { ipc = "notifications.dismissAll" })
o.bind_toggle("SUPER + CTRL + comma", "Toggle silencing notifications", "notification-silencing")
o.bind("SUPER + ALT + comma", "Invoke last notification", { ipc = "notifications.invokeLast" })
o.bind("SUPER + SHIFT + ALT + comma", "Open notification history", { ipc = "notifications.showHistory" })

o.bind_toggle("SUPER + CTRL + I", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
o.bind("SUPER + CTRL + Delete", "Toggle laptop display", "omarchy-hyprland-monitor-internal toggle")
o.bind("SUPER + CTRL + ALT + Delete", "Toggle laptop display mirroring", "omarchy-hyprland-monitor-internal-mirror toggle")
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

o.bind("PRINT", "Screenshot", "omarchy-capture-screenshot")
o.bind("ALT + PRINT", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")
o.bind("SUPER + ALT + code:34", "Make webcam overlay smaller", "omarchy-capture-webcam-resize smaller")
o.bind("SUPER + ALT + code:35", "Make webcam overlay larger", "omarchy-capture-webcam-resize larger")
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", "omarchy-capture-text")

-- Keyboard control for the slurp region picker (see omarchy-capture-region).
-- The binds live exactly as long as this command's selection layer is on
-- screen. slurp opens one layer per monitor, so track each layer by address.
local selection_binds = {}

local function is_capture_region_selection(layer)
  if layer.namespace ~= "selection" then
    return false
  end

  local process_root = "/proc/" .. tostring(layer.pid)
  local comm = io.open(process_root .. "/comm", "r")
  if not comm then
    return false
  end

  local name = comm:read("*l")
  comm:close()
  if name ~= "slurp" then
    return false
  end

  local environ = io.open(process_root .. "/environ", "rb")
  if not environ then
    return false
  end

  local values = environ:read("*a") or ""
  environ:close()
  for value in values:gmatch("[^%z]+") do
    if value == "OMARCHY_CAPTURE_REGION_PICKER=1" then
      return true
    end
  end

  return false
end

local capture_region_selection_layers = {}
local capture_region_selection_layer_count = 0

hl.on("layer.opened", function(layer)
  if not is_capture_region_selection(layer) or capture_region_selection_layers[layer.address] then
    return
  end

  capture_region_selection_layers[layer.address] = true
  capture_region_selection_layer_count = capture_region_selection_layer_count + 1

  if capture_region_selection_layer_count == 1 then
    selection_binds = {
      hl.bind("RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-window"), { description = "Capture highlighted window" }),
      hl.bind("CTRL + RETURN", hl.dsp.exec_cmd("omarchy-capture-region --take-fullscreen"), { description = "Capture entire screen" }),
      hl.bind("TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window next"), { description = "Select next window to capture" }),
      hl.bind("CTRL + TAB", hl.dsp.exec_cmd("omarchy-capture-region --select-window prev"), { description = "Select previous window to capture" }),
    }
    for _, direction in ipairs({ "left", "right", "up", "down" }) do
      table.insert(
        selection_binds,
        hl.bind(direction:upper(), hl.dsp.exec_cmd("omarchy-capture-region --select-window " .. direction), { description = "Select window to capture" })
      )
    end
  end
end)

hl.on("layer.closed", function(layer)
  if not capture_region_selection_layers[layer.address] then
    return
  end

  capture_region_selection_layers[layer.address] = nil
  capture_region_selection_layer_count = capture_region_selection_layer_count - 1

  if capture_region_selection_layer_count == 0 then
    for _, keybind in ipairs(selection_binds) do
      keybind:unbind()
    end
    selection_binds = {}
  end
end)

o.bind("SUPER + CTRL + S", "Share", { menu = "share" })

o.bind("SUPER + CTRL + PERIOD", "Transcode", "omarchy-transcode")

o.bind("SUPER + CTRL + R", "Set reminder", { menu = "reminder-set" })
o.bind("SUPER + CTRL + ALT + R", "Show reminders", "omarchy-reminder show")
o.bind("SUPER + SHIFT + CTRL + R", "Clear reminders", "omarchy-reminder clear")

o.bind("SUPER + CTRL + ALT + T", "Show time", "omarchy-notification-time")
o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "omarchy-notification-battery")
o.bind("SUPER + CTRL + ALT + W", "Toggle weather", "omarchy-notification-weather")

o.bind("SUPER + SHIFT + CTRL + A", "Agent", "omarchy-agent --pick")
o.bind("SUPER + CTRL + A", "Audio", { panel = "omarchy.audio" })
o.bind("SUPER + CTRL + B", "Bluetooth", { panel = "omarchy.bluetooth" })
o.bind("SUPER + CTRL + D", "Display", { panel = "omarchy.monitor" })
o.bind("SUPER + CTRL + ALT + D", "Calendar", { panel = "omarchy.clock" })
o.bind("SUPER + CTRL + ALT + E", "World clock", { panel = "omarchy.elsewhen" })
o.bind("SUPER + CTRL + W", "Network", { panel = "omarchy.network" })
o.bind("SUPER + CTRL + P", "Power", { panel = "omarchy.power" })
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

-- The letters above name a panel; the numbers count them. 1 is the leftmost
-- panel in the bar's right section, and a widget with no panel of its own (the
-- tray) is not counted, so the number matches the icon a user would point at.
-- A bar with fewer panels than this leaves the tail of the range doing nothing.
for panel = 1, 9 do
  o.bind(
    "SUPER + CTRL + code:" .. tostring(panel + 9),
    "Bar panel " .. panel,
    "omarchy-shell -q shell togglePanelAt right " .. panel
  )
end

o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

o.bind("SUPER + CTRL + L", "Lock system", "omarchy-system-lock")
