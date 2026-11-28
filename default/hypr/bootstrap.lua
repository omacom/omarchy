-- Hyprland bootstrap for Omarchy's Lua module path.

local home = os.getenv("HOME")
local reload_prefixes = {
  "default.hypr",
  "hypr",
  "omarchy.current.theme",
}

local function should_reload_module(module)
  for _, prefix in ipairs(reload_prefixes) do
    if module == prefix or module:sub(1, #prefix + 1) == prefix .. "." then
      return true
    end
  end

  return false
end

local modules_to_reload = {}
for module in pairs(package.loaded) do
  if should_reload_module(module) then
    table.insert(modules_to_reload, module)
  end
end

for _, module in ipairs(modules_to_reload) do
  package.loaded[module] = nil
end

-- Load generated state from ~/.local/state, user modules from ~/.config, and
-- Omarchy defaults from $OMARCHY_PATH.
package.path = home
  .. "/.local/state/?.lua;"
  .. home
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy")
  .. "/?.lua;"
  .. package.path

-- Guard personal overrides under ~/.config/hypr/ so a syntax error, runtime
-- error, or deleted override file never aborts the rest of hyprland.lua (later
-- overrides and default.hypr.toggles). Lives here rather than in the user's
-- hyprland.lua so existing installs get the protection automatically without
-- rewriting their personal config.
local function report_override_error(module, err)
  local message = "Could not load " .. module .. ": " .. tostring(err)
  if io and io.stderr then
    io.stderr:write(message .. "\n")
  else
    print(message)
  end
end

local function load_override_safely(module)
  if module:sub(1, 5) ~= "hypr." then
    return nil
  end

  local path = package.searchpath(module, package.path)
  if not path then
    return function()
      return true
    end
  end

  local chunk, err = loadfile(path)
  if not chunk then
    report_override_error(module, err)
    return function()
      return true
    end
  end

  return function(name, file)
    local ok, result = pcall(chunk, name, file)
    if not ok then
      report_override_error(name, result)
      return true
    end
    if result == nil then
      return true
    end
    return result
  end, path
end

local searchers = package.searchers or package.loaders
if searchers then
  local replaced = false
  if _G.__omarchy_override_searcher then
    for index, searcher in ipairs(searchers) do
      if searcher == _G.__omarchy_override_searcher then
        searchers[index] = load_override_safely
        replaced = true
        break
      end
    end
  end
  if not replaced then
    table.insert(searchers, 2, load_override_safely)
  end
  _G.__omarchy_override_searcher = load_override_safely
end
