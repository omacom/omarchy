-- Boost the power profile to performance while a game is running on AC, and
-- restore the user's saved profile once the last game exits.
--
-- The active-game marker lives inside this Hyprland instance's runtime
-- directory and is updated synchronously on the compositor event loop before
-- spawning omarchy-powerprofiles-set autodetect (which serializes under flock
-- and reads the current marker state). Rapid open/close pairs therefore always
-- converge on the final marker state, and a Hyprland crash + restart starts
-- with a fresh signature so a stale marker never outlives the session.
local GAME_CLASSES = {
  ["com.libretro.RetroArch"] = true,
  ["com.moonlight_stream.Moonlight"] = true,
  ["GeForceNOW"] = true,
  ["gamescope"] = true,
}

local function marker_path()
  local runtime = os.getenv("XDG_RUNTIME_DIR")
  local signature = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  if not runtime or runtime == "" or not signature or signature == "" then
    return nil
  end
  return runtime .. "/hypr/" .. signature .. "/omarchy-game-power-active"
end

local function file_exists(path)
  local file = path and io.open(path, "r")
  if not file then
    return false
  end
  file:close()
  return true
end

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
    if other ~= closing and (closing == nil or closing.address == nil or other.address ~= closing.address) and is_game(other) then
      return true
    end
  end

  return false
end

local function set_active(active)
  local path = marker_path()
  if not path then
    return
  end

  if active then
    if file_exists(path) then
      return
    end
    local file = io.open(path, "w")
    if not file then
      return
    end
    file:close()
  else
    if not file_exists(path) then
      return
    end
    os.remove(path)
  end

  hl.exec_cmd("omarchy-powerprofiles-set autodetect")
end

-- Reconcile any stale marker left across a config reload if no games remain.
if not has_other_game(nil) then
  set_active(false)
end

hl.on("window.open", function(window)
  if is_game(window) then
    set_active(true)
  end
end)

hl.on("window.destroy", function(window)
  if is_game(window) and not has_other_game(window) then
    set_active(false)
  end
end)
