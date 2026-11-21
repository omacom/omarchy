local paths = require("default.hypr.paths")

-- Keep Hyprland off an Apple Silicon Touch Bar panel and off nothing else.
-- tiny-dfr draws that adp card; aquamarine holding it open leaves the bar
-- blank. The helper's list is every other card, so the display controller,
-- the GPU, and a dock or adapter stay available. No Touch Bar card means no
-- AQ_DRM_DEVICES, which leaves every other machine on Hyprland's own scan.
local function touchbar_drm_devices()
  local command = o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-apple-touchbar-drm")
  local pipe = io.popen(command .. " 2>/dev/null")
  if not pipe then
    return ""
  end

  local devices = pipe:read("*l") or ""
  pipe:close()
  return devices
end

if (os.getenv("AQ_DRM_DEVICES") or "") == "" then
  local devices = touchbar_drm_devices()
  if devices ~= "" then
    hl.env("AQ_DRM_DEVICES", devices)
  end
end
