-- An agent desktop: config for each nested Hyprland that `agent-desktop start`
-- launches inside the user's session. Never loaded by the user's own Hyprland.
--
-- The headless output keeps rendering with no viewer. Disabling the backend
-- output before mapping prevents a separate mirror window on the user's seat.
hl.monitor({ output = "agent-main", mode = "2560x1440@60", position = "0x0", scale = 1 })
hl.monitor({ output = "WAYLAND-1", disabled = true })
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

-- Only the host window's devices are gated. Agent virtual input stays enabled.
local human_control = false
function agent_desktop_control(toggle)
  if toggle then human_control = not human_control end
  hl.device({ name = "wl_pointer", enabled = human_control })
  hl.device({ name = "wl_keyboard", enabled = human_control })
  return human_control and "unlocked" or "locked"
end
agent_desktop_control(false)

hl.on("hyprland.start", function()
  -- Tells the launcher which socket, instance and X display this nest got.
  -- AGENT_DESKTOP_SELF is the launcher's own path, set on the unit; a worktree
  -- under test is not on PATH.
  hl.exec_cmd('"${AGENT_DESKTOP_SELF:-agent-desktop}" _nest-ready')
end)
