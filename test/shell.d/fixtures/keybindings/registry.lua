local module = dofile(arg[1] .. '/default/hypr/keybindings.lua')
local handles, calls = {}, 0
hl = {
  bind = function(keys, action, opts)
    local handle = { display_key = keys, description = opts and opts.description, enabled = true, submap = '' }
    setmetatable(handle, { __tostring = function(self)
      if self.enabled == nil then return "HL.Keybind(expired)" end
      return "HL.Keybind(live)"
    end })
    function handle:is_enabled()
      assert(self.enabled ~= nil, "expired native handles must not be queried")
      return self.enabled
    end
    handles[#handles + 1] = handle
    return handle
  end,
  dispatch = function(action) return action() end,
}
local original = hl.bind
module.install()
local registry = omarchy_keybindings
local function action() calls = calls + 1; return 'called' end
local first = hl.bind('MOD3 + code:20', action, { description = 'comma, tab\tquote" backslash\\\nUnicode →' })
local second = hl.bind('SUPER + Q', action, { description = 'Same action' })
hl.bind('SUPER + X', function() error('different') end, { description = 'Same action' })
hl.bind('SUPER + Y', function() end) -- Undescribed, excluded.
local snapshot = registry.snapshot()
local token = snapshot:match('"generation":"([%x-]+)"')
assert(token)
assert(snapshot:find('"identity":1', 1, true))
assert(snapshot:find('\\u0009', 1, true) and snapshot:find('\\u0022', 1, true))
assert(snapshot:find('MOD3 + code:20', 1, true))
assert(registry.invoke(token, 1) == 'called' and calls == 1)
second.enabled = false
assert(not registry.snapshot():find('SUPER + Q', 1, true))
assert(not pcall(registry.invoke, token, 2))
second.enabled = true
assert(registry.snapshot():find('SUPER + Q', 1, true))
first.enabled = nil -- Real handles expire when unbound/removed.
assert(not registry.snapshot():find('MOD3', 1, true))
assert(not pcall(registry.invoke, token, 1))
assert(not pcall(registry.invoke, token, 999))
module.install()
assert(omarchy_keybindings.original_bind == original, 'reload must not wrap wrappers')
assert(omarchy_keybindings.snapshot():find('"bindings":[]', 1, true))
hl.bind('SUPER + N', function() calls = calls + 100 end, { description = 'New generation' })
assert(not pcall(omarchy_keybindings.invoke, token, 1), 'stale ID must never invoke new action')
assert(calls == 1)
print('ok - registry keeps real actions, filters disabled/removed bindings, escapes metadata, and rejects stale selections')
print('SNAPSHOT:' .. snapshot)
