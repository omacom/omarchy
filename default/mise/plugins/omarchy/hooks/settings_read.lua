local settings = require("settings")

-- Reports the current value of each declared key mise asks about. A key
-- Omarchy has no setting for is left out, so it shows as unset and
-- SettingsWrite explains it.
function PLUGIN:SettingsRead(ctx)
  local values = {}
  for _, key in ipairs(ctx.keys) do
    local setting = settings.by_key[key]
    if setting then
      values[key] = setting.read()
    end
  end
  return { values = values }
end
