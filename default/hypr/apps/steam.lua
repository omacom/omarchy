o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Steam games have their own window class. Protect the focused game in
-- windowed and fullscreen modes without inhibiting idle for the Steam client.
o.window("^steam_app_[0-9]+$", { idle_inhibit = "focus" })
