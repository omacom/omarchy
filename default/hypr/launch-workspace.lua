-- Open apps on the workspace they were launched from.
--
-- looknfeel turns misc.initial_workspace_tracking off so portal file dialogs
-- follow the app that asked for them, so Hyprland no longer remembers where a
-- launch came from. Binds made with o.bind and the app launcher stamp their
-- commands with o.launch_workspace_env() instead, and windows from that process
-- tree are sent back there, even when you switched away while the app was
-- starting. Unlike Hyprland's one-shot token, this also follows apps whose
-- first window is a splash or login that closes before the main window (Steam).

-- Seconds after a launch during which its new windows still follow it, long
-- enough for a slow first start, short enough that a game started from Steam an
-- hour later opens where you are.
local LAUNCH_WORKSPACE_TTL = 90

-- The launch workspace name and the seconds it has left, read from the
-- window's process environment.
local function launch_workspace(pid)
  local file = io.open("/proc/" .. pid .. "/environ", "rb")
  if not file then
    return nil
  end
  local env = "\0" .. (file:read("a") or "")
  file:close()

  local name = env:match("\0OMARCHY_LAUNCH_WORKSPACE=([^\0]+)")
  local launched = tonumber(env:match("\0OMARCHY_LAUNCH_TIME=(%d+)"))
  if not name or not launched then
    return nil
  end

  local left = launched + LAUNCH_WORKSPACE_TTL - os.time()
  if left > 0 then
    return name, left
  end
end

local function workspace_selector(name)
  if name:find("^special:") or tonumber(name) then
    return name
  end

  return "name:" .. name
end

hl.on("window.open", function(window)
  if not window.pid or window.pid <= 0 then
    return
  end

  local name, left = launch_workspace(window.pid)
  if not name or (window.workspace and window.workspace.name == name) then
    return
  end

  hl.dispatch(hl.dsp.window.move({ window = window, workspace = workspace_selector(name), follow = false }))

  -- A starting app activates its window, and focus_on_activate would pull you
  -- back to it. Mark it urgent instead until the launch has settled.
  hl.dispatch(hl.dsp.window.set_prop({ window = window, prop = "focus_on_activate", value = "0" }))
  hl.timer(function()
    pcall(hl.dispatch, hl.dsp.window.set_prop({ window = window, prop = "focus_on_activate", value = "unset" }))
  end, { timeout = left * 1000, type = "oneshot" })
end)
