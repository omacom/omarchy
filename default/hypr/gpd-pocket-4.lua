-- Fixed orientation for the portrait-mounted panel, independent of sensors.
-- User monitor/input overrides load after these defaults; reload reapplies it.
local paths = require("default.hypr.paths")

if o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-gpd-pocket-4")) then
  hl.monitor({ output = "eDP-1", transform = 3 })
  -- Hyprland replaces the udev matrix, so touch needs an explicit transform.
  hl.device({ name = "nvtk0603:00-0603:f001", transform = 3 })
end
