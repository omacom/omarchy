-- Hide the pointer on a cold start until the shell reveals the desktop. Only cursor.invisible
-- changes: with Hyprcursor off at startup, Hyprland 0.56 crashes when the pointer returns (#16941).
function omarchy_startup_cursor_restore()
  if not omarchy_startup_cursor_pending then return end
  omarchy_startup_cursor_pending = false
  hl.env("OMARCHY_STARTUP_CURSOR_SESSION", "")
  hl.config({ cursor = { invisible = omarchy_startup_cursor_invisible } })
end

hl.on("config.reloaded", function()
  if omarchy_startup_cursor_pending == nil then
    -- A reload starts a fresh Lua state, so a pending reveal is remembered in the compositor environment.
    local session = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
    local interrupted = session ~= nil and os.getenv("OMARCHY_STARTUP_CURSOR_SESSION") == session
    omarchy_startup_cursor_pending = #hl.get_monitors() == 0 or interrupted
    omarchy_startup_cursor_invisible = hl.get_config("cursor.invisible")
  end
  if omarchy_startup_cursor_pending then
    hl.env("OMARCHY_STARTUP_CURSOR_SESSION", os.getenv("HYPRLAND_INSTANCE_SIGNATURE"))
    hl.config({ cursor = { invisible = true } })
    hl.timer(omarchy_startup_cursor_restore, { timeout = 15000, type = "oneshot" })
  end
end)
