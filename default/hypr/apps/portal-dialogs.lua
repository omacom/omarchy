local requests = {}

local function chooser_for(window)
  for i = #requests, 1, -1 do
    local request = requests[i]
    local dialog = request.dialog
    if window == request.requester and dialog.mapped and not dialog.hidden and dialog.workspace == window.workspace then
      return dialog
    end
  end
end

-- Lua cannot read the Wayland parent. Use the window that has focus before
-- the chooser takes it, and only pair windows on the same workspace.
hl.on("window.open_early", function(dialog)
  if dialog.class ~= "xdg-desktop-portal-gtk" then return end

  local requester = hl.get_active_window()
  if requester and requester.floating and not requester.pinned and requester.workspace == dialog.workspace then
    requests[#requests + 1] = { requester = requester, dialog = dialog }
  end
end)

hl.on("window.close", function(window)
  for i = #requests, 1, -1 do
    local request = requests[i]
    if window == request.dialog or window == request.requester then
      table.remove(requests, i)
    end
  end
end)

hl.on("window.active", function(window)
  if not chooser_for(window) then return end

  -- Hyprland raises a clicked floating window after the focus event.
  hl.timer(function()
    if hl.get_active_window() ~= window or not window.floating or window.pinned then return end
    if not window.workspace or not window.workspace.visible then return end

    local dialog = chooser_for(window)
    if not dialog then return end

    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = dialog }))
    hl.dispatch(hl.dsp.focus({ window = dialog }))
  end, { type = "oneshot", timeout = 1 })
end)
