o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window("steam.*", { tag = "-default-opacity", opacity = "1 1" })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Fullscreen Proton games share class steam_app_*. With
-- misc.on_focus_under_fullscreen = 1, a tiled window on the same workspace can
-- take the keyboard while the mouse stays with the game (#13281). Keep focus on
-- the fullscreen client the same way DaVinci Resolve does.
o.window({ class = "^steam_app_", fullscreen = true }, { stay_focused = true })
