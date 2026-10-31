-- Let Hyprland upscale X11 (XWayland) apps to match the monitor scale.
--
-- By default Omarchy sets xwayland:force_zero_scaling, which hands X11 clients
-- an unscaled surface. Toolkit-aware apps (GTK/Qt/Electron) then scale
-- themselves via GDK_SCALE/QT_* and stay crisp. Apps that ignore those hints
-- render at 1x instead, so on a 2x monitor their text and controls come out
-- half size (RealVNC Viewer, older Java/Motif/Tk apps, some installers).
--
-- Turning this flag on drops force_zero_scaling so the compositor upscales
-- those windows to the monitor scale. It applies to every X11 window: apps
-- that were already scaling themselves look softer, and GTK apps that honor
-- GDK_SCALE get scaled twice and come out oversized.
hl.config({
  xwayland = {
    force_zero_scaling = false,
  },
})
