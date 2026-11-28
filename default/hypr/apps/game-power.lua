-- Boost the power profile to performance while a game is running on AC, and
-- restore the user's saved profile once the last game exits.
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
  return GAME_CLASSES[class]
    or class:match("^steam_app_%d+$") ~= nil
    or o.has_tag(window, "steam-game")
    or (o.is_native_steam_game ~= nil and o.is_native_steam_game(window))
end

local function has_other_game(closing)
  for _, other in ipairs(hl.get_windows() or {}) do
    if other ~= closing and (closing.address == nil or other.address ~= closing.address) and is_game(other) then
      return true
    end
  end

  return false
end

hl.on("window.open", function(window)
  if is_game(window) then
    hl.exec_cmd("omarchy-powerprofiles-game boost")
  end
end)

hl.on("window.destroy", function(window)
  if is_game(window) and not has_other_game(window) then
    hl.exec_cmd("omarchy-powerprofiles-game restore")
  end
end)
