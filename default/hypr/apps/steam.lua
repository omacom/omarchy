o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window("steam.*", { tag = "-default-opacity", opacity = "1 1" })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Games run as steam_app_<appid>. Gamepad input goes straight to the game and
-- never through the compositor, so a fullscreen game played on a controller
-- looks idle and the screensaver/lock fire mid-game.
o.window("steam_app_.*", { idle_inhibit = "fullscreen" })
