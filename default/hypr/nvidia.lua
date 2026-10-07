local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_display = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-display"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"

-- These detectors read cached sysfs IDs rather than shelling out to lspci.
-- lspci reads PCI config space, which resumes a runtime-suspended GPU, and on a
-- hybrid laptop that wake alone outlasts Hyprland's 1.5s config reload budget.
if o.shell_succeeds(o.shell_quote(nvidia)) then
  -- On hybrid laptops the display is wired to the iGPU, so forcing NVIDIA's
  -- VA-API/GLX drivers globally breaks Chromium-based browsers (black video).
  -- Only apply those when NVIDIA actually drives the display.
  local nvidia_is_display = o.shell_succeeds(o.shell_quote(nvidia_display))
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    if nvidia_is_display then
      hl.env("LIBVA_DRIVER_NAME", "nvidia")
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    if nvidia_is_display then
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
  end
end
