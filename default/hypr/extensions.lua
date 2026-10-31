-- Load every *.lua file in ~/.config/hypr/extensions/, in name order. An add-on
-- installs by dropping (or symlinking) a file there and uninstalls by deleting
-- it, without editing the user's Hyprland config, which `omarchy refresh
-- hyprland` would overwrite. They load after Omarchy's defaults, so they can
-- rebind its keys, and before the user's own files, which still have the last
-- word. One that fails to load is skipped with an on-screen error, so it can't
-- take the user's own bindings down with it.

local paths = require("default.hypr.paths")

local dir = paths.config_home .. "/hypr/extensions"
local handle = io.popen("find -L " .. o.shell_quote(dir) .. " -mindepth 1 -maxdepth 1 -type f -name '*.lua' 2>/dev/null | LC_ALL=C sort")
if not handle then
  return
end

for path in handle:lines() do
  local ok, error = pcall(dofile, path)
  if not ok then
    hl.notification.create({ text = "Could not load Hyprland extension " .. path .. ": " .. tostring(error), timeout = 10000, icon = "error" })
  end
end
handle:close()
