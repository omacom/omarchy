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
