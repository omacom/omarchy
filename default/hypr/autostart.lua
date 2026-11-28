hl.on("hyprland.start", function()
  -- Slow app launch fix -- set systemd and D-Bus activation vars before
  -- starting session services.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  hl.exec_cmd("omarchy-launch-shell")
  hl.exec_cmd("omarchy-provision-first-run")
  hl.exec_cmd("omarchy-powerprofiles-init")
  -- A reboot taken while the keyboard backlight was blanked brings it back at
  -- the 0 systemd-backlight saved; put back the level from before the blank.
  hl.exec_cmd("omarchy-brightness-keyboard restore")
  hl.exec_cmd("omarchy-hyprland-software-rendering")
  hl.exec_cmd(o.launch("omarchy-hyprland-monitor-watch"))

  -- Defer background daemons that aren't needed for the first frame so
  -- omarchy-shell brings up the desktop without competing for CPU and I/O.
  -- Encrypted drives unlock with their keyfile or ask for their password in the shell (omarchy-drive-unlock).
  hl.exec_cmd("sleep 2 && " .. o.launch("omarchy-drive-automount"))

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
