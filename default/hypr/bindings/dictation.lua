-- Dictation keys are bound only once the chosen backend's own program is
-- installed (Omarchy ships every adapter), so a selected backend that was
-- removed doesn't hold Right Alt (AltGr) or Alt + Space for nothing.
-- Personal bindings.lua dictation keys use the same check.
local paths = require("default.hypr.paths")

local function default_dictation()
  local file = io.open(paths.config_home .. "/omarchy/defaults/dictation", "r")
  if not file then
    return nil
  end

  local backend = file:read("*l")
  file:close()

  if backend and backend:match("^[a-z0-9][a-z0-9-]*$") then
    return backend
  end

  return nil
end

function o.dictation_installed()
  local backend = default_dictation()
  return backend ~= nil and not o.cmd_missing(backend)
end

if o.dictation_installed() then
  o.bind("ALT + SPACE", "Toggle dictation", "omarchy-dictation toggle")
  -- A modifier's mask changes between its press and release. Match the keysym
  -- independently of that mask.
  local hold = { ignore_mods = true }
  local keys = { "ALT + Alt_R" }

  -- Where Right Alt types characters as AltGr, it records only once held alone
  -- past the repeat delay, which any other key cancels. Hyprland resolves binds
  -- against the first layout, so Right Alt is ISO_Level3_Shift when an AltGr
  -- layout leads and Alt_R when one sits behind US. The press half doesn't
  -- consume the key, or AltGr + 2 would be a partial match that swallows the 2.
  if require("default.hypr.keyboard").altgr() then
    hold.long_press, hold.non_consuming = true, true
    table.insert(keys, "ISO_Level3_Shift")
  end

  for _, key in ipairs(keys) do
    o.bind_hold(key, "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop", hold)
  end
end
