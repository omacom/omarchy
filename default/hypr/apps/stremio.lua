-- Stremio's player fullscreen is still a normal window, and its
-- org.freedesktop.ScreenSaver inhibit has nobody listening, so the
-- screensaver starts over a stream. Hold idle off while this window
-- is focused.
o.window("com.stremio.Stremio", { idle_inhibit = "focus" })
