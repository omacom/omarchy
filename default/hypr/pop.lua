-- Hyprland moves a floating window to another monitor at the same offset from its origin,
-- so a popped-out window (Super+O) would land off-center or off a smaller screen.

local function popped(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag == "pop" then
      return true
    end
  end

  return false
end

local function geometry_file(address)
  local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
  if not runtime_dir or runtime_dir == "" then
    return nil
  end

  local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""
  return runtime_dir .. "/omarchy/windows/" .. signature .. "/pop-" .. address .. "-geometry"
end

-- A dispatcher move fires this before the window lands, while window.monitor is still
-- the one it is leaving, so the center waits a loop. A mouse drag has already landed.
hl.on("window.move_to_workspace", function(window, workspace)
  if not (window and workspace and window.monitor and workspace.monitor) then return end
  if window.monitor.id == workspace.monitor.id or not popped(window) then return end

  local target = "address:" .. window.address
  hl.timer(function()
    hl.dispatch(hl.dsp.window.center({ window = target }))
  end, { timeout = 1, type = "oneshot" })
end)

-- Popping a floating window records its original geometry in the session runtime
-- directory. Remove that file when the window closes without being unpopped.
hl.on("window.destroy", function(window)
  if window and window.address then
    local path = geometry_file(window.address)
    if path then
      os.remove(path)
    end
  end
end)
