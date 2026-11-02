local paths = require("default.hypr.paths")

local vm = paths.omarchy_path .. "/bin/omarchy-hw-vm"

-- Hyprland 0.57 turned skip_non_kms_dmabuf_formats on by default
-- (hyprwm/Hyprland#15803). A virtio-gpu primary plane only scans out XR24, so
-- the dmabuf feedback table shrinks to that one format, Mesa offers clients no
-- alpha EGL configs, and the shell's transparent full-screen layers (bar,
-- background) come out opaque black over every tiled window.
if o.shell_succeeds(o.shell_quote(vm)) then
  hl.config({ quirks = { skip_non_kms_dmabuf_formats = false } })
end
