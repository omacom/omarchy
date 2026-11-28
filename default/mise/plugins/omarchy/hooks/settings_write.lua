local settings = require("settings")

-- Writes the keys whose value differs. Every change is checked before the
-- first one is written, so a typo in one key leaves the desktop as it was.
function PLUGIN:SettingsWrite(ctx)
  for _, change in ipairs(ctx.changes) do
    local setting = settings.by_key[change.key]
    if not setting then
      error("omarchy has no setting named " .. change.key .. "; it has " .. settings.names, 0)
    end
    setting.check(change.key, change.to)
  end

  for _, change in ipairs(ctx.changes) do
    settings.by_key[change.key].write(change.to)
  end
end
