-- VLC does not inhibit idle under Wayland, so the Omarchy screensaver can
-- fire mid-movie. Inhibit idle while VLC has focus.
o.window("vlc", { idle_inhibit = "focus" })