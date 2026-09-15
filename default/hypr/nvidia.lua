local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local nvidia_drm_card = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-drm-card"

-- These detectors read cached sysfs IDs rather than shelling out to lspci.
-- lspci reads PCI config space, which resumes a runtime-suspended GPU, and on a
-- hybrid laptop that wake alone outlasts Hyprland's 1.5s config reload budget.
if o.shell_succeeds(o.shell_quote(nvidia)) then
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  end

  -- With NVIDIA as the only GPU (a desktop, or a hybrid laptop whose firmware
  -- MUX is set to discrete), nothing evicts the boot framebuffer and Aquamarine
  -- picks it up as a second GPU with a phantom output, then aborts into safe
  -- mode. Pin the NVIDIA card in that case; the detector prints nothing
  -- everywhere else, leaving autodetection alone.
  local pipe = io.popen(o.shell_quote(nvidia_drm_card) .. " 2>/dev/null")
  if pipe then
    local card = (pipe:read("*a") or ""):match("^(/dev/dri/card%d+)")
    pipe:close()
    if card then
      hl.env("AQ_DRM_DEVICES", card)
    end
  end
end
