local function cursor_theme(value)
  if value and value ~= "" and value ~= "omarchy-startup" then return value end
end

local function normal_theme(interrupted)
  local current = os.getenv("XCURSOR_THEME")
  local theme = cursor_theme(current)
  -- Only a lost preference needs recovering; an unset theme still means the default alias.
  if theme or not (interrupted or current == "omarchy-startup") then return theme or "default" end
  theme = cursor_theme(os.getenv("OMARCHY_STARTUP_CURSOR_THEME"))
  if theme then return theme end
  local pipe = io.popen("gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null", "r")
  if pipe then
    theme = cursor_theme((pipe:read("*a") or ""):match("^'(.-)'%s*$"))
    pipe:close()
  end
  return theme or "default"
end

local function normal_path()
  local kept = {}
  for entry in (os.getenv("XCURSOR_PATH") or "~/.local/share/icons:~/.icons:/usr/share/icons:/usr/share/pixmaps"):gmatch("[^:]+") do
    if not entry:match("/default/hypr/cursors$") then table.insert(kept, entry) end
  end
  return table.concat(kept, ":")
end

-- Retry the stalled stage until the reveal lands, never the Xcursor one over a loaded Hyprcursor theme.
local function retry()
  if omarchy_startup_cursor_pending then
    omarchy_startup_cursor.restoring = false
    omarchy_startup_cursor_restore(omarchy_startup_cursor.loaded)
    if omarchy_startup_cursor_pending then hl.timer(retry, { timeout = 15000, type = "oneshot" }) end
  end
end

-- Hyprland polls cursor.invisible, so its first frames need a blank cursor too.
function omarchy_startup_cursor_restore(loaded)
  if not omarchy_startup_cursor_pending then return end
  local cursor = omarchy_startup_cursor
  local hyprcursor = cursor.config.enable_hyprcursor and cursor.hyprcursor
  if loaded and hyprcursor and not (loaded == "hyprcursor" and cursor.attempt) then
    -- Only a setcursor made with Hyprcursor enabled loads its style, and Hyprland 0.56 draws an unloaded one as a
    -- null surface; only a reload turns it off again, so a completion is trusted only in the Lua state that sent it.
    cursor.loaded, cursor.attempt = true, cursor.attempt or math.random(0)
    hl.config({ cursor = { invisible = true, enable_hyprcursor = true, sync_gsettings_theme = cursor.config.sync_gsettings_theme } })
    local complete = "if omarchy_startup_cursor and omarchy_startup_cursor.attempt == " .. cursor.attempt
      .. ' then omarchy_startup_cursor_restore("hyprcursor") end'
    hl.exec_cmd("hyprctl setcursor " .. o.shell_quote(hyprcursor) .. " " .. cursor.size
      .. " && hyprctl eval " .. o.shell_quote(complete))
  elseif loaded then
    omarchy_startup_cursor_pending = false
    hl.env("OMARCHY_STARTUP_CURSOR_SESSION", "")
    hl.env("OMARCHY_STARTUP_CURSOR_THEME", "")
    hl.config({ cursor = cursor.config })
    hl.exec_cmd("xsetroot -cursor_name left_ptr >/dev/null 2>&1 || true")
  elseif not cursor.restoring then
    -- Reload the normal Xcursor fallback before enabling Hyprcursor or GSettings.
    cursor.restoring = true
    hl.env("XCURSOR_PATH", cursor.path)
    hl.env("XCURSOR_THEME", cursor.xcursor)
    hl.exec_cmd("dbus-update-activation-environment --systemd XCURSOR_PATH XCURSOR_THEME")
    local complete = "if omarchy_startup_cursor and omarchy_startup_cursor.xcursor == " .. string.format("%q", cursor.xcursor)
      .. " and omarchy_startup_cursor.size == " .. cursor.size .. " then omarchy_startup_cursor_restore(true) end"
    hl.exec_cmd("hyprctl setcursor " .. o.shell_quote(cursor.xcursor) .. " " .. cursor.size
      .. " && hyprctl eval " .. o.shell_quote(complete))
  end
end

hl.on("config.reloaded", function()
  local recover = false
  if omarchy_startup_cursor_pending == nil then
    -- An ordinary reload must not hide the pointer, but an interrupted reveal survives.
    local cold = #hl.get_monitors() == 0
    local session = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
    local interrupted = session and os.getenv("OMARCHY_STARTUP_CURSOR_SESSION") == session
    recover = not cold and not interrupted and os.getenv("XCURSOR_THEME") == "omarchy-startup"
    omarchy_startup_cursor_pending = cold or interrupted or recover
    if omarchy_startup_cursor_pending then
      local hyprcursor = hl.get_config("cursor.enable_hyprcursor")
      local xcursor = normal_theme(interrupted)
      omarchy_startup_cursor = {
        config = {
          invisible = hl.get_config("cursor.invisible"),
          enable_hyprcursor = hyprcursor,
          sync_gsettings_theme = hl.get_config("cursor.sync_gsettings_theme"),
        },
        -- The startup window leaves no Hyprcursor style loaded and only setcursor loads one,
        -- so the reveal always names a theme, following the Xcursor one when none is set (#16941).
        hyprcursor = cursor_theme(os.getenv("HYPRCURSOR_THEME")) or xcursor,
        size = tonumber((hyprcursor and os.getenv("HYPRCURSOR_SIZE")) or os.getenv("XCURSOR_SIZE")) or 24,
        path = normal_path(),
        xcursor = xcursor,
      }
      if omarchy_startup_cursor.size <= 0 then omarchy_startup_cursor.size = 24 end
      -- Compositor environment survives Lua reloads; a session id prevents stale inheritance.
      hl.env("OMARCHY_STARTUP_CURSOR_THEME", omarchy_startup_cursor.xcursor)
      hl.env("OMARCHY_STARTUP_CURSOR_SESSION", os.getenv("HYPRLAND_INSTANCE_SIGNATURE"))
      if cold then
        hl.env("XCURSOR_PATH", os.getenv("OMARCHY_PATH") .. "/default/hypr/cursors:" .. omarchy_startup_cursor.path)
        hl.env("XCURSOR_THEME", "omarchy-startup")
      else
        hl.env("XCURSOR_PATH", omarchy_startup_cursor.path)
        hl.env("XCURSOR_THEME", omarchy_startup_cursor.xcursor)
      end
    end
  end
  if omarchy_startup_cursor_pending then
    -- Keep the temporary cursor private to the compositor, including GSettings.
    hl.config({ cursor = { invisible = true, enable_hyprcursor = false, sync_gsettings_theme = false } })
    hl.timer(retry, { timeout = 15000, type = "oneshot" })
    if recover then omarchy_startup_cursor_restore() end
  end
end)
