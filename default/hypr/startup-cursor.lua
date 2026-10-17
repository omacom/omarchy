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

-- Hyprland polls cursor.invisible, so its first frames need a blank cursor too.
--
-- A `hyprctl reload` while the restore is pending (e.g. from
-- omarchy-hyprland-monitor-watch while a slow display is still waking up)
-- wipes this module's Lua state without touching the compositor's config or
-- environment. The captured cursor therefore also lives in the runtime dir,
-- so a fresh state picks the restore back up even after application startup
-- has restored XCURSOR_THEME. The phase belongs to this compositor instance.
local instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""
local phase_key = "OMARCHY_STARTUP_CURSOR"
local pending_phase = instance .. ":pending"
local done_phase = instance .. ":done"
local function omarchy_startup_cursor_state_path()
  local runtime = os.getenv("XDG_RUNTIME_DIR")
  if not runtime or runtime == "" or instance == "" or instance:find("[^%w_-]") then return nil end
  return runtime .. "/omarchy-startup-cursor-" .. instance .. ".state"
end

local function omarchy_startup_cursor_save(cursor)
  local path = omarchy_startup_cursor_state_path()
  if not path then return end
  local file = io.open(path, "w")
  if not file then return end
  local saved = {
    invisible = tostring(cursor.config.invisible),
    enable_hyprcursor = tostring(cursor.config.enable_hyprcursor),
    sync_gsettings_theme = tostring(cursor.config.sync_gsettings_theme),
    hyprcursor = cursor.hyprcursor or "",
    size = tostring(cursor.size),
    path = cursor.path,
    xcursor = cursor.xcursor,
  }
  for _, key in ipairs({ "invisible", "enable_hyprcursor", "sync_gsettings_theme", "hyprcursor", "size", "path", "xcursor" }) do
    local value = saved[key]:gsub("[%%\r\n]", function(char) return string.format("%%%02X", string.byte(char)) end)
    file:write(key .. "=" .. value .. "\n")
  end
  file:close()
end

local function omarchy_startup_cursor_drop()
  local path = omarchy_startup_cursor_state_path()
  if path then os.remove(path) end
end

local function omarchy_startup_cursor_load()
  local path = omarchy_startup_cursor_state_path()
  if not path then return nil end
  local file = io.open(path, "r")
  if not file then return nil end
  local saved = {}
  for line in file:lines() do
    local key, value = line:match("^([%w_]+)=(.*)$")
    if not key or saved[key] or value:gsub("%%(%x%x)", ""):find("%%") then
      file:close()
      return nil
    end
    saved[key] = value:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
  end
  file:close()
  for _, key in ipairs({ "invisible", "enable_hyprcursor", "sync_gsettings_theme" }) do
    if saved[key] ~= "true" and saved[key] ~= "false" then return nil end
  end
  if not saved.xcursor or saved.xcursor == "" or saved.xcursor == "omarchy-startup" then return nil end
  -- An explicitly empty XCURSOR_PATH is valid and uses the loader's defaults.
  -- Reject a missing field, not a captured empty value.
  if not saved.path then return nil end
  local size = tonumber(saved.size)
  if not size or size <= 0 or size == math.huge then return nil end
  return {
    config = {
      invisible = saved.invisible == "true",
      enable_hyprcursor = saved.enable_hyprcursor == "true",
      sync_gsettings_theme = saved.sync_gsettings_theme == "true",
    },
    hyprcursor = saved.hyprcursor ~= "" and saved.hyprcursor or nil,
    size = size,
    path = saved.path,
    xcursor = saved.xcursor,
  }
end

function omarchy_startup_cursor_restore(loaded)
  if not omarchy_startup_cursor_pending then return end
  local cursor = omarchy_startup_cursor
  if loaded then
    if cursor.revealing then return end
    cursor.revealing = true
    -- The pointer only picks up the restored theme when it is shown again, and
    -- the compositor checks cursor.invisible every 500ms, so hide it past one check.
    -- The reveal stays recorded until then, since a reload discards this timer.
    hl.config({ cursor = { invisible = true } })
    hl.timer(function()
      if not omarchy_startup_cursor_pending or omarchy_startup_cursor ~= cursor then return end
      omarchy_startup_cursor_pending = false
      hl.env(phase_key, done_phase)
      hl.env("OMARCHY_STARTUP_CURSOR_SESSION", "")
      hl.env("OMARCHY_STARTUP_CURSOR_THEME", "")
      hl.config({ cursor = cursor.config })
      hl.exec_cmd("xsetroot -cursor_name left_ptr >/dev/null 2>&1 || true")
      local theme = (cursor.config.enable_hyprcursor and cursor.hyprcursor and cursor.hyprcursor ~= "" and cursor.hyprcursor) or cursor.xcursor
      hl.exec_cmd("hyprctl setcursor " .. o.shell_quote(theme) .. " " .. cursor.size)
      omarchy_startup_cursor_drop()
    end, { timeout = 600, type = "oneshot" })
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
    -- Config updates in an existing compositor must not hide its pointer.
    local phase = os.getenv(phase_key)
    local cold = #hl.get_monitors() == 0
    local interrupted = phase == pending_phase or os.getenv("OMARCHY_STARTUP_CURSOR_SESSION") == instance
    local saved = phase == pending_phase and omarchy_startup_cursor_load() or nil
    recover = not cold and not interrupted and os.getenv("XCURSOR_THEME") == "omarchy-startup"
    omarchy_startup_cursor_pending = saved ~= nil or interrupted or recover or (phase ~= done_phase and cold)
    if saved then
      omarchy_startup_cursor = saved
    elseif omarchy_startup_cursor_pending then
      local hyprcursor = hl.get_config("cursor.enable_hyprcursor")
      omarchy_startup_cursor = {
        config = {
          invisible = hl.get_config("cursor.invisible"),
          enable_hyprcursor = hyprcursor,
          sync_gsettings_theme = hl.get_config("cursor.sync_gsettings_theme"),
        },
        hyprcursor = os.getenv("HYPRCURSOR_THEME"),
        size = tonumber((hyprcursor and os.getenv("HYPRCURSOR_SIZE")) or os.getenv("XCURSOR_SIZE")) or 24,
        path = normal_path(),
        xcursor = normal_theme(interrupted),
      }
      if omarchy_startup_cursor.size <= 0 then omarchy_startup_cursor.size = 24 end
      omarchy_startup_cursor_save(omarchy_startup_cursor)
      hl.env(phase_key, pending_phase)
    else
      -- Healthy session: a leftover capture (e.g. from a crash) must never
      -- hide the pointer of a later reload.
      omarchy_startup_cursor_drop()
    end
    if omarchy_startup_cursor_pending then
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
    hl.timer(function()
      if omarchy_startup_cursor_pending then
        omarchy_startup_cursor.restoring = false
        omarchy_startup_cursor_restore()
      end
    end, { timeout = 15000, type = "oneshot" })
    if recover then omarchy_startup_cursor_restore() end
  end
end)
