local paths = require("default.hypr.paths")

local intel_gles2 = paths.omarchy_path .. "/bin/omarchy-hw-intel-gles2"

-- Mesa's crocus driver only exposes GLES 2.0 on Intel Gen4/Gen5 iGPUs, but
-- Hyprland requires GLES 3.0 and aborts at renderer creation otherwise (black
-- screen after login). Overriding the advertised version lets the context be
-- created; it advertises a version the hardware doesn't fully implement, so
-- this is limited to the Gen4/Gen5 GPUs the detector below identifies.
--
-- The detector reads cached sysfs IDs rather than shelling out to lspci; see
-- bin/omarchy-hw-intel-gles2.
if o.shell_succeeds(o.shell_quote(intel_gles2)) then
  hl.env("MESA_GLES_VERSION_OVERRIDE", "3.0")
  hl.env("MESA_GLSL_VERSION_OVERRIDE", "300")
end
