-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Materialize all global workspace slots at config load time (if global mode is active).
-- Hyprland 0.56.x doesn't support synchronous workspace rule materialization, so we
-- force-create them by dispatching focus to each slot sequentially. This must happen
-- early so subsequent switches have workspaces to target.
if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") and _G.omarchy_monitor_bases then
  -- Create workspaces 1-30 by focusing them (Hyprland materializes on focus)
  for ws = 1, 30 do
    local ok = pcall(function()
      hl.dispatch(hl.dsp.focus({ workspace = tostring(ws) }))
    end)
    -- No yield/sleep here — must complete in one config pass
  end
  -- Return focus to ws 1
  pcall(function()
    hl.dispatch(hl.dsp.focus({ workspace = "1" }))
  end)
  
  -- Refresh bars after materialization (backgrounded)
  os.execute("sleep 0.1; qs ipc call omarchy.workspaces refresh &>/dev/null &")
end
