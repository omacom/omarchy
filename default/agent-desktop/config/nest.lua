-- An agent desktop: config for each nested Hyprland that `agent-desktop start`
-- launches inside the user's session. Never loaded by the user's own Hyprland.
--
-- The real output is headless. A Wayland-backend output only renders when its
-- host window is visible, so a nest that lived on one would freeze every app
-- in it, and hang screencopy, the moment the user toggled it away. The window
-- the user sees (WAYLAND-1) mirrors the headless output instead; it may stall
-- while hidden and nothing inside notices.
hl.monitor({ output = "agent-main", mode = "2560x1440@60", position = "0x0", scale = 1 })
hl.monitor({ output = "WAYLAND-1", mode = "preferred", position = "auto", scale = 1, mirror = "agent-main" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "agent-main", default = true, persistent = true })

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    focus_on_activate = true,
    background_color = "rgb(101418)",
  },
  general = { gaps_in = 4, gaps_out = 8, border_size = 2 },
  decoration = { rounding = 4 },
  cursor = { inactive_timeout = 0 },
})

hl.on("hyprland.start", function()
  -- Tells the launcher which socket, instance and X display this nest got.
  -- AGENT_DESKTOP_SELF is the launcher's own path, set on the unit; a worktree
  -- under test is not on PATH.
  hl.exec_cmd('"${AGENT_DESKTOP_SELF:-agent-desktop}" _nest-ready')
end)
