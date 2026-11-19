-- Tags floating-bounds.lua puts on floating windows for the dock, which hides
-- for a window carrying one as it would for a maximized window. Only
-- floating-bounds takes them off again, as the window is moved or resized, so
-- with Drag Snap off nothing would: toggles.lua clears them on every load
-- that leaves it off.

local M = {
  -- Kept at full size behind a window maximized over it.
  behind = "omarchy-maximized-behind",
  -- Snapped to half the screen.
  snapped = "omarchy-snapped",
}

M.all = { M.behind, M.snapped }

function M.clear()
  local cleared = false
  for _, tag in ipairs(M.all) do
    for _, window in ipairs(hl.get_windows({ tag = tag }) or {}) do
      hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag, window = window }))
      cleared = true
    end
  end

  -- A tag raises no Hyprland event, so the dock is asked to read its windows.
  if cleared then
    hl.exec_cmd("omarchy-shell -q omarchy.dock refreshWindows")
  end
end

return M
