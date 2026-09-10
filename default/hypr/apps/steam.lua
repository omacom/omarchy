o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window("steam.*", { tag = "-default-opacity", opacity = "1 1" })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- A running game is a separate window from the Steam client above, and Steam
-- classes it steam_app_<appid> (both native and Proton titles). Without this,
-- the screensaver and lock still engage during play since controller/gamepad
-- input doesn't register as activity.
o.window("^steam_app_[0-9]+$", { idle_inhibit = "fullscreen" })
