-- Keep menu edits separate from hand-written bindings. The original chord,
-- description and occurrence identify a declaration across config reloads.
local paths = require("default.hypr.paths")
local overrides, occurrences, handles = {}, {}, {}
local state_file = paths.state_home .. "/omarchy/keybindings.tsv"

local file = io.open(state_file, "r")
if file then
  for line in file:lines() do
    local id, chord = line:match("^([0-9a-f]+:%d+)\t(.*)$")
    if id and (chord == "" or chord:match("^[A-Z +]*code:%d+$")) then
      overrides[id] = chord
    end
  end
  file:close()
end

local function binding_id(keys, description)
  local identity = (keys .. "\0" .. (description or "")):gsub(".", function(byte)
    return string.format("%02x", byte:byte())
  end)
  occurrences[identity] = (occurrences[identity] or 0) + 1
  return identity .. ":" .. occurrences[identity]
end

local M = {}

function M.bind(keys, action, options)
  local id = binding_id(keys, options.description)
  local chord = overrides[id] or keys
  if chord == "" then return end

  local handle = hl.bind(chord, action, options)
  -- The menu's Lua scan uses a stub. Only live handles have a compositor ID.
  if type(handle) == "userdata" then
    handles[#handles + 1] = { id = id, handle = handle }
  end
end

function M.export(path)
  local output = assert(io.open(path, "w"))
  for _, entry in ipairs(handles) do
    local handle = entry.handle
    if tostring(handle) ~= "HL.Keybind(expired)" and handle.enabled and handle.submap == ""
        and not handle.mouse and not handle.key:match("^mouse:") then
      -- Hyprland exposes the same Lua dispatcher reference through IPC.
      local key = handle.keycode > 0 and ("code:" .. handle.keycode) or handle.key
      output:write(handle.arg, "\t", entry.id, "\t", key, "\n")
    end
  end
  assert(output:close())
end

return M
