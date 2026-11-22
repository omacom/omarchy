-- SUPER + F also fullscreens a popped-out (SUPER + O) window. Hyprland refuses
-- to fullscreen a pinned window, so put it back in the tiles first, the same way
-- omarchy-hyprland-window-pop does, then fullscreen it.

local M = {}

local function fullscreen()
  local window = hl.get_active_window()

  if window and window.pinned then
    local target = "address:" .. window.address
    hl.dispatch(hl.dsp.window.pin({ window = target }))
    if window.floating then
      hl.dispatch(hl.dsp.window.float({ window = target, action = "toggle" }))
    end
    hl.dispatch(hl.dsp.window.tag({ window = target, tag = "-pop" }))
  end

  hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))
end

-- The keybindings menu replays the bind as `hyprctl dispatch 'o.window_fullscreen.toggle()'`.
function M.toggle()
  o.bind_expressions[fullscreen] = "o.window_fullscreen.toggle()"
  return fullscreen
end

o.window_fullscreen = M

return M
