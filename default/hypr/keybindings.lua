-- Collect bindings in the real compositor, as they are registered. The menu
-- reads metadata and invokes the retained action; it never reloads user Lua.
local M = {}

local function json_string(value)
  return '"' .. tostring(value):gsub('[%z\1-\31\\"]', function(char)
    return string.format('\\u%04x', string.byte(char))
  end) .. '"'
end

-- Hyprland 0.56.2 dereferences expired handles in is_enabled(). Its tostring
-- implementation checks the weak reference first, so test expiry before any
-- property/method access. Removed bindings must also release their closures.
local function enabled(handle)
  if tostring(handle) == "HL.Keybind(expired)" then return nil end
  return handle:is_enabled()
end

function M.install()
  local previous = _G.omarchy_keybindings
  local bind = hl.bind
  if previous and bind == previous.bind then
    bind = previous.original_bind
  end

  -- A new Lua state can reuse both callback IDs and counters after a reload.
  -- A per-load token also rejects selections from a previous compositor.
  local file = assert(io.open('/proc/sys/kernel/random/uuid', 'r'))
  local generation = assert(file:read('*l'))
  file:close()
  local entries, action_ids = {}, setmetatable({}, { __mode = "k" })
  local next_id = 0
  local next_action = 0
  local registry = { original_bind = bind }

  function registry.bind(keys, action, options)
    local handle = bind(keys, action, options)
    if handle then
      if not action_ids[action] then
        next_action = next_action + 1
        action_ids[action] = next_action
      end
      next_id = next_id + 1
      entries[next_id] = { handle = handle, action = action, identity = action_ids[action] }
    end
    return handle
  end

  function registry.snapshot()
    local rows = {}
    local ids = {}
    for id, entry in pairs(entries) do
      if enabled(entry.handle) == nil then
        entries[id] = nil -- Release removed bindings and their captured closures.
      else
        ids[#ids + 1] = id
      end
    end
    table.sort(ids)
    for _, id in ipairs(ids) do
      local entry = entries[id]
      local handle = entry.handle
      if enabled(handle) and handle.description and handle.description ~= '' then
        rows[#rows + 1] = string.format(
          '{"id":%d,"identity":%d,"keys":%s,"description":%s,"submap":%s}',
          id, entry.identity, json_string(handle.display_key),
          json_string(handle.description), json_string(handle.submap or ''))
      end
    end
    return '{"generation":' .. json_string(generation) .. ',"bindings":[' .. table.concat(rows, ',') .. ']}'
  end

  function registry.invoke(token, id)
    assert(token == generation, 'Keybindings changed; reopen the menu')
    local entry = entries[id]
    assert(entry and enabled(entry.handle), 'Keybinding was removed or disabled; reopen the menu')
    return hl.dispatch(entry.action)
  end

  hl.bind = registry.bind
  _G.omarchy_keybindings = registry
end

return M
