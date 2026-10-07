-- Spotify runs under XWayland, so it can never bind zwp_idle_inhibit_manager_v1:
-- the CEF build it ships only inhibits idle through the Wayland ozone backend.
-- Nothing reports playback to the compositor, so the screensaver covers
-- fullscreen video podcasts mid-playback. Inhibit while fullscreen, matching the
-- XWayland class and the app id used under the Wayland backend. Scoping this to
-- fullscreen keeps idle running while Spotify is merely open playing music.
-- Hyprland counts a maximized window as fullscreen too, so match real fullscreen.
o.window({ class = "^[sS]potify$", fullscreen_state_internal = 2 }, { idle_inhibit = "fullscreen" })
