-- Require every *.lua file in a directory in sorted order.
-- Used for Omarchy extension-style folders such as default/hypr/apps,
-- default/hypr/bindings, and ~/.local/state/omarchy/toggles/hypr.
-- Pass a module prefix for normal package.path modules, e.g.
--   require_all.files(paths.omarchy_path .. "/default/hypr/apps", "default.hypr.apps")
-- Pass nil as the prefix when the directory itself has been added to package.path.
-- Pass options.exclude as a set of base names (without ".lua") to skip; a legacy
-- file that must never be loaded as code stays on disk for a migration to remove.

local M = {}

local function shell_quote(path)
  return "'" .. path:gsub("'", "'\\''") .. "'"
end

function M.files(dir, module_prefix, options)
  local probe = io.open(dir, "r")
  if not probe then
    return
  end
  probe:close()

  local exclude = options and options.exclude or {}
  local handle = io.popen(
    "for f in " .. shell_quote(dir) .. "/*.lua; do [ -f \"$f\" ] && [ ! -L \"$f\" ] && printf '%s\\n' \"${f##*/}\"; done 2>/dev/null"
  )
  if handle then
    for filename in handle:lines() do
      local name = filename:gsub("%.lua$", "")
      if not exclude[name] then
        local module = name
        if module_prefix then
          module = module_prefix .. "." .. module
        end

        if options and options.reload then
          package.loaded[module] = nil
        end

        require(module)
      end
    end
    handle:close()
  end
end

return M
