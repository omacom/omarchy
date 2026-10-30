o.window("steam", { float = true, idle_inhibit = "fullscreen" })
-- Proton games get their own steam_app_<appid> class and often run borderless
-- rather than fullscreen, while a gamepad never resets the compositor's idle
-- timer, so the screensaver and lock would start mid-game.
o.window("steam_app_.*", { idle_inhibit = "focus" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })
