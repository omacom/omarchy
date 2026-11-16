-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false
--
-- Disable Omarchy's default touchpad gestures. Add your own in hypr/input.lua.
-- omarchy_default_gestures = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
-- A broken override must not abort the rest of the config load: report it and
-- carry on with the defaults and the remaining files, so the compositor stays
-- responsive. A missing override is simply skipped.
local function load_override(module)
  if not package.searchpath(module, package.path) then
    return
  end

  local ok, err = pcall(require, module)
  if not ok then
    print("Could not load " .. module .. ": " .. tostring(err))
  end
end

load_override("hypr.monitors")
load_override("hypr.input")
load_override("hypr.bindings")
load_override("hypr.looknfeel")
load_override("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
