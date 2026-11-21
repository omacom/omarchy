-- Same terminal tag test as clipboard.lua.
local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

-- Keep the desktop shortcut independent of Fcitx's custom switching keys.
-- Read the live Fcitx group so setup works without a compositor reload.
o.bind("SUPER + I", "Switch input language", "omarchy-input-method cycle")
o.bind("SUPER + SHIFT + I", "Switch input language back", "omarchy-input-method cycle back")

-- Pass the tmux/Herdr prefix through and return to direct input, so the next
-- key reaches the multiplexer instead of the engine's composition.
o.bind("CTRL + SPACE", "Direct input for the terminal prefix", function()
  if active_window_is_terminal() then
    -- Wait for the local controller reply before dispatching the next key.
    o.shell_succeeds("timeout 0.3 fcitx5-remote --check -c")
  end
end, { non_consuming = true })

-- On Mac keyboards the Globe key reaches the compositor as XF86Fn (kernel
-- KEY_FN), unbound by default. Bind it to the same language switch as
-- SUPER + I, matching the XF86* hardware-keysym precedent.
o.bind("XF86Fn", "Switch input language with the Globe key", "omarchy-input-method cycle")
