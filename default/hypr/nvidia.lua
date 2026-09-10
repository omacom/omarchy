local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local nvidia_only = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-only"

-- These detectors read cached sysfs IDs rather than shelling out to lspci.
-- lspci reads PCI config space, which resumes a runtime-suspended GPU, and on a
-- hybrid laptop that wake alone outlasts Hyprland's 1.5s config reload budget.
if o.shell_succeeds(o.shell_quote(nvidia)) then
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

    -- On a hybrid laptop the compositor and its apps render on the integrated
    -- GPU, so forcing the NVIDIA VA-API driver hands them a decoder for a device
    -- they aren't drawing with: Chromium's GPU process crashes and video
    -- flickers. Leave it unset there and libva picks the driver from the
    -- render node an app actually opens.
    if o.shell_succeeds(o.shell_quote(nvidia_only)) then
      hl.env("LIBVA_DRIVER_NAME", "nvidia")
    end
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  end
end
