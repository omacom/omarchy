local paths = require("default.hypr.paths")

local intel_panel = paths.omarchy_path .. "/bin/omarchy-hw-apple-intel-panel"

-- On dual-GPU Intel Macs whose firmware handed the panel to the Intel iGPU,
-- Hyprland would otherwise pick the discrete card first and render everything
-- there. nouveau cannot reclock Kepler, so that desktop crawls at boot clocks.
-- /dev/dri/omarchy-apple-igpu is a udev symlink to the i915 card, written by
-- install/hardware/apple/fix-dual-gpu-intel-panel.sh: card numbers swap between
-- boots, and AQ_DRM_DEVICES splits on ':', so a by-path name can't be used.
if o.shell_succeeds(o.shell_quote(intel_panel)) then
  hl.env("AQ_DRM_DEVICES", "/dev/dri/omarchy-apple-igpu")
end
