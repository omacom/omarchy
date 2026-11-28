local started = false

local function start_once()
  if started then return end
  if not o.shell_succeeds("omarchy-hyprland-autostart-claim") then return end
  started = true

  -- Slow app launch fix -- set systemd and D-Bus activation vars before
  -- starting session services.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  hl.exec_cmd("omarchy-launch-shell")
  hl.exec_cmd("omarchy-provision-first-run")
  hl.exec_cmd("omarchy-powerprofiles-init")
  hl.exec_cmd("omarchy-hyprland-software-rendering")
  hl.exec_cmd(o.launch("omarchy-hyprland-monitor-watch"))

  -- Defer background daemons that aren't needed for the first frame so
  -- omarchy-shell brings up the desktop without competing for CPU and I/O.
  -- Encrypted drives unlock with their keyfile or ask for their password in the shell (omarchy-drive-unlock).
  hl.exec_cmd("sleep 2 && " .. o.launch("omarchy-drive-automount"))

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end

hl.on("hyprland.start", start_once)

-- Hyprland's safe-mode dialog can load the user config after hyprland.start
-- already fired. On a normal login config.reloaded arrives first, before the
-- Wayland display exists. The runtime claim persists across Lua reloads and
-- distinguishes a session whose startup already ran from safe-mode recovery.
hl.on("config.reloaded", function()
  if not os.getenv("WAYLAND_DISPLAY") then return end
  start_once()
end)
