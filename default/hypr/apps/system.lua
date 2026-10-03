-- Floating windows.
o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })

o.window(
  "(org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|Omarchy|About|TUI.float|imv|mpv)",
  {
    tag = "+floating-window",
  }
)

-- The portal only ever shows dialogs — file pickers, screen shares, permission
-- prompts — so every one of its windows belongs in the floating treatment,
-- whatever the app that asked for it titled it.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window({
  class = "(sublime_text|DesktopEditors|org.gnome.Nautilus)",
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
}, { tag = "+floating-window" })

-- Nautilus file-operations UI. Keep it a real floating, pinned window so an
-- exclusive seat grab cannot linger after the bubble hides when Nautilus loses
-- focus — which blocks hover/click on every workspace (#13326).
o.window({
  class = "^org\\.gnome\\.Nautilus$",
  title = "^(File Operation(s| Progress)?)$",
}, {
  float = true,
  pin = true,
  no_follow_mouse = true,
})

-- The About fastfetch layout needs more columns than the standard float provides.
-- This size only covers the first launch: omarchy-launch-about measures the
-- rendered content, remembers the size that hugs it, and applies that as its own
-- rule before every later launch.
o.window("org.omarchy.about", { float = true })
o.window("org.omarchy.about", { center = true })
o.window("org.omarchy.about", { size = { 920, 480 } })

o.window("omacalc", { float = true })

-- Fullscreen screensaver. stay_focused keeps dismiss keys from being stolen by
-- a lingering Nautilus file-operations grab (#13326).
o.window("org.omarchy.screensaver", { fullscreen = true })
o.window("org.omarchy.screensaver", { float = true })
o.window("org.omarchy.screensaver", { stay_focused = true })
o.window("org.omarchy.screensaver", { animation = "slide" })
-- The launcher picks each screensaver's workspace. A terminal mapped again as it closes lands out of sight instead,
-- where its fullscreen rule cannot take fullscreen from a window.
o.window("org.omarchy.screensaver", { workspace = "special:screensaver silent" })

-- No transparency on media windows.
o.window(
  "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
  {
    tag = "-default-opacity",
  }
)
o.window(
  "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
  {
    opacity = "1 1",
  }
)

-- Popped window rounding.
o.window({ tag = "pop" }, { rounding = 8 })

-- Prevent idle while open.
o.window({ tag = "noidle" }, { idle_inhibit = "always" })
