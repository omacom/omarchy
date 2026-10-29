-- A session that renders on the CPU (llvmpipe or softpipe) gets the same
-- lighter look as Appearance > Animations Off: no animations, blur or shadows.
-- omarchy-hyprland-software-rendering marks the session once Hyprland is up
-- and has picked its renderer, then reloads. This loads after the theme and
-- before ~/.config/hypr, so the user's own looknfeel.lua still has the last
-- word. The Glassy toggles load after that and check o.renders_on_cpu()
-- themselves (default/hypr/glass.lua).

if o.renders_on_cpu() then
  require("default.hypr.toggles.no-animations")
end
