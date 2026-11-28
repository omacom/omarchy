-- Backends may supply their own desktop integration without editing the
-- user's Hyprland config. Recording bindings remain owned by Omarchy.
local paths = require("default.hypr.paths")
local file = io.open(paths.config_home .. "/omarchy/defaults/dictation", "r")
if not file then
  return
end

local backend = file:read("*l")
file:close()

if not backend or not backend:match("^[a-z0-9][a-z0-9-]*$") or o.cmd_missing("omarchy-dictation-" .. backend) then
  return
end

local integration = paths.config_home .. "/" .. backend .. "/shortcuts.lua"
local file = io.open(integration, "r")
if file then
  file:close()
  local ok, error = pcall(dofile, integration)
  if not ok then
    print("Could not load dictation backend " .. backend .. ": " .. tostring(error))
  end
end
