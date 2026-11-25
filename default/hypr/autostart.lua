hl.on("hyprland.start", function()
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
  hl.exec_cmd("sleep 2 && " .. o.launch("udiskie --automount --no-notify --no-tray"))

  -- Start the herdr server inside the graphical session so its panes inherit
  -- WAYLAND_DISPLAY. Otherwise the first SSH login from a remote herdr starts
  -- it with a tty environment, and agents in its panes can't read the clipboard.
  -- Run as a transient user service in app.slice instead of app-graphical.slice
  -- so systemd gives it its own session (matching setsid), stops it with
  -- PartOf=graphical-session.target in parallel with Hyprland rather than
  -- blocking compositor teardown, and cleans up remaining pane processes via
  -- KillMode=mixed as soon as herdr finishes saving state and exits.
  hl.exec_cmd(
    "sleep 2 && systemd-run --user --quiet --collect --unit=omarchy-herdr-server --slice=app.slice "
      .. "--property=PartOf=graphical-session.target --property=KillMode=mixed "
      .. "--description='Herdr terminal multiplexer server' herdr server"
  )

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
