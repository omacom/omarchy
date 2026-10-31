-- Send with explicit mods to the focused surface by omitting the window target,
-- so universal clipboard shortcuts reach both normal windows and focused
-- layer-shell surfaces such as Omarchy panels. A virtual keyboard (wtype) won't
-- do: the physically held SUPER merges into the injected chord at the seat.
-- The down/up split works around Hyprland send_shortcut sometimes leaving
-- synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- Lean on window tags so there's one definition of what counts as a terminal
-- (default/hypr/apps/terminals.lua) or as an app that binds the Super chords
-- itself (opted in by the user). Dynamic tags carry a trailing "*".
local function active_window_has_tag(name)
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == name then
      return true
    end
  end

  return false
end

-- Apps the user tags native-super-clipboard get the Super chord itself, since
-- translating it would take away a shortcut they already handle. No app is
-- tagged by default: stock Emacs and Doom bind these chords only on macOS.
local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
  return function()
    if active_window_has_tag("native-super-clipboard") then
      send_shortcut_once("SUPER", default_key)()
    elseif terminal_mods and active_window_has_tag("terminal") then
      send_shortcut_once(terminal_mods, terminal_key)()
    else
      send_shortcut_once(default_mods, default_key)()
    end
  end
end

o.bind("SUPER + A", "Select all", universal_clipboard_shortcut("CTRL", "A"))
o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL SHIFT", "C"))
o.bind("SUPER + V", "Universal paste", universal_clipboard_shortcut("CTRL", "V", "CTRL SHIFT", "V"))
o.bind("SUPER + X", "Universal cut", universal_clipboard_shortcut("CTRL", "X"))
o.bind("SUPER + CTRL + V", "Clipboard manager", { panel = "omarchy.clipboard" })
