-- Minimal Hyprland config for the SDDM Wayland greeter.
-- SDDM starts the greeter itself after the compositor is ready.

-- Same pin as default/hypr/nvidia.lua: with NVIDIA as the only GPU the boot
-- framebuffer stays registered, and an unpinned greeter shows a phantom output
-- and crashes on exit. The greeter has no Omarchy helpers, so read the
-- detector's output directly.
do
  local omarchy_path = os.getenv("OMARCHY_PATH")
  if omarchy_path == nil or omarchy_path == "" then
    omarchy_path = "/usr/share/omarchy"
  end

  local detector = omarchy_path .. "/bin/omarchy-hw-nvidia-drm-card"
  local pipe = io.popen("'" .. detector:gsub("'", "'\\''") .. "' 2>/dev/null")
  if pipe then
    local card = (pipe:read("*a") or ""):match("^(/dev/dri/card%d+)")
    pipe:close()
    -- An AQ_DRM_DEVICES the user set themselves wins.
    if card and (os.getenv("AQ_DRM_DEVICES") or "") == "" then
      hl.env("AQ_DRM_DEVICES", card)
    end
  end
end
hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },
})
