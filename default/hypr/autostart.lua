hl.on("hyprland.start", function()
  -- Keep the pointer off the black startup screen until the shell reveals it.
  omarchy_startup_cursor_pending = true
  hl.config({ cursor = { invisible = true } })
  hl.timer(function()
    if omarchy_startup_cursor_pending then
      omarchy_startup_cursor_pending = false
      hl.config({ cursor = { invisible = false } })
    end
  end, { timeout = 15000, type = "oneshot" })

  -- Slow app launch fix -- set systemd vars before starting session services.
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  hl.exec_cmd("omarchy-launch-shell")
  hl.exec_cmd("omarchy-provision-first-run")
  hl.exec_cmd("omarchy-powerprofiles-init")
  hl.exec_cmd(o.launch("omarchy-hyprland-monitor-watch"))
  hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
