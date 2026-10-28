echo "Show X11 apps at the size of Wayland ones on every monitor"

# X11 apps draw at the GDK scale. A Hyprland with xwayland:scale lays X11 out
# at that scale and scales each X11 window to its size itself, so monitors.lua
# now hands it the GDK scale. Only a monitors.lua with the template's GDK_SCALE
# line gets it; one that sets GDK_SCALE some other way, or has its own xwayland
# settings, is left alone.
monitors="$HOME/.config/hypr/monitors.lua"

[[ -f $monitors ]] || exit 0
grep -qxF 'hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))' "$monitors" || exit 0
grep -q 'xwayland' "$monitors" && exit 0

# Appending writes through a symlink into a dotfiles repo rather than replacing it.
cat >>"$monitors" <<'LUA'

-- X11 apps draw at the GDK scale, so Hyprland lays X11 out at that scale too
-- and shows each X11 window at the size it would have on Wayland, on every
-- monitor. A Hyprland without xwayland:scale skips this and leaves X11
-- windows unscaled, as before.
if hl.get_config("xwayland.scale") ~= nil then
  hl.config({ xwayland = { scale = omarchy_gdk_scale } })
end
LUA
