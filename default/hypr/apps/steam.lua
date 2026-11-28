o.window("steam", { float = true, idle_inhibit = "fullscreen" })
-- Proton games run as steam_app_<appid> and are usually borderless, so the client's rule never
-- matches them and "fullscreen" would not either, leaving the machine to lock itself mid-game with
-- a controller in hand. Inhibit while the game is focused, so one left in the background still
-- locks as usual (#15329).
o.window("steam_app_.*", { idle_inhibit = "focus" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Games running under Proton get class steam_app_<appid>. Start them
-- fullscreen rather than tiled beside other windows. Battle.net's launcher
-- (steam_app_battlenet) keeps its own float rules.
o.window("^steam_app_\\d+$", { fullscreen = true, idle_inhibit = "fullscreen" })
