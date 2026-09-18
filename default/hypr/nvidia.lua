local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local nvidia_drives_display = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-drives-display"

-- These detectors read cached sysfs / DRM state rather than shelling out to
-- lspci. lspci reads PCI config space, which resumes a runtime-suspended GPU,
-- and on a hybrid laptop that wake alone outlasts Hyprland's 1.5s config
-- reload budget.
--
-- Presence alone is not enough for session-wide VA/GL vendor env: on hybrid
-- laptops the dGPU may be present while the panel hangs off the iGPU. Forcing
-- LIBVA_DRIVER_NAME=nvidia then stalls browser video decode (issue #10410).
-- Only set those vars when an NVIDIA card has a connected connector.
if o.shell_succeeds(o.shell_quote(nvidia)) and o.shell_succeeds(o.shell_quote(nvidia_drives_display)) then
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  end
end
