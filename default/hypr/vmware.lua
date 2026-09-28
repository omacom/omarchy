local paths = require("default.hypr.paths")

local vmware = paths.omarchy_path .. "/bin/omarchy-hw-vmware"

-- vmwgfx imports client dmabufs as TTM surface handles that Hyprland cannot
-- close: drmCloseBufferHandle() fails with EINVAL, Hyprland rejects the
-- buffer, and every GPU-rendering client dies on its first frame with
-- "invalid arguments for wl_surface.attach" (hyprwm/aquamarine#360). On
-- llvmpipe clients use wl_shm instead and work.
--
-- The variable is set from the start handler, not at parse time. A top-level
-- hl.env() reaches aquamarine before it creates the DRM renderer and puts
-- Hyprland itself on software GL ("CDRMRenderer(drm): Can't create renderer,
-- no matching devices found"). At runtime hl.env() is inherited by every
-- exec that follows, which is why omarchy.lua requires this module before
-- autostart: handlers fire in registration order, and autostart's handler
-- imports the environment into systemd and launches the shell.
--
-- The detector forks once here; the handler only sets the variable.
if o.shell_succeeds(o.shell_quote(vmware)) then
  hl.on("hyprland.start", function()
    hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
  end)
end
