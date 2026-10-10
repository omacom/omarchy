-- Hyprland polls cursor.invisible, so its first frames need a blank cursor too.
function omarchy_startup_cursor_restore(loaded)
  if not omarchy_startup_cursor_pending then return end
  local cursor = omarchy_startup_cursor
  if loaded then
    omarchy_startup_cursor_pending = false
    hl.config({ cursor = cursor.config })
    if cursor.config.enable_hyprcursor and cursor.hyprcursor then
      hl.exec_cmd("hyprctl setcursor " .. o.shell_quote(cursor.hyprcursor) .. " " .. cursor.size)
    end
  elseif not cursor.restoring then
    -- Reload the normal Xcursor fallback before enabling Hyprcursor or GSettings.
    cursor.restoring = true
    hl.exec_cmd("hyprctl setcursor " .. o.shell_quote(cursor.xcursor) .. " " .. cursor.size
      .. " && hyprctl eval 'omarchy_startup_cursor_restore(true)'")
  end
end

hl.on("config.reloaded", function()
  if omarchy_startup_cursor_pending == nil then
    -- Config updates in an existing compositor must not hide its pointer.
    omarchy_startup_cursor_pending = #hl.get_monitors() == 0
    if omarchy_startup_cursor_pending then
      local hyprcursor = hl.get_config("cursor.enable_hyprcursor")
      omarchy_startup_cursor = {
        config = {
          invisible = hl.get_config("cursor.invisible"),
          enable_hyprcursor = hyprcursor,
          sync_gsettings_theme = hl.get_config("cursor.sync_gsettings_theme"),
        },
        hyprcursor = os.getenv("HYPRCURSOR_THEME"),
        size = tonumber((hyprcursor and os.getenv("HYPRCURSOR_SIZE")) or os.getenv("XCURSOR_SIZE")) or 24,
        path = os.getenv("XCURSOR_PATH") or "~/.local/share/icons:~/.icons:/usr/share/icons:/usr/share/pixmaps",
        xcursor = os.getenv("XCURSOR_THEME") or "default",
      }
      if omarchy_startup_cursor.size <= 0 then omarchy_startup_cursor.size = 24 end
      hl.env("XCURSOR_PATH", os.getenv("OMARCHY_PATH") .. "/default/hypr/cursors:" .. omarchy_startup_cursor.path)
      hl.env("XCURSOR_THEME", "omarchy-startup")
    end
  end
  if omarchy_startup_cursor_pending then
    -- Keep the temporary cursor private to the compositor, including GSettings.
    hl.config({ cursor = { invisible = true, enable_hyprcursor = false, sync_gsettings_theme = false } })
    hl.timer(function() omarchy_startup_cursor_restore() end, { timeout = 15000, type = "oneshot" })
  end
end)
