o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Games running under Proton get class steam_app_<appid>. Start them
-- fullscreen rather than tiled beside other windows. Battle.net's launcher
-- (steam_app_battlenet) keeps its own float rules.
o.window("^steam_app_\\d+$", { fullscreen = true, idle_inhibit = "fullscreen" })
