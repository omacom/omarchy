-- Float Steam's secondary windows (Friends List, Settings, dialogs, etc.),
-- while tiling the main Steam client so it has no duplicate titlebar and
-- never sits on top of tiled games.
o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "^Steam$" }, { tile = true })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Games running under Proton get class steam_app_<appid>. Start them
-- fullscreen rather than tiled beside other windows. Battle.net's launcher
-- (steam_app_battlenet) keeps its own float rules.
o.window("^steam_app_\\d+$", { fullscreen = true, idle_inhibit = "fullscreen" })

-- Native Linux Steam games keep their own window class rather than
-- steam_app_<appid>, so they would open tiled beside other windows.
-- Steam exports SteamGameId/SteamAppId to every game it launches (never to the
-- Steam client itself), so fullscreen non-floating game windows as they open
-- and tag them to inhibit idle like Proton games do.
o.window({ tag = "steam-game" }, { idle_inhibit = "fullscreen" })

local function has_tag(window, name)
  for _, tag in ipairs(window.tags or {}) do
    if tag == name or tag == name .. "*" then
      return true
    end
  end
  return false
end

local function is_steam_game_process(pid)
  if not pid or pid <= 0 then
    return false
  end

  local file = io.open("/proc/" .. tostring(pid) .. "/environ", "rb")
  if not file then
    return false
  end

  local env = file:read("*a") or ""
  file:close()

  local padded = "\0" .. env
  local id = padded:match("%zSteamGameId=(%d+)%z") or padded:match("%zSteamAppId=(%d+)%z")
  return id ~= nil and id ~= "0"
end

hl.on("window.open", function(window)
  local class = window.class or ""
  if class == "steam" or class:match("^steam_app_") then
    return
  end

  -- Leave dialogs and windows that floated on their own alone, while still
  -- catching normal windows that a floating workspace rule floated.
  if window.floating and not has_tag(window, "omarchy-mode-opened") then
    return
  end

  if not is_steam_game_process(window.pid) then
    return
  end

  hl.dispatch(hl.dsp.window.tag({ tag = "+steam-game", window = window }))
  if (window.fullscreen or 0) == 0 then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = window }))
  end
end)
