local paths = require("default.hypr.paths")
if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-rog-ally")) then
  local panels = {}
  for _, namespace in ipairs({ "omarchy-menu", "omarchy-dock-apps" }) do
    panels[namespace] = hl.layer_rule({
      name = namespace .. "-ally-keyboard-order",
      match = { namespace = "^" .. namespace .. "$" },
      order = 1,
      enabled = false,
    })
  end

  local function first_line(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local line = file:read("*l")
    file:close()
    return line
  end

  local function owned_keyboard_pid()
    local runtime, display = os.getenv("XDG_RUNTIME_DIR"), os.getenv("WAYLAND_DISPLAY")
    local session = display and display:match("([^/]+)$")
    if not runtime or runtime == "" or not (session and session:match("^[%w_.-]+$")) then return nil end
    local record = first_line(runtime .. "/omarchy-desktop-keyboard-" .. session .. "/process")
    if not record then return nil end
    local pid, started = record:match("^(%d+) (%d+) .+$")
    if not pid then return nil end
    -- Use the compositor's layer PID and verify when that process started.
    local stat = first_line("/proc/" .. pid .. "/stat")
    local current = stat and stat:match(".*%) " .. string.rep("%S+ ", 19) .. "(%d+) ")
    return current == started and tonumber(pid) or nil
  end

  local function keyboard_output(closing)
    local pid = owned_keyboard_pid()
    if not pid then return nil end
    local output, other = nil, {}
    for _, layer in ipairs(hl.get_layers({ namespace = "wvkbd" })) do
      local monitor = layer.monitor
      if layer ~= closing and layer.mapped and monitor then
        if layer.pid == pid then
          if not monitor.name:match("^eDP%-%d+$") or (output and output ~= monitor) then return nil end
          output = monitor
        else
          other[monitor.name] = true
        end
      end
    end
    return output and not other[output.name] and output or nil
  end

  local function panel_on_output(namespace, output, focused, closing)
    local found = false
    for _, layer in ipairs(hl.get_layers({ namespace = namespace })) do
      -- Read the real monitor once the compositor has allocated the layer,
      -- including its initial commit before exclusive keyboard focus.
      if layer ~= closing and (layer.mapped or layer.keyboard_interactivity == 0) then
        if layer.monitor ~= output then return false end
        found = true
      end
    end
    return found or focused == output
  end

  local function sync_keyboard_order(focused, closing)
    local output = keyboard_output(closing)
    if output and #hl.get_monitors() > 1 then
      hl.exec_cmd(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-toggle-desktop-keyboard") .. " hide")
      output = nil
    end
    focused = focused or hl.get_active_monitor()
    for namespace, rule in pairs(panels) do
      local enabled = output ~= nil and panel_on_output(namespace, output, focused, closing)
      if rule:is_enabled() ~= enabled then rule:set_enabled(enabled) end
    end
  end

  local function panel_or_keyboard(layer)
    return panels[layer.namespace] ~= nil or layer.namespace == "wvkbd"
  end

  sync_keyboard_order()
  hl.on("monitor.focused", sync_keyboard_order)
  hl.on("monitor.added", function() sync_keyboard_order() end)
  hl.on("monitor.removed", function() sync_keyboard_order() end)
  hl.on("layer.opened", function(layer)
    if panel_or_keyboard(layer) then sync_keyboard_order() end
  end)
  hl.on("layer.closed", function(layer)
    if panel_or_keyboard(layer) then sync_keyboard_order(nil, layer) end
  end)
end
