-- Boost the power profile to performance while a game is running on AC, and
-- restore the user's saved profile once the last game exits. Setting
-- performance directly via powerprofilesctl leaves Omarchy's saved AC profile
-- untouched so `omarchy-powerprofiles-set autodetect` restores it afterwards.

local GAME_CLASSES = {
  ["com.libretro.RetroArch"] = true,
  ["com.moonlight_stream.Moonlight"] = true,
  ["GeForceNOW"] = true,
  ["gamescope"] = true,
}

local function is_game(window)
  if not window then
    return false
  end

  local class = window.class or ""
  if GAME_CLASSES[class] or class:match("^steam_app_%d+$") then
    return true
  end

  return o.has_tag(window, "steam-game")
end

local function has_active_game()
  for _, window in ipairs(hl.get_windows() or {}) do
    if is_game(window) then
      return true
    end
  end

  return false
end

local function file_exists(path)
  if not path then
    return false
  end

  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end

  return false
end

local function touch_file(path)
  if not path then
    return false
  end

  local file = io.open(path, "w")
  if not file then
    return false
  end

  file:close()
  return true
end

-- Hyprland starts a fresh Lua state on every reload, so record an active boost
-- in this Hyprland instance's runtime directory. The boost command removes the
-- marker again when it decides not to boost (on battery or when the hardware
-- has no performance profile), so closing that game skips restoring too.
local function boost_marker()
  local runtime = os.getenv("XDG_RUNTIME_DIR")
  local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  if not runtime or runtime == "" or not signature or signature == "" then
    return nil
  end

  return runtime .. "/hypr/" .. signature .. "/omarchy-game-power-boosted"
end

local marker = boost_marker()
local marker_active = file_exists(marker)
local boosted = marker_active

local function is_boosted()
  if not boosted then
    return false
  end

  if marker_active and not file_exists(marker) then
    boosted = false
    marker_active = false
    return false
  end

  return true
end

local function boost_command(clear_marker)
  local check_ac =
    '[ "$(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2>/dev/null)" != "b true" ]'
  local apply =
    "omarchy-powerprofiles-list | grep -qx performance && powerprofilesctl set performance && (omarchy-shell -q battery refreshPowerProfile >/dev/null 2>&1 || true)"

  if clear_marker then
    return "if " .. check_ac .. " && " .. apply .. "; then :; else rm -f " .. o.shell_quote(clear_marker) .. "; fi"
  end

  return check_ac .. " && " .. apply
end

local function boost()
  if is_boosted() then
    return
  end

  boosted = true
  marker_active = touch_file(marker)
  hl.exec_cmd(boost_command(marker_active and marker or nil))
end

local function restore()
  if not is_boosted() then
    return
  end

  boosted = false
  if marker_active then
    os.remove(marker)
    marker_active = false
  end

  hl.exec_cmd("omarchy-powerprofiles-set autodetect")
end

-- If a previous Lua state left a boost active before a reload and the game has
-- already exited, restore immediately; if a game is still open, keep tracking.
if boosted and not has_active_game() then
  restore()
end

hl.on("window.open", function(window)
  if is_game(window) then
    boost()
  end
end)

-- window.close still lists the closing window in hl.get_windows(); wait for
-- window.destroy so the remaining game count has settled.
hl.on("window.destroy", function()
  if is_boosted() and not has_active_game() then
    restore()
  end
end)
