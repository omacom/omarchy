local paths = require("default.hypr.paths")
local require_optional = require("default.hypr.require_optional")

-- GUM environment variables for styling purposes.
require_optional.module("omarchy.current.theme.gum_env")

-- Cursor size.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland.
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc).
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Use XCompose file.
hl.env("XCOMPOSEFILE", paths.home .. "/.XCompose")

-- hyprctl setenv doesn't reach keybind dispatcher env; use hl.env.
hl.env("OMARCHY_PATH", paths.omarchy_path)

local bin_dir = paths.omarchy_path .. "/bin"
local kept = {}
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= bin_dir then table.insert(kept, entry) end
end
table.insert(kept, 1, bin_dir)
hl.env("PATH", table.concat(kept, ":"))

-- Hardware-specific environment.
require("default.hypr.nvidia")

-- Detect virtual machine and enable software rendering if needed.
-- This allows Omarchy to run in QEMU/KVM without GPU passthrough.
local function detect_vm()
  -- Check systemd-detect-virt (most reliable)
  local handle = io.popen("systemd-detect-virt 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result and (result:match("qemu") or result:match("kvm") or result:match("vm")) then
      return true
    end
  end
  -- Fallback: check /sys/class/dmi/id/product_name
  local f = io.open("/sys/class/dmi/id/product_name", "r")
  if f then
    local product = f:read("*a")
    f:close()
    if product and (product:match("QEMU") or product:match("Standard PC")) then
      return true
    end
  end
  return false
end

if detect_vm() then
  -- Force software rendering for Mesa (OpenGL)
  hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
  hl.env("GALLIUM_DRIVER", "llvmpipe")
  -- Force software rendering for Qt6/Quickshell
  hl.env("QSG_RHI_BACKEND", "software")
  hl.env("QT_QUICK_BACKEND", "software")
  -- Force software rendering for GTK4
  hl.env("GSK_RENDERER", "software")
end

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  ecosystem = {
    no_update_news = true,
  },
})
