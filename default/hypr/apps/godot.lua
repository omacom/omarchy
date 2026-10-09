-- Godot is a visual workspace; skip the default window dimming.
o.window("^(Godot|org\\.godotengine\\.Godot)$", { tag = "-default-opacity", opacity = "1 1" })

-- Project manager is a picker, not the editor.
o.window({ class = "^(Godot|org\\.godotengine\\.Godot)$", title = ".*Project Manager.*" }, {
  float = true,
  center = true,
})

-- Running games (F5) get a separate window class on X11.
o.window("Godot_Engine", { tag = "-default-opacity", opacity = "1 1", idle_inhibit = "fullscreen" })
