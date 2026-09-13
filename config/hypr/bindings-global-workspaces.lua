-- ── Global workspace switching ────────────────────────────────────────────
-- Installed by omarchy-global-workspaces/install.sh into ~/.config/hypr/bindings.lua
--
-- SUPER+1..10 — switch to AW slot N.
-- omarchy-switch-to-aw checks the toggle at runtime:
--   global mode → omarchy-hyprland-workspace-global-switch N (all monitors)
--   local mode  → hyprctl dispatch workspace N (current monitor only)
for slot = 1, 10 do
  local key = "code:" .. tostring(slot + 9)
  hl.unbind("SUPER + " .. key)
  o.bind("SUPER + " .. key,
    "Switch to Workspace " .. slot,
    "omarchy-switch-to-aw " .. tostring(slot))
end

-- SUPER+SHIFT+1..10 — move focused window to AW slot N, silently.
-- omarchy-move-window-to-aw checks the toggle at runtime:
--   global mode → omarchy-hyprland-workspace-global-move-window N (same monitor, slot N)
--   local mode  → hyprctl movetoworkspacesilent N
for slot = 1, 10 do
  local key = "code:" .. tostring(slot + 9)
  hl.unbind("SUPER + SHIFT + " .. key)
  o.bind("SUPER + SHIFT + " .. key,
    "Move window to Workspace " .. slot,
    "omarchy-move-window-to-aw " .. tostring(slot))
end
-- ── End global workspace switching ───────────────────────────────────────
