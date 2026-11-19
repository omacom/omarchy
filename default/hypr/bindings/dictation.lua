local paths = require("default.hypr.paths")

local function shipped_adapter(backend)
  local file = io.open(paths.omarchy_path .. "/bin/omarchy-dictation-" .. backend, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Dictation keys are bound only once the chosen backend is installed: built-in
-- backends ship their adapter with Omarchy, so check the backend's own program
-- to release Right Alt (AltGr) and Alt + Space when its package is removed;
-- custom backends may provide only an omarchy-dictation-<backend> adapter.
-- Personal bindings.lua dictation keys use the same check.
function o.dictation_installed()
  local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
  local backend = pipe and pipe:read("*l")
  if pipe then
    pipe:close()
  end
  if not backend or not backend:match("^[%w%-]+$") then
    return false
  end
  if shipped_adapter(backend) then
    return not o.cmd_missing(backend)
  end
  return not o.cmd_missing("omarchy-dictation-" .. backend)
end

if o.dictation_installed() then
  o.bind("ALT + SPACE", "Toggle dictation", "omarchy-dictation toggle")
  -- A modifier's mask changes between its press and release. Match the keysym
  -- independently of that mask; AltGr layouts use a different keysym.
  o.bind_hold("ALT + Alt_R", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { ignore_mods = true })
end
