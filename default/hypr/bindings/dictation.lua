-- Dictation keys are bound only once the chosen backend's own program is
-- installed (Omarchy ships every adapter), so a selected backend that was
-- removed doesn't hold Right Alt or Alt + Space for nothing.
-- Personal bindings.lua dictation keys use the same check.
local keyboard = require("default.hypr.keyboard")

function o.dictation_installed()
  local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
  local backend = pipe and pipe:read("*l")
  if pipe then
    pipe:close()
  end
  return backend ~= nil and backend:match("^[%w%-]+$") ~= nil and not o.cmd_missing(backend)
end

if o.dictation_installed() then
  o.bind("ALT + SPACE", "Toggle dictation", "omarchy-dictation toggle")
  -- Right Alt is AltGr on the layouts keyboard.right_alt_is_altgr names.
  -- Hyprland still resolves this bind as the first layout's Alt_R, so the
  -- hold would start dictation instead of typing level 3. Alt + Space stays.
  if not keyboard.right_alt_is_altgr() then
    o.bind_hold("ALT + Alt_R", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { ignore_mods = true })
  end
end
