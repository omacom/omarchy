-- Scale, resolution and arrangement are set from the monitor panel in the top
-- bar and saved for each monitor in ~/.local/state/omarchy/monitors/settings.
-- This file is for what the panel doesn't cover, and it loads after Omarchy's
-- defaults. A choice made in the panel still wins for that monitor.
--
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Scale every monitor without a choice of its own (Omarchy picks "auto").
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })

-- GTK and XWayland scale, a whole number (Omarchy sets 2 until a scale is
-- chosen in the panel).
-- hl.env("GDK_SCALE", "1")

-- Turn a monitor on its side (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Run a mode the panel doesn't offer, such as a high refresh rate.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "auto", scale = 1 })

-- Keep a monitor off, such as the phantom output an Apple 6K XDR can show.
-- hl.monitor({ output = "DP-3", disabled = true })

-- Match a monitor by its description rather than its connector.
-- hl.monitor({ output = "desc:Dell Inc. DELL U2723QE", mode = "preferred", position = "auto", scale = 1.5 })

-- 10-bit color.
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, bitdepth = 10 })

-- Variable refresh rate (0 = off, 1 = always, 2 = fullscreen only).
-- hl.config({ misc = { vrr = 0 } })
