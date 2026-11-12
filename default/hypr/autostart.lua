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
  hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))

  -- Start the herdr server inside the graphical session so its panes inherit
  -- WAYLAND_DISPLAY. Otherwise the first SSH login from a remote herdr starts
  -- it with a tty environment, and agents in its panes can't read the clipboard.
  -- setsid makes it lead its own session, as when herdr starts it itself, so
  -- remote clients don't ask to restart it on every attach.
  hl.exec_cmd(o.launch("setsid herdr server"))

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
