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

-- Exercise the current helpers, including the terminal closure and table-based
-- shell shortcuts. The registry must invoke their real action, not a command
-- reconstructed from the description or o.bind_commands.
package.path = arg[1] .. '/?.lua;' .. package.path
local executed, focused = nil, { pid = 42 }
hl.exec_cmd = function(command) executed = command end
hl.get_active_window = function() return focused end
hl.dsp = {
  exec_cmd = function(command) return function() executed = command end end,
  global = function(name) return function() executed = 'global:' .. name end end,
}
require('default.hypr.helpers')
module.install()
registry = omarchy_keybindings
o.bind('SUPER + RETURN', 'Terminal', o.launch_terminal())
token = registry.snapshot():match('"generation":"([%x-]+)"')
focused = { pid = 84 }
registry.invoke(token, 1)
assert(executed == 'omarchy-launch-terminal --pid=84', executed)
focused = nil
registry.invoke(token, 1)
assert(executed == 'omarchy-launch-terminal', executed)
print('ok - the retained terminal closure reads the focused pid at invocation')

local shortcuts = {
  { { menu = 'root' }, 'menu.root' },
  { { panel = 'omarchy.audio' }, 'panel.omarchy.audio' },
  { { audio = 'raise' }, 'audio.raise' },
  { { brightness = 'raise' }, 'brightness.raise' },
  { { ipc = 'notifications.dismissOne' }, 'ipc.notifications.dismissOne' },
}
for index, shortcut in ipairs(shortcuts) do
  o.bind('SUPER + F' .. index, shortcut[2], shortcut[1])
  registry.invoke(token, index + 1)
  assert(executed == 'global:omarchy:' .. shortcut[2], executed)
end
print('ok - current menu, panel, media, brightness and notification actions retain global dispatch')
