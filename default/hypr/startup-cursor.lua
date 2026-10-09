-- Hyprland polls cursor.invisible, so its first frames need a blank cursor too.
-- A config reload starts a fresh Lua state, so the startup phase lives in the
-- compositor's environment, tagged with its instance so a later session ignores it.
local phase_variable = "OMARCHY_STARTUP_CURSOR"
local instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""

local function set_startup_cursor_phase(phase)
  hl.env(phase_variable, instance .. ":" .. phase)
end

local function startup_cursor_phase()
  local value = os.getenv(phase_variable) or ""
  local tagged_instance, phase = value:match("^(.*):(%a+)$")
  if tagged_instance == instance then return phase end
end

local function capture_startup_cursor()
  local hyprcursor = hl.get_config("cursor.enable_hyprcursor")
  local cursor = {
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
  if cursor.size <= 0 then cursor.size = 24 end
  return cursor
end

function omarchy_startup_cursor_restore(loaded)
  if not omarchy_startup_cursor_pending then return end
  local cursor = omarchy_startup_cursor
  if loaded then
    omarchy_startup_cursor_pending = false
    set_startup_cursor_phase("done")
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
    local phase = startup_cursor_phase()
    local first_load = phase == nil
    -- A reload before the reveal still holds the blank theme, which only the
    -- restore replaces. Config updates in an existing compositor must not hide
    -- its pointer, even when a reload lands while every monitor is gone.
    omarchy_startup_cursor_pending = phase == "pending" or (first_load and #hl.get_monitors() == 0)
    if omarchy_startup_cursor_pending then
      -- After a reload the user's environment is back, so this recaptures it.
      omarchy_startup_cursor = capture_startup_cursor()
      if first_load then
        set_startup_cursor_phase("pending")
        hl.env("XCURSOR_PATH", os.getenv("OMARCHY_PATH") .. "/default/hypr/cursors:" .. omarchy_startup_cursor.path)
        hl.env("XCURSOR_THEME", "omarchy-startup")
      end
    elseif first_load then
      set_startup_cursor_phase("done")
    end
  end
  if omarchy_startup_cursor_pending then
    -- Keep the temporary cursor private to the compositor, including GSettings.
    hl.config({ cursor = { invisible = true, enable_hyprcursor = false, sync_gsettings_theme = false } })
    hl.timer(function() omarchy_startup_cursor_restore() end, { timeout = 15000, type = "oneshot" })
  end
end)
