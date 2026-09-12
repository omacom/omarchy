local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local hybrid_gpu = paths.omarchy_path .. "/bin/omarchy-hw-hybrid-gpu"

-- These detectors read cached sysfs IDs rather than shelling out to lspci. lspci reads
-- PCI config space, which resumes a runtime-suspended GPU, and on a hybrid laptop that
-- wake alone outlasts Hyprland's 1.5s config reload budget.
if o.shell_succeeds(o.shell_quote(nvidia)) then
  -- On a hybrid laptop the panel hangs off the iGPU and the dGPU is meant to stay
  -- suspended until something asks for it. Pointing GLX at the NVIDIA vendor library
  -- makes EVERY OpenGL client render on the dGPU, so it wakes at login and never gets
  -- to sleep again -- a constant battery cost for no visible gain, since the frames
  -- still have to be copied back to the iGPU to reach the display.
  --
  -- Leave the Mesa/iGPU default in place there and let the discrete card be opted into
  -- per application (prime-run, or __NV_PRIME_RENDER_OFFLOAD=1). Desktops where NVIDIA
  -- actually drives the display are unaffected: they are not hybrid, so this is skipped.
  if not o.shell_succeeds(o.shell_quote(hybrid_gpu)) then
    if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
      hl.env("NVD_BACKEND", "direct")
      hl.env("LIBVA_DRIVER_NAME", "nvidia")
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
      hl.env("NVD_BACKEND", "egl")
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
  end
end
