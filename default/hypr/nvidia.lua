local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local hybrid = paths.omarchy_path .. "/bin/omarchy-hw-hybrid-gpu"

-- These detectors read cached sysfs IDs rather than shelling out to lspci.
-- lspci reads PCI config space, which resumes a runtime-suspended GPU, and on a
-- hybrid laptop that wake alone outlasts Hyprland's 1.5s config reload budget.
--
-- On hybrid systems (e.g. laptops with integrated AMD/Intel + discrete NVIDIA),
-- do not export global NVIDIA driver variables for the entire desktop session.
-- Doing so forces all desktop apps, Electron apps, and web browsers onto the discrete
-- GPU, preventing runtime D3 (D3cold) power management and severely degrading battery life.
-- Discrete-only desktop systems still receive the optimal NVIDIA environment.
if o.shell_succeeds(o.shell_quote(nvidia)) and not o.shell_succeeds(o.shell_quote(hybrid)) then
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  end
end

