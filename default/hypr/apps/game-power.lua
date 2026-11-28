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
  return GAME_CLASSES[class] or class:match("^steam_app_%d+$") ~= nil or o.has_tag(window, "steam-game")
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
  local file = path and io.open(path, "r")
  if not file then
    return false
  end

  file:close()
  return true
end

-- Hyprland starts a fresh Lua state on every reload, so record an active boost
-- in this Hyprland instance's runtime directory. The boost command clears the
-- marker when it declines to boost (on battery or without a performance
-- profile), so closing that game skips restoring too.
local runtime = os.getenv("XDG_RUNTIME_DIR")
local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
local marker = (runtime and runtime ~= "" and signature and signature ~= "")
    and (runtime .. "/hypr/" .. signature .. "/omarchy-game-power-boosted")
  or nil
local boosted = file_exists(marker)

local function is_boosted()
  if boosted and marker and not file_exists(marker) then
    boosted = false
  end

  return boosted
end

local function boost()
  if is_boosted() then
    return
  end

  boosted = true
  if marker then
    local file = io.open(marker, "w")
    if file then
      file:close()
    else
      marker = nil
    end
  end

  local cmd = '[ "$(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2>/dev/null)" != "b true" ]'
    .. " && powerprofilesctl set performance >/dev/null 2>&1"
    .. " && { omarchy-shell -q battery refreshPowerProfile >/dev/null 2>&1 || true; }"
  if marker then
    cmd = cmd .. " || rm -f " .. o.shell_quote(marker)
  end

  hl.exec_cmd(cmd)
end

local function restore()
  if not is_boosted() then
    return
  end

  boosted = false
  if marker then
    os.remove(marker)
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
