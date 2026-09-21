-- Apply the menu preference after the user's input config without rewriting it.
local paths = require("default.hypr.paths")
local file = io.open(paths.state_home .. "/omarchy/caps-lock", "r")
if not file then
  return
end

local mode = file:read("*l")
file:close()
if mode ~= "normal" and mode ~= "compose" then
  return
end

local options = {}
for option in (hl.get_config("input.kb_options") or ""):gmatch("[^,]+") do
  option = option:match("^%s*(.-)%s*$")
  -- Remove options involving Caps Lock, including Ctrl/Compose remaps and
  -- the both-Shift shortcut. Keep layout switching and other keys intact.
  if not option:find("caps", 1, true) then
    table.insert(options, option)
  end
end
table.insert(options, mode == "normal" and "caps:capslock" or "compose:caps")
hl.config({ input = { kb_options = table.concat(options, ",") } })
