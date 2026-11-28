-- App-specific tweaks (listed directly so Hyprland reloads avoid shelling out).
local modules = {
  "1password",
  "battlenet",
  "bitwarden",
  "browser",
  "captive-portal",
  "davinci-resolve",
  "game-vibes",
  "geforce",
  "hermes",
  "inkscape",
  "jetbrains",
  "localsend",
  "moonlight",
  "omarchy-shell",
  "pip",
  "retroarch",
  "screenshot-selection",
  "steam",
  "system",
  "telegram",
  "terminals",
  "webcam-overlay",
}

for _, name in ipairs(modules) do
  require("default.hypr.apps." .. name)
end
