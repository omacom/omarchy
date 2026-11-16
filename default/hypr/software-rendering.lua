-- A session that renders on the CPU (llvmpipe or softpipe) gets the same
-- lighter look as Appearance > Animations Off: no animations, blur or shadows.
-- omarchy-hyprland-software-rendering marks the session once Hyprland is up
-- and has picked its renderer, then reloads. This loads after the theme and
-- before ~/.config/hypr, so the user's own looknfeel.lua still has the last
-- word. Turning animations on in Appearance (omarchy-toggle-animations) lifts
-- all of it, and keeps doing so in later sessions. The Glassy toggles load after
-- that and check o.software_rendering_defaults() themselves
-- (default/hypr/glass.lua).

if o.software_rendering_defaults() then
  require("default.hypr.toggles.no-animations")
end
