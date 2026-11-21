o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

-- Games use steam_app_<id> (Hyprland FullMatch won't hit the client rule above).
-- Many run borderless, so "fullscreen" never engages; controller input also
-- doesn't reset the idle timer. Inhibit while focused so play stays awake and
-- a game left in the background still locks as usual. gamescope is a common
-- Steam/Proton wrapper with the same gap.
o.window("^(steam_app_[0-9]+|gamescope)$", { idle_inhibit = "focus" })
