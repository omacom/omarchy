-- Write the keyboard briefs o.keyboard_brief() collected from the user's
-- hypr/input.lua to state, where the top bar's keyboard layout widget reads
-- them. Required after the user's files, so it sees what their input.lua
-- collected; a reload re-runs it and clears briefs the user's file stopped
-- collecting.

local paths = require("default.hypr.paths")

local BRIEFS_FILE = paths.state_home .. "/omarchy/keyboard/briefs"

local function read_briefs()
  local file = io.open(BRIEFS_FILE, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()
  return content
end

local function write_briefs(content)
  local file = io.open(BRIEFS_FILE, "w")
  if not file then
    os.execute("mkdir -p " .. o.shell_quote(paths.state_home .. "/omarchy/keyboard"))
    file = io.open(BRIEFS_FILE, "w")
  end

  if file then
    file:write(content)
    file:close()
  end
end

local overrides = o.keyboard_briefs or {}

local keys = {}
for key in pairs(overrides) do
  table.insert(keys, key)
end
table.sort(keys)

local lines = {}
for _, key in ipairs(keys) do
  lines[#lines + 1] = key .. "\t" .. overrides[key] .. "\n"
end
local content = table.concat(lines)

-- Nothing to write and nothing on disk: leave it there. An empty override set
-- clears what an earlier load wrote, so removing a call from hypr/input.lua
-- removes its brief on the next reload.
if content == "" then
  os.remove(BRIEFS_FILE)
  return
end

-- Rewriting on every reload churns the file the shell watches for nothing, so
-- only write what changed on disk.
if content == read_briefs() then
  return
end

write_briefs(content)
