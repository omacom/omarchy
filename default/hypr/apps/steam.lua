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
-- Steam exports SteamGameId to every game it launches (never to the Steam
-- client itself), so fullscreen non-floating game windows as they open and
-- tag them to inhibit idle like Proton games do.
o.window({ tag = "steam-game" }, { idle_inhibit = "fullscreen" })

local function steam_game_id(pid)
  local file = pid and pid > 0 and io.open("/proc/" .. tostring(pid) .. "/environ", "rb")
  if not file then
    return nil
  end
  local env = "\0" .. (file:read("*a") or "")
  file:close()
  local id = env:match("%zSteamGameId=(%d+)%z")
  return id ~= "0" and id or nil
end

hl.on("window.open", function(window)
  local class = window.class or ""
  -- steam_app_* has its own rules above; skip the client without a /proc read.
  if class == "steam" or class:match("^steam_app_") then
    return
  end

  -- Ignore browsers and terminals cold-started from a game (they inherit SteamGameId).
  if o.has_tag(window, "chromium-based-browser") or o.has_tag(window, "firefox-based-browser") or o.has_tag(window, "terminal") then
    return
  end

  -- Leave dialogs and windows that floated on their own alone, while still
  -- catching normal windows that a floating workspace rule floated.
  if window.floating and not o.has_tag(window, "omarchy-mode-opened") then
    return
  end

  if not steam_game_id(window.pid) then
    return
  end

  hl.dispatch(hl.dsp.window.tag({ tag = "+steam-game", window = window }))
  if (window.fullscreen or 0) == 0 then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = window }))
  end
end)
